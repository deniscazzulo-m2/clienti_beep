INSERT INTO [BpPROMOSER].[dbo].[MixAnaRif]
([ItemType]
,[ItemID]
,[ItemIDRif]
,[ItemDefault]
,[ItemUse]
,[ItemDes]
,[RecCreate]
,[RecChange]
,[RecLocked]
,[Tel1]
,[Tel2]
,[Tel3])
SELECT 
[ItemType],
[ItemID],
'1',
'1',
'1',
'Contatti',
'2024-09-05', 
'2024-09-05', 
'0',
[Info5], 
[Info6], 
[Info7]
FROM [BpPROMOSER].[dbo].[MixAna] WHERE [Info5] <> '' OR [Info6] <> '' OR [Info7] <> '';

Update [BpPROMOSER].[dbo].[MixAna] Set 
[Info5] = '',
[Info6] = '',
[Info7] = '' 
WHERE [Info5] <> '' OR [Info6] <> '' OR [Info7] <> ''