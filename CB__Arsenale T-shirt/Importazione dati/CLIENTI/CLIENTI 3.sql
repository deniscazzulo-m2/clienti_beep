INSERT INTO [DATABASE].[dbo].[MixAna] (
    [ItemType],
    [ItemID],
    [CFis],
    [PIva],
    [ItemDes],
    [Ind],
    [Cap],
    [Loc],
    [Pro],
    [Reg],
    [Naz],
    [FepaDest],
    [FepaPEC],
    [Info1],
    [Info2],
    [Info3],
    [ItemMemo],
    [AgeName],
    [PagCod],
    [Banca],
    [Info5],--[BanCod] MANCA TABELLA NOSTRE BANCHE
    [TrPorto],
    [ItemInfo],
    [Info6],-- MANCA TABELLA LISTINI
    [ItemUse],
    [ItemHide],
    [RecCreate],
    [RecChange],
    [RecLocked]
    )
SELECT
'1',
LTRIM(RTRIM(ISNULL([Cod.],''))),
CASE WHEN LEN(REPLACE(LTRIM(RTRIM(ISNULL([Codice fiscale],''))), ' ', '' )) BETWEEN 1 AND 16 THEN REPLACE(LTRIM(RTRIM(ISNULL([Codice fiscale],''))), ' ', '' ) ELSE NULL END,
CASE 
WHEN LEN(REPLACE(LTRIM(RTRIM(ISNULL([Partita Iva],''))), ' ', '' )) BETWEEN 1 AND 16 THEN REPLACE(LTRIM(RTRIM(ISNULL([Partita Iva],''))), ' ', '' ) 
WHEN LEN(REPLACE(LTRIM(RTRIM(ISNULL([Codice fiscale],''))), ' ', '' )) NOT BETWEEN 1 AND 16 THEN 'N.A.' 
ELSE NULL END,
CASE WHEN LEN(LTRIM(RTRIM(ISNULL([Denominazione],'')))) BETWEEN 1 AND 256 THEN LTRIM(RTRIM(ISNULL([Denominazione],''))) ELSE NULL END,
CASE WHEN LEN(LTRIM(RTRIM(ISNULL([Indirizzo],'')))) BETWEEN 1 AND 256 THEN LTRIM(RTRIM(ISNULL([Indirizzo],''))) ELSE NULL END,
CASE WHEN LEN(LTRIM(RTRIM(ISNULL([Cap],'')))) BETWEEN 1 AND 16 THEN LTRIM(RTRIM(ISNULL([Cap],''))) ELSE NULL END,
CASE WHEN LEN(LTRIM(RTRIM(ISNULL([Citta],'')))) BETWEEN 1 AND 128 THEN LTRIM(RTRIM(ISNULL([Citta],''))) ELSE NULL END,
CASE WHEN LEN(LTRIM(RTRIM(ISNULL([Prov.],'')))) BETWEEN 1 AND 16 THEN LTRIM(RTRIM(ISNULL([Prov.],''))) ELSE NULL END,
CASE WHEN LEN(LTRIM(RTRIM(ISNULL([Regione],'')))) BETWEEN 1 AND 32 THEN LTRIM(RTRIM(ISNULL([Regione],''))) ELSE NULL END,
CASE WHEN LEN(UPPER(LTRIM(RTRIM(ISNULL([Nazione],''))))) BETWEEN 1 AND 64 THEN UPPER(LTRIM(RTRIM(ISNULL([Nazione],'')))) ELSE NULL END,
CASE 
    WHEN LEN(LTRIM(RTRIM(ISNULL([Cod. destinatario Fatt. elettr.],'')))) = 7 
    THEN LEN(LTRIM(RTRIM(ISNULL([Cod. destinatario Fatt. elettr.],'')))) 
    ELSE NULL 
    END,
CASE 
    WHEN LEN(LTRIM(RTRIM(ISNULL([Pec],'')))) > 0 OR LEN(LTRIM(RTRIM(ISNULL([Cod. destinatario Fatt. elettr.],'')))) = 7
    THEN (CASE WHEN LEN(LTRIM(RTRIM(ISNULL([Pec],'')))) BETWEEN 1 AND 256 THEN LTRIM(RTRIM(ISNULL([Pec],''))) ELSE NULL END)
    ELSE (CASE WHEN LEN(LTRIM(RTRIM(ISNULL([Cod. destinatario Fatt. elettr.],'')))) BETWEEN 1 AND 256 THEN LTRIM(RTRIM(ISNULL([Cod. destinatario Fatt. elettr.],''))) ELSE NULL END)
    END,
CASE WHEN LEN(LTRIM(RTRIM(ISNULL([Referente],'')))) BETWEEN 1 AND 32 THEN LTRIM(RTRIM(ISNULL([Referente],''))) ELSE NULL END,
CASE WHEN LEN(LTRIM(RTRIM(ISNULL([Tel.],'')))) BETWEEN 1 AND 32 THEN LTRIM(RTRIM(ISNULL([Tel.],''))) ELSE NULL END,
CASE WHEN LEN(CONCAT(LTRIM(RTRIM(ISNULL([Cell],''))),';',LTRIM(RTRIM(ISNULL([Fax],''))))) BETWEEN 1 AND 32 THEN CONCAT(LTRIM(RTRIM(ISNULL([Cell],''))),';',LTRIM(RTRIM(ISNULL([Fax],'')))) ELSE NULL END,
CASE WHEN LEN(LTRIM(RTRIM(ISNULL([e-mail],'')))) BETWEEN 1 AND 1024 THEN LTRIM(RTRIM(ISNULL([e-mail],''))) ELSE NULL END,
CASE WHEN LEN(LTRIM(RTRIM(ISNULL([Agente],'')))) BETWEEN 1 AND 128 THEN LTRIM(RTRIM(ISNULL([Agente],''))) ELSE NULL END,
CASE 
    WHEN LTRIM(RTRIM(ISNULL([Pagamento],''))) IN ('Assegno') THEN 'ASS01'
    WHEN LTRIM(RTRIM(ISNULL([Pagamento],''))) IN ('Bancomat','Carta di credito','Carta di pagamento') THEN 'CAR01'
    WHEN LTRIM(RTRIM(ISNULL([Pagamento],''))) IN ('PayPal','Satispay') THEN 'PE01'
    WHEN LTRIM(RTRIM(ISNULL([Pagamento],''))) IN ('Bonifico 30 gg') THEN 'BB09'
    WHEN LTRIM(RTRIM(ISNULL([Pagamento],''))) IN ('Bonifico 30 gg F.M.') THEN 'BB03'
    WHEN LTRIM(RTRIM(ISNULL([Pagamento],''))) IN ('Bonifico 60 gg') THEN 'BB10'
    WHEN LTRIM(RTRIM(ISNULL([Pagamento],''))) IN ('Bonifico 60 gg F.M.') THEN 'BB04'
    WHEN LTRIM(RTRIM(ISNULL([Pagamento],''))) IN ('Bonifico Bancario','Bonifico vista fattura') THEN 'BB01'
    WHEN LTRIM(RTRIM(ISNULL([Pagamento],''))) IN ('Contrassegno') THEN 'RD01'
    WHEN LTRIM(RTRIM(ISNULL([Pagamento],''))) IN ('RIBA') THEN 'RB12'
    WHEN LTRIM(RTRIM(ISNULL([Pagamento],''))) IN ('RIBA 30 gg F.M.') THEN 'RB01'
    WHEN LTRIM(RTRIM(ISNULL([Pagamento],''))) IN ('RIBA 30-60 gg F.M.') THEN 'RB05'
    WHEN LTRIM(RTRIM(ISNULL([Pagamento],''))) IN ('RIBA 60 gg F.M.') THEN 'RB02'
    WHEN LTRIM(RTRIM(ISNULL([Pagamento],''))) IN ('RIBA 90 gg F.M.') THEN 'RB03'
    WHEN LTRIM(RTRIM(ISNULL([Pagamento],''))) IN ('Rid a 30 gg') THEN 'RD04'
    ELSE (CASE WHEN LEN(LTRIM(RTRIM(ISNULL([Pagamento],'')))) BETWEEN 1 AND 16 THEN LTRIM(RTRIM(ISNULL([Pagamento],''))) ELSE NULL END)
END,
CASE WHEN LEN(LTRIM(RTRIM(ISNULL([Banca],'')))) BETWEEN 1 AND 128 THEN LTRIM(RTRIM(ISNULL([Banca],''))) ELSE NULL END,
CASE WHEN LEN(LTRIM(RTRIM(ISNULL([Ns Banca],'')))) BETWEEN 1 AND 32 THEN LTRIM(RTRIM(ISNULL([Ns Banca],''))) ELSE NULL END,
CASE WHEN LTRIM(RTRIM(ISNULL([Porto],''))) = 'Franco' THEN '1' ELSE NULL END,
LTRIM(RTRIM(ISNULL([Note],''))),
CASE WHEN LEN(LTRIM(RTRIM(ISNULL([Listino],'')))) BETWEEN 1 AND 32 THEN LTRIM(RTRIM(ISNULL([Listino],''))) ELSE NULL END,
'10',
'0',
CAST(GETDATE() as DATE),
CAST(GETDATE() as DATE),
'0'
FROM [DATABASE].[dbo].[tempClienti]