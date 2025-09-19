INSERT INTO [BpSaldobraz].[dbo].[PrdPrz]
([LstCod]
,[PrdCod]
,[PrdPrz]
,[RecCreate]
,[RecChange]
,[RecLocked])
SELECT 
RTRIM(LTRIM([Info3])),
[PrdCod], 
CAST(REPLACE([Info2],',','.') AS decimal(19,6)),
CAST(GETDATE() AS date),
CAST(GETDATE() AS date),
'0'
FROM [BpSaldobraz].[dbo].[PrdAna] WHERE 
RTRIM(LTRIM(ISNULL([Info2], ''))) NOT IN ('0','') AND
RTRIM(LTRIM(ISNULL([Info3], ''))) IN ('2000-NEW COIR','1000- CLOOS');

INSERT INTO [BpSaldobraz].[dbo].[PrdFor]
([ForCod]
,[PrdCod]
,[PrdPrz])
SELECT 
CASE
    WHEN RTRIM(LTRIM([Info3])) = '2000-NEW COIR' THEN '0086'
    WHEN RTRIM(LTRIM([Info3])) = '1000- CLOOS' THEN '00165'
    ELSE NULL END,
[PrdCod], 
CAST(REPLACE([Info1],',','.') AS decimal(19,6))
FROM [BpSaldobraz].[dbo].[PrdAna] WHERE 
RTRIM(LTRIM(ISNULL([Info1], ''))) NOT IN ('0','') AND
RTRIM(LTRIM(ISNULL([Info3], ''))) IN ('2000-NEW COIR','1000- CLOOS');

UPDATE [BpSaldobraz].[dbo].[PrdAna] SET
[Info1] = NULL, [Info2] = NULL, [Info3] = NULL
WHERE 
    RTRIM(LTRIM(ISNULL([Info1], ''))) NOT IN ('0','') AND 
    RTRIM(LTRIM(ISNULL([Info2], ''))) NOT IN ('0','') AND
    RTRIM(LTRIM(ISNULL([Info3], ''))) IN ('2000-NEW COIR','1000- CLOOS');