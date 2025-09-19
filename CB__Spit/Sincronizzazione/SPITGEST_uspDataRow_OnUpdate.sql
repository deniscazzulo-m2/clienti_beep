/*
*
*
* Uso: verifica congruità dei dati.
* Valore di ritorno: MIX (vedi documentazione tecnica)
* Per comporre la stringa @sReturnValues usare udfDataRow_append()
*
*	@iSession: numero di sessione, da cui sono ricavabili utente, lingua, …
*	@sFormName: nome del modulo.
*	@sDataName: nome dei dati gestiti, normalmente il nome della tabella.
*	@sDataValues: stringa composta di coppie campo-valore della riga in gestione, codificata:
*	[nomecampo1]valorecampo1<ASC5>[nomecampo2]valorecampo2<ASC5>
*	Il valore associato ad un campo può essere estratto con udfDataRow_value()
*	Per ogni campo vengono considerati i primi 64 bytes.
*
*   Personalizzata per la sincronizzazione
*
*/
CREATE PROCEDURE [uspDataRow_OnUpdate]
	@iSession int,
	@sFormName varchar(64),
	@sDataName varchar(64),
	@sDataValues nvarchar(MAX)
AS
SET NOCOUNT ON
Declare @bReturnMIX bit = 1
Declare @sReturnSEP char(1) = Char(6)
Declare @sReturnMSG varchar(2048) = ''
Declare @sReturnVALUES varchar(4096) = ''
Declare @sReturnSQL varchar(4096) = ''
Declare @sReturnSCRIPT varchar(4096) = ''

Declare @sEditID varchar(8)
Declare @sName varchar(128)
Declare @sValue varchar(64)
Declare @sValue1 varchar(64)
Declare @sValue2 varchar(64)
Declare @dValue decimal(19, 6)
Declare @dValue1 decimal(19, 6)
Declare @dValue2 decimal(19, 6)

Declare @sItemID varchar(64)
Declare @sItemType varchar(8)
Declare @sItemKind varchar(8)
Declare @sItemUse varchar(8)

Declare @iItemKind tinyint
Declare @iItemIDRif smallint
Declare @iEanAnaType tinyint

Declare @iCount int = 0
Declare @iUserID smallint
Declare @iNumero decimal(13)
Declare @sParName varchar(32)
Declare @iLen tinyint

Declare @iPar4010 tinyint
Declare @bForDefault bit
-- --------------------------------------------------
/****************************************************
ESEMPIO:
If @sDataName = 'MixAna'
	BEGIN
		If dbo.udfDataRow_value('cap', @sDataValues) = '12345'
			Set @sReturnMSG = '(SN)Il CAP non può essere 12345'
	END
****************************************************/
-- --------------------------------------------------
If @sDataName = 'AppEnviron'
BEGIN
	Set @sEditID = dbo.[udfDataRow_value]('ParEditID', @sDataValues)
	--0: testo, 1: numerico, 2: data, 3: orario, 4: boolean (Si/No)
	Set @sValue = dbo.[udfDataRow_value]('ParValue', @sDataValues)
	If (@sEditID In('1', '11')) And (IsNumeric(@sValue) = 0)
		Set @sReturnMSG = '(KO)Il valore del parametro deve essere numerico.'
	Else If (@sEditID In('2', '12')) And (@sValue <> '') And ((IsDate(@sValue) = 0) Or (Len(@sValue) <> 10))
		Set @sReturnMSG = '(KO)Il valore del parametro deve essere una data valida, indicata nel formato GG/MM/AAAA.'
	Else If (@sEditID In('4', '14')) And (@sValue Not In('0', '1', 'N', 'S', ''))
		Set @sReturnMSG = '(KO)Il valore del parametro deve essere N per indicare No, oppure S per indicare Si'

	If @sReturnMSG = ''
	Begin
		Set @sName = dbo.[udfDataRow_value]('ParName', @sDataValues)
		If (@sName Between '0010' And '0040') And (@sValue > '6')
				Set @sReturnMSG = '(KO)Il numero massimo di cifre decimali ammesso è 6.'
		If (@sName = '0041') And ((@sValue <> '1') And (@sValue <> '100') And (@sValue <> '1000'))
				Set @sReturnMSG = '(KO)Il rapporto tra misure e totale può essere 1, 100, 1000.'

		If (@sName = '0050')
		Begin
			-- definizione piano dei conti
			If dbo.[udfStrIsNumeric](@sValue) = 0
				Set @sReturnMSG = '(KO)La struttura del piano dei conti deve essere indicata con 3 o più caratteri numerici.'
			Else If dbo.[udfStrSum](@sValue) > 16
				Set @sReturnMSG = '(KO)La struttura del piano dei conti deve prevedere N livelli per un totale di 16 caratteri.'
			Else If (Len(@sValue) < 3)
				Set @sReturnMSG = '(KO)La struttura del piano dei conti deve essere composta da un minimo di 3 caratteri numerici.'
		End

		If (@sName = '0300')
		Begin
			If IsNull(@sValue, '') = ''
				Set @sReturnMSG = '(OK)In assenza di indicazioni verrà applicato il colore predefinito oppure scelto da ciascun utente. E` necessario chiudere e riavviare l`applicativo perchè questa modifica abbia effetto.'
			Else If Exists(Select ColorName From [BpDataSystem].dbo.[SystemColors] Where ColorName = @sValue)
				Set @sReturnMSG = '(OK)E` necessario chiudere e riavviare l`applicativo perchè questa modifica abbia effetto.'
			Else
				Set @sReturnMSG = '(KO)Il nome del colore non è valido, fare copia/incolla del nome dalla tabella Colori dal menù Strumenti.'
		End
	End
END -- AppEnviron

Else If @sDataName = 'PrdAna'
BEGIN
	Set @sItemID = dbo.[udfDataRow_value]('PrdCod', @sDataValues)
	If LTrim(RTrim(@sItemID)) = ''
	Begin
		Set @sParName = 'MixAna5'
		Execute [uspNumUniqNext_out] @sParName, @iNumero OUTPUT

		Set @sParName = '1005'
		Set @iLen = dbo.[udfEnvironRead_int](@sParName)
		Set @iLen = IsNull(@iLen, 0)
		If @iLen <= 0
			Set @iLen = 6

		Set @sItemID = Replace(Str(@iNumero, @iLen), ' ', '0')
		If Left(@sItemID, 1) = '*'
			Set @sReturnMSG = '(KO)E'' prevista l''assegnazione automatica del codice ma il valore progressivo previsto supera il numero di caratteri impostati nei parametri aziendali. E'' necessario digitare manualmente il nuovo codice.'
		Else If EXISTS(Select TOP 1 PrdCod From dbo.[PrdAna] Where PrdCod = @sItemID)
			Set @sReturnMSG = '(KO)E'' prevista l''assegnazione automatica del codice ma il valore progressivo previsto determina un duplicato. E'' necessario digitare manualmente il nuovo codice.'
		Else
			Set @sReturnValues = dbo.[udfDataRow_append](@sReturnValues, 'PrdCod', @sItemID)
	End


	If Left(@sItemID, 1) In('.', '!', '$', '@', '#', '%')
            Set @sReturnMSG = '(KO)Un codice prodotto non può iniziare con un punto o con ! $ @ # %'

	If @sReturnMSG = ''
	BEGIN
		Declare @sIvaCod varchar(8) = dbo.[udfDataRow_value]('IvaCod', @sDataValues)
		Declare @iPrdKind tinyint = dbo.[udfDataRow_value_int]('PrdKind', @sDataValues)

		If (IsNull(@sIvaCod, '') = '') And (IsNull(@iPrdKind, 0) <> 19)
			Set @sReturnMSG = '(KO)Il codice I.V.A. è obbligatorio a meno che il prodotto sia indicato come fittizio/descrittivo.'
	END

	If @sReturnMSG = ''
	BEGIN
		Declare @dQtaMin decimal(19, 6)
		Declare @iQtaUso int
		Declare @dQtaRap decimal(19, 6)

		Set @sValue = dbo.[udfDataRow_value]('QtaMin', @sDataValues)
		Set @dQtaMin = dbo.[udfC_Dec](@sValue)

		Set @sValue = dbo.[udfDataRow_value]('QtaMinUso', @sDataValues)
		Set @iQtaUso = dbo.[udfC_Int](@sValue)
		If @dQtaMin <> 0 And @iQtaUso > 1
		Begin
			Set @sValue = dbo.[udfDataRow_value]('PrdUm2Rap', @sDataValues)
			Set @dQtaRap = dbo.[udfC_Dec](@sValue)
			If @dQtaRap <> 0
			Begin
				Set @dValue = dbo.[udfC_Multiplo](@dQtaRap, @dQtaMin, 'QV')
				If @dQtaRap <> @dValue
				Begin
					Set @sReturnMSG = 'Il rapporto tra la U.M.Primaria e la U.M.Secondaria|non è un multiplo della quantità minima!'
      						+ '||Il multiplo più vicino è ' + dbo.[udfFormat](@dValue, 'QV')
					If @iQtaUso <> 2
						Set @sReturnMSG = '(KO)' + @sReturnMSG
				End
			End
		End
	END

	If @sReturnMSG = ''
	BEGIN
		Declare @iPrdUso tinyint = dbo.[udfDataRow_value_int]('PrdUso', @sDataValues)
		If (@iPrdUso Between 210 And 229)
		Begin
			-- @sItemID = PrdCod
			Select @iCount = Count(*)
			From dbo.[PrdAna]
			Where (IsNull(PrdCod, '') <> @sItemID)
				And (IsNull(PrdUso, 0) = @iPrdUso)

			Set @iCount = IsNull(@iCount, 0)
			If (@iCount > 0)
				Set @sReturnMSG = '(KO)Esiste già un codice-prodotto con <b>uso ' + Cast(@iPrdUso As varchar(8))
							+'</b>. E'' ammesso un unico codice-prodotto per ciascun uso compreso tra 210 e 229.'
		End
	END

END -- PrdAna

Else If @sDataName = 'MixAna'
BEGIN
	Set @sItemID = dbo.[udfDataRow_value]('ItemID', @sDataValues)
	Set @sItemType = dbo.[udfDataRow_value]('ItemType', @sDataValues)
	Set @sItemUse = dbo.[udfDataRow_value]('ItemUse', @sDataValues)
	-- ------------------------------------------------------------------------
	-- FEPA
	-- cliente - FepaType/FepaDest
	--
	Declare @sNumMat varchar(16) = dbo.[udfDataRow_value]('NumMat', @sDataValues)
	Declare @sFepaType varchar(8) = dbo.[udfDataRow_value]('FepaType', @sDataValues)
	Declare @sFepaDest  varchar(8) = dbo.[udfDataRow_value]('FepaDest', @sDataValues)
	Declare @sFepaEsgIva  varchar(8) = dbo.[udfDataRow_value]('FepaEsgIva', @sDataValues)

	Set @sFepaType = IsNull(@sFepaType, '')
	Set @sValue = dbo.[udfDataRow_value]('Naz', @sDataValues)
	If (@sItemType = '1')
	Begin
		Set @sFepaDest = IsNull(@sFepaDest, '')
		If @sFepaType = 'NO'
		Begin
			Set @sFepaDest = ''
			Set @sFepaEsgIva = ''
		End -- @sFepaType = 'NO'

		Else If (@sFepaType = 'FE')
		Begin
			If (@sFepaDest = '')
			Begin
				Set @sFepaDest = Case
					When (@sValue In('', 'IT', 'ITA', 'ITALIA', 'ITALY')) Then '0000000'
					Else 'XXXXXXX'
					End
			End
		End -- @sFepaType = 'FE'

		Else If (@sFepaType = 'PA')
		Begin
			If @sFepaDest <> ''
				Set @sNumMat = @sFepaDest
		End -- @sFepaType = 'PA'

		Set @sReturnSCRIPT = 'ValueSet("FepaType","' + @sFepaType + '")'
					+ '<BR>ValueSet("FepaDest","' + @sFepaDest + '")'
					+ '<BR>ValueSet("FepaEsgIva","' + @sFepaEsgIva + '")'
					+ '<BR>ValueSet("NumMat","' + @sNumMat + '")'
	End -- @sItemType = '1'
	-- FEPA END
	-- ------------------------------------------------------------------------

	If LTrim(RTrim(@sItemID)) = ''
	Begin
		Set @sParName = 'MixAna' + @sItemType
		Execute [uspNumUniqNext_out] @sParName, @iNumero OUTPUT

		Set @sParName = Cast(1000 + dbo.[udfC_TinyInt](@sItemType) As char(4))
		Set @iLen = dbo.[udfEnvironRead_int](@sParName)
		Set @iLen = IsNull(@iLen, 0)
		If @iLen <= 0
			Set @iLen = 5

		Set @sItemID = Replace(Str(@iNumero, @iLen), ' ', '0')
		If Left(@sItemID, 1) = '*'
			Set @sReturnMSG = '(KO)E'' prevista l''assegnazione automatica del codice ma il valore progressivo previsto supera il numero di caratteri impostati nei parametri aziendali. E'' necessario digitare manualmente il nuovo codice.'
			
		--PERS M2SISTEMI x SINCRONIZZATORE/SYNCHRONIZATION
		--Else If EXISTS(Select TOP 1 ItemID From [MixAna] Where ItemID = @sItemID And ItemType = @sItemType)
		Else If EXISTS(Select TOP 1 ItemID From [BpSPIT].dbo.[MixAna] Where ItemID = @sItemID And ItemType = @sItemType And @sItemType = 1) Or
			EXISTS(Select TOP 1 ItemID From [BpSTUDIOISOARDI].dbo.[MixAna] Where ItemID = @sItemID And ItemType = @sItemType And @sItemType = 1) Or
			EXISTS(Select TOP 1 ItemID From [BpSPITGEST].dbo.[MixAna] Where ItemID = @sItemID And ItemType = @sItemType)
			Set @sReturnMSG = '(KO)E'' prevista l''assegnazione automatica del codice ma il valore progressivo previsto determina un duplicato. E'' necessario digitare manualmente il nuovo codice.'
		Else
			Set @sReturnValues = dbo.[udfDataRow_append](@sReturnValues, 'ItemID', @sItemID)
	End

	If (@sReturnMSG = '') And (@sItemID <> '') And (@sItemUse = '13')
	BEGIN
		-- CASA MANDANTE
		--
		If Not EXISTS(
			Select ItemID
			From dbo.[MixAna]
			Where ItemID = @sItemID
				And ItemType = 1
			)
		Begin
			-- non ancora salvata come CLIENTE
			-- verifica fornitore già esistente
			If EXISTS(
				Select ItemID
				From dbo.[MixAna]
				Where ItemID = @sItemID
					And ItemType = 2
				)
			Begin
				Set @sReturnMSG = '(KO)Le case mandanti presuppongo la codifica sia come <b>cliente</b> che come <b>fornitore</b>. Esiste già un fornitore con codice "' + @sItemID + '", <b>assegnare un codice diverso</b> alla casa mandante.'
			End
		End
	END -- (@sReturnMSG = '') And (@sItemID <> '') And (@sItemUse = '13')

	If (@sReturnMSG = '')
	BEGIN
		Set @sValue1 = dbo.[udfDataRow_value]('PIva', @sDataValues)
		Set @sValue2 = dbo.[udfDataRow_value]('CFis', @sDataValues)
		If (@sValue1 = '') And (@sValue2 = '')
			Set @sReturnMSG = '(KO)Almeno uno tra Partita IVA e Codice Fiscale devono essere indicati. Se nessuno dei due dati è previsto, indicare la sigla n.a. (not available/applicable) nella Partita IVA.'
	END

	If (@sReturnMSG = '') And (@sItemType = '1') And (IsNull(@sFepaType, '') = '')
		Set @sReturnMSG = '(KO)Indicare il <b>tipo di fattura elettronica</b> da emettere a questo cliente.'

	If (@sReturnMSG = '')
	BEGIN
		Set @sValue = dbo.[udfDataRow_value]('Naz', @sDataValues)
		If @sValue In('', 'IT', 'ITALIA', 'ITALY')
		BEGIN
			Declare @iItemType tinyint = dbo.[udfC_int](@sItemType)

			Set @sValue1 = dbo.[udfDataRow_value]('PIva', @sDataValues)
			Set @sValue2 = dbo.[udfDataRow_value]('CFis', @sDataValues)

			If (@sValue1 Not In('', 'n.d.', 'n.a.'))
			Begin
				Set @sValue1 = Replace(@sValue1, 'IT', '')
				If dbo.[udfCFisPIvaOk](@sValue1) = 0
					Set @sValue1 = 'BAD'

				If @sValue1 <> 'BAD'
				Begin
					If Exists(
						Select Top 1 PIva
						From dbo.[MixAna]
						Where IsNull(ItemType, 0) = @iItemType
							And PIva = @sValue1
							And ItemID <> @sItemID
						)
						Set @sValue1 = 'DUP'
				End
			End

			If @sValue2 <> ''
			Begin
				If dbo.[udfCFisPIvaOk](@sValue2) = 0
					Set @sValue2 = 'BAD'

				If @sValue2 <> 'BAD'
				Begin
					If Exists(
						Select Top 1 CFis
						From dbo.[MixAna]
						Where IsNull(ItemType, 0) = @iItemType
							And CFis = @sValue2
							And ItemID <> @sItemID
						)
						Set @sValue2 = 'DUP'
				End
			End

			If @sValue1 = 'BAD'
				Set @sReturnMSG = '(KO)Numero di PARTITA I.V.A. non valido in base alla normativa italiana!'
			Else If @sValue2 = 'BAD'
				Set @sReturnMSG = '(KO)CODICE FISCALE non valido in base alla normativa italiana!'
			Else If (@sValue1 = 'DUP') And (@sValue2 = 'DUP')
				Set @sReturnMSG = '(NS)Sia PARTITA I.V.A. che CODICE FISCALE indicati su questa scheda sono già presenti in un''altra anagrafica. I duplicati sono da considerarsi validi?'
			Else If (@sValue1 = 'DUP')
				Set @sReturnMSG = '(NS)E'' già presente un''altra anagrafica con la PARTITA I.V.A indicata su questa scheda. Il duplicato é da considerarsi valido?'
			Else If (@sValue2 = 'DUP')
				Set @sReturnMSG = '(NS)E'' già presente un''altra anagrafica con il CODICE FISCALE indicato su questa scheda. Il duplicato é da considerarsi valido?'
		END -- In('', 'IT', 'ITALIA', 'ITALY')
	END -- @sReturnMSG = ''
END -- MixAna

Else If @sDataName = 'MixAnaAlias'
BEGIN
	Set @sItemID = dbo.[udfDataRow_value]('AliasID', @sDataValues)
	Set @sItemType = dbo.[udfDataRow_value]('AliasType', @sDataValues)
	If (@sItemType = '13')
		Begin
			Set @iEanAnaType = dbo.[udfDataRow_value_int]('ItemType', @sDataValues)
			If (LTrim(RTrim(@sItemID)) = '')
				Execute dbo.[uspEAN13_next_out] @iEanAnaType, @sItemID OUTPUT
			Else
				Begin
					If dbo.[udfStrIsNumeric](@sItemID) = 1
						Set @sItemID = dbo.[udfEAN13_add_check](Left(@sItemID, 12))
					Else
						Set @sReturnMSG = '(KO)Un codice definito come EAN13 deve essere composto esclusivamente da caratteri numerici!'
				End

			If @sReturnMSG = ''
				Set @sReturnValues = dbo.[udfDataRow_append](@sReturnValues, 'AliasID', @sItemID)
		End
END -- MixAnaAlias

Else If @sDataName = 'MixAnaRif'
BEGIN
	Set @iItemIDRif = dbo.[udfDataRow_value_int]('ItemIDRif', @sDataValues)
	If IsNull(@iItemIDRif, 0) = 0
	Begin
		Declare @sItemIDSede varchar(16) = dbo.[udfDataRow_value]('ItemIDSede', @sDataValues)
		Set @sItemID = dbo.[udfDataRow_value]('ItemID', @sDataValues)
		Set @iItemType = dbo.[udfDataRow_value_int]('ItemType', @sDataValues)

		Select @iItemIDRif = Max(ItemIDRif)
		From dbo.[MixAnaRif]
		Where ItemID = @sItemID
			And ItemType = @iItemType
			And IsNull(ItemIDSede, '') = IsNull(@sItemIDSede, '')

		Set @iItemIDRif = IsNull(@iItemIDRif, 0) + 1
		Set @sReturnValues = dbo.[udfDataRow_append](@sReturnValues, 'ItemIDRif', @iItemIDRif)
	End
END -- MixAnaRif

Else If @sDataName = 'PagTab'
BEGIN
	Declare @iIva smallint = dbo.[udfDataRow_value_int]('Iva', @sDataValues)
	Declare @sBonusCpt varchar(16) = dbo.[udfDataRow_value]('BonusCpt', @sDataValues)
	If IsNull(@iIva, 0) = 4 And IsNull(@sBonusCpt, '') = ''
		Set @sReturnMSG = '(KO)Per la gestione del <b>bonus</b> (I.V.A. = 4) è necessario indicare il <b>Conto credito</b> (conto erario crediti di imposta).||Se non si indica la <b>percentuale</b> sarà considerata del 50%.'
END -- PagTab

Else If @sDataName = 'CntGrp'
BEGIN
	Declare @sSplit varchar(16) = dbo.[udfEnvironRead]('0050')
	Declare @iItemLiv smallint = dbo.[udfDataRow_value_int]('ItemLiv', @sDataValues)
	Declare @iItemSez tinyint = dbo.[udfDataRow_value_int]('ItemSez', @sDataValues)
	Declare @iItemLen int

	If @iItemLiv > Len(@sSplit)
		Set @sReturnMSG = '(KO)Il livello nella gerarchia dei codici non è valido, è superiore alla definizione della struttura dei piano dei conti definita nei parametri aziendali!'

	If @sReturnMSG = ''
	Begin
		Set @sItemID = dbo.[udfDataRow_value]('ItemID', @sDataValues)
		Set @iItemLen = dbo.[udfStrSum](Substring(@sSplit, 1, @iItemLiv))
		If (Len(@sItemID) <> @iItemLen)
			Set @sReturnMSG = '(KO)Il codice ed il livello non sono coerenti con la struttura del piano del conti, per il livello indicato il codice deve essere composto da ' + LTrim(Str(@iItemLen)) + ' caratteri/cifre!'
	End

	If @sReturnMSG = ''
	Begin
		If (@iItemSez Not In(0, 3)) And (dbo.[udfDataRow_value_bit]('ItemND', @sDataValues) <> 0)
			Set @sReturnMSG = '(KO)La colonna "Costo non deducibile" può essere spuntata soltanto per i conti che si riferiscono a costi!'
	End

	If @sReturnMSG = ''
	Begin
		If (@iItemLiv <> Len(@sSplit)) And (dbo.[udfC_Int](dbo.[udfDataRow_value]('ItemUse', @sDataValues)) <> 0)
			Set @sReturnMSG = '(KO)La colonna "Uso" può essere valorizzata soltanto per conti all`ultimo livello!'
	End
END -- CntGrp

Else If (@sDataName = 'CntRegMod')
BEGIN
	Declare @iDocTipDefault tinyint = dbo.[udfDataRow_value]('DocTipDefault', @sDataValues)
	If @iDocTipDefault <> 0
	Begin
		Set @sItemID = dbo.[udfDataRow_value]('ItemID', @sDataValues)

		If EXISTS(
			Select ItemID
			From dbo.[CntRegMod]
			Where ItemID <> @sItemID
				And IsNull(DocTipDefault, 0) = @iDocTipDefault
			)
		Begin
			Set @sReturnMSG = '(KO)E'' già presente un modello con uso predefinito ' + Cast(@iDocTipDefault As varchar(8)) + '.'
		End
	End
END -- CntRegMod

Else If @sDataName = 'CespitiAna'
BEGIN
	Set @sItemID = dbo.[udfDataRow_value]('ItemID', @sDataValues)

	If LTrim(RTrim(@sItemID)) = ''
	Begin
		Set @sParName = 'MixAna7'
		Execute [uspNumUniqNext_out] @sParName, @iNumero OUTPUT

		Set @sParName = '1007'
		Set @iLen = dbo.[udfEnvironRead_int](@sParName)
		Set @iLen = IsNull(@iLen, 0)
		If @iLen <= 0
			Set @iLen = 5

		Set @sItemID = Replace(Str(@iNumero, @iLen), ' ', '0')
		If Left(@sItemID, 1) = '*'
			Set @sReturnMSG = '(KO)E'' prevista l''assegnazione automatica del codice ma il valore progressivo previsto supera il numero di caratteri impostati nei parametri aziendali. E'' necessario digitare manualmente il nuovo codice.'
		Else If EXISTS(Select TOP 1 ItemID From dbo.[CespitiAna] Where ItemID = @sItemID)
			Set @sReturnMSG = '(KO)E'' prevista l''assegnazione automatica del codice ma il valore progressivo previsto determina un duplicato. E'' necessario digitare manualmente il nuovo codice.'
		Else
			Set @sReturnValues = dbo.[udfDataRow_append](@sReturnValues, 'ItemID', @sItemID)
	End

	If @sReturnMSG = ''
	Begin
		Declare @sCspCat varchar(16) = dbo.[udfDataRow_value]('CspCat', @sDataValues)
		Declare @sCspTip char(1) = dbo.[udfDataRow_value]('CspTip', @sDataValues)

		Select @sItemType = ItemType
		From [CespitiCat]
		Where ItemID = @sCspCat

		If @sItemType <> @sCspTip
			Set @sReturnMSG = '(KO)Il tipo di cespite non è coerente con la categoria!'
	End

	If @sReturnMSG = ''
		Begin
			Set @sValue1 = dbo.[udfDataRow_value]('DtaUso', @sDataValues)
			Set @sValue2 = dbo.[udfDataRow_value]('DocDtaA', @sDataValues)
			If dbo.[udfDate_compare](@sValue1, @sValue2) < 0
				Set @sReturnMSG = '(KO)La data di entrata in funzione non può essere anteriore alla data di acquisto!'
		End

	If @sReturnMSG = ''
		Begin
			Set @sValue1 = dbo.[udfDataRow_value]('ImpAmm', @sDataValues)
			Set @sValue2 = dbo.[udfDataRow_value]('PrzAcq', @sDataValues)

			Set @dValue1 = dbo.[udfC_Dec](@sValue1)
			Set @dValue2 = dbo.[udfC_Dec](@sValue2)
			If @dValue1 > @dValue2
				Set @sReturnMSG = '(KO)L`importo ammortizzabile non può essere maggiore del prezzo di acquisto!'
		End

END -- CespitiAna

Else If (@sDataName = 'UserAna')
BEGIN
	Set @sItemID = dbo.[udfDataRow_value]('Barcode', @sDataValues)
	If (LTrim(RTrim(@sItemID)) = '')
	Begin
		Set @iUserID = dbo.[udfDataRow_value_int]('UserID', @sDataValues)
		Set @sItemID = dbo.[udfUserBarcode](@iUserID)
		Set @sReturnValues = dbo.[udfDataRow_append](@sReturnValues, 'Barcode', @sItemID)
	End
END -- UserAna

Else If (@sDataName = 'BanInfo')
BEGIN
	Set @sItemID = dbo.[udfDataRow_value]('BanCod', @sDataValues)
	Set @iNumero =  dbo.[udfDataRow_value_int]('ItemID', @sDataValues)
	If @iNumero = 0
	Begin
		Select @iNumero = Max(ItemID)
		From dbo.[BanInfo]
		Where BanCod = @sItemID

		Set @iNumero = IsNull(@iNumero, 0) + 1
		Set @sReturnValues = dbo.[udfDataRow_append](@sReturnValues, 'ItemID', @iNumero)
	End
END -- UserAna


Else If (@sDataName = 'PrdMag')
BEGIN
	Set @sItemID = dbo.[udfDataRow_value]('PosMagBC', @sDataValues)
	If (LTrim(RTrim(@sItemID)) = '')
	Begin
		Set @iEanAnaType = 149
		Execute dbo.[uspEAN13_next_out] @iEanAnaType, @sItemID OUTPUT
	End
	Else
		Begin
			If dbo.[udfStrIsNumeric](@sItemID) = 1
				Set @sItemID = dbo.[udfEAN13_add_check](Left(@sItemID, 12))
			Else
				Set @sReturnMSG = '(KO)Il barcode è di tipo EAN13, deve essere composto esclusivamente da caratteri numerici!'
		End

	If @sReturnMSG = ''
		Set @sReturnValues = dbo.[udfDataRow_append](@sReturnValues, 'PosMagBC', @sItemID)
END -- PrdMag

Else If (@sDataName = 'PrdFor')
BEGIN
	Set @bForDefault = dbo.[udfDataRow_value_bit]('ItemDefault', @sDataValues)
	Set @sValue1 = dbo.[udfDataRow_value]('PrdCod', @sDataValues)
	Set @sValue2 = dbo.[udfDataRow_value]('ForCod', @sDataValues)


	Set @iPar4010 = dbo.[udfEnvironRead_int]('4010')
	If @iPar4010 In(1, 2, 11, 21, 101, 201, 111, 211)
	Begin
		Set @dValue1 = dbo.[udfDataRow_value_dec]('PrdPrz', @sDataValues, 'PA')
		Set @dValue2 = dbo.[udfDataRow_value_dec]('PrdPrz2', @sDataValues, 'PA')
		If (@bForDefault = 1) And (@sValue1 <> '') And (@sValue2 <> '') And (@dValue1 > 0)
			Execute dbo.[uspPrdPrz_update_byfor] @iSession, 0, @iPar4010, @sValue1, @sValue2, @dValue1, @dValue2
	End

	Select @iCount = Count(*)
	From dbo.[PrdFor]
	Where (IsNull(PrdCod, '') = @sValue1)
		And (IsNull(ForCod, '') <> @sValue2)
		And (IsNull(ItemDefault, 0) = 1)

	Set @iCount = IsNull(@iCount, 0)
	Set @bForDefault = IsNull(@bForDefault, 0)
	If (@iCount > 0) And (@bForDefault = 1)
		Set @sReturnMSG = '(KO)Soltanto uno tra i fornitori può essere indicato come fornitore predefinito/abituale!'
END -- PrdFor


Else If (@sDataName In('VndPro', 'PrdForPromo'))
BEGIN
	Declare @sCliCod varchar(16) = dbo.[udfDataRow_value]('CliCod', @sDataValues)
	Declare @sCliCat varchar(32) = dbo.[udfDataRow_value]('CliCat', @sDataValues)
	Declare @sPrdCod varchar(32) = dbo.[udfDataRow_value]('PrdCod', @sDataValues)
	Declare @sGrpCod varchar(32) = dbo.[udfDataRow_value]('GrpCod', @sDataValues)
	Declare @sCatCod varchar(32) = dbo.[udfDataRow_value]('CatCod', @sDataValues)
	Declare @sTreeCod varchar(16) = dbo.[udfDataRow_value]('TreeCod', @sDataValues)

	Set @sCliCod = LTrim(RTrim(IsNull(@sCliCod, '')))
	Set @sCliCat = LTrim(RTrim(IsNull(@sCliCat, '')))
	Set @sPrdCod = LTrim(RTrim(IsNull(@sPrdCod, '')))
	Set @sGrpCod = LTrim(RTrim(IsNull(@sGrpCod, '')))
	Set @sCatCod = LTrim(RTrim(IsNull(@sCatCod, '')))
	Set @sTreeCod = LTrim(RTrim(IsNull(@sTreeCod, '')))

	-- codice cliente esclude categoria-cliente e viceversa.
	-- codice prodotto esclude gruppo/categoria/classificazione prodotto e viceversa.
	-- codice classificazione-prodotto esclude codice/gruppo/categoria prodotto.
	-- in presenza di codice categoria-prodotto é obbligatorio il codice gruppo-prodotto.
	If (@sDataName = 'VndPro') And (@sCliCod <> '') And (@sCliCat <> '')
		Set @sReturnMSG = '(KO)Codice e categoria cliente si escludono a vicenda, indicare uno solo dei due!'

	If (@sReturnMSG = '') And (@sPrdCod <> '') And ((@sGrpCod + @sCatCod + @sTreeCod) <> '')
		Set @sReturnMSG = '(KO)Il codice-prodotto esclude gruppo/categoria/classificazione, indicare il solo codice-prodotto oppure uno o più tra i codici gruppo/categoria/classificazione!'

	If (@sReturnMSG = '') And (@sTreeCod <> '') And ((@sGrpCod + @sCatCod + @sPrdCod) <> '')
		Set @sReturnMSG = '(KO)La classificazione-prodotto esclude gruppo/categoria e codice-prodotto, indicare il solo codice-classificazione, oppure il solo codice-prodotto oppure uno o più tra i codici gruppo e categoria!'

	If (@sReturnMSG = '') And (@sCatCod <> '') And (@sGrpCod = '')
		Set @sReturnMSG = '(KO)In presenza di categoria-prodotto é obbligatorio indicare il gruppo-prodotto!'


	If (@sReturnMSG = '') And (@sDataName = 'PrdForPromo')
	Begin
		Set @iPar4010 = dbo.[udfEnvironRead_int]('4010')
		If @iPar4010 In(11, 12, 111, 211)
		Begin
			Set @sValue1 = dbo.[udfDataRow_value]('PrdCod', @sDataValues)
			Set @sValue2 = dbo.[udfDataRow_value]('ForCod', @sDataValues)

			Set @bForDefault = 0
			Select @bForDefault = ItemDefault
			From dbo.[PrdFor]
			Where PrdCod = @sValue1
				And ForCod = @sValue2

			Set @bForDefault = IsNull(@bForDefault, 0)
			If @bForDefault = 1
			Begin
				Set @dValue1 = 0
				Set @dValue2 = dbo.[udfDataRow_value_dec]('PrdPrz', @sDataValues, 'PA')
				If (@bForDefault = 1) And (@sValue1 <> '') And (@sValue2 <> '') And (@dValue2 > 0)
					Execute dbo.[uspPrdPrz_update_byfor] @iSession, 1, @iPar4010, @sValue1, @sValue2, @dValue1, @dValue2
			End
		End


	End -- PrdForPromo ONLY
END -- VndPro, PrdForPromo

Else If (@sDataName = 'VndProLin')
BEGIN
	Set @sValue = dbo.[udfDataRow_value]('PrdSc', @sDataValues)
	Set @dValue = dbo.[udfDataRow_value_dec]('PrdPrz', @sDataValues, 'PV')

	If (LTrim(RTrim(@sValue )) = '') And (@dValue = 0)
		Set @sReturnMSG = '(KO)Non può esistere una promozione senza né prezzo né sconto, indicare uno dei due in base ai criteri di applicazione dell''offerta!'

	If @sReturnMSG = ''
	Begin
		Set @sValue = dbo.[udfDataRow_value]('PrdCod', @sDataValues)

		-- ---------------------------------------------------------------------
		-- versione con gestione dei caratteri jolly
		-- cerca primo codice-prodotto convertendo carattery jolly
		--
		If (CHARINDEX('*', @sValue) > 0) Or (CHARINDEX('?', @sValue) > 0) Or (CHARINDEX('[', @sValue) > 0)
		Begin
			Set @sValue2 = @sValue
			Set @sValue = ''
			Select TOP 1 @sValue = PrdCod
			From dbo.[PrdAna]
			Where (PrdCod Like Replace(Replace(@sValue2, '*', '%'), '?', '_'))

			Set @sValue = IsNull(@sValue, '')
		End

		If (@sValue <> '')
		Begin
			Set @dValue = dbo.[udfDataRow_value_dec]('PrdQta', @sDataValues, 'QV')
			Set @dValue1 = dbo.[udfPrdCod_QTA](@sValue, '', 0)
			If @dValue < @dValue1
				Set @sReturnMSG = '(KO)La quantità dell''offerta non può essere inferiore alla quantità minima di vendita!'
		End

		-- ---------------------------------------------------------------------
		--
		-- versione SENZA gestione dei caratteri jolly
		--
		--		If (CHARINDEX('*', @sValue) = 0) And (CHARINDEX('?', @sValue) = 0) And (CHARINDEX('[', @sValue) = 0)
		--		Begin
		--			Set @dValue = dbo.[udfDataRow_value_dec]('PrdQta', @sDataValues, 'QV')
		--			Set @dValue1 = dbo.[udfPrdCod_QTA](@sValue, '', 0)
		--			If @dValue < @dValue1
		--				Set @sReturnMSG = '(KO)La quantità dell''offerta non può essere inferiore alla quantità minima di vendita!'
		--		End
	End
END -- VndProLin


Else If (@sDataName = 'LogNetwork')
BEGIN
	Set @sValue1 = dbo.[udfDataRow_value]('PosEcrIP', @sDataValues)
	Set @sValue2 = dbo.[udfDataRow_value]('PosEcrSerial', @sDataValues)

	If (LTrim(RTrim(@sValue1 )) <> '') And (LTrim(RTrim(@sValue2 )) = '')
		Execute dbo.[uspSendMessage] '[SUGGERIMENTO]E'' opportuno indicare subito il numero di matricola fiscale. E'' possibile ricavare la matricola utilizzando il pannello di controllo ECR.'
END -- LogNetwork

Else If (@sDataName = 'DocDef')
BEGIN
	If dbo.[udfDataRow_value]('DocTip', @sDataValues) = '18'
	Begin
		Set @sValue1 = dbo.[udfDataRow_value]('DocUserDefault', @sDataValues)
		Set @sValue2 = dbo.[udfDataRow_value]('DocUserAllow', @sDataValues)

		If (LTrim(RTrim(@sValue1 )) <> '') Or (LTrim(RTrim(@sValue2 )) <> '')
			Execute dbo.[uspSendMessage] '(AT)[IMPORTANTE]Per gli scontrini le impostazioni su prefisso/suffisso predefiniti vanno assegnate per ciascun PC nei parametri operativi accessibili dal menù P.O.S. - QUANTO INDICATO QUI in merito agli utenti E'' IGNORATO.'
	End
END -- DocDef

Else If @sDataName = 'MagAnaItem'
BEGIN
	Set @iItemKind = dbo.[udfDataRow_value_int]('ItemKind', @sDataValues)
	If IsNull(@iItemKind, 0) In(1, 2)
	Begin
		Declare @iItemV smallint = dbo.[udfDataRow_value_int]('ItemV', @sDataValues)
		Declare @iItemH smallint = dbo.[udfDataRow_value_int]('ItemH', @sDataValues)
		If (IsNull(@iItemV, 0) = 0) Or (IsNull(@iItemH, 0) = 0)
			Set @sReturnMSG = '(KO)Per scaffali e cassettiere è necessario indicare sia il numero di posizioni verticali che il numero di posizioni orizzontali.'
	End
END -- MagAnaItem


Else If @sDataName = 'WorkItemRif'
BEGIN
	Set @iItemIDRif = dbo.[udfDataRow_value_int]('ItemIDRif', @sDataValues)
	If IsNull(@iItemIDRif, 0) = 0
	Begin
		Set @sItemID = dbo.[udfDataRow_value]('ItemID', @sDataValues)
		Set @iItemType = dbo.[udfDataRow_value_int]('ItemType', @sDataValues)

		Select @iItemIDRif = Max(ItemIDRif)
		From dbo.[WorkItemRif]
		Where ItemID = @sItemID
			And ItemType = @iItemType

		Set @iItemIDRif = IsNull(@iItemIDRif, 0) + 1
		Set @sReturnValues = dbo.[udfDataRow_append](@sReturnValues, 'ItemIDRif', @iItemIDRif)
	End
END -- WorkItemRif

Else If @sDataName In('WorkTool', 'WorkStaff')
BEGIN
	Set @sItemType = dbo.[udfDataRow_value]('ItemType', @sDataValues)
	Set @sItemKind = dbo.[udfDataRow_value]('ItemKind', @sDataValues)
	Set @sItemID = dbo.[udfDataRow_value]('ItemID', @sDataValues)
	Set @sItemID = LTrim(RTrim(@sItemID))

	If @sItemID <> ''
	Begin
		If Left(@sItemID, 1) In('.', '!', '$', '@', '#', '%')
				Set @sReturnMSG = '(KO)Il codice non può iniziare con un punto o con ! $ @ # %'
		Else If Charindex(':', @sItemID) > 0
				Set @sReturnMSG = '(KO)Il codice non può contenere :  (due punti)'
	End

	If @sReturnMSG = ''
	Begin
		-- BARCODE
		Declare @sBarcode varchar(16) = dbo.[udfDataRow_value]('Barcode', @sDataValues)
		Set @iEanAnaType = dbo.[udfC_Int](@sItemType)
		If (LTrim(RTrim(@sBarcode)) = '')
			Execute dbo.[uspEAN13_next_out] @iEanAnaType, @sBarcode OUTPUT
		Else
		Begin
			If dbo.[udfStrIsNumeric](@sBarcode) = 1
				Set @sBarcode = dbo.[udfEAN13_add_check](Left(@sBarcode, 12))
			Else
				Set @sReturnMSG = '(KO)Un codice definito come EAN13 deve essere composto esclusivamente da caratteri numerici!'
		End
		If @sReturnMSG = ''
			Set @sReturnValues = dbo.[udfDataRow_append](@sReturnValues, 'Barcode', @sBarcode)
	End

	If (@sReturnMSG = '') And (@sItemID <> '') And (@sDataName = 'WorkTool')
	Begin
		Set @iItemKind = dbo.[udfC_TinyInt](@sItemKind)
		Execute dbo.[uspWorkToolFeatureTemplate] @iSession, 1, @iItemKind, @sItemID
	End
END -- WorkTool, WorkStaff


Else If @sDataName = 'WorkPCycleStep'
BEGIN
	Declare @sStepID varchar(16) = dbo.[udfDataRow_value]('StepID', @sDataValues)
	Declare @iStepRowID int = dbo.[udfDataRow_value]('StepRowID', @sDataValues)
	Declare @sStepMandatory varchar(64) = ''

	If @sStepID <> ''
	Begin
		Select @sStepMandatory = StepMandatory
		From dbo.[WorkPStep]
		Where StepID = @sStepID

		Set @sStepMandatory = IsNull(@sStepMandatory, '')
	End

	If (@sStepMandatory <> '')
	BEGIN
		Set @sStepMandatory = ',' + @sStepMandatory + ','
		Set @sReturnMSG = ''

		--
		--1 StepMachineID: Macchina
		--2 StepStaffID: Operatore
		--3 StepTimeSS: Durata
		--4 StepForCod: Terzista
		--5 StepForService: Codice servizio del terzista
		--6 StepPrdCod: Prodotto di riferimento o semilavorato
		--7 StepTools: Attrezzi, utensili, strumenti
		--
		--QP: StepQPlanID: Piano di controllo qualità
		--CR: StepCostRule: Specifiche di calcolo costi
		--CF: StepCost: Costo fisso

		If (@sStepMandatory Like '%,1,%')
		Begin
			Set @sValue = dbo.[udfDataRow_value]('StepMachineID', @sDataValues)
			If IsNull(@sValue, '') = ''
				Set @sReturnMSG = '(KO)Il codice della <b>macchina</b> è obbligatorio.'
		End

		If (@sReturnMSG = '') And (@sStepMandatory Like '%,2,%')
		Begin
			Set @sValue = dbo.[udfDataRow_value]('StepStaffID', @sDataValues)
			If IsNull(@sValue, '') = ''
				Set @sReturnMSG = '(KO)Il codice dell''<b>operatore</b> è obbligatorio.'
		End

		If (@sReturnMSG = '') And (@sStepMandatory Like '%,3,%')
		Begin
			Set @dValue = dbo.[udfDataRow_value_dec]('StepTimeSS', @sDataValues, '2')
			If IsNull(@dValue, 0) = 0
				Set @sReturnMSG = '(KO)L''indicazione della <b>durata</b> è obbligatoria.'
		End

		If (@sReturnMSG = '') And (@sStepMandatory Like '%,4,%')
		Begin
			Set @sValue = dbo.[udfDataRow_value]('StepForCod', @sDataValues)
			If IsNull(@sValue, '') = ''
				Set @sReturnMSG = '(KO)Il codice del <b>terzista</b> è obbligatorio.'
		End

		If (@sReturnMSG = '') And (@sStepMandatory Like '%,5,%')
		Begin
			Set @sValue = dbo.[udfDataRow_value]('StepForService', @sDataValues)
			If IsNull(@sValue, '') = ''
				Set @sReturnMSG = '(KO)Il codice del <b>servizio</b> fornito dal terzista è obbligatorio.'
		End

		If (@sReturnMSG = '') And (@sStepMandatory Like '%,6,%')
		Begin
			Set @sValue = dbo.[udfDataRow_value]('StepPrdCod', @sDataValues)
			If IsNull(@sValue, '') = ''
				Set @sReturnMSG = '(KO)Il codice del <b>prodotto</b> di riferimento o semilavorato è obbligatorio.'
		End

		If (@sReturnMSG = '') And (@sStepMandatory Like '%,7,%')
		Begin
			Set @sValue = dbo.[udfDataRow_value]('StepTools', @sDataValues)
			If IsNull(@sValue, '') = ''
				Set @sReturnMSG = '(KO)L''indicazione degli <b>attrezzi/utensili/strumenti</b> è obbligatoria.'
		End

		If (@sStepMandatory Like '%,QP,%')
		Begin
			Set @sValue = dbo.[udfDataRow_value]('StepQPlanID', @sDataValues)
			If IsNull(@sValue, '') = ''
				Set @sReturnMSG = '(KO)Il piano di <b>controllo qualità</b> è obbligatorio.'
		End

		If (@sReturnMSG = '') And (@sStepMandatory Like '%,CR,%')
		Begin
			Set @sValue = dbo.[udfDataRow_value]('StepCostRule', @sDataValues)
			If IsNull(@sValue, '') = ''
				Set @sReturnMSG = '(KO)Le specifiche di <b>calcolo costi</b> sono obbligatorie.'
		End

		If (@sReturnMSG = '') And (@sStepMandatory Like '%,CF,%')
		Begin
			Set @dValue = dbo.[udfDataRow_value_dec]('StepCost', @sDataValues, '2')
			If IsNull(@dValue, 0) = 0
				Set @sReturnMSG = '(KO)L''indicazione del <b>costo fisso</b> è obbligatoria.'
		End

		--
		-- FORMULE
		-- LE FORMULE NON SONO PRESENTI NELLA GRIGLIA e devono essere lette dalla tabella WorkPCycleStep in base a StepRowID
		--
		--F1: StepFormulaTime: Formula durata
		--F2: StepFormulaStaff: Formula costo manodopera
		--F3: StepFormulaMachine: Formula costo macchina
		--F4: StepFormulaTools: Formula costo attrezzi
		--F5: StepFormulaExtern: Formula costo esterno, terzista
		--

		If (@sReturnMSG = '') And (@sStepMandatory Like '%,F1,%')
		Begin
			Set @sValue = ''
			Select @sValue = StepFormulaTime
			From dbo.[WorkPCycleStep]
			Where StepRowID = @iStepRowID

			If IsNull(@sValue, '') = ''
				Set @sReturnMSG = '(KO)La <b>Formula per la durata della fase</b> è obbligatoria.'
		End

		If (@sReturnMSG = '') And (@sStepMandatory Like '%,F2,%')
		Begin
			Set @sValue = ''
			Select @sValue = StepFormulaStaff
			From dbo.[WorkPCycleStep]
			Where StepRowID = @iStepRowID

			If IsNull(@sValue, '') = ''
				Set @sReturnMSG = '(KO)La <b>Formula per il costo manodopera</b> è obbligatoria.'
		End

		If (@sReturnMSG = '') And (@sStepMandatory Like '%,F3,%')
		Begin
			Set @sValue = ''
			Select @sValue = StepFormulaMachine
			From dbo.[WorkPCycleStep]
			Where StepRowID = @iStepRowID

			If IsNull(@sValue, '') = ''
				Set @sReturnMSG = '(KO)La <b>Formula per il costo macchina</b> è obbligatoria.'
		End

		If (@sReturnMSG = '') And (@sStepMandatory Like '%,F4,%')
		Begin
			Set @sValue = ''
			Select @sValue = StepFormulaTools
			From dbo.[WorkPCycleStep]
			Where StepRowID = @iStepRowID

			If IsNull(@sValue, '') = ''
				Set @sReturnMSG = '(KO)La <b>Formula per il costo attrezzi</b> è obbligatoria.'
		End

		If (@sReturnMSG = '') And (@sStepMandatory Like '%,F5,%')
		Begin
			Set @sValue = ''
			Select @sValue = StepFormulaExtern
			From dbo.[WorkPCycleStep]
			Where StepRowID = @iStepRowID

			If IsNull(@sValue, '') = ''
				Set @sReturnMSG = '(KO)La <b>Formula per il costo esterno/terzista</b> è obbligatoria.'
		End
	END --  @sStepMandatory <> ''
END -- WorkPCycleStep


-- ====================================================================
If @bReturnMIX = 1
Begin
	Select IsNull(@sReturnMSG, '')
			+ @sReturnSEP + IsNull(@sReturnVALUES, '')
			+ @sReturnSEP + IsNull(@sReturnSQL , '')
			+ @sReturnSEP + IsNull(@sReturnSCRIPT, '') As Mix
End