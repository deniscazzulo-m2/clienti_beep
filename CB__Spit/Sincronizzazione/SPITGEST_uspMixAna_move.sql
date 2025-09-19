/* 
*	Sposta cliente/fornitore da potenziale a reale e viceversa
*
*	Ritorna il codice anagrafico di destinazione (nullo se é impossibile procedere)
*	seguito da '|' + eventuale messaggio
*
*	Se Ok il record del codice originale risulterà eliminato
*
*   Personalizzata per la sincronizzazione
*/
CREATE PROCEDURE [dbo].[uspMixAna_move]
	@iItemType tinyint,
	@sItemID varchar(16),
	@sItemID_new varchar(16)
AS
SET NOCOUNT ON
Declare @sResponse varchar(1204) = ''
Declare @iItemType_new tinyint = 0
Declare @iItemUse_new tinyint = 0

If @iItemType = 19
BEGIN
	-- cliente potenziale
	Declare @iCount int = 0
	
	Select @iCount = Count(Uniq)
	From dbo.[CliOff]
	Where (IsNull(DocKind, 0) = 19)
		And (IsNull(AnaType, 0) = 19)
		And (AnaCod = @sItemID)
	
	If IsNull(@iCount, 0) <> 0
		Set @sResponse = '|Per il cliente potenziale ' + @sItemID + ' sono presenti <b>offerte</b>, convertire oppure eliminare le offerte.'	
END

If (@sResponse = '')
BEGIN
	Declare @bUsed bit = dbo.[udfMixAnaID_used](@iItemType, @sItemID)
	If @bUsed <> 0
		Set @sResponse = '|Il codice '
					+ Case When @iItemType = 1 Then 'cliente ' Else 'fornitore ' End + @sItemID
					+ ' é stato utilizzato in documenti o registrazioni, non può essere eliminato!'
END

If (@sResponse = '')
BEGIN
	-- 1: Cliente
	--19: Cliente potenziale
	-- 2: Fornitore
	--29: Fornitore potenziale
	Set @iItemType_new = Case @iItemType
							When 1 Then 19
							When 19 Then 1
							When 2 Then 29
							When 29 Then 2
						End
	
	Set @iItemUse_new = Case @iItemType_new
							When 1 Then 10
							When 19 Then 10
							When 2 Then 20
							When 29 Then 20
						End
	
	If @sItemID_new = ''
	Begin
		Declare @sItemType_new varchar(3) = Cast(@iItemType_new As varchar(3))
		Declare @sParName varchar(32) = 'MixAna' + @sItemType_new
		Declare @iLen int = 0
		Declare @iNumero int = 0
		
		Execute [uspNumUniqNext_out] @sParName, @iNumero OUTPUT
		
		Set @sParName = Cast(1000 + dbo.[udfC_TinyInt](@sItemType_new) As char(4))
		Set @iLen = dbo.[udfEnvironRead_int](@sParName)
		Set @iLen = IsNull(@iLen, 0)
		If @iLen <= 0
			Set @iLen = 5
		
		Set @sItemID_new = Replace(Str(@iNumero, @iLen), ' ', '0')
		If Left(@sItemID_new, 1) = '*'
			Set @sResponse = '|Il valore progressivo del nuovo codice supera il numero di caratteri impostati nei parametri aziendali. E'' necessario modificare il parametro oppure provvedere manualmente alla copia dei dati anagrafici.'
		
		--PERS M2SISTEMI x SINCRONIZZATORE/SYNCHRONIZATION
		--Else If EXISTS(Select TOP 1 ItemID From dbo.[MixAna] Where ItemID = @sItemID_new And ItemType = @iItemType_new)
		Else If EXISTS(Select TOP 1 ItemID From [BpSPIT].dbo.[MixAna] Where ItemID = @sItemID_new And ItemType = @iItemType_new And @iItemType_new = 1) Or
				EXISTS(Select TOP 1 ItemID From [BpSTUDIOISOARDI].dbo.[MixAna] Where ItemID = @sItemID_new And ItemType = @iItemType_new And @iItemType_new = 1) Or
				EXISTS(Select TOP 1 ItemID From [BpSPITGEST].dbo.[MixAna] Where ItemID = @sItemID_new And ItemType = @iItemType_new)
			Set @sResponse = '|Il valore progressivo del nuovo codice determina un duplicato. Provvedere manualmente alla copia dei dati anagrafici.'
	End
END
	
If @sResponse = ''
Begin
	--
	-- OK
	--
	
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
		
	
	Set @sResponse = @sItemID_new + '|'
End


Select @sResponse As Response