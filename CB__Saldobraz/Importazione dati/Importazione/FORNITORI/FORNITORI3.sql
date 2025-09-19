INSERT INTO [BpSaldobraz].[dbo].[MixAna] (
    [ItemID],
    [ItemDes],
    [ItemDesShort],
    [PIva],
    [CFis],
    [Ind],
    [Loc],
    [Cap],
    [Pro],
    [Naz],
    [ItemInfo],
    [FepaPEC],
	[banabi],
	[bancab],
	[baniban],
	[banca],
	[pagcod],
	[Info9],
    [ItemType],
    [ItemUse],
    [ItemHide],
    [RecCreate],
    [RecChange],
    [RecLocked]
    )

SELECT
RIGHT(CONCAT('00000',CAST([id] AS varchar)),5),--[ItemID]
rtrim(ltrim(RagioneSociale))--[ItemDes]
,rtrim(ltrim(RagioneSocialeBr))--[ItemDesShort]
,rtrim(ltrim(partitaiva))--[PIva]
,rtrim(ltrim(codicefiscale))--[CFis]
,rtrim(ltrim([Indirizzo completo]))--[Ind]
,rtrim(ltrim(Citta))--[Loc]
,rtrim(ltrim(CAP))--[Cap]
,rtrim(ltrim(Provincia))--[Pro]
,rtrim(ltrim([Nazione]))--[Naz]
,concat('Tel: ',rtrim(ltrim(Telefono)),' | Email: ',rtrim(ltrim(email)))--[ItemInfo]
,rtrim(ltrim([Email PEC]))--[FepaPEC]
,rtrim(ltrim(abi))--[banabi]
,rtrim(ltrim(cab))--[bancab]
,rtrim(ltrim(iban))--[baniban]
,rtrim(ltrim(banca))--[banca]
,rtrim(ltrim([codpag]))--[pagcod]
,rtrim(ltrim([key]))--[Info9]
,'2'--[ItemType]
,'20'--[ItemUse]
,'0'--[ItemHide]
,CAST(GETDATE() AS date)--[RecCreate]
,CAST(GETDATE() AS date)--[RecChange]
,'0'--[RecLocked]
From [BpSaldobraz].[dbo].[tempFornitori]