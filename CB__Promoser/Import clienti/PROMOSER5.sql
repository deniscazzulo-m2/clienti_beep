INSERT INTO [BpPROMOSER].[dbo].[MixAnaSedi]
([ItemType]
,[ItemID]
,[ItemIDSede]
,[ItemUse]
,[ItemDes]
,[RecCreate]
,[RecChange]
,[RecLocked]
,[Ind]
,[Cap]
,[Loc]
,[Pro])
SELECT 
[ItemType],
[ItemID],
'1',
'1',
'Sede',
'2024-09-05', 
'2024-09-05', 
'0',
[ItemMemo],
[Info2],
[Info3],
[Info4]
FROM [BpPROMOSER].[dbo].[MixAna] WHERE [ItemMemo] <> '' OR [Info2] <> '' OR [Info3] <> '' OR [Info4] <> '';

Update [BpPROMOSER].[dbo].[MixAna] Set 
[ItemMemo] = '',
[Info2] = '',
[Info3] = '' ,
[Info4] = '' 
WHERE [ItemMemo] <> '' OR [Info2] <> '' OR [Info3] <> '' OR [Info4] <> ''