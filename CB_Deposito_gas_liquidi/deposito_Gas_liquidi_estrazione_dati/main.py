#!/usr/bin/env python3
# -*- coding: utf-8 -*-

#import sys
import pandas as pd

INPUT_XLSX = "mew/dianflex2.xlsx"
SHEET1_NAME = "Foglio1"
SHEET2_NAME = "Foglio2"
OUTPUT_XLSX = "output_join2.xlsx"

COL_MVCODART = "mvcodart"
COL_ALIAS    = "arcodart"
COLS_F1_KEEP = ["andescri", "totven", "qtaven"]

def normalize_series(s: pd.Series) -> pd.Series:
    return (
        s.astype(str)
         .str.strip()
         .str.lower()
         .fillna("")
    )

def main():
    f1 = pd.read_excel(INPUT_XLSX, sheet_name=SHEET1_NAME, dtype=object)
    f2 = pd.read_excel(INPUT_XLSX, sheet_name=SHEET2_NAME, dtype=object)

    # Normalizza chiavi
    f1["_key"] = normalize_series(f1[COL_MVCODART])
    f2["_key"] = normalize_series(f2[COL_ALIAS])

    # Riduci Foglio1 ai campi che servono
    f1_reduced = f1[["_key"] + COLS_F1_KEEP].copy()

    # Join per i match
    merged = pd.merge(
        f2,
        f1_reduced,
        on="_key",
        how="inner",
        suffixes=("", "_f1")
    )

    cols_out = COLS_F1_KEEP + [c for c in f2.columns if c != "_key"]
    for c in merged.columns:
        if c not in cols_out and c != "_key":
            cols_out.append(c)

    out = merged[cols_out].copy()

    # === Non trovati: elementi di Foglio1 che non hanno corrispondenza in Foglio2 ===
    f1_check = f1.merge(f2[["_key"]], on="_key", how="left", indicator=True)
    not_found = f1_check[f1_check["_merge"] == "left_only"]
    not_found = not_found.drop(columns=["_key", "_merge"])

    # Scrivi Excel
    with pd.ExcelWriter(OUTPUT_XLSX, engine="openpyxl") as writer:
        out.to_excel(writer, index=False, sheet_name="Risultato")
        not_found.to_excel(writer, index=False, sheet_name="NonTrovati")

    print(f"Output scritto in {OUTPUT_XLSX}")
    print(f"- Match trovati : {out.shape[0]}")
    print(f"- Non trovati   : {not_found.shape[0]}")

if __name__ == "__main__":
    main()
