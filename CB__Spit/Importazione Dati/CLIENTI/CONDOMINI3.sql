INSERT INTO [BpSpit].[dbo].[MixAna] (
    [ItemType],
    [ItemID],
    [ItemDes],
    [Ind],
    [CFis],
    [ItemMemo],
    [ItemUse],
    [ItemHide],
    [RecCreate],
    [RecChange],
    [RecLocked]
    )
SELECT
'1',
CONCAT('C',FORMAT([id], '0000')),
LTRIM(RTRIM([Nome])),
LTRIM(RTRIM([Citta])),
CASE WHEN LEN(LTRIM(RTRIM([CodiceFiscale]))) <= 16 THEN LTRIM(RTRIM([CodiceFiscale])) ELSE '' END,
LTRIM(RTRIM([Amministratore])),
'20',
'0',
'2024-09-05',
'2024-09-05',
'0'
FROM [BpSpit].[dbo].[tempCondomini]