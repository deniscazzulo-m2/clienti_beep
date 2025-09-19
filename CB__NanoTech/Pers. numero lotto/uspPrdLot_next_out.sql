/*
*
*
*
*/
CREATE PROCEDURE [dbo].[uspPrdLot_next_out]
	@sPrdCod varchar(32),
	@sPrdLot varchar(32) OUTPUT
AS
SET NOCOUNT ON

/****************************************************************
Maschera di composizione  - Environ ParName 1110
[YYYY]: anno a 4 cifre
[YY]: anno a 2 cifre
[MM]: mese a 2 cifre
[WW]: settimana dell'anno
[DW]: giorno della settimana
[DD]: giorno
[HH]: ore
[MI]: minuti
[NP]: numero progressivo, relativo al prodotto (5 cifre), esclude [NA]
[NA]: numero progressivo assoluto (6 cifre), esclude [NP]

[PRD]: codice prodotto
[PRD>nn]: parte iniziale del codice prodotto, nn=numero di caratteri iniziali
[PRD<nn]: parte finale del codice prodotto, nn=numero di caratteri finali
[PRD-nn1-nn2]: parte del codice prodotto, nn1=posizione carattere di partenza, nn2=numero di caratteri
NOTA: nn, nn1 e nn2 devono sempre essere composti di 2 cifre
****************************************************************/

Declare @sMask varchar(32) = dbo.[udfEnvironRead]('1110')
Declare @sMaskNN varchar(32)
Declare @iChar int
Declare @iN1 int
Declare @iN2 int

Set @sMask = IsNull(@sMask, '')
If @sMask <> ''
BEGIN
	Declare @sItemID varchar(64) = ''
	Declare @iItemNext decimal(13) = 0
	Declare @tDate datetime = GetDate()

	Set @sPrdCod = IsNull(@sPrdCod, '')

	Set @sMask = Replace(@sMask, '[YYYY]', Cast(DATEPART(yyyy, @tDate) As varchar(8)))
	Set @sMask = Replace(@sMask, '[YY]', Right(Cast(100 + DATEPART(yy, @tDate) As varchar(8)), 2))
	Set @sMask = Replace(@sMask, '[MM]', Right(Cast(100 + DATEPART(mm, @tDate) As varchar(8)), 2))
	Set @sMask = Replace(@sMask, '[WW]', Right(Cast(100 + DATEPART(ww, @tDate) As varchar(8)), 2))
	Set @sMask = Replace(@sMask, '[DW]', Right(Cast(100 + DATEPART(dw, @tDate) As varchar(8)), 2))
	Set @sMask = Replace(@sMask, '[DD]', Right(Cast(100 + DATEPART(dd, @tDate) As varchar(8)), 2))
	Set @sMask = Replace(@sMask, '[HH]', Right(Cast(100 + DATEPART(hh, @tDate) As varchar(8)), 2))
	Set @sMask = Replace(@sMask, '[MI]', Right(Cast(100 + DATEPART(mi, @tDate) As varchar(8)), 2))
	Set @sMask = Replace(@sMask, '[PRD]', Upper(@sPrdCod))

	Set @iChar = CHARINDEX('[PRD>', @sMask)
	If @iChar > 0
	Begin
		--[PRD>nn]: Left
		Set @sMaskNN = SUBSTRING (@sMask, @iChar, @iChar + 5)
		Set @iN1 = dbo.[udfC_Int](SUBSTRING (@sMaskNN, 6, 2))
		If @iN1 > 0
			Set @sMask = Replace(@sMask, @sMaskNN, Upper(Left(@sPrdCod, @iN1)))
	End

	Set @iChar = CHARINDEX('[PRD<', @sMask)
	If @iChar > 0
	Begin
		--[PRD<nn]: Right
		Set @sMaskNN = SUBSTRING (@sMask, @iChar, @iChar + 5)
		Set @iN1 = dbo.[udfC_Int](SUBSTRING (@sMaskNN, 6, 2))
		If @iN1 > 0
			Set @sMask = Replace(@sMask, @sMaskNN, Upper(Right(@sPrdCod, @iN1)))
	End

	Set @iChar = CHARINDEX('[PRD-', @sMask)
	If @iChar > 0
	Begin
		--[PRD-nn1-nn2]: Substring
		Set @sMaskNN = SUBSTRING (@sMask, @iChar, @iChar + 8)
		Set @iN1 = dbo.[udfC_Int](SUBSTRING (@sMaskNN, 6, 2))
		Set @iN2 = dbo.[udfC_Int](SUBSTRING (@sMaskNN, 9, 2))
		If (@iN1 > 0) And (@iN2 > 0)
			Set @sMask = Replace(@sMask, @sMaskNN, Upper(Substring(@sPrdCod, @iN1, @iN2)))
	End

	If CHARINDEX('[NP]', @sMask) > 0
	Begin
		Set @sItemID = 'PrdLotto:' + @sPrdCod
		Execute dbo.[uspNumUniqNext_out] @sItemID, @iItemNext OUTPUT
		Set @sMask = Replace(@sMask, '[NP]', Right('00000' + Cast(@iItemNext As varchar(8)), 5))
	End
	Else If CHARINDEX('[NA]', @sMask) > 0
	Begin
		Set @sItemID = 'PrdLotto:any'
		Execute dbo.[uspNumUniqNext_out] @sItemID, @iItemNext OUTPUT
		Set @sMask = Replace(@sMask, '[NA]', Right('000000' +  + Cast(@iItemNext As varchar(8)), 6))
	End
	Else If CHARINDEX('[NPP]', @sMask) > 0 -- PERS M2SISTEMI
	Begin
		Set @sItemID = Concat('PrdLotto:',Cast(Year(GETDATE()) As varchar),'.',Right('00' + Cast(Month(GETDATE()) As varchar), 2))
		Execute dbo.[uspNumUniqNext_out] @sItemID, @iItemNext OUTPUT
		Set @sMask = Replace(@sMask, '[NPP]', Right('00' +  + Cast(@iItemNext As varchar(8)), 2))
	End
	
	--	--
	--	-- Insert in PrdLotAna
	--	--
	--	Set @iItemNext = 0
	--	Execute dbo.[uspNumUniqNext_out] 'PrdLotto', @iItemNext OUTPUT
	--	
	--	Insert dbo.[PrdLotAna](
	--		PrdLottoID, 
	--		PrdCod, PrdLotto, ItemDes, 
	--		DtaStart, 
	--		ItemType, ItemStatus
	--		)
	--	Values(
	--		@iItemNext,
	--		@sPrdCod, @sMask, 'LOTTO ' + @sMask,
	--		@tDate,
	--		120, 1
	--		)
	
END

-- Select @sMask As ItemNext
Set @sPrdLot = @sMask