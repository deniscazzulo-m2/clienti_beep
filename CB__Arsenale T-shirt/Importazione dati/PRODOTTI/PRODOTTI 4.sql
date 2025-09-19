INSERT INTO [DATABASE].[dbo].[PrdPrz] 
([PrdCod]
,[LstCod]
,[PrdPrz]
,[RecCreate]
,[RecChange]
,[RecLocked])
SELECT 
[PrdCod],--[PrdCod]
'LISTINO1',--[LstCod]
REPLACE(LTRIM(RTRIM([Info1])),',','.'),--[PrdPrz]
CAST(GETDATE() as DATE),--[RecCreate]
CAST(GETDATE() as DATE),--[RecChange]
'0'--[RecLocked]
FROM [DATABASE].[dbo].[PrdAna] WHERE LTRIM(RTRIM(ISNULL([Info1],''))) <> '';

UPDATE [DATABASE].[dbo].[PrdAna] SET [Info1] = NULL WHERE LTRIM(RTRIM(ISNULL([Info1],''))) <> '';


INSERT INTO [DATABASE].[dbo].[PrdPrz] 
([PrdCod]
,[LstCod]
,[PrdPrz]
,[RecCreate]
,[RecChange]
,[RecLocked])
SELECT 
[PrdCod],--[PrdCod]
'LISTINO2',--[LstCod]
REPLACE(LTRIM(RTRIM([Info2])),',','.'),--[PrdPrz]
CAST(GETDATE() as DATE),--[RecCreate]
CAST(GETDATE() as DATE),--[RecChange]
'0'--[RecLocked]
FROM [DATABASE].[dbo].[PrdAna] WHERE LTRIM(RTRIM(ISNULL([Info2],''))) <> '';

UPDATE [DATABASE].[dbo].[PrdAna] SET [Info2] = NULL WHERE LTRIM(RTRIM(ISNULL([Info2],''))) <> '';


INSERT INTO [DATABASE].[dbo].[PrdPrz] 
([PrdCod]
,[LstCod]
,[PrdPrz]
,[RecCreate]
,[RecChange]
,[RecLocked])
SELECT 
[PrdCod],--[PrdCod]
'LISTINO3',--[LstCod]
REPLACE(LTRIM(RTRIM([Info3])),',','.'),--[PrdPrz]
CAST(GETDATE() as DATE),--[RecCreate]
CAST(GETDATE() as DATE),--[RecChange]
'0'--[RecLocked]
FROM [DATABASE].[dbo].[PrdAna] WHERE LTRIM(RTRIM(ISNULL([Info3],''))) <> '';

UPDATE [DATABASE].[dbo].[PrdAna] SET [Info3] = NULL WHERE LTRIM(RTRIM(ISNULL([Info3],''))) <> '';


INSERT INTO [DATABASE].[dbo].[MixAnaAlias] 
([ItemType]
,[ItemID]
,[AliasType]
,[AliasID]
,[AliasDefault]
,[AliasHide]
,[PrintOnLabel]
,[DivideOnLabel])
SELECT 
'5',--[ItemType]
[PrdCod],--[ItemID]
'13',--[AliasType]
LTRIM(RTRIM([Info6])),--[AliasID]
'1',--[AliasDefault]
'0',--[AliasHide]
'1',--[PrintOnLabel]
'1'--[DivideOnLabel]
FROM [DATABASE].[dbo].[PrdAna] WHERE LTRIM(RTRIM(ISNULL([Info6],''))) <> '';

UPDATE [DATABASE].[dbo].[PrdAna] SET [Info6] = NULL WHERE LTRIM(RTRIM(ISNULL([Info6],''))) <> '';


INSERT INTO [DATABASE].[dbo].[PrdFor] 
([PrdCod]
,[ForCod]
,[PrdForCod]
,[PrdPrz]
,[TmpCns])
SELECT 
[PrdCod],--[PrdCod]
(SELECT LTRIM(RTRIM([Token])) 
FROM dbo.[udfStrSplit_TN]([Info8],';') 
WHERE [TokenNumber] = 1),--[ForCod]
(SELECT LTRIM(RTRIM(ISNULL([Token],''))) 
FROM dbo.[udfStrSplit_TN]([Info8],';') 
WHERE [TokenNumber] = 2),--[PrdForCod]
CASE 
    WHEN LTRIM(RTRIM(ISNULL([Info9],';'))) NOT LIKE ';%'
    THEN (SELECT REPLACE(LTRIM(RTRIM([Token])),',','.') 
        FROM dbo.[udfStrSplit_TN]([Info9],';') 
        WHERE [TokenNumber] = 1)
    ELSE NULL END,--[PrdPrz]
(SELECT LTRIM(RTRIM(ISNULL([Token],''))) 
FROM dbo.[udfStrSplit_TN]([Info9],';') 
WHERE [TokenNumber] = 2)--[TmpCns]
FROM [DATABASE].[dbo].[PrdAna] WHERE LTRIM(RTRIM(ISNULL([Info8],';'))) NOT LIKE ';%';

UPDATE [DATABASE].[dbo].[PrdAna] SET 
[Info8] = NULL, 
[Info9] = NULL
WHERE LTRIM(RTRIM(ISNULL([Info8],';'))) NOT LIKE ';%';

