INSERT INTO [BpPROMOSER].[dbo].[PrdAna] (
    [PrdCod],
    [PrdDes],
    [Info1],
    [GrpCod],
    [PrdHide],
    [PrdFabbPlan],
    [PrdUso],
    [RecCreate],
    [RecChange],
    [RecLocked]
    )
SELECT
RTRIM(LTRIM([Codice])),
RTRIM(LTRIM([Descrizione])),
RTRIM(LTRIM([Prezzo])),
'PROM',
'0',
'3',
'10',
CAST(GETDATE() AS date),
CAST(GETDATE() AS date),
'0'
FROM [BpPROMOSER].[dbo].[tempProdotti]
--WHERE RTRIM(LTRIM([Codice])) NOT IN (SELECT [PrdCod] FROM [BpPROMOSER].[dbo].[PrdAna])
