CREATE TABLE [tempSedi]( 
    [id] INT IDENTITY(1,1) 
	,[ItemType] nvarchar(512) NULL
	,[ItemID] nvarchar(512) NULL
	,[ItemDes] nvarchar(512) NULL
	,[Ind] nvarchar(512) NULL
	,[Cap] nvarchar(512) NULL
	,[Loc] nvarchar(512) NULL
	,[Pro] nvarchar(512) NULL
    ,[Naz] nvarchar(512) NULL
	)
    
--,OVER (PARTITION BY concat(rtrim(ltrim(b.mastro)),'.',right(concat('00000',rtrim(ltrim(b.sottoc))),5)) ORDER BY 1)