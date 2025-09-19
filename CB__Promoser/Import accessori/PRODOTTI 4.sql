INSERT INTO [BpPROMOSER].[dbo].[PrdPrz]
([LstCod]
,[RecCreate]
,[RecChange]
,[RecLocked]
,[PrdCod]
,[PrdPrz])
SELECT 
'BASE',
CAST(GETDATE() AS date),
CAST(GETDATE() AS date),
'0',
P.[PrdCod], 
P.[Info1]
FROM [BpPROMOSER].[dbo].[PrdAna] P WHERE 
ISNULL([Info1], '') <> '' AND
ISNULL((SELECT TOP 1 1 FROM [BpPROMOSER].[dbo].[PrdPrz] Q WHERE Q.[PrdCod] = P.[PrdCod]), 0) <> 1;

Update [BpPROMOSER].[dbo].[PrdAna] Set 
[Info1] = NULL
WHERE ISNULL([Info1], '') <> ''