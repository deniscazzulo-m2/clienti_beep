INSERT INTO [BpSaldobraz].[dbo].[PrdAna] (
    [PrdCod],
    [PrdDes],
    [PrdUm],
    [CatCod],
    [Info9],
    [IvaCod],
    [PrdHide],
    [PrdFabbPlan],
    [PrdUso],
    [RecCreate],
    [RecChange],
    [RecLocked]
    )
SELECT
RTRIM(LTRIM(ISNULL([Articolo],''))),
RTRIM(LTRIM(ISNULL([Descrizione],''))),
'NR',
'1',
'INUTILIZZATO',
'01',
'0',
'3',
'10',
CAST(GETDATE() AS date),
CAST(GETDATE() AS date),
'0'
FROM [BpSaldobraz].[dbo].[tempArticoli2] 