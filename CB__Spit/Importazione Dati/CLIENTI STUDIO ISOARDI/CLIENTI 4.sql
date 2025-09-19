INSERT INTO [BpSpit].[dbo].[MixAnaRif]
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
,[MailAddress])
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
[Info3], 
[ItemInfo]
FROM [BpSpit].[dbo].[MixAna] WHERE [ItemType] = '1' AND ([Info3] <> '' OR [ItemInfo] <> '');

Update [BpSpit].[dbo].[MixAna] Set 
[Info3] = NULL, 
[ItemInfo] = NULL
WHERE [ItemType] = '1' AND ([Info3] <> '' OR [ItemInfo] <> '')