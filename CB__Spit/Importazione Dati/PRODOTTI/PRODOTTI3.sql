INSERT INTO [BpSPIT].[dbo].[PrdAna] (
    [PrdCod],
    [PrdDes],
    [PrdHide],
    [PrdFabbPlan],
    [PrdUso],
    [RecCreate],
    [RecChange],
    [RecLocked]
    )
SELECT
[Codice],
[Descrizione],
'0',
'3',
'10',
'2024-09-05',
'2024-09-05',
'0'
FROM [BpSPIT].[dbo].[tempProdotti]
