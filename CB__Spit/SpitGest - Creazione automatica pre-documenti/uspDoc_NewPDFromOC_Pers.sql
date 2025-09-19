/*
*	Genera nuovo documento da altro
*	Valore di ritorno: MIX - ReturnUNIQ valorizzato, stringa nulla indica KO
*
*	---------------------------------------------------------------------
*	@iSession: numero di sessione, da cui sono ricavabili utente, lingua, …
*
*/
CREATE PROCEDURE [uspDoc_NewPDFromOC_Pers]
	@iSession int,
	@iUniqDocFrom int
AS
SET NOCOUNT ON
Declare @sReturnSEP char(1) = Char(6)
Declare @sReturnUNIQ varchar(32) = ''
Declare @sReturnMSG varchar(2048) = ''
Declare @iDocTipNew tinyint = 13
Declare @sTableID varchar(64) = dbo.[udfDocTip_TableID](@iDocTipNew)

-- ----------------------------------------------------------------------------------
-- ====================================================================
-- VENDITE/ACQUISTI
--
--
--	3: dettaglio

Declare @sTable3 varchar(64) = dbo.[udfDocTip_TableName](@iDocTipNew, 3)

Declare @iUserID smallint = dbo.[udfSysUserID](@iSession)
Declare @sDate varchar(10) = dbo.[udfSysDate]()

Declare @sSql varchar(2048)
Declare @sTableFrom1 varchar(64)
Declare @sTableFrom3 varchar(64)
Declare @sTableFrom4 varchar(64)

Declare @sDocNum varchar(64) -- NO 32
Declare @iDocTipFrom smallint = 11
Declare @sUniqDocFrom varchar(32) = Cast(@iUniqDocFrom As varchar(16))
Declare @iNumero int
Declare @tDocDta date
Declare @sNumPrefix varchar(8)
Declare @sNumSuffix varchar(8)
Declare @iYear smallint

Declare @sNumCod varchar(8)

Declare @sAnaCod varchar(16)

Declare @iUniqDoc int
Declare @iUniqLin int
Declare @iUniqLin_OLD int
Declare @iUniqRow int
Declare @iLinNum smallint

Declare @sInfo varchar(1024)
Declare @sNoteFT varchar(MAX)
Declare @sCrLf char(2) = Char(13) + Char(10)

DECLARE @wtDocTable [DocTableTYPE]
DECLARE @wtDocTableLin [DocTableLinTYPE]
DECLARE @wtDocTableLinPar [DocTableLinParTYPE]

--
-- stesso tipo anagrafico
--
If IsNull((Select Top 1 1 From dbo.[CliOrdEx_Pers] Where Uniq = @iUniqDocFrom And DtaScadenza Is Not NULL),0) = 1
Begin
	INSERT @wtDocTable(
		Info,
		DocTip, DocNum, DocDta, DocOra, DocKind,
		ForDocNum, ForDocDta,
		AnaType, AnaCod, AnaCodFrom, DsmCod, MndCod,
		PagStart, PagCod, AgeCod, PrvFix, PrvSplitCod,
		LstCod, LstSconti, ShipPayCod, ShipCod, VetCod, VetCod2,
		SctTot,

		DocIvaCod, Divisa, Cambio,
		TrPorto, TrMezzo, EmiCau, Imballo, SegueFt,
		Fornitura, Lotto, RapUniq, Packing,
		VsRif, NsRif, NumExt, DocRif,
		SendDta, SendWay, SendInfo, CnsDta, CnsWeek, CnsInfo,

		Colli, Peso, PesoNetto, Volume,
		SpImballo, SpTra, SpVarie, VetComp,

		Info1, Info2, Info3, Info4, Info5, Info6,

		CntRegMod, MagMovMod, MagMovMod2, NumCod,
		CntRegDta, CntRegDtaIva, MagMovDta,
		RecCreate, RecUserID
		)
	Select
		Info,
		@iDocTipNew, DocNum, DocDta, DocOra, DocKind,
		ForDocNum, ForDocDta,
		AnaType, AnaCod, AnaCodFrom, DsmCod, MndCod,
		PagStart, PagCod, AgeCod, PrvFix, PrvSplitCod,
		LstCod, LstSconti, ShipPayCod, ShipCod, VetCod, VetCod2,
		SctTot,

		DocIvaCod, Divisa, Cambio,
		TrPorto, TrMezzo, EmiCau, Imballo, SegueFt,
		Fornitura, Lotto, RapUniq, Packing,
		VsRif, NsRif, NumExt, DocRif,
		SendDta, SendWay, SendInfo, CnsDta, CnsWeek, CnsInfo,

		Colli, Peso, PesoNetto, Volume,
		SpImballo, SpTra, SpVarie, VetComp,

		Info1, Info2, Info3, Info4, Info5, Info6,

		CntRegMod, MagMovMod, MagMovMod2, NumCod,
		CntRegDta, CntRegDtaIva, MagMovDta,
		RecCreate, RecUserID
	From dbo.[udfVPD_NewFromOC_check_head_Pers](@iSession, @iUniqDocFrom)

	-- --------------------------------------------------------
	Select TOP 1
		@sDocNum = DocNum,
		@sReturnMSG = Info,
		@tDocDta = DocDta,
		@sNumCod = NumCod,
		@sAnaCod = AnaCod
	From @wtDocTable

	Set @sReturnMSG = IsNull(@sReturnMSG, '')
End
Else
	Set @sReturnMSG = IsNull(@sReturnMSG, '(KO)Il documento di origine non ha data di scadenza, non é possibile generare il pre-documento.')
-- --------------------------------------------------------
Set @sDocNum = IsNull(@sDocNum, '')

Set @sReturnUNIQ = ''
If @sDocNum <> ''
Begin
	Execute dbo.[uspNumUniqNext_out] @sTableID, @iUniqDoc OUTPUT

	Set @sReturnUNIQ = Cast(@iUniqDoc As varchar(16))
	Set @sDocNum = REPLACE(@sDocNum, '{DOCNUM}', @sReturnUNIQ)

	Set @iYear = Year(@tDocDta)
	Set @sNumPrefix = dbo.[udfDocNum_split](1, @sDocNum)
	Set @sNumSuffix = dbo.[udfDocNum_split](2, @sDocNum)

	Execute dbo.[uspDocNumBuild_out] @sNumCod, @iYear, @sNumPrefix, @sNumSuffix, @sDocNum OUTPUT, @iNumero OUTPUT

	Update @wtDocTable Set
		DocNum = @sDocNum,
		Numero = @iNumero,
		Uniq = @iUniqDoc,
		Info = NULL
End


If @sReturnUNIQ <> ''
Begin
	-- usa LinNum negativo per nuove righe inserite qui
	-- per i riferimenti ai documenti di origine
	-- -----------------------------------------------------------------
	Set @sTableFrom3 = dbo.[udfDocTip_TableName](@iDocTipFrom, 3)
	Set @sTableFrom4 = dbo.[udfDocTip_TableName](@iDocTipFrom, 4)

	Set @sSql = 'Select * FROM dbo.[' + @sTableFrom3 + '] WHERE UniqDoc = ' + @sUniqDocFrom
						+ ' Order By LinNum'
	INSERT @wtDocTableLin Execute(@sSql)

	UPDATE @wtDocTableLin Set DocTipFrom = @iDocTipFrom WHERE UniqDoc = @iUniqDocFrom

	Set @sSql = 'Select * FROM dbo.[' + @sTableFrom4 + '] WHERE UniqDoc = ' + @sUniqDocFrom
	INSERT @wtDocTableLinPar Execute(@sSql)

	--
	-- pulizia precauzionale parametri dettaglio
	--
	Delete @wtDocTableLinPar
	Where IsNull(UniqLin, 0) Not In(
		Select IsNull(Uniq, 0)
		From @wtDocTableLin
		)

	-- aggiorna dettaglio, parametri dettaglio
	-- assegna ed usa Uniq2 a mo' di UniqRow, numeratore univoco delle righe di dettaglio
	--
	Set @iUniqRow = 0
	Update @wtDocTableLin Set
		@iUniqRow = Uniq2 = @iUniqRow + 1,
		UniqFrom = UniqDoc,
		UniqLinFrom = Uniq

	-- ========================================================================
	-- NOTE FATTURAZIONE - START
	--
	Set @sTableFrom1 = ''
	Set @sNoteFT = ''

	Set @sInfo = ''
	Set @sTableFrom1 = dbo.[udfDocTip_TableName](@iDocTipFrom, 1)

	Set @sSql = 'Declare [cCursor_INFO] Cursor FAST_FORWARD For'
		+ ' Select Info From dbo.[' + @sTableFrom1 + ']'
		+ ' Where Uniq = ' + Cast(@iUniqDocFrom As varchar(16))

	Execute(@sSql)
	Open [cCursor_INFO]
	Fetch Next From [cCursor_INFO] Into @sInfo
	Close [cCursor_INFO]
	Deallocate [cCursor_INFO]

	Set @sInfo = IsNull(@sInfo, '')
	If @sInfo <> ''
	Begin
		Set @sNoteFT += @sInfo + @sCrLf
	End --  @sInfo <> ''
	-- ----------------------------------------------------------

	Set @sNoteFT = dbo.[udfStrTrimX](@sNoteFT)
	Update @wtDocTable Set
		Info = Left(@sNoteFT, 1024)

	-- NOTE FATTURAZIONE - END
	-- ========================================================================

	-- ---------------------------------------------------------
	-- legge ultimo numero-unico di riga
	Execute dbo.[uspNumUniqRead_out] @sTable3, @iUniqLin OUTPUT
	Set @iLinNum = 0

	-- AGGIORNA UniqDoc, Uniq, LinNum su ogni RIGA
	Set @iUniqDoc = dbo.[udfC_int](@sReturnUNIQ)

	Declare [cCursor] Cursor LOCAL FAST_FORWARD For
	Select Uniq2, Uniq
	From @wtDocTableLin
	Order By UniqDoc, LinNum

	Open [cCursor]
	Fetch Next From [cCursor] Into @iUniqRow, @iUniqLin_OLD
	While (@@Fetch_Status <> -1)
	BEGIN
		Set @iUniqLin += 1
		Set @iLinNum += 1

		Update @wtDocTableLin Set
			Uniq = @iUniqLin, UniqDoc = @iUniqDoc, LinNum = @iLinNum
		Where Uniq2 = @iUniqRow

		Update @wtDocTableLinPar Set
			UniqLin = @iUniqLin, UniqDoc = @iUniqDoc
		Where UniqLin = @iUniqLin_OLD
		-- ----------------------------------------------------------
		Fetch Next From [cCursor] Into @iUniqRow, @iUniqLin_OLD
	END -- @@Fetch_Status
	Close [cCursor]
	Deallocate [cCursor]


	-- aggiorna contropartita costo/ricavo da anagrafica prodotto
	-- annulla Uniq2 + altri update
	Update @wtDocTableLin Set
		Uniq2 = NULL,
		LinStat = NULL, LinLavStadio = NULL, LinStatFrom = NULL,
		-- --------------------------------------------------------------
		LinSaldo = 0,
		CdcCommessa =  NULL,
		CdcModel = NULL,
		QtaEvs = NULL, QtaEvs2 = NULL, PrdQtaCnsNow = NULL,
		LinMP = NULL, LinRistFrom = NULL,
		UniqStp = NULL, UniqStpGrp = NULL, UniqStpDta = NULL, MustSpool = NULL,
		ElabNum = NULL, ElabLavNum = NULL, SpedMagMoved = NULL,
		RowCreate = @sDate, RowUserID = @iUserID,
		RowChange = @sDate, RowChangeUserID = @iUserID,
		RowLocked  = NULL, RowPrinted = NULL

	-- ----------------------------------------------------
	-- calcolo eventuale spese accessorie
	Declare @dTotMerce_now decimal(19, 2)

	Declare @sPagCod varchar(16)
	Declare @dSctPagPc decimal(9, 2)
	Declare @dSctPag decimal(19, 2)
	Declare @dSpRiba decimal(9, 2)
	-- ----------------------------------------------------
	-- PagCod
	-- totale merce attuale da righe al netto di omaggi
	-- spese bancarie
	Select
		  @sPagCod = PagCod
	From @wtDocTable

	Set @sPagCod = IsNull(@sPagCod, '')
	Select @dSpRiba = Spese, @dSctPagPc = Sconto
	From dbo.[PagTab]
	Where ItemID = @sPagCod

	Set @dSpRiba = IsNull(@dSpRiba, 0)
	Set @dSctPagPc = IsNull(@dSctPagPc, 0)
	If @dSctPagPc <> 0
	Begin
		Select @dTotMerce_now = Sum(IsNull(TotPrz2, 0))
		From @wtDocTableLin
		Where IsNull(LinOmg, 0) = 0

		Set @dTotMerce_now = IsNull(@dTotMerce_now, 0)
		Set @dSctPag = Round(@dTotMerce_now * @dSctPagPc / 100.00, 2)
	End

    -- ----------------------------------------------------
	-- aggiorna dati di testata
	--
	Update @wtDocTable Set
		SctPagPc = @dSctPagPc,
		SctPag = @dSctPag,
		SpRiba = @dSpRiba

	Update @wtDocTableLin Set
		DocTipFrom = NULL,
		UniqFrom = NULL,
		UniqLinFrom = NULL

	If IsNull((Select Top 1 1 From @wtDocTableLin Where PrdCod Like 'CPI%'),0) = 1
	Begin
		Declare @sRemText nvarchar(512)
		Declare @tDtaShow date = DATEADD(DAY, -30, @tDocDta)
		Select Top 1 @sRemText = ('Scadenza CPI per ' + IsNull(ItemDes,'') + ' (' 
			+ Case When IsNull(Loc,'') <> '' Then Loc + IIf(IsNull(Pro,'') <> '', ' (' + Pro + ')', '') + ', ' 
			Else '' End + IsNull(Ind,'') + ') in data ' + dbo.[udfDate_str](@tDocDta, 0) + @sCrLf 
			+ 'Rif. pre-doc. ' + @sDocNum) From dbo.[MixAna] Where ItemType = 1 And ItemID = @sAnaCod
		Execute dbo.[uspUserReminder_add] @iSession, '(ALTRI)', '', @sRemText, @tDocDta, @tDtaShow, '09', '00', 0, 0
	End

	-- -----------------------------------------------------------
	-- Scrive ultimo numero-unico di riga
	--
	Execute dbo.[uspNumUniqUpdate] 	@sTable3, @iUniqLin

	--
	-- copia nelle tabelle reali
	--
	Insert dbo.[CliDoc] Select * From @wtDocTable
	Insert dbo.[CliDocLin] Select * From @wtDocTableLin
	Insert dbo.[CliDocLinPar] Select * From @wtDocTableLinPar
	Insert dbo.[CliDocEx_Pers](Uniq, CaPre, Note, Escl, Tecnico) 
	Select @iUniqDoc, CaPre, Note, Escl, Tecnico From dbo.[CliOrdEx_Pers] Where Uniq = @iUniqDocFrom
	
	Execute dbo.[uspDD_Total_update] @iSession, @iDocTipNew, @iUniqDoc, 0, 0, 0, 0, 0, 0, 0

	-- -----------------------------------------------------------
	-- Eventuale esenzione/agevolazione IVA su tutto il documento
	--
	Declare @sDocIvaCod varchar(8) = ''
	Select @sDocIvaCod = DocIvaCod
	From @wtDocTable

	If IsNull(@sDocIvaCod, '') <> ''
		Execute dbo.[uspDD_DocIvaCod_apply] @iDocTipNew, @iUniqDoc, @sDocIvaCod


End -- @sReturnUNIQ <> ''

-- *********************************************************************************

-- ====================================================================
Select IsNull(@sReturnUNIQ, '')
	+ @sReturnSEP + IsNull(@sReturnMSG, '') As Mix