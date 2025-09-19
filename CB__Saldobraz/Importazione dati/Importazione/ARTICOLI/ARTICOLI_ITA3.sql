INSERT INTO [BpSaldobraz].[dbo].[PrdDes] (
    [PrdCod],
    [PrdDes],
    [Language]
    )
SELECT
B.PrdCod,
RTRIM(LTRIM(ISNULL([descrizione],''))),
'ITA'
FROM [BpSaldobraz].[dbo].[tempArticoliIta] A JOIN [PrdAna] B ON 
    ('0' + LTRIM(RTRIM(A.codice)) = B.PrdCod OR LTRIM(RTRIM(A.codice)) = B.PrdCod) AND
    LTRIM(RTRIM(A.categoria)) = B.CatCod