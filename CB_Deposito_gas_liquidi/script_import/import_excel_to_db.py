#!/usr/bin/env python3
import pandas as pd
import pyodbc
from pathlib import Path
from datetime import datetime

# =======================
# CONFIG — MODIFICA QUI
# =======================
CONFIG = {
    "excel_path": "DPGarticoli.xls",
    "sheet_name": "Foglio1",  # unico sheet
    "sqlserver": {
        "conn_str": "DRIVER={ODBC Driver 17 for SQL Server};SERVER=PC-TEC-01\\TEST;DATABASE=bpEUROLEGNO;Trusted_Connection=yes;"
    },

    # Per ogni tabella:
    # - "table": nome tabella su SQL Server
    # - "mapping": { "Colonna Excel": "ColonnaDB", ... }  (ordine = ordine nelle VALUES)
    # - "fixed":   { "ColonnaDB": valore_fisso } (opzionale; aggiunti in INSERT)
    "tables": [
        {
            "table": "PrdAnaImp_Pers",
            "mapping": {
                # Esempio: Excel ⇒ DB
                "CODICE ARTICOLO": "prdCod",
                "Descrizione_articolo": "prdDes",
                "Aliquota_IVA": "ivaCod",
                "Unita_misura_1": "prdUm",
                "Codice gruppo merceologico": "GrpCod",
            },
            "fixed": {
                # esempi fissi (se non ti servono, elimina):
                "PrdUso": 10,
                "RecCreate": datetime.now(),
                "RecChange": datetime.now(),
                "RecUserID": 1,
                "RecChangeUserID": 1,
            },
        },
        {
            "table": "MixAnaAliasImp_Pers",
            "mapping": {
                "CODICE ARTICOLO": "ItemID",
                "BARCODE": "AliasID",
            },
            "fixed": {
                "ItemType": 5,
            },
        },
        {
            "table": "PrdPrzImp_Pers",
            "mapping": {
                "CODICE ARTICOLO": "PrdCod",
                "Prezzo DI VENDITA": "PrdPrz",
            },
            "fixed": {
                "LStCod": "BASE",
                "RecCreate": datetime.now(),
                "RecChange": datetime.now(),
                "RecUserID": 1,
                "RecChangeUserID": 1,
            },
        },
    ],

    # Opzionale: normalizza chiavi (sostituisce spazi con underscore) su queste colonne DB
    "normalize_keys_on": ["prdCod", "ItemID", "PrdCod"],

    # Opzionale: taglio a destra (RTRIM + LEFT) su alcune colonne DB: {"tabella.colonna": max_len}
    "maxlen": {
        "PrdAnaImp_Pers.prdDes": 256,
        "MixAnaAliasImp_Pers.AliasID": 32,
    },

    # File log errori
    "log_path": "./import_errori.log",
}

# =============== NON TOCCARE DA QUI IN GIÙ (se non necessario) ===============

def normalize_key(val):
    if val is None:
        return None
    return str(val).strip().replace(" ", "_")

def trim_right(val, max_len):
    if val is None:
        return None
    s = str(val).rstrip()
    return s[:max_len] if max_len and len(s) > max_len else s

def main():
    excel_path = Path(CONFIG["excel_path"])
    if not excel_path.exists():
        print(f"ERRORE: Excel non trovato: {excel_path}")
        return

    df = pd.read_excel(excel_path, sheet_name=CONFIG["sheet_name"], dtype=str)
    df = df.map(lambda x: x.strip() if isinstance(x, str) else x)
    df = df.where(pd.notnull(df), None)

    errors = []
    conn = pyodbc.connect(CONFIG["sqlserver"]["conn_str"])
    cursor = conn.cursor()
    # velocizza inserimenti
    cursor.fast_executemany = True

    ok_counts = {}

    try:
        for t in CONFIG["tables"]:
            table = t["table"]
            mapping = t["mapping"]
            fixed = t.get("fixed", {})
            ok_counts.setdefault(table, 0)

            excel_cols = list(mapping.keys())
            db_cols_map = mapping  # Excel -> DB
            db_cols = list(db_cols_map.values()) + list(fixed.keys())

            # se la colonna è Unita di misura transcodifico
            if "Unita_misura_1" in excel_cols:
                get_um_sql = "SELECT DISTINCT ItemID FROM dbo.PrdUm"
                cursor.execute(get_um_sql)
                valid_um = { (row[0].strip().upper() if row[0] is not None else "") for row in cursor.fetchall() }

                # 2) Normalizzo la colonna dello sheet (trim + upper); i NaN li tratto come stringa vuota
                import numpy as np
                col = "Unita_misura_1"
                df[col] = df[col].astype(str).str.strip().str.upper()
                df[col] = np.where(df[col].isin(valid_um), df[col], "NR")

            #decodifica Aliquota IVA
            if "Aliquota_IVA" in excel_cols:
                mapping = {
                    "22": "01",
                    "10": "02",
                    "20": "01"
                }
                df["Aliquota_IVA"] = df["Aliquota_IVA"].map(lambda x: mapping.get(x, "01"))
            else:
                df["Aliquota_IVA"] = "01"


            # Verifica colonne Excel presenti
            missing = [c for c in excel_cols if c not in df.columns]
            if missing:
                raise RuntimeError(f"Sheet non contiene colonne richieste per {table}: {missing}")

            # Prepara INSERT
            placeholders = ",".join(["?"] * len(db_cols))
            cols_sql = ",".join(f"[{c}]" for c in db_cols)
            insert_sql = f"INSERT INTO [{table}] ({cols_sql}) VALUES ({placeholders})"

            # Estrai dati e applica normalizzazioni/tagli
            rows_to_insert = []
            for idx, row in df.iterrows():
                try:
                    descr_val = row.get("Descrizione_articolo")
                    if descr_val is None or str(descr_val).strip() == "":
                        # salto questa riga, non la inserisco
                        continue
                    
                    barcode = row.get("BARCODE")
                    if barcode is None or str(barcode).strip() == "":
                        # salto questa riga, non la inserisco
                        continue

                    values = []
                    for ex_col in excel_cols:
                        db_col = db_cols_map[ex_col]
                        v = row[ex_col]

                        # normalizza chiavi se richiesto
                        if db_col in CONFIG["normalize_keys_on"]:
                            v = normalize_key(v)

                        # trim right / left maxlen se configurato
                        maxlen_key = f"{table}.{db_col}"
                        if maxlen_key in CONFIG["maxlen"]:
                            v = trim_right(v, CONFIG["maxlen"][maxlen_key])

                        values.append(v)

                    # aggiungi fissi
                    for k in fixed.keys():
                        values.append(fixed[k])

                    rows_to_insert.append(tuple(values))
                except Exception as e:
                    errors.append(f"{table} row={idx}: PREP_ERROR {e}")

            # Esegui insert batch (se qualche riga fallisce, riprova per-singola per loggarla)
            try:
                cursor.executemany(insert_sql, rows_to_insert)
                conn.commit()  # <--- COMMIT SOLO QUESTA TABELLA
                ok_counts[table] += len(rows_to_insert)
            except Exception:
                # fallback riga-per-riga per loggare gli errori puntuali
                conn.rollback()
                inserted = 0
                for idx, vals in enumerate(rows_to_insert):
                    try:
                        cursor.execute(insert_sql, vals)
                        inserted += 1
                    except Exception as e2:
                        errors.append(f"{table} row={idx}: INSERT_ERROR {e2}")
                conn.commit()
                ok_counts[table] += inserted
    except Exception as e:
        conn.rollback()
        print(f"ERRORE: {e}")
    finally:
        cursor.close()
        conn.close()

    # Log errori
    if errors:
        with open(CONFIG["log_path"], "w", encoding="utf-8") as f:
            f.write("\n".join(errors))
        print(f"[ATTENZIONE] Righe non importate: {len(errors)}. Vedi log: {CONFIG['log_path']}")
    else:
        print("Import completato senza errori.")

if __name__ == "__main__":
    main()
