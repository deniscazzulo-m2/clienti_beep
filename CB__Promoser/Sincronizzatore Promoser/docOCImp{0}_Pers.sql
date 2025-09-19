--###############################################################################
----------------------------------Indice 0---------------------------------------
--###############################################################################
Select
	ROW_NUMBER() OVER (ORDER BY LIN.id_lin) As LinNum
	, '' As LinStatSigla
	, 'N' As LinStatStyle
	, 0 As LinStat
	, 0 As LinLavStadio
	, 0 As LinStatFrom
	, 0 As LinSaldo
	, 0 As QtaEvs
	, 0 As QtaEvs2
	, 0 As LinOmg
	-- '' As buttonPlus
	, null As PrdCod
	, (Case When (IsNull(LIN.variation_id, '') = '') Then (Case When IsNull(LIN.product_id, '') = '' Then (null) Else (LIN.product_id) End) Else (LIN.variation_id) End) As PrdCod2
	, null As ForCod
	, null As PrdForCod
	, null As PrzAcq
	, null As PrdParams
	, null As PrdSerial
	, null As PrdLotto
	, null As PrdDtaMake
	, null As PrdDtaCns
	, (Case When (IsNull(LIN.name, '') = '') Then (Case When IsNull(LIN.parent_name, '') = '' Then (null) Else (LIN.parent_name) End) Else (LIN.name) End) As PrdDes
	, null As PrdUm2
	, null As QtaUm2
	, null As PrdQtaCnsNow
	, 'NR' As PrdUm
	, LIN.quantity As PrdQta
	, null As PrdQta2
	, LIN.price As PrdPrz
	, 0 As PrdSc
	, LIN.price As PrdPrz2
	, 0 As PrdAdd
	, (Case When (IsNull(LIN.total, 0) = 0) Then (Case When IsNull(LIN.subtotal, 0) = 0 Then (null) Else (LIN.subtotal + IsNull(LIN.subtotal_tax, 0)) End) Else (LIN.total + IsNull(LIN.total_tax, 0)) End) As TotPrz2
	, LIN.sku As LinRif
	, null As LinType
	, (Case When (DOC.tax_rate_code = 'IT-IVA-1') Then ('01') Else (null) End) As IvaCod
	, DOC.tax_rate_percent As IvaAlq
	, 0 As PrvAlq
	, null As PrvAgeCod
	, null As CptCnt
	, null As CdcModel
	, null As CdcCommessa
	, (Case When (LIN.origin = 'adunata') Then ('ADUNATASTORE') Else ('BASE') End) As PrzLstCod
	, 0 As PrzLst
	, 0 As TotPrz
	, null As TotPrz2C
	, null As TotPrz2S
	, null As TotDivisaP
	, 0 As TotQta2
	, null As Info
	, null As InfoExt
	, 10 As PrdUso
	, 1 As Tm
	, 1 As TmCalc
	, null As LinMP
	, null As LinRistFrom
	, null As DocTipFrom
	, null As UniqFrom
	, null As UniqStp
	, null As UniqStpGrp
	, null As UniqStpDta
	, null As UniqLinFrom
	, null As MustSpool
	, null As ElabNum
	, null As ElabLavNum
	, null As SpedMagMoved
	, null As FormCod
	, null As DibaCod
	, 0 As OffCod
	, 0 As OffQta
	, 0 As OffMinFt
	, 0 As OffMinFt1
	, 0 As OffMinFt2
	, 0 As OffPrvFix
	-- ,  As Uniq
	-- ,  As UniqDoc
	-- ,  As Uniq2
	-- ,  As UniqDoc2
	, DOC.date_created As RowCreate
	, {(Session)} As RowUserID
	, DOC.date_modified As RowChange
	, {(Session)} As RowChangeUserID
	, 0 As RowLocked
	, 0 As RowPrinted
From dbo.[CliOrdLinImp_Pers] LIN
Join dbo.[CliOrdImp_Pers] DOC On LIN.origin = DOC.origin And LIN.id = DOC.id
Where origin = (0) And id = (1)
Order By LinNum

--###############################################################################
----------------------------------Indice 1---------------------------------------
--###############################################################################
Select A.*
    , Concat(
        (Case When (IsNull(DOC.billing_last_name, '') = '') Then (IsNull(DOC.shipping_last_name, '') = '') Else (DOC.billing_last_name) End)
        , ' '
        , (Case When (IsNull(DOC.billing_first_name, '') = '') Then (IsNull(DOC.shipping_first_name, '') = '') Else (DOC.billing_first_name) End)
        , (Case When (IsNull(DOC.billing_company, '') = '') Then (
            (Case When (IsNull(DOC.shipping_company, '') = '') Then ('') Else (Concat(' - ', DOC.shipping_company)) End)
        ) Else (Concat(' - ', DOC.billing_company)) End)
    ) As ItemDes
    , (
        Case When (IsNull(DOC.billing_address_1, '') = '') Then (
            Case When IsNull(DOC.billing_address_2, '') = '' Then (
                Case When (IsNull(DOC.shipping_address_1, '') = '') Then (
                    Case When IsNull(DOC.shipping_address_2, '') = '' Then (
                        null
                    ) Else (DOC.shipping_address_2) End
                ) Else (DOC.shipping_address_1) End
            ) Else (DOC.billing_address_2) End
        ) Else (DOC.billing_address_1) End
    ) As Ind
    , (
        Case When (IsNull(DOC.billing_city, '') = '') Then (
            Case When (IsNull(DOC.shipping_city, '') = '') Then (
                null
            ) Else (DOC.shipping_city) End
        ) Else (DOC.billing_city) End
    ) As Loc
    , (
        Case When (IsNull(DOC.billing_state, '') = '') Then (
            Case When (IsNull(DOC.shipping_state, '') = '') Then (
                null
            ) Else (DOC.shipping_state) End
        ) Else (DOC.billing_state) End
    ) As Pro
    , (
        Case When (IsNull(DOC.billing_country, '') = '') Then (
            Case When (IsNull(DOC.shipping_country, '') = '') Then (
                null
            ) Else (DOC.shipping_country) End
        ) Else (DOC.billing_country) End
    ) As Naz
    , (
        Case When (IsNull(DOC.billing_phone, '') = '') Then (
            Case When (IsNull(DOC.shipping_phone, '') = '') Then (
                null
            ) Else (DOC.shipping_phone) End
        ) Else (DOC.billing_phone) End
    ) As 'Telefono'
    , null As PIva
    , null As CFis
From dbo.[CliOrdImp_Pers] A
Where origin = (0) And id = (1)