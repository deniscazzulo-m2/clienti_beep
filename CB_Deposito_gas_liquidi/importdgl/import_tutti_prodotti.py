#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Importa TUTTE le colonne di un Excel in una tabella SQL Server (staging NVARCHAR).
- Crea la tabella se non esiste (tutte le colonne NVARCHAR).
- Se esiste: TRUNCATE opzionale e ADD COLUMN per le colonne mancanti.
- Unica transazione pilotabile: --mode ask|commit|rollback

Uso tipico:
  python import_tutti_prodotti.py --excel "ELENCO ARTICOLI MODIFICATO LUGLIO 25.xlsx" --table "tutti_i_prodotti_2023" --mode ask --truncate

Requisiti: pandas, pyodbc, openpyxl (per .xlsx)
  pip install pandas pyodbc openpyxl
"""
import argparse
import re
from pathlib import Path

import pandas as pd
import pyodbc


DEFAULT_CONN_STR = (
    "DRIVER={ODBC Driver 17 for SQL Server};"
    "SERVER=PC-TEC-01\\TEST;"
    "DATABASE=bpEUROLEGNO;"
    "Trusted_Connection=yes;"
)


def sanitize_sql_name(name: str) -> str:
    """Rende SQL-safe un identificatore: sostituisce non-alfa con _, evita iniziare con cifra."""
    if name is None:
        return "col"
    s = str(name).strip()
    if s == "":
        return "col"
    s = re.sub(r"[^\w]+", "_", s, flags=re.UNICODE)
    s = re.sub(r"_+", "_", s).strip("_")
    if s == "":
        s = "col"
    if re.match(r"^\d", s):
        s = "c_" + s
    # limita a 128 char (limite nomi SQL Server)
    return s[:128]


def make_unique(names):
    """Rende unici i nomi (case-insensitive) aggiungendo suffissi _2, _3, ..."""
    seen = {}
    out = []
    for n in names:
        key = n.lower()
        count = seen.get(key, 0) + 1
        seen[key] = count
        out.append(n if count == 1 else f"{n}_{count}")
    return out


def ensure_table(conn, table_name: str, excel_df: pd.DataFrame, varchar_len: int, truncate: bool):
    """
    Crea/adatta dbo.table_name per contenere tutte le colonne di excel_df come NVARCHAR(varchar_len).
    Ritorna mapping: {excel_header -> sql_col_name}.
    """
    cur = conn.cursor()

    # Normalizza nome tabella (consiglio: no spazi). Se contiene uno schema, lo rispetto.
    if "." in table_name:
        schema, name = table_name.split(".", 1)
        schema = schema.strip("[]")
        name = name.strip("[]")
    else:
        schema, name = "dbo", table_name.strip("[]")

    # Esistenza tabella
    cur.execute(
        "SELECT COUNT(*) FROM sys.tables t JOIN sys.schemas s ON s.schema_id=t.schema_id "
        "WHERE t.name=? AND s.name=?;",
        (name, schema),
    )
    exists = cur.fetchone()[0] == 1

    # Preparo mapping colonne
    raw_headers = [str(c) if c is not None else "" for c in excel_df.columns]
    sani = [sanitize_sql_name(h) for h in raw_headers]
    sani = [s if s else "col" for s in sani]
    sani = make_unique(sani)
    col_map = dict(zip(excel_df.columns, sani))

    if not exists:
        cols_sql = ", ".join(f"[{col_map[c]}] NVARCHAR({varchar_len}) NULL" for c in excel_df.columns)
        cur.execute(f"EXEC('CREATE TABLE [{schema}].[{name}] ( [id] INT IDENTITY(1,1) PRIMARY KEY, {cols_sql} );')")
    else:
        if truncate:
            cur.execute(f"EXEC('TRUNCATE TABLE [{schema}].[{name}]');")
        # Aggiungi colonne mancanti come NVARCHAR
        cur.execute(
            "SELECT c.name FROM sys.columns c "
            "JOIN sys.tables t ON t.object_id=c.object_id "
            "JOIN sys.schemas s ON s.schema_id=t.schema_id "
            "WHERE t.name=? AND s.name=? AND c.name<>'id' ORDER BY c.column_id;",
            (name, schema),
        )
        existing = {r[0].lower() for r in cur.fetchall()}
        for orig, sani_col in col_map.items():
            if sani_col.lower() not in existing:
                cur.execute(
                    f"EXEC('ALTER TABLE [{schema}].[{name}] ADD [{sani_col}] NVARCHAR({varchar_len}) NULL;')"
                )

    return f"[{schema}].[{name}]", col_map


def insert_rows(conn, fq_table: str, df: pd.DataFrame, col_map: dict, chunk_size: int = 1000):
    """
    Inserisce df nel fq_table usando NVARCHAR e fast_executemany, a chunk per non saturare memoria.
    """
    cur = conn.cursor()
    cur.fast_executemany = True

    # Ordinamento colonne secondo l'Excel (mappate)
    target_cols = [col_map[c] for c in df.columns if c in col_map]
    if not target_cols:
        raise RuntimeError("Nessuna colonna valida per l'inserimento.")

    cols_sql = ", ".join(f"[{c}]" for c in target_cols)
    params_sql = ", ".join(["?"] * len(target_cols))
    insert_sql = f"INSERT INTO {fq_table} ({cols_sql}) VALUES ({params_sql})"

    # Funzione di pulizia: tutto a stringa (o None) perché le colonne sono NVARCHAR
    def clean_cell(x):
        if pd.isna(x):
            return None
        return str(x).strip()

    # Prepara iterator sui chunk
    total = 0
    for start in range(0, len(df), chunk_size):
        chunk = df.iloc[start : start + chunk_size]
        rows = [
            tuple(clean_cell(v) for v in chunk.iloc[i].tolist())
            for i in range(len(chunk))
        ]
        cur.executemany(insert_sql, rows)
        total += len(rows)

    return total


def main():
    ap = argparse.ArgumentParser(description="Importa tutte le colonne dell'Excel in una tabella SQL Server (staging NVARCHAR).")
    ap.add_argument("--excel", required=True, help="Percorso file Excel (.xlsx, .xls).")
    ap.add_argument("--sheet", default=None, help="Nome/n° del foglio (default: primo foglio).")
    ap.add_argument("--table", default="tutti_i_prodotti", help="Nome tabella di destinazione. Puoi includere schema (es. dbo.mia_tabella).")
    ap.add_argument("--conn", default=DEFAULT_CONN_STR, help="Connection string ODBC per SQL Server.")
    ap.add_argument("--varchar-len", type=int, default=4000, help="Lunghezza NVARCHAR per le colonne create (default 4000). Usa  MAX passando 0.")
    ap.add_argument("--truncate", action="store_true", help="Se la tabella esiste, fa TRUNCATE prima di inserire.")
    ap.add_argument("--mode", choices=["ask", "commit", "rollback"], default="ask", help="Conferma finale: ask|commit|rollback.")
    ap.add_argument("--chunk", type=int, default=1000, help="Numero di righe per batch (default 1000).")
    args =  ap.parse_args()

    excel_path = Path(args.excel)
    if not excel_path.exists():
        print(f"ERRORE: file Excel non trovato: {excel_path}")
        return

    # Carico Excel
    try:
        if args.sheet is None:
            df = pd.read_excel(excel_path, dtype=str)  # primo foglio
            sheet_used = "primo"
        else:
            try:
                sheet_name = int(args.sheet)
            except ValueError:
                sheet_name = args.sheet
            df = pd.read_excel(excel_path, sheet_name=sheet_name, dtype=str)
            sheet_used = args.sheet
    except Exception as e:
        print(f"ERRORE lettura Excel: {e}")
        return

    # Drop colonne completamente vuote, strip celle
    df = df.dropna(axis=1, how="all")
    df = df.map(lambda x: x.strip() if isinstance(x, str) else x)

    # Se varchar-len == 0 -> usa MAX
    varchar_len = "MAX" if args.varchar_len == 0 else args.varchar_len

    # Transazione unica
    conn = pyodbc.connect(args.conn, autocommit=False)
    try:
        print(f">>> TRANSAZIONE APERTA (mode={args.mode}). Excel='{excel_path.name}', foglio='{sheet_used}'.")
        fq_table, col_map = ensure_table(conn, args.table, df, varchar_len, args.truncate)
        inserted = insert_rows(conn, fq_table, df, col_map, chunk_size=args.chunk)
        print(f"[PREVIEW TX] {fq_table}: righe pronte all'inserimento: {inserted}. (Non confermate finché non fai COMMIT)")

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


if __name__ == "__main__":
    main()
