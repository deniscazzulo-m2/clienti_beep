INSERT INTO [BpSaldobraz].[dbo].[PrdAna] (
    [PrdCod],
    [PrdDes],
    [CatCod],
    [Info1],
    [Info2],
    [Info3],
    [Peso],
    [PrdUm],
    [IvaCod],
    [PrdHide],
    [PrdFabbPlan],
    [PrdUso],
    [RecCreate],
    [RecChange],
    [RecLocked]
    )
SELECT
RTRIM(LTRIM(ISNULL([codice],''))),
RTRIM(LTRIM(ISNULL([descrizione],''))),
RTRIM(LTRIM(ISNULL([categoria],''))),
RTRIM(LTRIM(ISNULL([pzfor],''))),
RTRIM(LTRIM(ISNULL([pzprd],''))),
RTRIM(LTRIM(ISNULL([listino],''))),
CAST([peso] as decimal(9,3)),
'NR',
'01',
'0',
'3',
'10',
CAST(GETDATE() AS date),
CAST(GETDATE() AS date),
'0'
FROM [BpSaldobraz].[dbo].[tempArticoli] 