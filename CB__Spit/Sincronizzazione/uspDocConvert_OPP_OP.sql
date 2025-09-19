/* 
*
*	Converte offerta emessa a cliente potenziale
*	in offerta reale con trasferimento del cliente da potenziale a reale
*
*	@sItemID_new: codice cliente reale
*	@sUniqs: lista Uniq offerte da convertire
*	------------------------------------------------------------------------
*	IMPORTANTE: le offerte devono appartenere allo stesso cliente potenziale
*	------------------------------------------------------------------------
*
*   Personalizzata per la sincronizzazione
*/
CREATE PROCEDURE [dbo].[uspDocConvert_OPP_OP]
	@iSession int,
	@sItemID_new varchar(16), -- codice cliente reale
	@sUniqs varchar(1024)
AS
SET NOCOUNT ON
Declare @sResponse varchar(1204) = ''
Declare @iItemType tinyint = 19
Declare @iItemType_new tinyint = 1
Declare @iItemUse_new tinyint = 10
Declare @sItemID varchar(16) = '' 	-- codice cliente potenziale ricavato dalle offerte in @sUniqs

-- ----------------------------------------------------------------------------
Declare @tbUniqs TABLE([Uniq] int)

Insert @tbUniqs(Uniq)
Select Token
From dbo.[udfStrSplit](@sUniqs, ',')

Select @sItemID = AnaCod
From dbo.[CliOff]
Where Uniq = (Select TOP 1 Uniq From @tbUniqs)

Set @sItemID = IsNull(@sItemID, '')
If @sItemID = ''
	Set @sResponse = '!Impossibile determinare il codice del cliente potenziale.'

-- ----------------------------------------------------------------------------
If (@sResponse = '') And (@sItemID_new = '')
BEGIN
	Declare @sItemType_new varchar(3) = Cast(@iItemType_new As varchar(3))
	Declare @sParName varchar(32) = 'MixAna' + @sItemType_new
	Declare @iNumero int = 0
	Declare @iLen int = 0

	Execute [uspNumUniqNext_out] @sParName, @iNumero OUTPUT

	Set @sParName = Cast(1000 + dbo.[udfC_TinyInt](@sItemType_new) As char(4))
	Set @iLen = dbo.[udfEnvironRead_int](@sParName)
	Set @iLen = IsNull(@iLen, 0)
	If @iLen <= 0
		Set @iLen = 5

	Set @sItemID_new = Replace(Str(@iNumero, @iLen), ' ', '0')
	If Left(@sItemID_new, 1) = '*'
		Set @sResponse = '!Il valore progressivo del nuovo codice supera il numero di caratteri impostati nei parametri aziendali. E'' necessario modificare il parametro oppure provvedere manualmente alla copia dei dati anagrafici.'

	--PERS M2SISTEMI x SINCRONIZZATORE/SYNCHRONIZATION
	--Else If EXISTS(Select TOP 1 ItemID From dbo.[MixAna] Where ItemID = @sItemID_new And ItemType = @iItemType_new)
	Else If EXISTS(Select TOP 1 ItemID From [BpSPIT].dbo.[MixAna] Where ItemID = @sItemID_new And ItemType = @iItemType_new) Or
			EXISTS(Select TOP 1 ItemID From [BpSTUDIOISOARDI].dbo.[MixAna] Where ItemID = @sItemID_new And ItemType = @iItemType_new) Or
			EXISTS(Select TOP 1 ItemID From [BpSPITGEST].dbo.[MixAna] Where ItemID = @sItemID_new And ItemType = @iItemType_new)
		Set @sResponse = '!Il valore progressivo del nuovo codice-cliente determina un duplicato. Provvedere manualmente alla copia dei dati anagrafici.'
END -- @sResponse = ''

-- ----------------------------------------------------------------------------
If @sResponse = ''
BEGIN
	--
	-- OK
	--
	Declare @tDate date = GetDate()
	Declare @iUserID smallint = dbo.[udfSysUserID](@iSession)
	
	Update dbo.[MixAna] Set
		  ItemType = @iItemType_new
		, ItemID = @sItemID_new
		, ItemUse = @iItemUse_new
	Where ItemType = @iItemType
		And ItemID = @sItemID

	Update dbo.[MixAnaSedi] Set
		  ItemType = @iItemType_new
		, ItemID = @sItemID_new
	Where ItemType = @iItemType
		And ItemID = @sItemID
		
	Update dbo.[MixAnaRif] Set
		  ItemType = @iItemType_new
		, ItemID = @sItemID_new
	Where ItemType = @iItemType
		And ItemID = @sItemID

	Update dbo.[CliOff] Set
		  DocKind = NULL
		, AnaType = 1
		, AnaCod = @sItemID_new
		, AnaCodFrom = @sItemID_new
		
		, RecCreate = @tDate
		, RecUserID = @iUserID
	Where Uniq In(Select Uniq From @tbUniqs)

	Set @sResponse = @sItemID_new
END -- @sResponse = ''

-- ----------------------------------------------------------------------------
Select @sResponse As Response