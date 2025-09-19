/* 
*	Gestione letture barcode
*
*	@iAction	0: ritorna TermID, TermComSettings da LogNetwork
*				1: salva TermComSettings = @sParams in LogNetwork
*				2: salva TermParams = @sParams in LogNetwork
*
*				5, 6: elabora dati in @sParams, ritorna ElabID
*					5: raggruppa su PrdCod, somma QTA
*					6: NON raggruppa, NON somma
*				15, 16: come 5, 6 con forzatura della quantità = 1
*
*				8: imposta flag ElabOk = 0
*				9: verifica i dati elaborati, imposta flag ElabOk
*
*/
CREATE PROCEDURE [dbo].[uspTermDataElab_Pers]
	@iSession int,
	@iAction tinyint,
	@iElabID int,
	@sParams varchar(MAX)
AS
SET NOCOUNT ON
Declare @sPcName varchar(256) = dbo.[udfSysPcName](@iSession)
--Declare @sLanguage varchar(8) = dbo.[udfSysLanguage](@iSession)
Declare @sElabRif varchar(128)

If @iAction = 0
BEGIN
-- 0: ritorna TermID, TermComSettings da LogNetwork
	Select TermID, TermComSettings, TermParams
	From dbo.[LogNetwork]
	Where PcName = @sPcName
END

Else If @iAction = 1
BEGIN
-- 1: salva TermComSettings = @sParams in LogNetwork
	Update dbo.[LogNetwork] Set
		TermComSettings = @sParams
	Where PcName = @sPcName
END

Else If @iAction = 2
BEGIN
-- 2: salva TermParams = @sParams in LogNetwork
	Update dbo.[LogNetwork] Set
		TermParams = @sParams
	Where PcName = @sPcName
END

Else If @iAction In(5, 6, 15, 16)
BEGIN
	-- Elabora dati in @sParams, ritorna ElabID
	--
	Declare @tElabDta date = dbo.[udfSysDate]()
	Declare @sElabTime varchar(16) = dbo.[udfSysTime]()
	Declare @iUserID smallint = dbo.[udfSysUserID](@iSession)
	Declare @sUserName varchar(64) = dbo.[udfSysUserID_Name](@iUserID)
	Declare @sAsc5 char(1) = char(5)
	Declare @iTermID int = 0
	Declare @iElabType tinyint = 0
	
	Declare @sToken varchar(32)
	Declare @iTokenLen smallint
	
	Declare @bBarcodeOk bit 
	Declare @sPrdAlert varchar(32)
	Declare @sPrdCod varchar(32)
	Declare @sPrdCodBC varchar(32)
--	Declare @sPrdSerial varchar(32)
--	Declare @sPrdLotto varchar(32)
	Declare @sPrdDes nvarchar(2048)
	Declare @sPrdUm varchar(8)
	Declare @dPrdQta decimal(19, 6)
	-- -----------------------------------------------------
	Declare @bPrdHide bit
	Declare @sPrdTip varchar(8)
	-- -----------------------------------------------------
	Declare @sPrdCodBC_temp varchar(16)
	Declare @sPrdQta_temp varchar(16)	
	-- -----------------------------------------------------
	-- 5: raggruppa su PrdCod, somma QTA
	-- 6: NON raggruppa, NON somma QTA
	-- 15, 16: come 5,6 con forzatura QTA = 1
	--
	Declare @iCountSum int = 0
	Declare @bQtaSum bit = 0
	Declare @bQta1 bit = 0
	
	If @iAction In(5, 15)
		Set @bQtaSum = 1
		
	If @iAction In(15, 16)
		Set @bQta1 = 1

	-- -----------------------------------------------------	

	Declare @tbDataLin TABLE(
		[ElabID] int NULL,
		[PrdAlert] varchar(32) NULL,
		[PrdCod] varchar(32) NULL,
		[PrdCodBC] varchar(32) NULL,
		[PrdSerial] varchar(32) NULL,
		[PrdLotto] varchar(32) NULL,
		[PrdDes] nvarchar(2048) NULL,
		[PrdUm] varchar(8) NULL,
		[PrdQta] decimal(19, 6) NULL,
		[UniqRow] int IDENTITY
		)

	Select @iTermID = TermID, @iElabType = TermElabType
	From dbo.[LogNetwork]
	Where PcName = @sPcName
	
	--
	--	ricava ElabID da TermDataElab, scrive record in TermDataElab
	--
	Set @iElabType = IsNull(@iElabType, 0)
	Set @iElabID = 0
	SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
	BEGIN TRAN
		Select @iElabID = Max(ElabID)
		From dbo.[TermDataElab]
		
		Set @iElabID = IsNull(@iElabID, 0) + 1
		
		Set @sElabRif = 'Lettura ' + Cast(@iElabID As varchar(8)) + ' - ' + IsNull(@sUserName, '')
		
		INSERT dbo.[TermDataElab](ElabID, ElabDta, ElabTime, ElabRif, ElabOk, TermID, PcName, ElabUserID)
		VALUES(@iElabID, @tElabDta, @sElabTime, @sElabRif, 0, @iTermID, @sPcName, @iUserID)
	COMMIT TRAN

	Set @sParams = IsNull(@sParams, '')
	Set @sParams = Replace(@sParams, char(13), @sAsc5)
	Set @sParams = Replace(@sParams, char(10), @sAsc5)

	Declare [cCursor] Cursor LOCAL FAST_FORWARD For
	Select Token
	From dbo.[udfStrSplit](@sParams, @sAsc5)
	Order By Pos

	Set @bBarcodeOk = 0
	Set @sPrdCodBC = ''
	Set @dPrdQta = 0
	Open [cCursor]
	Fetch Next From [cCursor] Into @sToken
	While (@@Fetch_Status <> -1)
	BEGIN
		-- @iElabType
		-- 	0: Standard, flusso codice + quantità (CR-LF separatore)
		-- 10: Flusso codice + quantità concatenate (righe di 18, 19, 21, 22 bytes)
		--
		Set @sToken = IsNull(@sToken, '')
		Set @sToken = LTrim(RTrim(@sToken))
		Set @iTokenLen = Len(@sToken)
		If @iTokenLen > 0
		BEGIN
			If @iElabType = 0
			BEGIN
				--
				-- STANDARD, flusso codice + quantità (CR-LF separatore)
				--
				If (CHARINDEX('/', @sToken) > 0) And (IsDate(@sToken) = 1)
				Begin
					-- DATE --> exclude
					Set @sToken = @sToken
				End
				Else If (CHARINDEX(':', @sToken) > 0)
				Begin
					-- TIME  --> exclude
					Set @sToken = @sToken
				End
				Else If (@iTokenLen < 8) And (IsNumeric(@sToken) = 1) And (@bBarcodeOk = 1)
				Begin
					-- QTA
					Set @dPrdQta = dbo.[udfC_Dec](@sToken)
					Set @bBarcodeOk = 0
				End
				Else
				Begin
					-- BARCODE				
					Set @sPrdCodBC = @sToken
					Set @bBarcodeOk = 1
					If @bQta1 = 1
						Set @dPrdQta = 1
				End
			END -- @iElabType = 0

			Else If (@iElabType = 10) And (@iTokenLen In(18, 19, 21, 22))
			BEGIN
				--
				-- Flusso codice + quantità concatenate (righe di 18, 19, 21, 22 bytes)
				--
				Set @sPrdCodBC = ''
				Set @sPrdCodBC_temp = Left(@sToken, 13)
				If @iTokenLen = 18
					Set @sPrdQta_temp = SubString(@sToken, 14, 5)

				Else If @iTokenLen = 19
					Set @sPrdQta_temp = SubString(@sToken, 14, 6)

				Else If @iTokenLen = 21
					Set @sPrdQta_temp = Replace(SubString(@sToken, 14, 8), ',', '.')

				Else
					Set @sPrdQta_temp = Replace(SubString(@sToken, 14, 9), ',', '.')
	
				If (IsNumeric(@sPrdCodBC_temp) = 1) And (IsNumeric(@sPrdQta_temp) = 1)
				Begin
					Set @sPrdCodBC = @sPrdCodBC_temp
					Set @dPrdQta = Cast(@sPrdQta_temp As decimal(19, 6))
				End					
			END -- @iElabType = 10			
			
			
			If (@sPrdCodBC <> '') And (@dPrdQta > 0)
			Begin
				-- INSERT
				--
				Set @sPrdAlert = ''
				Set @sPrdCod = ''
				Set @sPrdDes = ''
				Set @sPrdUm = ''
				
				Set @bPrdHide = 0
				Set @sPrdTip = ''

				Select @sPrdCod = ItemID
				From dbo.[MixAnaAlias]
				Where AliasID = @sPrdCodBC
					And ItemType = 5

				Set @sPrdCod = IsNull(@sPrdCod, '')
				
				--INIZIO PERS M2SISTEMI
				If @sPrdCod = ''
				Begin
					Set @sPrdCod = @sPrdCodBC
					Set @sPrdCodBC = '(?)'
				End
				--FINE PERS M2SISTEMI

				If @sPrdCod <> ''
				Begin
					Select 
						@sPrdDes = PrdDes,
						@sPrdUm = PrdUM,
						@bPrdHide = PrdHide,
						@sPrdTip = PrdTip
					From dbo.[PrdAna]
					Where PrdCod = @sPrdCod
					
					Set @sPrdDes = IsNull(@sPrdDes, '')
					Set @sPrdUm = IsNull(@sPrdUm, '')
					Set @bPrdHide = IsNull(@bPrdHide, 0)
					Set @sPrdTip = IsNull(@sPrdTip, '')
				End
				
				If @sPrdCod = ''
				Begin
					Set @sPrdCod = '(? sconociuto)'
					Set @sPrdAlert = '!!! SCONOSCIUTO'
				End
				Else
				Begin
					If @bPrdHide = 1
						Set @sPrdAlert = '!!! DISATTIVATO'
				End
								
				If @sPrdDes = ''
				Begin
					Set @sPrdDes = '(?)'
					If @sPrdAlert = ''
						Set @sPrdAlert = '!? descrizione'
				End
					
				If @sPrdUm = ''
				Begin
					Set @sPrdUm = '(?)'
					If @sPrdAlert = ''
						Set @sPrdAlert = '!? unità di misura'
				End

				INSERT @tbDataLin(
					ElabID,
					PrdAlert,
					PrdCod,
					PrdCodBC,
					PrdDes,
					PrdUm,
					PrdQta
					)
				VALUES (
					@iElabID,
					@sPrdAlert,
					@sPrdCod,
					@sPrdCodBC,
					@sPrdDes,
					@sPrdUm,
					@dPrdQta
					)

				Set @sPrdCodBC = ''
				Set @dPrdQta = 0
			End
		END -- @iTokenLen > 0
		-- ----------------------------------------------------------
		Fetch Next From [cCursor] Into @sToken
	END
	Close [cCursor]
	Deallocate [cCursor]


	-- --------------------------------------------------------------
	Set @iCountSum = 0
	
	Select TOP 1 @iCountSum = Count(PrdCodBC)
	From @tbDataLin
	Group By PrdCodBC
	Order By Count(PrdCodBC) DESC
	
	Set @iCountSum = IsNull(@iCountSum, 0)
	If @iCountSum < 2
		Set @bQtaSum = 0
	-- --------------------------------------------------------------

	If @bQtaSum = 1 -- RAGGRUPPA
	Begin
		INSERT dbo.[TermDataElabLin](
			ElabID,
			PrdAlert,
			PrdCod,
			PrdCodBC,
			PrdDes,
			PrdUm,
			PrdQta
			)
		SELECT 
			@iElabID As ElabID,
			Max(PrdAlert) As PrdAlert,
			Max(PrdCod) As PrdCod,
			PrdCodBC,
			Max(PrdDes) As PrdDes,
			Max(PrdUm) As PrdUm,
			Sum(IsNull(PrdQta, 0)) As PrdQta
		FROM @tbDataLin
		GROUP BY PrdCodBC
		ORDER BY PrdCodBC

	End
	Else -- @iAction = 6 NON RAGGRUPPA
	Begin
		INSERT dbo.[TermDataElabLin](
			ElabID,
			PrdAlert,
			PrdCod,
			PrdCodBC,
			PrdDes,
			PrdUm,
			PrdQta
			)
		SELECT 
			@iElabID As ElabID,
			PrdAlert,
			PrdCod,
			PrdCodBC,
			PrdDes,
			PrdUm,
			PrdQta
		FROM @tbDataLin
		ORDER By UniqRow
	End
	
	Select @iElabID As ElabID	
END -- @iAction 5, 6, 15, 16


Else If @iAction = 8
BEGIN
	-- 8: imposta flag ElabOk = 0
	--
	Update dbo.[TermDataElab] Set
		ElabOk = 0
	Where ElabID = @iElabID
END -- @iAction = 8

Else If @iAction = 9
BEGIN
	-- 9: verifica i dati elaborati, imposta flag ElabOk = 1
	--
	Declare @sMsg varchar(2048) = ''
	Declare @bElabOk bit = 0
	
	Select @sElabRif = ElabRif
	From dbo.[TermDataElab]
	Where ElabID = @iElabID
	
	Set @sElabRif = IsNull(@sElabRif, '')
	If @sElabRif = ''
		Set @sMsg = 'Digitare un riferimento utile ad identificare l''origine dei dati letti dal terminale.'
	Else
	Begin
		If EXISTS(
				Select UniqRow	
				From dbo.[TermDataElabLin]
				Where ElabID = @iElabID
					And IsNull(PrdAlert, '') <> ''
				) Set @sMsg = 'Una o più righe derivate dalla lettura dei barcode contengono <b>segnalazioni</b>. E'' possibile convalidare una lettura cancellando il testo della segnalazione.'
	End
	
	If @sMsg = ''
		Set @bElabOk = 1
		
	Update dbo.[TermDataElab] Set
		ElabOk = @bElabOk
	Where ElabID = @iElabID

	-- ------------------------
	Select @sMsg As Smg
END -- @iAction = 9