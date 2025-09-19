INSERT INTO [BpSpit].[dbo].[MixAna] (
    [ItemID],--[id]
    [ItemDes],--[Nome]
    --[Codice interno],
    [Ind],--[Indirizzo]
    [Loc],--[Comune]
    [Cap],--[CAP]
    [Pro],--[Provincia]
    --[Indirizzo extra],
    [Naz],--[Paese]
    [ItemInfo],--[E-mail]
    --[Referente],
    [Info3],--[Telefono]
    [PIva],--[P.IVA/TAX ID]
    [CFis],--[Codice Fiscale]
    --[Note Extra],
    [FepaPEC],--[E-mail PEC]
    [FepaDest],--[Codice SDI]
    [ItemType],
    [ItemUse],
    [ItemHide],
    [RecCreate],
    [RecChange],
    [RecLocked]
    )
SELECT
FORMAT((SELECT MAX(TRY_CAST([ItemID] AS int)) FROM [MixAna] WHERE [ItemType] = '1') + [id], '00000'),--[ItemID]
LTRIM(RTRIM([Nome])),--[ItemDes]
LTRIM(RTRIM([Indirizzo])),--[Ind]
LTRIM(RTRIM([Comune])),--[Loc]
LTRIM(RTRIM([CAP])),--[Cap]
LTRIM(RTRIM([Provincia])),--[Pro]
LTRIM(RTRIM([Paese])),--[Naz]
LTRIM(RTRIM([E-mail])),--[ItemInfo]
LTRIM(RTRIM([Telefono])),--[Info3]
CASE 
    WHEN LTRIM(RTRIM(ISNULL([P.IVA/TAX ID], ''))) = '' THEN 'N.A.' 
    ELSE LTRIM(RTRIM([P.IVA/TAX ID])) END,--[PIva]
LTRIM(RTRIM([Codice Fiscale])),--[CFis]
LTRIM(RTRIM([E-mail PEC])),--[FepaPEC]
LTRIM(RTRIM([Codice SDI])),--[FepaDest]
'1',
'20',
'0',
CAST(GETDATE() AS date),
CAST(GETDATE() AS date),
'0'
FROM [BpSpit].[dbo].[tempClienti2]