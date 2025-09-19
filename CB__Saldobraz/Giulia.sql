/*
*
*	Ritorna elenco dati derivati da documento
*	per report basati su etichette a composizione dinamica
*
*	@iLabelQty		numero di etichette per ciascun documento/riga
*					-1 = Numero di etichette = numero di colli
*					-2 = Numero di etichette = numero di righe presenti nel documento
*					-3 = Numero di etichette = quantità prodotto presente sulla riga
*	@iLabelQtyBlank	numero di etichette bianche di separazione
*	@iDocTip		tipo di documento
*	@iDocUniq		numero unico di documento, ignorato se @sDocUniqLins <> ''
*	@sDocUniqLins	elenco di Uniq di righe documento, separati da virgola, ha prevalenza su @iDocUniq
*					NOTA: le righe DEVONO APPARTENERE ALLO STESSO DOCUMENTO
*
*	@sParams		'TextLeft'
*
*/
CREATE PROCEDURE [dbo].[uspRpt_Labels_DOC_Pers]
	@iSession int,
	@sRptID varchar(64),
	@iLabelQty smallint,
	@iLabelQtyBlank tinyint,
	@iDocTip tinyint,
	@iDocUniq int,
	@sDocUniqLins varchar(MAX),
	@sParams varchar(128)
AS
SET NOCOUNT ON

Declare @tbRptData TABLE(
	[RptData] nvarchar(MAX) NULL,
	[RptBarcode] varchar(64) NULL,
	[RptImage] varbinary(MAX) NULL,
	[UniqRow] int IDENTITY
	)

Declare @iCount smallint = 0
Declare @iLabel_count smallint = 0
Declare @iTextLeft smallint = 0
Declare @sItemID varchar(32)
Declare @sRptLabelText nvarchar(MAX)
Declare @sRptData nvarchar(MAX)

Declare @sSql_1 varchar(1024)  = ''
Declare @sSql varchar(1024)  = ''
Declare @sFields varchar(2048) = ''

Declare @sField varchar(64) = ''
Declare @sValue varchar(256) = ''
Declare @sBarcode varchar(64) = ''
Declare @sFieldQuoted varchar(64) = ''

Declare @sUniqDoc varchar(16) = ''
Declare @sUniqLin varchar(16) = ''
Declare @sAnaCod varchar(16) = ''
Declare @sDsmCod varchar(16) = ''

Declare @iAnaType tinyint = dbo.[udfDocTip_AnaType](@iDocTip)
Declare @sTable_DOC varchar(64) = dbo.[udfDocTip_TableName](@iDocTip, 1)
Declare @sTable_DOCLIN varchar(64) = dbo.[udfDocTip_TableName](@iDocTip, 3)

Declare @sFields_DOC varchar(2048) = 'DocTip,DocNum,DocDta'

Declare @sFields_DOCLIN varchar(1024) = 'A.LinNum,A.PrdCod,A.PrdParams,A.PrdDes,A.PrdUm,A.PrdQta,A.LinRif,A.Tm,B.GrpCod,C.PosMag'

Declare @sSql_DOC varchar(1024) = 'Declare cCursor_2 Cursor FAST_FORWARD For'
								+ ' Select Cast(IsNull({FIELD}, '''') As varchar(256)) '
								+ ' From dbo.[' + @sTable_DOC + ']'
								+ ' Where Uniq = {UNIQ}'

Declare @sSql_DOCLIN varchar(1024) = 'Declare cCursor_2 Cursor FAST_FORWARD For'
								+ ' Select Cast(IsNull({FIELD}, '''') As varchar(256)) '
								+ ' From dbo.[' + @sTable_DOCLIN + '] A Join dbo.[PrdAna] B On A.[PrdCod] = B.[PrdCod]'
								+ ' Join dbo.[PrdMag] C On B.[PrdCod] = C.[PrdCod] And C.[MagCod] = ''LOCALE'''
								+ ' Where Uniq = {UNIQ}'


Set @sDocUniqLins = IsNull(@sDocUniqLins, '')
Set @sParams = IsNull(@sParams, '')
Set @iLabelQty = IsNull(@iLabelQty, 0)
Set @iLabelQtyBlank = IsNull(@iLabelQtyBlank, 0)

Set @iTextLeft = dbo.[udfC_SmallInt](dbo.[udfStrTokenN](@sParams, 1, ','))

Select @sRptLabelText = RptLabelText
From [BpDataSystem].dbo.[SystemReports]
Where RptID = @sRptID

Set @sRptData = @sRptLabelText

Set @sFieldQuoted = '[DocSigla]'
If (CharIndex(@sFieldQuoted, @sRptData) > 0)
Begin
	Declare @sSigla varchar(8) = dbo.[udfDocTip_DocSigla](@iDocTip)
	Set @sRptData = Replace(@sRptData, @sFieldQuoted, @sSigla)
End
-- ===================================================================
--
-- DOCUMENTO
--
If @sDocUniqLins = ''
Begin
	Set @sUniqDoc = Cast(@iDocUniq As varchar(16))
End
Else
Begin
	Set @sUniqLin = dbo.[udfStrTokenN](@sDocUniqLins, 1, ',')
	Set @sSql_1 = 'Declare cCursor_2 Cursor FAST_FORWARD For'
			+ ' Select Cast(UniqDoc As varchar(16)) As UniqDoc'
			+ ' From dbo.[' + @sTable_DOCLIN + ']'
			+ ' Where Uniq = ' + @sUniqLin
	Execute(@sSql_1)
	Open [cCursor_2]
	Fetch Next From [cCursor_2] Into @sUniqDoc
	Close [cCursor_2]
	Deallocate [cCursor_2]

End
-- --------------------------------------------------------
-- DOC
Set @sSql = @sSql_DOC
Set @sFields = @sFields_DOC
Declare [cCursor_1] Cursor LOCAL FAST_FORWARD For
Select Token
From dbo.[udfStrSplit](@sFields, ',')
Open [cCursor_1]
Fetch Next From [cCursor_1] Into @sField
While (@@Fetch_Status <> -1)
BEGIN
	Set @sFieldQuoted = '[' + @sField + ']'
	If (CharIndex(@sFieldQuoted, @sRptData) > 0)
	Begin
		Set @sSql_1 = @sSql
		Set @sSql_1 = Replace(@sSql_1, '{FIELD}', @sField)
		Set @sSql_1 = Replace(@sSql_1, '{UNIQ}', @sUniqDoc)

		Set @sValue = ''
		Execute(@sSql_1)
		Open [cCursor_2]
		Fetch Next From [cCursor_2] Into @sValue
		Close [cCursor_2]
		Deallocate [cCursor_2]

		Set @sValue = IsNull(@sValue, '')
		If @sValue <> ''
		Begin
			If @sField In('DocDta', 'ForDocDta')
				Set @sValue = Convert(varchar(10), Cast(@sValue As date), 103)
			Else
				If (@iTextLeft > 0) Set @sValue = Left(@sValue, @iTextLeft)
		End

		Set @sRptData = Replace(@sRptData, @sFieldQuoted, @sValue)
	End
	Fetch Next From [cCursor_1] Into @sField
END -- cCursor_1
Close [cCursor_1]
Deallocate [cCursor_1]


-- ===================================================================
If @sDocUniqLins = ''
BEGIN
	-- Numero di etichette = numero di righe presenti nel documento
	--
	Set @sSql_1 = 'Declare cCursor_2 Cursor FAST_FORWARD For'
		+ ' Select Count(Uniq)'
		+ ' From dbo.[' + @sTable_DOCLIN + ']'
		+ ' Where UniqDoc = ' + @sUniqDoc

	Set @sValue = ''
	Execute(@sSql_1)
	Open [cCursor_2]
	Fetch Next From [cCursor_2] Into @iLabelQty
	Close [cCursor_2]
	Deallocate [cCursor_2]

	Set @iLabelQty = IsNull(@iLabelQty, 0)
	If @iLabelQty <= 0
		Set @iLabelQty = 1

	Set @iCount = 1
	Set @iLabel_count = 0
	While @iCount <= @iLabelQty
	Begin
		Set @iLabel_count += 1

		INSERT @tbRptData(RptData, RptBarcode)
		VALUES (Replace(@sRptData, '[Label]', Cast(@iLabel_count As varchar(8))),
				@sBarcode
				)
		Set @iCount += 1
	End

	Set @iCount = 1
	While @iCount <= @iLabelQtyBlank
	Begin
		INSERT @tbRptData(RptData, RptBarcode) VALUES ('', '')
		Set @iCount += 1
	End
END -- @sDocUniqLins = ''

ELSE

BEGIN
	--
	-- DETTAGLIO MERCE
	--
	Declare @iQty smallint = @iLabelQty

	Set @sRptLabelText = @sRptData
	Set @sSql = @sSql_DOCLIN
	Set @sFields = @sFields_DOCLIN

	Declare [cCursor] Cursor LOCAL FAST_FORWARD For
	Select Token
	From dbo.[udfStrSplit](@sDocUniqLins, ',')
	Where IsNull(Token, '') <> ''
	Order By Pos
	Open [cCursor]
	Fetch Next From [cCursor] Into @sUniqLin
	While (@@Fetch_Status <> -1)
	BEGIN
		Set @sUniqLin = LTrim(RTrim(@sUniqLin))
		Set @sRptData = @sRptLabelText

		-- --------------------------------------------------------
		-- DOCLIN
		Declare [cCursor_1] Cursor LOCAL FAST_FORWARD For
		Select Token
		From dbo.[udfStrSplit](@sFields, ',')
		Open [cCursor_1]
		Fetch Next From [cCursor_1] Into @sField
		While (@@Fetch_Status <> -1)
		BEGIN
			Set @sFieldQuoted = '[' + @sField + ']'
			If (CharIndex(@sFieldQuoted, @sRptData) > 0)
			Begin
				Set @sSql_1 = @sSql_DOCLIN
				Set @sSql_1 = Replace(@sSql_1, '{FIELD}', @sField)
				Set @sSql_1 = Replace(@sSql_1, '{UNIQ}', @sUniqLin)

				Set @sValue = ''
				Execute(@sSql_1)
				Open [cCursor_2]
				Fetch Next From [cCursor_2] Into @sValue
				Close [cCursor_2]
				Deallocate [cCursor_2]

				Set @sValue = IsNull(@sValue, '')
				If @sField Like '%.PrdQta'
					Set @sValue = dbo.[udfRpt_Format](Cast(@sValue As decimal(19, 6)), '2')
				Else
					If (@iTextLeft > 0) Set @sValue = Left(@sValue, @iTextLeft)


				If (@iTextLeft > 0) And (@sValue <> '')
					Set @sValue = Left(@sValue, @iTextLeft)

				Set @sRptData = Replace(@sRptData, @sFieldQuoted, @sValue)
			End
			Fetch Next From [cCursor_1] Into @sField
		END -- cCursor_1
		Close [cCursor_1]
		Deallocate [cCursor_1]

		-- ----------------------------------------------------
		-- LABELs

		Set @iLabelQty = IsNull(@iLabelQty, 0)
		If @iLabelQty <= 0
			Set @iLabelQty = 1

		Set @iCount = 1
		Set @iLabel_count = 0
		While @iCount <= @iLabelQty
		Begin
			Set @iLabel_count += 1

			INSERT @tbRptData(RptData, RptBarcode)
			VALUES (Replace(@sRptData, '[Label]', Cast(@iLabel_count As varchar(8))),
					@sBarcode
					)

			Set @iCount += 1
		End

		Set @iCount = 1
		While @iCount <= @iLabelQtyBlank
		Begin
			INSERT @tbRptData(RptData, RptBarcode) VALUES ('', '')
			Set @iCount += 1
		End

		----------------------------------------------------------
		Fetch Next From [cCursor] Into @sUniqLin
	END -- cCursor
	Close [cCursor]
	Deallocate [cCursor]
END -- @sDocUniqLins <> ''

-- ----------------------------------------------------------
Select
	UniqRow,
	RptData,
	RptBarcode,
	RptImage
From @tbRptData
Order By UniqRow