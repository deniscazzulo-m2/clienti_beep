/*
*
*	Di supporto per generazione di nuovo PRE-DOCUMENTO
*	da altro documento di ORDINE CLIENTE, senza evasione documenti di origine.
*	Ritorna i dati di testata
*
*	NOTE:
*		NON ASSEGNA Uniq						--> deve essere assegnato esternamente
*		ASSEGNA DocNum = '({DOCNUM})' se OK 	--> {DOCNUM} deve essere sostituito esternamente
*		ASSEGNA DocNum = '' se KO
*		ASSEGNA Info = ReturnMSG
*
*
*	Verifica congruità dei documenti di origine
*
*/
CREATE FUNCTION [dbo].[udfVPD_NewFromOC_check_head_Pers]
(
	@iSession int,
	@iDocUniqFrom int
)
RETURNS @tbDocHead TABLE(
	[DocTip] tinyint NULL,
	[DocNum] varchar(32) NULL,
	[DocDta] date NULL,
	[DocOra] varchar(16) NULL,
	[DocKind] tinyint NULL,

	[AnaType] tinyint NULL,
	[AnaCod] varchar(16) NULL,
	[AnaCodFrom] varchar(16) NULL,
	[DsmCod] varchar(16) NULL,
	[MndCod] varchar(16) NULL,
	[ForDocNum] varchar(32) NULL,
	[ForDocDta] date NULL,
	[VsRif] varchar(64) NULL,
	[NsRif] varchar(64) NULL,
	[NumExt] varchar(64) NULL,
	[DocRif] varchar(64) NULL,
	[Info] varchar(1024) NULL,

	[SendDta] date NULL,
	[SendWay] varchar(32) NULL,
	[SendInfo] varchar(256) NULL,
	[CnsDta] date NULL,
	[CnsWeek] tinyint NULL,
	[CnsInfo] varchar(256) NULL,

	[PagStart] date NULL,
	[PagCod] varchar(16) NULL,
	[AgeCod] varchar(16) NULL,
	[PrvSplitCod] varchar(16) NULL,
	[PrvFix] decimal(9, 2) NULL,
	[LstCod] varchar(32) NULL,
	[LstSconti] varchar(16) NULL,
	[ShipPayCod] varchar(8) NULL,
	[ShipCod] varchar(8) NULL,
	[VetCod] varchar(16) NULL,
	[VetCod2] varchar(16) NULL,
	[SctTot] decimal(19, 6) NULL,
	[SctPag] decimal(19, 2) NULL,
	[SpImballo] decimal(9, 2) NULL,
	[SpTra] decimal(9, 2) NULL,
	[SpRiba] decimal(9, 2) NULL,
	[SpBolli] decimal(9, 2) NULL,
	[SpVarie] decimal(9, 2) NULL,

	[Lotto] varchar(32) NULL,
	[Fornitura] int NULL,
	[RapUniq] int NULL,
	[Packing] int NULL,

	[TrMezzo] tinyint NULL,
	[TrPorto] tinyint NULL,
	[Colli] smallint NULL,
	[EmiCau] varchar(32) NULL,
	[Imballo] varchar(64) NULL,
	[Peso] decimal(9, 3) NULL,
	[PesoNetto] decimal(9, 3) NULL,
	[Volume] decimal(19, 6) NULL,
	[SegueFt] bit NULL,
	[VetComp] decimal(19, 6) NULL,
	[Info1] varchar(64) NULL,
	[Info2] varchar(64) NULL,
	[Info3] varchar(64) NULL,
	[Info4] varchar(64) NULL,
	[Info5] varchar(64) NULL,
	[Info6] varchar(64) NULL,
	[DocIvaCod] varchar(8) NULL,
	[Divisa] varchar(8) NULL,
	[Cambio] decimal(19, 6) NULL,
	[CambioDta] date NULL,
	[CntRegMod] varchar(8) NULL,
	[CntRegDta] date NULL,
	[CntRegDtaIva] date NULL,
	[MagMovMod] varchar(8) NULL,
	[MagMovMod2] varchar(8) NULL,
	[MagMovDta] date NULL,
	[NumCod] varchar(8) NULL,
	[RecCreate] date NULL,
	[RecUserID] smallint NULL
)
AS
BEGIN
Declare @bOk bit = 1
Declare @sReturnMSG varchar(2048) = ''
Declare @iFormDocTip tinyint = 13

Declare @tDate date = GetDate()
Declare @sTime varchar(8) = dbo.[udfSysTime]()
Declare @iUserID smallint = dbo.[udfSysUserID](@iSession)
Declare @iAnaType tinyint = dbo.[udfDocTip_AnaType](@iFormDocTip)

Declare @iDocTipFrom tinyint = 11
Declare @iCount int

Declare @iDocKind tinyint
Declare @sAnaCod varchar(16)
Declare @sAnaCodFrom varchar(16)
Declare @sDsmCod varchar(16)
Declare @sMndCod varchar(16)

Declare @sDocNum varchar(32)
Declare @tDocDta date
Declare @sNumPrefix varchar(8)
Declare @sNumSuffix varchar(8)

Declare @tPagStart date
Declare @sPagCod varchar(16)
Declare @sAgeCod varchar(16)
Declare @dPrvFix decimal(9, 2)
Declare @sPrvSplitCod varchar(16)
Declare @sLstCod varchar(32)
Declare @sLstSconti varchar(16)
Declare @sShipPayCod varchar(8)
Declare @sShipCod varchar(8)
Declare @sVetCod varchar(16)
Declare @sVetCod2 varchar(16)
Declare @iTrMezzo tinyint
Declare @iTrPorto tinyint
Declare @sImballo varchar(64)
Declare @dVetComp decimal(19, 6)

Declare @sDocIvaCod varchar(8)
Declare @sDivisa varchar(8)
Declare @dCambio decimal(19, 6)
Declare @tCambioDta date

Declare @sEmiCau varchar(32)
Declare @bSegueFt bit

Declare @dSctTot decimal(19, 6)
Declare @dSpImballo decimal(9, 2)
Declare @dSpTra decimal(9, 2)
Declare @dSpBolli decimal(9, 2)
Declare @dSpVarie decimal(9, 2)

Declare @iColli smallint
Declare	@dPeso decimal(9, 3)
Declare @dPesoNetto decimal(9, 3)
Declare @dVolume decimal(19, 6)

Declare @iFornitura int

Declare @sVsRif varchar(64)
Declare @sNsRif varchar(64)
Declare @sNumExt varchar(64)
Declare @sDocRif varchar(64)

Declare @tSendDta date
Declare @sSendWay varchar(32)
Declare @sSendInfo varchar(256)
Declare @tCnsDta date
Declare @iCnsWeek tinyint
Declare @sCnsInfo varchar(256)

Declare @sInfo1 varchar(64)
Declare @sInfo2 varchar(64)
Declare @sInfo3 varchar(64)
Declare @sInfo4 varchar(64)
Declare @sInfo5 varchar(64)
Declare @sInfo6 varchar(64)

Declare @sCntRegMod varchar(8)
Declare @sCntRegMod_ANA varchar(8)
Declare @tCntRegDta date
Declare @tCntRegDtaIva date
Declare @sMagMovMod varchar(8)
Declare @sMagMovMod2 varchar(8)
Declare @tMagMovDta date

Declare @sNumCod varchar(8)

-- Parametro operativo 2011: 
-- Se 1 (UNO) abilita l'azzeramento dello sconto su totale in un documento originato da altro
-- che è già stato oggetto di evasione parziale.
Declare @bPar2011 bit = dbo.[udfEnvironRead_bit]('2011')

-- ====================================================================================
-- VERIFICHE CONGRUITA'
-- ------------------------------------------------------------------------------------
-- usa tabella temporanea per facilitare le verifiche
--
Declare @tbDocCheck TABLE(
	[DocTip] tinyint NULL,
	[Uniq] int,
	
	[DocKind] tinyint NULL,
	[DocDta] date,
	[DocNum] varchar(32),
	[Numero] int,

	[AnaCod] varchar(16) NULL,
	[DsmCod] varchar(16) NULL,
	[MndCod] varchar(16) NULL,
	
	[PagCod] varchar(16) NULL,
	[AgeCod] varchar(16) NULL,
	[PrvFix] decimal(9, 2) NULL,
	[PrvSplitCod] varchar(16) NULL,
	[Divisa] varchar(8) NULL,

	[LstCod] varchar(32) NULL,
	[LstSconti] varchar(16) NULL,
	[ShipPayCod] varchar(8) NULL,
	[ShipCod] varchar(8) NULL,
	[VetCod] varchar(16) NULL,
	[VetCod2] varchar(16) NULL,
	[TrMezzo] tinyint NULL,
	[TrPorto] tinyint NULL,
	[Imballo] varchar(64) NULL,

	[Fornitura] int NULL,

	[SctTot] decimal(19, 6) NULL,
	[SctPag] decimal(19, 2) NULL,
	[SpImballo] decimal(9, 2) NULL,
	[SpTra] decimal(9, 2) NULL,
	[SpRiba] decimal(9, 2) NULL,
	[SpBolli] decimal(9, 2) NULL,
	[SpVarie] decimal(9, 2) NULL,
	[VetComp] decimal(19, 6) NULL,

	[Colli] smallint NULL,
	[Peso] decimal(9, 3) NULL,
	[PesoNetto] decimal(9, 3) NULL,
	[Volume] decimal(19, 6) NULL,

	[VsRif] varchar(64) NULL,
	[NsRif] varchar(64) NULL,
	[NumExt] varchar(64) NULL,
	[DocRif] varchar(64) NULL,

	[SendDta] date NULL,
	[SendWay] varchar(32) NULL,
	[SendInfo] varchar(256) NULL,
	[CnsDta] date NULL,
	[CnsWeek] tinyint NULL,
	[CnsInfo] varchar(256) NULL,

	[Info1] varchar(64) NULL,
	[Info2] varchar(64) NULL,
	[Info3] varchar(64) NULL,
	[Info4] varchar(64) NULL,
	[Info5] varchar(64) NULL,
	[Info6] varchar(64) NULL
	)

INSERT @tbDocCheck
Select
	DocTip, Uniq,
	DocKind, DocDta, DocNum, Numero,
	AnaCod, DsmCod, MndCod, PagCod, AgeCod, PrvFix, PrvSplitCod, Divisa,
	LstCod, LstSconti, ShipPayCod, ShipCod, VetCod, VetCod2, TrMezzo, TrPorto, Imballo,
	Fornitura,
	SctTot, SctPag, SpImballo, SpTra, SpRiba, SpBolli, SpVarie, VetComp,
	Colli, Peso, PesoNetto, Volume,
	VsRif, NsRif, NumExt, DocRif,
	SendDta, SendWay, SendInfo, CnsDta, CnsWeek, CnsInfo,
	Info1, Info2, Info3, Info4, Info5, Info6
From dbo.[udfDD_Head](@iDocTipFrom, @iDocUniqFrom)

-- ----------------------------------------------------------------------------------
Set @bOk = 1
-- ----------------------------------------------------------------------------------
-- incongruità bloccanti
--
If @bOk = 1
Begin
	Select @iCount = Count(DISTINCT Divisa)
	From @tbDocCheck
	If IsNull(@iCount, 0) > 1
	Begin
		Set @bOk = 0
		Set @sReturnMSG = '(KO)I documenti di origine fanno riferimento a divise diverse, non é possibile generare un unico documento riepilogativo.'
	End
End

-- DEBUG Select @sReturnMSG As MSG, @bOk As OK, * From @tbDocCheck
-- ==================================================================================
If @bOk = 0
BEGIN
	INSERT @tbDocHead(DocNum, Info) VALUES('', @sReturnMSG)
	RETURN
END
-- ==================================================================================

-- ----------------------------------------------------------------------------------
-- incongruità con sola segnalazione
--
Set @sReturnMSG = ''

Select @iCount = Count(DISTINCT AnaCod)
From @tbDocCheck
If IsNull(@iCount, 0) > 1
Begin
	Set @sReturnMSG += '|Codici anagrafici (cliente/fornitore) diversi.'
End

--DocKind tinyint
Select @iCount = Count(DISTINCT IsNull(DocKind, 0))
From @tbDocCheck
If IsNull(@iCount, 0) > 1
	Set @sReturnMSG += '|Genere di documento diversi.'

--DsmCod varchar(16)
Select @iCount = Count(DISTINCT IsNull(DsmCod, ''))
From @tbDocCheck
If IsNull(@iCount, 0) > 1
	Set @sReturnMSG += '|Destinazioni merce diverse.'

--MndCod varchar(16)
Select @iCount = Count(DISTINCT IsNull(MndCod, ''))
From @tbDocCheck
If IsNull(@iCount, 0) > 1
	Set @sReturnMSG += '|Case mandanti diverse.'

--PagCod varchar(16)
Select @iCount = Count(DISTINCT IsNull(PagCod, ''))
From @tbDocCheck
If IsNull(@iCount, 0) > 1
	Set @sReturnMSG += '|Codici pagamento diversi.'

--LstCod varchar(32)
Select @iCount = Count(DISTINCT IsNull(LstCod, ''))
From @tbDocCheck
If IsNull(@iCount, 0) > 1
	Set @sReturnMSG += '|Codici listino diversi.'

--VetCod varchar(16)
Select @iCount = Count(DISTINCT IsNull(VetCod, ''))
From @tbDocCheck
If IsNull(@iCount, 0) > 1
	Set @sReturnMSG += '|Codici vettore diversi.'

--AgeCod varchar(16),
Select @iCount = Count(DISTINCT IsNull(AgeCod, ''))
From @tbDocCheck
If IsNull(@iCount, 0) > 1
	Set @sReturnMSG += '|Codici agente diversi.'

--PrvFix decimal(9, 2),
Select @iCount = Count(DISTINCT IsNull(PrvFix, 0))
From @tbDocCheck
If IsNull(@iCount, 0) > 1
	Set @sReturnMSG += '|Percentuali di provvigione fissa diverse.'

--PrvSplitCod varchar(16),
Select @iCount = Count(DISTINCT IsNull(PrvSplitCod, ''))
From @tbDocCheck
If IsNull(@iCount, 0) > 1
	Set @sReturnMSG += '|Codici di ripartizione provvigioni diversi.'

-- Fornitura int
Select @iCount = Count(DISTINCT IsNull(Fornitura, 0))
From @tbDocCheck
If IsNull(@iCount, 0) > 1
	Set @sReturnMSG += '|Codici di fornitura diversi.'

If @sReturnMSG <> ''
	Set @sReturnMSG = '(OK)Ho rilevato:' + @sReturnMSG + '||Al nuovo documento ho assegnato i dati presenti nel documento di origine più recente.'

-- -------------------------------------------------
-- acquisisce estremi dal più  recente documento di origine

Select TOP 1
	@iDocKind = DocKind,
	@sAnaCod = AnaCod, @sDsmCod = DsmCod, @sMndCod = MndCod, @sPagCod = PagCod,
	@sAgeCod = AgeCod, @dPrvFix = PrvFix, @sPrvSplitCod = PrvSplitCod, @sDivisa = Divisa,
	@sLstCod = LstCod, @sLstSconti = LstSconti,
	@sShipPayCod = ShipPayCod, @sShipCod = ShipCod,
	@sVetCod = VetCod, @sVetCod2 = VetCod2, @iTrPorto = TrPorto, @iTrMezzo = TrMezzo, @sImballo = Imballo,
	@iFornitura = Fornitura,
	@sVsRif = VsRif, @sNsRif = NsRif, @sNumExt = NumExt, @sDocRif = DocRif,
	@tSendDta = SendDta, @sSendWay = SendWay, @sSendInfo = SendInfo, @tCnsDta = CnsDta, @iCnsWeek = CnsWeek, @sCnsInfo = CnsInfo,
	@sInfo1 = Info1, @sInfo2 = Info2, @sInfo3 = Info3, @sInfo4 = Info4, @sInfo5 = Info5, @sInfo6 = Info6
From @tbDocCheck
Order By DocDta DESC, Numero DESC


-- ----------------------------------------------------------------------------------
-- SctTot - @bPar2011
-- Azzeramento dello sconto su totale in un documento originato da altro che è già stato oggetto di evasione parziale.
--
If (@bPar2011 = 1)
Begin
	-- @iFormDocTip tipo-documento in generazione
	--
	Declare @bSctTotZero bit = 0
	
	Declare [cCursor] Cursor LOCAL FAST_FORWARD For
	Select DocTip, Uniq
	From @tbDocCheck
	Where IsNull(SctTot, 0) <> 0
	Open [cCursor]
	Fetch Next From [cCursor] Into @iDocTipFrom, @iDocUniqFrom
	While (@@Fetch_Status <> -1)
	Begin
		Set @bSctTotZero = 0
			If EXISTS(
				Select Uniq
				From dbo.[CliDocLin]
				Where UniqFrom = @iDocUniqFrom
					And DocTipFrom = @iDocTipFrom
				) Set @bSctTotZero = 1

		If @bSctTotZero = 1
		Begin
			Update @tbDocCheck Set
				SctTot = 0
			Where Uniq = @iDocUniqFrom
				And DocTip = @iDocTipFrom
		End
		-- ----------------------------------------------------------
		Fetch Next From [cCursor] Into @iDocTipFrom, @iDocUniqFrom
	End
	Close [cCursor]
	Deallocate [cCursor]
End -- @bPar2011 = 1


-- ----------------------------------------------------------------------------------
Select
	@dSctTot = Sum(SctTot),
	@dSpImballo = Sum(SpImballo),
	@dSpTra = Sum(SpTra),
	@dSpBolli = Sum(SpBolli),
	@dSpVarie = Sum(SpVarie),
	@dVetComp = Sum(VetComp),
	
	@iColli = Sum(Colli),
	@dPeso = Sum(Peso),
	@dPesoNetto = Sum(PesoNetto),
	@dVolume = Sum(Volume)	
From @tbDocCheck

-- ====================================================================================
-- congruità OK, procede a generare la testata del nuovo documento
--
Select @tDocDta = DtaScadenza From dbo.[CliOrdEx_Pers] Where Uniq = @iDocUniqFrom
Set @tDocDta = IsNull(@tDocDta,'')
Set @sAnaCodFrom = @sAnaCod
Set @tCntRegDta = @tDocDta
Set @tCntRegDtaIva = @tDocDta
Set @tMagMovDta = @tDocDta
Set @tPagStart = @tDocDta

Select
	@sNumPrefix = NumPrefix,
	@sNumSuffix = NumSuffix,
	@sNumCod = NumCod,
	@sEmiCau = EmiCau,
	@bSegueFt = SegueFt,
	@sCntRegMod = CntRegMod,
	@sMagMovMod = MagMovMod,
	@sMagMovMod2 = MagMovModQNE
From dbo.[udfDD_DocDef](@iSession, 1, @iFormDocTip, @iAnaType, @sAnaCod)

Set @sDocNum = '({DOCNUM})'
If @sNumPrefix <> ''
	Set @sDocNum = @sNumPrefix + '-' + @sDocNum
If @sNumSuffix <> ''
	Set @sDocNum = @sDocNum + '/' + @sNumSuffix

Set @sDocIvaCod = dbo.[udfDD_DocIvaCod](@iFormDocTip, @tDocDta, @sAnaCod, @sDsmCod)

Set @sDivisa = IsNull(@sDivisa, '')
If @sDivisa = ''
	Set @sDivisa = dbo.[udfSysDivisa](@sDivisa)

Select @dCambio = ItemValue, @tCambioDta = ItemDate
From dbo.[udfCambio_info](@sDivisa)

Set @sCntRegMod_ANA = dbo.[udfDD_CntRegMod_ANA](@iAnaType, @sAnaCod, @iFormDocTip, @sNumPrefix, @sNumSuffix)
If IsNull(@sCntRegMod_ANA, '') <> ''
	Set @sCntRegMod = @sCntRegMod_ANA

If IsNull(@sCntRegMod, '') = ''
	Set @sCntRegMod = dbo.[udfDD_CntRegMod](@iFormDocTip, @sNumPrefix, @sNumSuffix)

INSERT @tbDocHead(
	Info,
	DocTip, DocNum, DocDta, DocOra, DocKind,
	AnaType, AnaCod, AnaCodFrom, DsmCod, MndCod,
	PagStart, PagCod, AgeCod, PrvFix, PrvSplitCod,
	LstCod, LstSconti, ShipPayCod, ShipCod, VetCod, VetCod2,
	DocIvaCod, Divisa, Cambio, CambioDta,
	SctTot, SpImballo, SpTra, SpBolli, SpVarie, VetComp,
	Colli, Peso, PesoNetto, Volume,	
	TrPorto, TrMezzo, EmiCau, Imballo, SegueFt,
	Fornitura,
	VsRif, NsRif, NumExt, DocRif,
	SendDta, SendWay, SendInfo, CnsDta, CnsWeek, CnsInfo,
	Info1, Info2, Info3, Info4, Info5, Info6,
	CntRegMod, MagMovMod, MagMovMod2, NumCod,
	CntRegDta, CntRegDtaIva, MagMovDta,
	RecCreate, RecUserID
	)
VALUES (
	@sReturnMSG,
	@iFormDocTip, @sDocNum, @tDocDta, @sTime, @iDocKind,
	@iAnaType, @sAnaCod, @sAnaCodFrom, @sDsmCod, @sMndCod,
	@tPagStart, @sPagCod, @sAgeCod, @dPrvFix, @sPrvSplitCod,
	@sLstCod, @sLstSconti, @sShipPayCod, @sShipCod, @sVetCod, @sVetCod2,
	@sDocIvaCod, @sDivisa, @dCambio, @tCambioDta,
	@dSctTot, @dSpImballo, @dSpTra, @dSpBolli, @dSpVarie, @dVetComp,
	@iColli, @dPeso, @dPesoNetto, @dVolume,
	@iTrPorto, @iTrMezzo, @sEmiCau, @sImballo, @bSegueFt,
	@iFornitura,
	@sVsRif, @sNsRif, @sNumExt, @iDocUniqFrom,
	@tSendDta, @sSendWay, @sSendInfo, @tCnsDta, @iCnsWeek, @sCnsInfo,
	@sInfo1, @sInfo2, @sInfo3, @sInfo4, @sInfo5, @sInfo6,
	@sCntRegMod, @sMagMovMod, @sMagMovMod2, @sNumCod,
	@tCntRegDta, @tCntRegDtaIva, @tMagMovDta,
	@tDate, @iUserID
	)

-- -------------------------------
	RETURN
END