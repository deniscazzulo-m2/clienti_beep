#!/usr/bin/env python3
import pandas as pd
import pyodbc
import re
import argparse
from pathlib import Path

# =======================
# CONFIG — MODIFICA QUI
# =======================
CONFIG = {
    "excel_path": "output_join2.xlsx",   # verranno letti i primi DUE fogli
    "sqlserver": {
        "conn_str": "DRIVER={ODBC Driver 17 for SQL Server};SERVER=PC-TEC-01\\TEST;DATABASE=bpEUROLEGNO;Trusted_Connection=yes;"
    },
    # Se True: se la tabella esiste la TRUNCATE; se False: prova a inserire in append
    "truncate_if_exists": True,
    # Se True: se la tabella NON esiste la crea
    "create_if_missing": True,
    # Staging sempre NVARCHAR (robusto, evita clash tipi)
    "staging_all_varchar": True,
    # Lunghezza di default per colonne testo
    "default_varchar_len": 4000,
    # Log errori
    "log_path": "./import_errori.log",
    # Nomi delle tabelle di destinazione
    "table_sheet1": "dgl_dianflex_match",
    "table_sheet2": "dgl_dianflex_nomatch",
}

# =============== FUNZIONI DI SUPPORTO ===============

def sanitize_sql_name(name: str) -> str:
    if not name or str(name).strip() == "":
        return ""
    s = str(name).strip()
    s = re.sub(r"[^\w]+", "_", s, flags=re.UNICODE)
    s = re.sub(r"_+", "_", s).strip("_")
    if s == "":
        return ""
    if re.match(r"^\d", s):
        s = "c_" + s
    return s

def make_unique(names):
    seen = {}
    out = []
    for n in names:
        base = n or "col"
        key = base.lower()
        if key not in seen:
            seen[key] = 1
            out.append(base)
        else:
            seen[key] += 1
            out.append(f"{base}_{seen[key]}")
    return out

def ensure_table(conn, table_name: str, df: pd.DataFrame, cfg):
    """
    Crea (o adatta) la tabella staging.
    Se staging_all_varchar=True: tutte le colonne NVARCHAR(cfg['default_varchar_len']).
    """
    cursor = conn.cursor()
    cursor.execute("""
        SELECT COUNT(*) 
        FROM sys.tables t
        WHERE t.[name] = ? AND SCHEMA_NAME(t.[schema_id]) = 'dbo'
    """, table_name)
    exists = cursor.fetchone()[0] == 1

    raw_headers = [str(c) if c is not None else "" for c in df.columns]
    sanitized = [sanitize_sql_name(h) for h in raw_headers]
    sanitized = [s if s else "col" for s in sanitized]
    sanitized = make_unique(sanitized)
    col_map = dict(zip(df.columns, sanitized))

    if not exists:
        if not cfg["create_if_missing"]:
            raise RuntimeError(f"La tabella dbo.{table_name} non esiste e create_if_missing=False.")
        # Staging: TUTTO NVARCHAR per evitare qualsiasi clash
        cols_ddl = [f"[{col_map[c]}] NVARCHAR({cfg['default_varchar_len']}) NULL" for c in df.columns]
        ddl = f"""
        CREATE TABLE [dbo].[{table_name}] (
            [id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
            {", ".join(cols_ddl)}
        );
        """
        cursor.execute(ddl)
    else:
        if cfg["truncate_if_exists"]:
            cursor.execute(f"TRUNCATE TABLE [dbo].[{table_name}];")
        # aggiungo eventuali colonne mancanti come NVARCHAR
        cursor.execute(f"""
            SELECT c.[name]
            FROM sys.columns c
            INNER JOIN sys.tables t ON t.[object_id]=c.[object_id]
            WHERE t.[name]=? AND SCHEMA_NAME(t.[schema_id])='dbo' AND c.[name] <> 'id'
            ORDER BY c.[column_id]
        """, table_name)
        existing_cols = {r[0].lower() for r in cursor.fetchall()}
        for orig, sani in col_map.items():
            if sani.lower() not in existing_cols:
                cursor.execute(
                    f"ALTER TABLE [dbo].[{table_name}] ADD [{sani}] NVARCHAR({cfg['default_varchar_len']}) NULL;"
                )
    return col_map

def insert_dataframe(conn, table_name: str, df: pd.DataFrame, col_map: dict, errors: list):
    cursor = conn.cursor()
    cursor.fast_executemany = True

    target_cols = [col_map[c] for c in df.columns if c in col_map]
    cursor.execute(f"""
        SELECT c.[name]
        FROM sys.columns c
        INNER JOIN sys.tables t ON t.[object_id]=c.[object_id]
        WHERE t.[name]=? AND SCHEMA_NAME(t.[schema_id])='dbo' AND c.[name] <> 'id'
        ORDER BY c.[column_id]
    """, table_name)
    actual_cols = [r[0] for r in cursor.fetchall()]
    target_cols = [c for c in target_cols if c in actual_cols]

    if not target_cols:
        raise RuntimeError(f"Nessuna colonna da inserire per dbo.{table_name} (controlla mapping/headers).")

    placeholders = ",".join(["?"] * len(target_cols))
    cols_sql = ",".join(f"[{c}]" for c in target_cols)
    insert_sql = f"INSERT INTO [dbo].[{table_name}] ({cols_sql}) VALUES ({placeholders})"

    def _clean_cell(x):
        # Stringhizzo tutto: staging è NVARCHAR => niente clash tipi
        if pd.isna(x):
            return None
        return str(x).strip()

    inv_map = {v: k for k, v in col_map.items()}
    df_ins = pd.DataFrame({tc: df[inv_map[tc]] if inv_map[tc] in df.columns else None for tc in target_cols})
    rows = [tuple(_clean_cell(v) for v in row) for _, row in df_ins.iterrows()]

    try:
        cursor.executemany(insert_sql, rows)
        return len(rows)
    except Exception:
        # niente rollback qui: decide il main a fine transazione
        inserted = 0
        for i, vals in enumerate(rows):
            try:
                cursor.execute(insert_sql, vals)
                inserted += 1
            except Exception as e2:
                errors.append(f"{table_name} row={i}: INSERT_ERROR {e2}")
        return inserted

# =============== MAIN ===============

def main():
    parser = argparse.ArgumentParser(description="Import Excel -> dbo.dgl/dbo.dgl2 (staging NVARCHAR) con transazione pilotabile.")
    parser.add_argument("--mode", choices=["ask", "commit", "rollback"], default="ask",
                        help="ask=chiedi conferma a video; commit=conferma automaticamente; rollback=annulla automaticamente")
    args = parser.parse_args()

    excel_path = Path(CONFIG["excel_path"])
    if not excel_path.exists():
        print(f"ERRORE: Excel non trovato: {excel_path}")
        return

    xls = pd.ExcelFile(excel_path)
    sheet_names = xls.sheet_names
    if len(sheet_names) < 2:
        print(f"ERRORE: servono almeno 2 fogli nel file. Trovati: {sheet_names}")
        return

    sheet1 = sheet_names[0]
    sheet2 = sheet_names[1]

    # Leggo senza inferenze avanzate (gli avvisi su infer_datetime_format spariscono)
    df1 = pd.read_excel(excel_path, sheet_name=sheet1, dtype=str)
    df2 = pd.read_excel(excel_path, sheet_name=sheet2, dtype=str)
    df1 = df1.dropna(axis=1, how="all").map(lambda x: x.strip() if isinstance(x, str) else x)
    df2 = df2.dropna(axis=1, how="all").map(lambda x: x.strip() if isinstance(x, str) else x)

    errors = []
    ok_counts = {}

    # autocommit=False per tenere tutto in 1 transazione
    conn = pyodbc.connect(CONFIG["sqlserver"]["conn_str"], autocommit=False)
    try:
        print(f">>> TRANSAZIONE APERTA (mode={args.mode}). Modifiche visibili solo in questa sessione (a meno di NOLOCK).")

        table1 = CONFIG["table_sheet1"]
        col_map1 = ensure_table(conn, table1, df1, CONFIG)
        inserted1 = insert_dataframe(conn, table1, df1, col_map1, errors)
        ok_counts[table1] = inserted1

        table2 = CONFIG["table_sheet2"]
        col_map2 = ensure_table(conn, table2, df2, CONFIG)
        inserted2 = insert_dataframe(conn, table2, df2, col_map2, errors)
        ok_counts[table2] = inserted2

        # Preview conteggi
        cur = conn.cursor()
        for t in (table1, table2):
            cur.execute(f"SELECT COUNT(*) FROM dbo.{t};")
            c = cur.fetchone()[0]
            print(f"[PREVIEW TX] dbo.{t}: {c} righe (non ancora confermate).")

        # Decisione finale
        if args.mode == "commit":
            conn.commit()
            print(">>> COMMIT eseguito.")
        elif args.mode == "rollback":
            conn.rollback()
            print(">>> ROLLBACK eseguito.")
        else:
            ans = input("Confermi COMMIT? [y/N]: ").strip().lower()
            if ans in ("y", "yes", "s", "si", "sì"):
                conn.commit()
                print(">>> COMMIT eseguito.")
            else:
                conn.rollback()
                print(">>> ROLLBACK eseguito.")

    except Exception as e:
        conn.rollback()
        print(f"ERRORE (transazione annullata): {e}")
    finally:
        conn.close()

    # Log errori
    if errors:
        with open(CONFIG["log_path"], "w", encoding="utf-8") as f:
            f.write("\n".join(errors))
        print(f"[ATTENZIONE] Alcune righe hanno dato errore (vedi {CONFIG['log_path']}).")
    for t, n in ok_counts.items():
        print(f"Tabella {t}: preparate {n} righe per l'inserimento.")

if __name__ == "__main__":
    main()
