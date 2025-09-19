/*
*	Genera nuovo documento
*	Valore di ritorno: MIX  - ReturnUNIQ valorizzato
*	---------------------------------------------------------------------
*	@iSession: numero di sessione, da cui sono ricavabili utente, lingua, …
*   @sOrigin: assieme ad @iId identifica l'ordine da cui creare il documento
*   @iId: assieme ad @sOrigin identifica l'ordine da cui creare il documento
*
*/
CREATE PROCEDURE [dbo].[uspDoc_NewFromImp_Pers]
	@iSession int,
    @sOrigin varchar(16),
    @iId int
AS
SET NOCOUNT ON
Declare @sReturnSEP char(1) = Char(6)
Declare @sReturnUNIQ varchar(32) = ''
Declare @sReturnMSG varchar(2048) = ''
Declare @sReturnSCRIPT varchar(4096) = ''

Declare @sDocNum varchar(32)
Declare @iUserID smallint = dbo.[udfSysUserID](@iSession)
Declare @sAnaCod varchar(16)
Declare @tDocDta date
Declare @dFeeTotal decimal(9,3)
Declare @dFeeTotalTax decimal(9,3)
Declare @iYear smallint
Declare @sNumPrefix varchar(8)
Declare @sNumSuffix varchar(8)
Declare @sNumCod varchar(8)
Declare @iNumero int
Declare @sPrdCod varchar(32)
Declare @iPrdQta int

Declare @iUniq int = 0
Declare @iUniqDoc int = 0
Declare @iUniqLin int = 0
Declare @iLinNum smallint = 0
Declare @iIdLin int


DECLARE @wtDocTable [DocTableTYPE]
DECLARE @wtDocTableLin [DocTableLinTYPE]
DECLARE @wtDocTableLinPar [DocTableLinParTYPE]

-- -------------------------------------------------
-- TESTATA DOCUMENTO
-- -------------------------------------------------
Insert @wtDocTable(
	DocTip/*, DocNum*/, DocDta, DocOra/*, DocKind, DocStatus*/, AnaType, AnaCod, AnaCodFrom/*, DsmCod, MndCod, ForDocNum, ForDocDta, VsRif, NsRif*/
	, NumExt/*, DocRif*/, Info/*, SendDta, SendWay*/, SendInfo/*, CnsDta, CnsWeek, CnsInfo*/
	, DocTot, DocImp, DocIva, DocOmg
	, DocMerce
	/*, DocSconti*/, DocSpese, PagStart
	, PagCod/*, AgeCod, PrvSplitCod*/
	, PrvFix, PrvTot, LstCod/*, LstSconti, ShipPayCod, ShipCod, VetCod, VetCod2*//*, SctTotPc*/
	/*, SctTot*//*, SctPagPc, SctPag, SpImballo*/, SpTra/*, SpRiba, SpBolli, SpVarie, Lotto, Fornitura, RapUniq, Packing, TrMezzo, TrPorto, Colli, EmiCau*/
	, AspBeni/*, Imballo, Peso, PesoNetto, Volume, DtaRitM, OraRitM, SegueFt, VetComp, Info1, Info2, Info3*/
	, Info4/*, Info5, Info6*/
	, DocIvaCod, Divisa, Cambio, CambioDta/*, CntRegMod, CntRegDta, CntRegDtaIva, MagMovMod, MagMovMod2, MagMovDta, NumCod, Numero, Uniq, Uniq2*/
	, RecCreate, RecUserID/*, RecCompany, RecAgency*/, RecLocked, RecPrinted/*, RecType, RecElabID, RecValue, RecMaster*/
	)
Select
	11, Cast(date_modified as date), Convert(varchar(8), Cast(date_modified as datetime), 108), 1, AnaCod, customer_id
	, id, Left(payment_method_title, 256), Left(shipping_method_title, 256)
	, IsNull(total, 0), IsNull(subtotal, (IsNull(total, 0) - IsNull(total_tax, 0))), IsNull(total_tax, 0), 0
	, IsNull(subtotal, (IsNull(total, 0) - IsNull(total_tax, 0))) + IsNull(discount_total, 0) - IsNull(shipping_total, 0) - IsNull(fee_total, 0)
	/*, IsNull(discount_total, 0)*/, 0, Cast(date_paid as date)
	, (Case 
		When (RTrim(LTrim(payment_method_title)) = 'Bonifico Bancario anticipato') Then ('BB14') 
		When (RTrim(LTrim(payment_method_title)) = 'Contrassegno') Then ('RD01') 
		When (RTrim(LTrim(payment_method_title)) In ('Pagamento in Autoritiro', 'Pagamento al ritiro c/o la nostra sede')) Then ('RIT') 
		When (RTrim(LTrim(payment_method_title)) In ('Carte di Credito / Bancomat', 'PayPal o Carte di Credito', 'PayPal')) Then ('CRTPAY') 
		When (RTrim(LTrim(payment_method_title)) = 'Solito In Essere') Then (Select A.PagCod From dbo.[MixAna] A Where A.ItemType = 1 And A.ItemID = DOC.AnaCod) 
		Else (null) End)
	, 0, 0, (Case When (origin = 'adunata') Then ('ADUNATASTORE') Else ('BASE') End)/*, coupon_nominal_amount*/
	/*, IsNull(discount_total, 0)*/, IsNull(shipping_total, 0)
	, 'A VISTA'
	, (Case 
		When (origin = 'promoser') Then ('https://www.promoser.net') 
		When (origin = 'gagliardetti') Then ('https://www.gagliardetti.net') 
		When (origin = 'adunata') Then ('https://www.adunatastore.it') 
		Else (null) End) 
	, (Case When (tax_rate_code = 'IT-IVA-1') Then ('01') Else (null) End), currency, dbo.[udfCambio](currency), GETDATE()
	, Cast(date_created as date), @iUserID, 0, 0
From dbo.[CliOrdImp_Pers] DOC
Where origin = @sOrigin And id = @iId

Select 
	@sAnaCod = AnaCod,
	@tDocDta = DocDta
From @wtDocTable

Set @sDocNum = '({DOCNUM})'

Select
	@sNumPrefix = NumPrefix,
	@sNumSuffix = NumSuffix,
	@sNumCod = NumCod
From dbo.[udfDD_DocDef](@iSession, 1, 11, 1, @sAnaCod)

Set @iYear = Year(@tDocDta)

If @sNumPrefix <> ''
	Set @sDocNum = @sNumPrefix + '-' + @sDocNum
If @sNumSuffix <> ''
	Set @sDocNum = @sDocNum + '/' + @sNumSuffix

Execute dbo.[uspNumUniqNext_out] 'CliOrd', @iUniqDoc OUTPUT

Set @sReturnUNIQ = Cast(@iUniqDoc As varchar(16))
Set @sDocNum = REPLACE(@sDocNum, '{DOCNUM}', @sReturnUNIQ)	

Execute dbo.[uspDocNumBuild_out] @sNumCod, @iYear, @sNumPrefix, @sNumSuffix, @sDocNum OUTPUT, @iNumero OUTPUT

Update @wtDocTable Set
	DocNum = @sDocNum,
	Numero = @iNumero,
	Uniq = @iUniqDoc,
	NumCod = @sNumCod

-- -------------------------------------------------
-- RIGHE DOCUMENTO
-- -------------------------------------------------
Insert @wtDocTableLin(
	LinNum/*, LinStat, LinLavStadio, LinStatFrom, LinSaldo, QtaEvs, QtaEvs2, LinOmg*/, PrdCod
	, PrdCod2/*, ForCod, PrdForCod, PrzAcq, PrdParams, PrdSerial, PrdLotto, PrdDtaMake, PrdDtaCns*/
	, PrdDes/*, PrdUm2, QtaUm2*/
	, PrdUm/*, PrdQtaCnsNow*/, PrdQta/*, PrdQta2*/
	, PrdPrz
	, PrdSc
	, PrdPrz2, PrdAdd
	, TotPrz2
	, LinRif/*, LinType*/, IvaCod, IvaAlq/*, PrvAlq, PrvAgeCod, CptCnt, CdcModel, CdcCommessa*/
	, PrzLstCod, PrzLst, TotPrz/*, TotPrz2C, TotPrz2S, TotDivisaP, TotQta2, Info, InfoExt*/, PrdUso, Tm, TmCalc/*, LinMP, LinRistFrom, DocTipFrom, UniqFrom, UniqLinFrom, UniqStp, UniqStpGrp*/
	/*, UniqStpDta, MustSpool, ElabNum, ElabLavNum, SpedMagMoved*/, FormCod, DibaCod/*, OffCod, OffQta, OffMinFt, OffMinFt1, OffMinFt2, OffPrvFix, Uniq*/, UniqDoc/*, Uniq2, UniqDoc2*/, RowCreate
	, RowUserID, RowChange, RowChangeUserID, RowLocked, RowPrinted
	)
Select
	LIN.id_lin, LIN.PrdCod
	, (Case When (IsNull(LIN.variation_id, '') = '') Then (Case When IsNull(LIN.product_id, '') = '' Then (null) Else (LIN.product_id) End) Else (LIN.variation_id) End)
	, (Case When (IsNull(LIN.name, '') = '') Then (Case When IsNull(LIN.parent_name, '') = '' Then (null) Else (Left(LIN.parent_name, 2048)) End) Else (Left(LIN.name, 2048)) End)
	, 'NR', LIN.quantity
	, (IsNull(LIN.subtotal, 0) / IsNull(NullIf(LIN.quantity, 0), 1))
	, Cast((100 - (100 * IsNull(LIN.price, 0) * IsNull(LIN.quantity, 1) / IsNull(NullIf(LIN.subtotal, 0), 1))) As int)
	, IsNull(LIN.price, 0), 0
	, (Case 
		When (IsNull(LIN.total, 0) <> 0) Then (LIN.total)
		When (IsNull(LIN.subtotal, 0) <> 0) Then (LIN.subtotal)
		Else (null) End)
	, LIN.sku, (Case When (DOC.tax_rate_code = 'IT-IVA-1') Then ('01') Else (null) End), DOC.tax_rate_percent
	, (Case When (LIN.origin = 'adunata') Then ('ADUNATASTORE') Else ('BASE') End), 0, 0, 10, 1, 1
	, ANA.FormCod, ANA.DiBaCod, @iUniqDoc, Cast(DOC.date_created as date)
	, @iUserID, Cast(DOC.date_modified as date), @iUserID, 0, 0
From dbo.[CliOrdImp_Pers] DOC 
Join dbo.[CliOrdLinImp_Pers] LIN On DOC.origin = LIN.origin And DOC.id = LIN.id
Join dbo.[PrdAna] ANA On LIN.PrdCod = ANA.PrdCod
Where LIN.origin = @sOrigin And LIN.id = @iId

-- -------------------------------------------------
-- PARAMETRI RIGHE
-- -------------------------------------------------
Declare [cCursor] Cursor LOCAL FAST_FORWARD For
Select LinNum, PrdCod
From @wtDocTableLin
Order By LinNum

Open [cCursor]
Fetch Next From [cCursor] Into @iIdLin, @sPrdCod
While (@@Fetch_Status <> -1)
BEGIN
	Execute dbo.[uspNumUniqNext_out] 'CliOrdLin', @iUniqLin OUTPUT
	Set @iLinNum += 1

	Update @wtDocTableLin Set
		Uniq = @iUniqLin,
		LinNum = @iLinNum
	Where LinNum = @iIdLin
	
	Update dbo.[CliOrdLinImp_Pers] Set UniqDoc = @iUniqDoc, Uniq = @iUniqLin
	Where origin = @sOrigin And id = @iId And id_lin = @iIdLin

	If IsNull((Select Top 1 FormCod From dbo.[PrdAna] Where PrdCod = @sPrdCod), '') <> ''
	BEGIN
		Insert @wtDocTableLinPar(
			UniqDoc, UniqLin, ParID, ParLin
			, ParDes, ParValue, ParText, ParAddTot, ParAddQta1, ParAddQta2, ParAddQta2X, ParAddUmPc, ParAddTotMis, ParAddMis1
			, ParAddSconti/*, ParAddIvaDed*/, FormCod/*, UniqDoc2, UniqLin2*/
			)
		Select
			@iUniqDoc, @iUniqLin, FORM.ParID, FORM.ParLin
			, FORM.ParDes, FORM.ParDefault, IsNull(TABLIN.ItemDes, FORM.ParDefault), 0, 0, 0, 0, 0, 0, 0
			, null, FORM.FormCod
		From dbo.[PrdFormLin] FORM Left Join dbo.[PrdFormTabLin] TABLIN On FORM.ParTabCod = TABLIN.TabCod And FORM.ParDefault = TABLIN.ItemID
		Where FORM.FormCod = (Select Top 1 FormCod From dbo.[PrdAna] Where PrdCod = @sPrdCod)

		Update TEMP Set
			TEMP.ParValue = (dbo.[udfStrBetween](PAR.display_value, '(#', ')', 0)), 
			TEMP.ParText = IsNull(TABLIN.ItemDes, (dbo.[udfStrBetween](PAR.display_value, '(#', ')', 0)))
		From dbo.[CliOrdLinParImp_Pers] PAR 
		Join dbo.[CliOrdLinParImpSettings_Pers] PSET 
			On Stuff(PAR.key_, 1, 3, '') = PSET.id Or (Left(PAR.key_, 26) = 'variante-gagliardetti-mod-' And Len(PAR.key_) > 26)
		Join @wtDocTableLinPar TEMP On TEMP.ParID = IsNull(PSET.ParID, 1) And TEMP.ParLin = IsNull(PSET.ParLin, 5)
		Left Join dbo.[PrdFormTabLin] TABLIN
			On (PSET.TabCod = TABLIN.TabCod Or ((Left(PAR.key_, 26) = 'variante-gagliardetti-mod-' And Len(PAR.key_) > 26) And TABLIN.TabCod = Stuff(PAR.key_, 1, 26, 'Tabella_Varianti_')))
			And TABLIN.ItemID = (dbo.[udfStrBetween](PAR.display_value, '(#', ')', 0))
		Where PAR.origin = @sOrigin And PAR.id = @iId And PAR.id_lin = @iIdLin 
			And Left(PAR.key_, 3) = 'pa_' 
			And IsNull(dbo.[udfStrBetween](PAR.display_value, '(#', ')', 0), '') <> ''
	
		Update PAR Set PAR.UniqDoc = @iUniqDoc, PAR.UniqLin = @iUniqLin, PAR.ParID = IsNull(PSET.ParID, 1)
		From dbo.[CliOrdLinParImp_Pers] PAR 
		Join dbo.[CliOrdLinParImpSettings_Pers] PSET 
			On Stuff(PAR.key_, 1, 3, '') = PSET.id Or (Left(PAR.key_, 26) = 'variante-gagliardetti-mod-' And Len(PAR.key_) > 26)
		Where PAR.origin = @sOrigin And PAR.id = @iId And PAR.id_lin = @iIdLin
	END
	-- ----------------------------------------------------------
	Fetch Next From [cCursor] Into @iIdLin, @sPrdCod
END -- @@Fetch_Status
Close [cCursor]
Deallocate [cCursor]

If IsNull((Select Top 1 1 From @wtDocTableLin Where LinRif = '(#express)'), 0) = 1
Begin
	Set @iUniqLin = null
	Set @sPrdCod = null
	Set @iPrdQta = null

	Select @iUniqLin = LIN.Uniq, @sPrdCod = LIN.PrdCod, @iPrdQta = LIN.PrdQta
	From @wtDocTableLin LIN 
	Join dbo.[PrdAna] ANA On LIN.PrdCod = ANA.PrdCod
	Join dbo.[PrdFormLin] FORM On ANA.FormCod = FORM.FormCod
	Where FORM.ParDes = 'Consegna Express' And LIN.PrdQta > 0

	If IsNull(@iUniqLin,0) <> 0 And IsNull(@sPrdCod,'') <> ''
	Begin
		Select 
			@dFeeTotal = IsNull(fee_total, 0),
			@dFeeTotalTax = IsNull(fee_total_tax, 0)
		From dbo.[CliOrdImp_Pers] DOC Where origin = @sOrigin And id = @iId

		Update @wtDocTableLinPar Set 
			ParValue = 'SI',
			ParText = 'SI',
			ParAddTot = (@dFeeTotal / @iPrdQta),
			ParAddQta1 = (@dFeeTotal / @iPrdQta)
		Where UniqLin = @iUniqLin And ParID = 25 And ParLin = 25

		Update @wtDocTableLin Set 
			PrdAdd = (@dFeeTotal / @iPrdQta),
			TotPrz2 = TotPrz2 + @dFeeTotal
		Where Uniq = @iUniqLin

		Delete From @wtDocTableLin Where LinRif = '(#express)'
	End
End

-- -------------------------------------------------
-- INSERIMENTO DATI
-- -------------------------------------------------
Insert dbo.[CliOrd] Select * From @wtDocTable	
Insert dbo.[CliOrdLin] Select * From @wtDocTableLin	
Insert dbo.[CliOrdLinPar] Select * From @wtDocTableLinPar	

Update A Set
	PrdParams = dbo.[udfDD_PrdParams](11, A.Uniq)
From dbo.[CliOrdLin] A Join @wtDocTableLin B On A.Uniq = B.Uniq

Update dbo.[CliOrdImp_Pers] Set Uniq = @iUniqDoc
Where origin = @sOrigin And id = @iId
	
	
-- ====================================================================
Select IsNull(@sReturnUNIQ, '')
	+ @sReturnSEP + IsNull(@sReturnMSG, '')
	+ @sReturnSEP + IsNull(@sReturnSCRIPT, '') As Mix