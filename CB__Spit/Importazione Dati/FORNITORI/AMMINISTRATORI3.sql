INSERT INTO [BpSpit].[dbo].[MixAna] (
    [ItemType],
    [ItemID],
    [ItemDes],
    [ItemMemo],
    [Ind],
    [Info1],
    [Info2],
    [ItemUse],
    [ItemHide],
    [RecCreate],
    [RecChange],
    [RecLocked]
    )
SELECT
'2',
CONCAT('A',FORMAT([id], '0000')),
LTRIM(RTRIM([Nome])),
LTRIM(RTRIM([Contatti])),
LTRIM(RTRIM([Studio])),
LTRIM(RTRIM([Condomini])),
LTRIM(RTRIM([Contratti])),
'23',
'0',
'2024-09-05',
'2024-09-05',
'0'
FROM [BpSpit].[dbo].[tempAmministratori]