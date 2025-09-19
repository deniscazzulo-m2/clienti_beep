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
    [FepaDest],
	[banabi],
	[bancab],
	[pagcod],
	[Info9],
	[baniban],
	[banca],
	[bancod],
    [ItemType],
    [ItemUse],
    [ItemHide],
    [RecCreate],
    [RecChange],
    [RecLocked]
    )

SELECT
rtrim(ltrim(id))
,rtrim(ltrim(RagioneSociale))
,rtrim(ltrim(RagioneSocialeBr))
,rtrim(ltrim(partitaiva))
,rtrim(ltrim(codicefiscale))
,rtrim(ltrim([Indirizzo completo]))
,rtrim(ltrim(Citta))
,rtrim(ltrim(CAP))
,rtrim(ltrim(Provincia))
,rtrim(ltrim([Nazione]))
,concat('Tel: ',rtrim(ltrim(Telefono)),' | Email: ',rtrim(ltrim(email)))
,rtrim(ltrim([Email PEC]))
,rtrim(ltrim([sdi]))
,rtrim(ltrim(abi))
,rtrim(ltrim(cab))
,rtrim(ltrim([codpag]))
,rtrim(ltrim([key]))
,rtrim(ltrim(iban))
,rtrim(ltrim(banca))
,rtrim(ltrim(bancans))
,'1'
,'10'
,'0'
,CAST(GETDATE() AS date)
,CAST(GETDATE() AS date)
,'0'
From [BpSaldobraz].[dbo].[tempClienti2] where
id not in ('120.10219','120.00059','120.00537','120.10203','120.10158','120.10402','120.10303','120.00258','120.10355')