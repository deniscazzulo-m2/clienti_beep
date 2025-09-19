INSERT INTO [BpSaldobraz].[dbo].[MixAnaSedi] (
    [ItemType]
    ,[ItemID]
    ,[ItemIDSede]
    ,[ItemDes]
    ,[Ind]
    ,[Cap]
    ,[Loc]
    ,[Pro]
    ,[Naz]
    )

SELECT
[ItemType]
,[ItemID]
,row_number() OVER (PARTITION BY itemid ORDER BY itemid)
,[ItemDes]
,[Ind]
,[Cap]
,[Loc]
,[Pro]
,[Naz]
From [BpSaldobraz].[dbo].[tempsedi] where
len(rtrim(ltrim(isnull(itemdes,''))))>0