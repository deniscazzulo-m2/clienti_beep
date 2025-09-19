INSERT INTO [BpSaldobraz].[dbo].[MixAna] (
    [ItemID],
    [ItemDes],
    [PIva],
    [CFis],
    [Ind],
    [Loc],
    [Cap],
    [Pro],
    [Naz],
    [ItemInfo],
    [FepaPEC],
    [FepaDest],
    [ItemType],
    [ItemUse],
    [ItemHide],
    [RecCreate],
    [RecChange],
    [RecLocked]
    )
SELECT
RIGHT(CONCAT('00000',CAST([id] AS varchar)),5),
RTRIM(LTRIM(ISNULL([RagioneSociale],''))),
CASE 
    WHEN RTRIM(LTRIM(ISNULL([PartitaIva],''))) NOT IN ('0','') THEN
        CASE
            WHEN TRY_CONVERT(decimal, RTRIM(LTRIM([PartitaIva]))) IS NOT NULL THEN
                RIGHT(CONCAT('000000000000',RTRIM(LTRIM([PartitaIva]))),12)
            ELSE RTRIM(LTRIM([PartitaIva])) END
    ELSE 'N.A.' END,
CASE 
    WHEN RTRIM(LTRIM(ISNULL([CodiceFiscale],''))) NOT IN ('0','') THEN
        CASE
            WHEN TRY_CONVERT(decimal, RTRIM(LTRIM([CodiceFiscale]))) IS NOT NULL 
            AND RTRIM(LTRIM([CodiceFiscale])) = RTRIM(LTRIM(ISNULL([PartitaIva],''))) THEN
                RIGHT(CONCAT('000000000000',RTRIM(LTRIM([CodiceFiscale]))),12)
            ELSE RTRIM(LTRIM([CodiceFiscale])) END
    ELSE NULL END,
CASE
    WHEN RTRIM(LTRIM(ISNULL([Indirizzo completo],''))) NOT IN ('0',',','') THEN
        RTRIM(LTRIM([Indirizzo completo]))
    ELSE NULL END,
CASE
    WHEN RTRIM(LTRIM(ISNULL([Citta],''))) NOT IN ('0','') THEN
        RTRIM(LTRIM([Citta]))
    ELSE NULL END,
CASE
    WHEN RTRIM(LTRIM(ISNULL([CAP],''))) NOT IN ('0','') THEN
        RTRIM(LTRIM([CAP]))
    ELSE NULL END,
CASE
    WHEN RTRIM(LTRIM(ISNULL([Provincia],''))) NOT IN ('0','') THEN
        RTRIM(LTRIM([Provincia]))
    ELSE NULL END,
CASE
    WHEN RTRIM(LTRIM(ISNULL([Nazione],''))) IN ('IT','I','ITA') THEN 'ITALIA'
    WHEN RTRIM(LTRIM(ISNULL([Nazione],''))) IN ('AT') THEN 'AUSTRIA'
    WHEN RTRIM(LTRIM(ISNULL([Nazione],''))) IN ('BE') THEN 'BELGIO'
    WHEN RTRIM(LTRIM(ISNULL([Nazione],''))) IN ('BY') THEN 'BIELORUSSIA'
    WHEN RTRIM(LTRIM(ISNULL([Nazione],''))) IN ('CH','CHF','SW') THEN 'SVIZZERA'
    WHEN RTRIM(LTRIM(ISNULL([Nazione],''))) IN ('D','DE') THEN 'GERMANIA'
    WHEN RTRIM(LTRIM(ISNULL([Nazione],''))) IN ('ES') THEN 'SPAGNA'
    WHEN RTRIM(LTRIM(ISNULL([Nazione],''))) IN ('FIN') THEN 'FINLANDIA'
    WHEN RTRIM(LTRIM(ISNULL([Nazione],''))) IN ('FR') THEN 'FRANCIA'
    WHEN RTRIM(LTRIM(ISNULL([Nazione],''))) IN ('IE') THEN 'IRLANDA'
    WHEN RTRIM(LTRIM(ISNULL([Nazione],''))) IN ('IN') THEN 'INDIA'
    WHEN RTRIM(LTRIM(ISNULL([Nazione],''))) IN ('NL') THEN 'OLANDA'
    WHEN RTRIM(LTRIM(ISNULL([Nazione],''))) IN ('PL') THEN 'POLONIA'
    WHEN RTRIM(LTRIM(ISNULL([Nazione],''))) IN ('RO') THEN 'ROMANIA'
    WHEN RTRIM(LTRIM(ISNULL([Nazione],''))) IN ('RUSS') THEN 'RUSSIA'
    WHEN RTRIM(LTRIM(ISNULL([Nazione],''))) IN ('SI','SL') THEN 'SLOVENIA'
    WHEN RTRIM(LTRIM(ISNULL([Nazione],''))) IN ('SK') THEN 'REP.SLOVACCA'
    WHEN RTRIM(LTRIM(ISNULL([Nazione],''))) IN ('USA') THEN 'STATI UNITI'
    ELSE NULL END,
CONCAT(
    'Telefono: ',
    RTRIM(LTRIM(ISNULL([Telefono],''))),
    CHAR(10), 'Cellulare: ',
    RTRIM(LTRIM(ISNULL([Cellulare],''))),
    CHAR(10), 'Email: ',
    RTRIM(LTRIM(ISNULL([Email],'')))
),
CASE
    WHEN RTRIM(LTRIM(ISNULL([Email PEC],''))) NOT IN ('0','') THEN
        RTRIM(LTRIM([Email PEC]))
    ELSE NULL END,
CASE
    WHEN RTRIM(LTRIM(ISNULL([CodiceDestinatario],''))) NOT IN ('0','') THEN
        RTRIM(LTRIM([CodiceDestinatario]))
    ELSE NULL END,
'1',
'10',
'0',
CAST(GETDATE() AS date),
CAST(GETDATE() AS date),
'0'
FROM [BpSaldobraz].[dbo].[tempClienti]