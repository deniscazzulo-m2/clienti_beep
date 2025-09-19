/* 
*
*	Ritorna stringa con riferimenti ai documenti di origine
*	da includere nel documento in fase di generazione.
*
*
*	@iDocTip	: tipo di documento in fase di generazione	
*	@iDocTipFrom: tipo di documento di origine (da cui si genera @iDocTip)
*	@iUniqFrom	: numero unico del documento di origine
*
*/
CREATE FUNCTION [dbo].[udfDoc_New_from_rif]
(
	@iDocTip tinyint,
	@iDocTipFrom tinyint,
	@iUniqFrom int
)
RETURNS varchar(1024)
AS
BEGIN
	Declare @iPar2043 int = dbo.[udfEnvironRead_int]('2043')
	Declare @iPar2041 int = dbo.[udfEnvironRead_int]('2041')
	Declare @sRif varchar(512) = ''
	
	Declare @iRifParam int = dbo.[udfEnvironRead_int]('2040')
	If (@iPar2043 = 1)
	Begin
		-- Se impostato a 1 (UNO) determina l'uso dei parametri 2043-DDT e 2043-FT anzichè del parametro 2040.
		If (@iDocTip = 14)
			Set @iRifParam = dbo.[udfEnvironRead_int]('2043-DDT')
		Else If (@iDocTip = 15)
		Begin
			If EXISTS(
				Select UniqFrom
				From dbo.[CliDocLin]
				Where UniqDoc = @iUniqFrom
					And IsNull(DocTipFrom, 0) = 11
					And IsNull(UniqFrom, 0) > 0
				) Set @iRifParam = dbo.[udfEnvironRead_int]('2043-FT-OC')
			Else
				Set @iRifParam = dbo.[udfEnvironRead_int]('2043-FT')
		End
			
	End		
	
	Set @sRif = dbo.[udfDoc_New_from_rif_one](@iRifParam, @iDocTipFrom, @iUniqFrom)
	
	If (@iDocTip = 15) And (@iDocTipFrom = 14) And (@iPar2041 <> 0)
	Begin
		Declare @sCrLf char(2) = char(13) + char(10)
		Declare @sRif_1 varchar(512) = ''
		If @iPar2041 = 1
		Begin
			--INIZIO PERS M2SISTEMI
			--Set @sRif = ''
			Declare @sRif_2 varchar(512) = (Select DocRif From dbo.[CliDoc] Where Uniq = @iUniqFrom)
			Set @sRif_2 = ISNULL(@sRif_2,'')
--			If Len(@sRif_2) = 0
--			Begin
				--Set @sRif = dbo.[udfDoc_New_from_rif_one](@iRifParam, @iDocTipFrom, @iUniqFrom)
				
			Declare [cCursor] Cursor LOCAL FAST_FORWARD For
			Select PrdDes
			From dbo.[CliDocLin]
			Where UniqDoc = @iUniqFrom
				And PrdCod = '.Rif'
			Order By LinNum
			
			Open [cCursor]
			Fetch Next From [cCursor] Into @sRif_1
			While (@@Fetch_Status <> -1)
			Begin
				Set @sRif += @sCrLf + IsNull(@sRif_1, '')
				-- ----------------------------------------------------------
				Fetch Next From [cCursor] Into @sRif_1
			End
			Close [cCursor]
			Deallocate [cCursor]
--			End
--			Else
			If Len(@sRif_2) > 0
				Set @sRif = Concat(@sRif,@sCrLf,'Vostro ordine:',@sCrLf,@sRif_2)
			--FINE PERS M2SISTEMI
		End
		
		Else If @iPar2041 = 2
		Begin
			Declare @iPar2042 int = dbo.[udfEnvironRead_int]('2042')
			Declare @iDocTipFrom_1 tinyint = 11 -- OC
			Declare @iUniqFrom_1 int = 0
	
			Declare [cCursor] Cursor LOCAL FAST_FORWARD For
			Select DISTINCT UniqFrom
			From dbo.[CliDocLin]
			Where UniqDoc = @iUniqFrom
				And IsNull(DocTipFrom, 0) = 11
				And IsNull(UniqFrom, 0) > 0
			
			Open [cCursor]
			Fetch Next From [cCursor] Into @iUniqFrom_1
			While (@@Fetch_Status <> -1)
			Begin
				Set @sRif_1 = dbo.[udfDoc_New_from_rif_one](@iPar2042, @iDocTipFrom_1, @iUniqFrom_1)	
				Set @sRif += @sCrLf + @sRif_1
				-- ----------------------------------------------------------
				Fetch Next From [cCursor] Into @iUniqFrom_1
			End
			Close [cCursor]
			Deallocate [cCursor]
		End
	End -- (@iDocTip = 15) And (@iDocTipFrom = 14) And (@iPar2041 <> 0)
	
	Set @sRif = dbo.[udfDoc_New_from_rif_strip](@sRif)
	
	RETURN @sRif
END