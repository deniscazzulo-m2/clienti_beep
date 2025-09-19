/* 
*
*	Inserimento rapido nuovo cliente per POS
*
*	@iStep	0: verifiche preliminari, ritorna messaggio
*			1: inserisce o aggiorna anagrafica, ritorna AnaCod - !ERR + messaggio in caso di errore
*
*   Personalizzata per la sincronizzazione
*
*/
CREATE PROCEDURE [dbo].[uspPOS_MixAna_save]
	@iSession int,
	@iStep tinyint,
	@sDataValues varchar(MAX)
AS
SET NOCOUNT ON
Declare @iDocUniq int = dbo.[udfDataRow_value_int]('DocUniq', @sDataValues)

Declare @sAnaCod varchar(16) = dbo.[udfDataRow_value]('AnaCod', @sDataValues)
Declare @sAnaNom nvarchar(256) = dbo.[udfDataRow_value]('AnaNom', @sDataValues)
Declare @sAnaCAP varchar(16) = dbo.[udfDataRow_value]('AnaCAP', @sDataValues)
Declare @sAnaInd nvarchar(256) = dbo.[udfDataRow_value]('AnaInd', @sDataValues)
Declare @sAnaPro varchar(16) = dbo.[udfDataRow_value]('AnaPro', @sDataValues)
Declare @sAnaLoc nvarchar(128) = dbo.[udfDataRow_value]('AnaLoc', @sDataValues)
Declare @sAnaPIva varchar(16) = dbo.[udfDataRow_value]('AnaPIva', @sDataValues)
Declare @sAnaCFis varchar(16) = dbo.[udfDataRow_value]('AnaCFis', @sDataValues)

Declare @iEmiFtRiep tinyint = dbo.[udfDataRow_value_int]('EmiFtRiep', @sDataValues)
Declare @bEmiDocWe tinyint = dbo.[udfDataRow_value_int]('EmiDocWe', @sDataValues)
Declare @sPagCod varchar(16) = dbo.[udfDataRow_value]('PagCod', @sDataValues)

Declare @sFepaType varchar(8) = dbo.[udfDataRow_value]('FepaType', @sDataValues)
Declare @sFepaEsgIva varchar(8) = dbo.[udfDataRow_value]('FepaEsgIva', @sDataValues)
Declare @sFepaDest varchar(8) = dbo.[udfDataRow_value]('FepaDest', @sDataValues)
Declare @sFepaPEC varchar(256) = dbo.[udfDataRow_value]('FepaPEC', @sDataValues)

Set @iStep = IsNull(@iStep, 0)
If @iStep = 0
BEGIN
	-- verifiche preliminari, ritorna messaggio
	--
	Declare @sMsg varchar(1024) = ''
	
	If IsNull(@sAnaNom, '') = ''
		Set @sMsg = 'Indicare il nominativo o la ragione sociale del cliente!'
	Else If IsNull(@sAnaInd, '') = ''
		Set @sMsg = 'Inserire l''indirizzo!'
	Else If IsNull(@sAnaCAP, '') = ''
		Set @sMsg = 'Inserire il codice di avviamento postale!'
	Else If IsNull(@sAnaLoc, '') = ''
		Set @sMsg = 'Inserire la località/città!'
	Else If IsNull(@sAnaPro, '') = ''
		Set @sMsg = 'Inserire la sigla della provincia!'
	Else If (IsNull(@sPagCod, '') = '')
		Set @sMsg = 'Inserire il codice del pagamento!'
	Else If (IsNull(@sAnaPIva, '') = '') And (IsNull(@sAnaCFis, '') = '')
		Set @sMsg = 'Indicare la Partita IVA oppure il Codice Fiscale!'
	
	If (@sMsg = '') And (IsNull(@sFepaDest, '') = '') And (IsNull(@sFepaPEC, '') = '')
		Set @sMsg = 'Indicare il codice-destinatario oppure l''indirizzo PEC per il recapito della fattura elettronica'
	
	If @sMsg = ''
	Begin
		If IsNull(@sAnaPIva, '') <> ''
		Begin
			If @sAnaPIva Like 'IT%'
				Set @sAnaPIva = Right(@sAnaPIva, 11)
		
			If dbo.[udfCFisPIvaOk](@sAnaPIva) = 0
				Set @sMsg = 'Numero di PARTITA IVA non valido in base alla normativa italiana. Se il cliente è estero indicare il prefisso dello stato estero.'			
		End
	End
	
	If @sMsg = ''
	Begin
		If IsNull(@sAnaCFis, '') <> ''
		Begin
			If dbo.[udfCFisPIvaOk](@sAnaCFis) = 0
				Set @sMsg = 'CODICE FISCALE non valido in base alla normativa italiana. Se il cliente è estero non indicare alcun codice.'			
		End
	End

	If @sMsg = ''
	Begin
		If IsNull(@sFepaDest, '') <> ''
		Begin
			If (@sFepaType = 'PA') And (Len(@sFepaDest) <> 6)
				Set @sMsg = 'Per una fattura elettronica PA il codice-destinatario deve essere di 6 caratteri.'
			Else If (@sFepaType = 'FE') And (Len(@sFepaDest) <> 7)
				Set @sMsg = 'Per una fattura elettronica B2B/B2C il codice-destinatario deve essere di 7 caratteri.'
		End
	End

	
	Select @sMsg As Msg
END -- @iStep = 0

Else If @iStep = 1
BEGIN
	-- inserisce, ritorna AnaCod (AnaCod = '!ERR' + MESSAGGIO in caso di errore)
	--
	Declare @iUserID smallint = dbo.[udfSysUserID](@iSession)
	Declare @tDate date = GetDate()
	Declare @sItemID varchar(1024) = ''	-- può contenere messaggio

	Set @sAnaCod = IsNull(@sAnaCod, '')
	If @sAnaCod = ''
	Begin	
		Declare @sItemType varchar(3) = '1'
		Declare @sParName varchar(16) = 'MixAna' + @sItemType
		Declare @iNumero int = 0
		Declare @iLen int = 0

		Execute dbo.[uspNumUniqNext_out] @sParName, @iNumero OUTPUT

		Set @sParName = Cast(1000 + dbo.[udfC_TinyInt](@sItemType) As char(4))
		Set @iLen = dbo.[udfEnvironRead_int](@sParName)
		Set @iLen = IsNull(@iLen, 0)
		If @iLen <= 0
			Set @iLen = 5

		Set @sItemID = Replace(Str(@iNumero, @iLen), ' ', '0')
		If Left(@sItemID, 1) = '*'
			Set @sItemID = '!ERR E'' prevista l''assegnazione automatica del codice ma il valore progressivo previsto supera il numero di caratteri impostati nei parametri aziendali. E'' necessario intervenire sui parametri.'
		
		--PERS M2SISTEMI x SINCRONIZZATORE/SYNCHRONIZATION
		--Else If EXISTS(Select TOP 1 ItemID From dbo.[MixAna] Where ItemID = @sItemID And ItemType = @sItemType)
		Else If EXISTS(Select TOP 1 ItemID From [BpSPIT].dbo.[MixAna] Where ItemID = @sItemID And ItemType = @sItemType) Or
				EXISTS(Select TOP 1 ItemID From [BpSTUDIOISOARDI].dbo.[MixAna] Where ItemID = @sItemID And ItemType = @sItemType) Or
				EXISTS(Select TOP 1 ItemID From [BpSPITGEST].dbo.[MixAna] Where ItemID = @sItemID And ItemType = @sItemType)
			Set @sItemID = '!ERR E'' prevista l''assegnazione automatica del codice ma il valore progressivo previsto determina un duplicato. E'' necessario intervenire sull''anagrafica clienti.'
		Else
		Begin
			Set @sAnaCod = @sItemID
			
			Insert dbo.[MixAna](
				  ItemType
				, ItemUse
				, ItemID
				, ItemHide
				, RecCreate, RecUserID, RecChange, RecChangeUserID
				, RecType
				, RecDate						
				)
			Values(
				  1
				, 10
				, @sAnaCod
				, 0
				, @tDate, @iUserID, @tDate, @iUserID
				, 10 -- RISTORANTE
				, @tDate
				)
		End
	End -- @sAnaCod = ''
	
	If Left(@sItemID, 4) <> '!ERR'
	Begin
		-- UPDATE
		--
		Update dbo.[MixAna] Set
			  ItemDes = @sAnaNom
			, Ind = @sAnaInd
			, Cap = @sAnaCAP
			, Loc = @sAnaLoc
			, Pro = @sAnaPro
			, Reg = ''
			, Naz = 'ITALIA'
			, PIva = @sAnaPIva
			, CFis = @sAnaCFis
			
			, EmiFtRiep = @iEmiFtRiep
			, EmiDocWe = @bEmiDocWe
			, PagCod = @sPagCod
			
			, FepaType = @sFepaType
			, FepaEsgIva = @sFepaEsgIva
			, FepaDest = @sFepaDest
			, FepaPEC = @sFepaPEC
		Where ItemID = @sAnaCod
			And ItemType = 1
			
		Update dbo.[PosDoc] Set
			  AnaType = 1
			, AnaCod = @sAnaCod
			, PagCod = @sPagCod
			, SegueFt = Case When IsNull(@iEmiFtRiep, 0) <> 0 Then 1 Else 0 End
		Where Uniq = @iDocUniq			
	End -- NOT !ERR
	
	Select @sItemID As AnaCod
END -- @iStep = 1