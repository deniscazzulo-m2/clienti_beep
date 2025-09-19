/* 
*	Duplica cliente come fornitore/nuovo cliente
*	Duplica fornitore come cliente/nuovo fornitore
*
*	Ritorna il codice anagrafico di destinazione (nullo se é impossibile procedere)
*	seguito da '|' + eventuale messaggio
*
*   Personalizzata per la sincronizzazione
*
*/
CREATE PROCEDURE [dbo].[uspMixAna_duplicate]
	@iSession int,
	@iItemType tinyint,
	@iItemType_new tinyint,
	@sItemID varchar(16),
	@sItemID_new varchar(16)
AS
SET NOCOUNT ON
Declare @sResponse varchar(1204) = ''
Declare @iItemUse_new tinyint = 0

If @iItemType = @iItemType_new
Begin
	Select @iItemUse_new = ItemUse
	From dbo.[MixAna]
	Where ItemType = @iItemType
		And ItemID = @sItemID
End

Set @iItemUse_new = IsNull(@iItemUse_new, 0)
If @iItemUse_new = 0
	Set @iItemUse_new = Case @iItemType_new When 1 Then 10 Else 20 End

If @sItemID_new = ''
Begin
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
		Set @sResponse = '|Il valore progressivo del nuovo codice supera il numero di caratteri impostati nei parametri aziendali. E'' necessario modificare il parametro oppure provvedere manualmente alla copia dei dati anagrafici.'

	--PERS M2SISTEMI x SINCRONIZZATORE/SYNCHRONIZATION
	--Else If EXISTS(Select TOP 1 ItemID From dbo.[MixAna] Where ItemID = @sItemID_new And ItemType = @iItemType_new)
	Else If EXISTS(Select TOP 1 ItemID From [BpSPIT].dbo.[MixAna] Where ItemID = @sItemID_new And ItemType = @iItemType_new) Or
			EXISTS(Select TOP 1 ItemID From [BpSTUDIOISOARDI].dbo.[MixAna] Where ItemID = @sItemID_new And ItemType = @iItemType_new And @iItemType_new = 1) Or
			EXISTS(Select TOP 1 ItemID From [BpSPITGEST].dbo.[MixAna] Where ItemID = @sItemID_new And ItemType = @iItemType_new And @iItemType_new = 1)
		Set @sResponse = '|Il valore progressivo del nuovo codice determina un duplicato. E'' provvedere manualmente alla copia dei dati anagrafici.'
End

If @sResponse = ''
Begin
	--
	-- OK
	--
	-- ItemType, ItemUse, ItemID, ItemAlert, ItemHide, ItemPriority, ItemDes, ItemDesShort, ItemIDFat, ItemIDStat, ItemIDOther, ItemNoMail, ItemNoSMS, Ind, Cap, Loc, Pro, Reg, Naz, PIva, CFis, www, PosArc, LstCod, PagCod, Sconti, GrpCod, CatCod, AgeCod, AgeName, PrvCla, PrvFix, PrvFixOff, PrvFrom, PrdCat, ShipCod, VetCod, VetCod2, AerCod, ShipPayCod, TrMezzo, TrPorto, TrImballo, TrFDeposito, NumCCIAA, NumDitte, NumTrib, NumIstat, NumMat, NumAlbo, CapSoc, Language, Divisa, AutTD, AutDta, BanCod, Banca, BanCC, BanABI, BanCAB, BanCIN, BanCheck, BanIBAN, BanBIC, CntCpt, CntCpt2, CntCpt3, CntGrp, CntCau, CntRegMod, EmiFtRiep, EmiRbRiep, IvaCod, IvaCod2, IvaCod3, IvaDelay, Fido, FidoAlert, FidoStop, PFisica, NatoData, NatoLuogo, NatoCAP, NatoProv, Sesso, PosFam, NetCod, AutoCod, CasCod, Info1, Info2, Info3, Info4, Info5, Info6, Info7, Info8, Info9, Tab1, Tab2, Tab3, Tab4, Tab5, Tab6, Tab7, Tab8, Tab9, ItemMemo, ItemInfo, RecCreate, RecUserID, RecChange, RecChangeUserID, RecCompany, RecAgency, RecLocked, RecType
	
	Declare @iUserID smallint = dbo.[udfSysUserID](@iSession)
	Declare @tDate date = dbo.[udfSysDate]()

	Insert dbo.[MixAna](
		  ItemType
		, ItemUse
		, ItemID 
		, ItemAlert, ItemHide, ItemPriority, ItemDes, ItemDesShort, ItemIDFat, ItemIDStat, ItemIDOther, ItemNoMail, ItemNoSMS, Ind, Cap, Loc, Pro, Reg, Naz, PIva, CFis, www, PosArc, LstCod, PagCod, Sconti, GrpCod, CatCod, AgeCod, AgeName, PrvCla, PrvFix, PrvFixOff, PrvFrom, PrdCat, ShipCod, VetCod, VetCod2, AerCod, ShipPayCod, TrMezzo, TrPorto, TrImballo, TrFDeposito, NumCCIAA, NumDitte, NumTrib, NumIstat, NumMat, NumAlbo, CapSoc, Language, Divisa, AutTD, AutDta, BanCod, Banca, BanCC, BanABI, BanCAB, BanCIN, BanCheck, BanIBAN, BanBIC, CntCpt, CntCpt2, CntCpt3, CntGrp, CntCau, CntRegMod, EmiFtRiep, EmiRbRiep, EmiDocWe, IvaCod, IvaCod2, IvaCod3, IvaDelay, Fido, FidoAlert, FidoStop, PFisica, NatoData, NatoLuogo, NatoCAP, NatoProv, Sesso, PosFam, NetCod, AutoCod, CasCod, Info1, Info2, Info3, Info4, Info5, Info6, Info7, Info8, Info9, Tab1, Tab2, Tab3, Tab4, Tab5, Tab6, Tab7, Tab8, Tab9, ItemMemo, ItemInfo 
		, RecCreate 
		, RecUserID 
		, RecChange 
		, RecAgency 
		, RecLocked
		, FepaType, FepaEsgIva, FepaDest, FepaPEC, FepaEori
		)
	Select
		  @iItemType_new As ItemType
		, @iItemUse_new As ItemUse
		, @sItemID_new As ItemID
		, ItemAlert, ItemHide, ItemPriority, ItemDes, ItemDesShort, ItemIDFat, ItemIDStat, ItemIDOther, ItemNoMail, ItemNoSMS, Ind, Cap, Loc, Pro, Reg, Naz, PIva, CFis, www, PosArc, LstCod, PagCod, Sconti, GrpCod, CatCod, AgeCod, AgeName, PrvCla, PrvFix, PrvFixOff, PrvFrom, PrdCat, ShipCod, VetCod, VetCod2, AerCod, ShipPayCod, TrMezzo, TrPorto, TrImballo, TrFDeposito, NumCCIAA, NumDitte, NumTrib, NumIstat, NumMat, NumAlbo, CapSoc, Language, Divisa, AutTD, AutDta, BanCod, Banca, BanCC, BanABI, BanCAB, BanCIN, BanCheck, BanIBAN, BanBIC, CntCpt, CntCpt2, CntCpt3, CntGrp, CntCau, CntRegMod, EmiFtRiep, EmiRbRiep, EmiDocWe, IvaCod, IvaCod2, IvaCod3, IvaDelay, Fido, FidoAlert, FidoStop, PFisica, NatoData, NatoLuogo, NatoCAP, NatoProv, Sesso, PosFam, NetCod, AutoCod, CasCod, Info1, Info2, Info3, Info4, Info5, Info6, Info7, Info8, Info9, Tab1, Tab2, Tab3, Tab4, Tab5, Tab6, Tab7, Tab8, Tab9, ItemMemo, ItemInfo
		, @tDate As RecCreate
		, @iUserID As RecUserID
		, @tDate As RecChange
		, @iUserID As RecChangeUserID
		, 0 As RecLocked
		, FepaType, FepaEsgIva, FepaDest, FepaPEC, FepaEori
	From dbo.[MixAna]
	Where ItemType = @iItemType
		And ItemID = @sItemID
	
	--
	-- MixAnaSedi
	--
	Insert dbo.[MixAnaSedi](
		  ItemType
		, ItemID
		, ItemIDSede, ItemUse, ItemDsm, ItemDes, Ind, Cap, Loc, Pro, Reg, Naz, Language, www, LstCod, PagCod, Sconti, GrpCod, CatCod, AgeCod, PrvCla, PrvFix, PrvFixOff, ShipCod, VetCod, VetCod2, AerCod, ShipPayCod, TrMezzo, TrPorto, TrImballo, TrFDeposito, TrSendWay, Info1, Info2, Info3, Info4, Info5, Info6, Info7, Info8, Info9, Tab1, Tab2, Tab3, Tab4, Tab5, Tab6, Tab7, Tab8, Tab9, ItemInfo
		, RecCreate
		, RecUserID
		, RecChange
		, RecChangeUserID
		, RecLocked
		, RecType
		)
	Select
		  @iItemType_new As ItemType
		, @sItemID_new As ItemID
		, ItemIDSede, ItemUse, ItemDsm, ItemDes, Ind, Cap, Loc, Pro, Reg, Naz, Language, www, LstCod, PagCod, Sconti, GrpCod, CatCod, AgeCod, PrvCla, PrvFix, PrvFixOff, ShipCod, VetCod, VetCod2, AerCod, ShipPayCod, TrMezzo, TrPorto, TrImballo, TrFDeposito, TrSendWay, Info1, Info2, Info3, Info4, Info5, Info6, Info7, Info8, Info9, Tab1, Tab2, Tab3, Tab4, Tab5, Tab6, Tab7, Tab8, Tab9, ItemInfo
		, @tDate As RecCreate
		, @iUserID As RecUserID
		, @tDate As RecChange
		, @iUserID As RecChangeUserID
		, 0 As RecLocked
		, RecType
	From dbo.[MixAnaSedi]
	Where ItemType = @iItemType
		And ItemID = @sItemID		

	--
	-- MixAnaRif
	--
	Insert dbo.[MixAnaRif](
		  ItemType
		, ItemID
		, ItemIDSede, ItemIDRif, ItemDefault, ItemUse, ItemDes, WhoTitle, WhoName, WhoPos, Tel1, Tel2, Tel3, MailAddress, MailAddressPEC, VoIP1, VoIP2, VoIP3, ItemInfo
		, RecCreate
		, RecUserID
		, RecChange
		, RecChangeUserID
		, RecLocked
		, RecType
		)
	Select
		  @iItemType_new As ItemType
		, @sItemID_new As ItemID
		, ItemIDSede, ItemIDRif, ItemDefault, ItemUse, ItemDes, WhoTitle, WhoName, WhoPos, Tel1, Tel2, Tel3, MailAddress, MailAddressPEC, VoIP1, VoIP2, VoIP3, ItemInfo
		, @tDate As RecCreate
		, @iUserID As RecUserID
		, @tDate As RecChange
		, @iUserID As RecChangeUserID
		, 0 As RecLocked
		, RecType
	From dbo.[MixAnaRif]
	Where ItemType = @iItemType
		And ItemID = @sItemID
	
	Set @sResponse = @sItemID_new + '|'
End

Select @sResponse As Response