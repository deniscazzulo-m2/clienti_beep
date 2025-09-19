INSERT INTO [BpSpit].[dbo].[MixAna] (
    [ItemType],
    [ItemID],
    [ItemDes],
    [Info1],
    [PIva],
    [CFis],
    [Ind],
    [FepaDest],
    [FepaPEC],
    [ItemUse],
    [ItemHide],
    [RecCreate],
    [RecChange],
    [RecLocked]
    )
SELECT
'1',
FORMAT([id], '00000'),
LTRIM(RTRIM([Descrizione])),
LTRIM(RTRIM([Tipologia])),
LTRIM(RTRIM([PIva])),
LTRIM(RTRIM([CodiceFiscale])),
LTRIM(RTRIM([Indirizzo])),
CASE WHEN LEN(LTRIM(RTRIM([CodiceDestinatario]))) = 7 THEN LTRIM(RTRIM([CodiceDestinatario])) WHEN LTRIM(RTRIM([CodiceDestinatario])) = '0' THEN '0000000' ELSE '' END,
CASE WHEN LEN(LTRIM(RTRIM([CodiceDestinatario]))) > 7 THEN LTRIM(RTRIM([CodiceDestinatario])) ELSE '' END,
'20',
'0',
CAST(GETDATE() AS date),
CAST(GETDATE() AS date),
'0'
FROM [BpSpit].[dbo].[tempClienti]