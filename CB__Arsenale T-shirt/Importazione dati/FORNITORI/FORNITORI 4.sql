INSERT INTO [DATABASE].[dbo].[MixAnaRif]
([ItemType]
,[ItemID]
,[ItemIDRif]
,[ItemDefault]
,[ItemUse]
,[ItemDes]
,[WhoName]
,[Tel1]
,[Tel2]
,[Tel3]
,[MailAddress]
,[RecCreate]
,[RecChange]
,[RecLocked])
SELECT 
[ItemType],
[ItemID],
'1',
'1',
'1',
'Referente',
[Info1], 
[Info2], 
SUBSTRING([Info3], 
1, 
CASE CHARINDEX(';', [Info3])
    WHEN 0
        THEN LEN([Info3])
    ELSE CHARINDEX(';', [Info3]) - 1
    END), 
SUBSTRING([Info3], 
CASE CHARINDEX(';', [Info3])
    WHEN 0
        THEN LEN([Info3]) + 1
    ELSE CHARINDEX(';', [Info3]) + 1
    END, 
1000), 
CASE WHEN LEN([ItemMemo]) <= 128 THEN [ItemMemo] ELSE NULL END,
CAST(GETDATE() as DATE),
CAST(GETDATE() as DATE),
'0'
FROM [DATABASE].[dbo].[MixAna] WHERE 
[ItemType] = '2' AND (
IsNull([Info1],'') <> '' OR 
IsNull([Info2],'') <> '' OR 
IsNull([info3],'') NOT IN (';','') OR 
IsNull([ItemMemo],'') <> '');


Update [DATABASE].[dbo].[MixAna] Set 
[Info1] = '',
[Info2] = '',
[info3] = '' 
WHERE 
[ItemType] = '2' AND (
IsNull([Info1],'') <> '' OR 
IsNull([Info2],'') <> '' OR 
IsNull([info3],'') <> '');


Update [DATABASE].[dbo].[MixAna] Set 
[ItemMemo] = '' 
WHERE 
[ItemType] = '2' AND (
IsNull([ItemMemo],'') <> '' AND
LEN([ItemMemo]) <= 128);