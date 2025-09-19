/* 
*
*
*
*/
CREATE TRIGGER [trgCliOrdLinImp_Pers_OnInsertUpdate]
ON [dbo].[CliOrdLinImp_Pers]
FOR INSERT, UPDATE
AS
SET NOCOUNT ON
IF UPDATE (sku)
Begin
	Declare @sPrdCod varchar(32)
	Declare @sSku varchar(64)
	Declare @sOrigin varchar(16)
	Declare @iId int
	Declare @iIdLin int
	
	Declare [cCursor] Cursor FAST_FORWARD LOCAL For
	Select origin, id, id_lin, sku
	From inserted
	Where IsNull(sku, '') <> '' And origin = 'promoser'
	
	Open [cCursor]
	Fetch Next From [cCursor] Into @sOrigin, @iId, @iIdLin, @sSku
	While (@@Fetch_Status <> -1)
	Begin
		Set @sPrdCod = dbo.[udfStrBetween](@sSku, '(#', ')', 0)
		If IsNull(@sPrdCod, '') <> ''
		Begin
			Select @sPrdCod = dbo.[udfStrBetween](display_value, '(#', ')', 0) From dbo.[CliOrdLinParImp_Pers] 
			Where origin = @sOrigin And id = @iId And id_lin = @iIdLin 
			And IsNull((Select Top 1 1 From dbo.[PrdAna] Where PrdCod = (dbo.[udfStrBetween](display_value, '(#', ')', 0))), 0) <> 0
		End
		Set @sPrdCod = IsNull(@sPrdCod, '')
		If @sPrdCod <> '' And IsNull((Select Top 1 1 From dbo.[PrdAna] Where PrdCod = @sPrdCod), 0) <> 0
		Begin
			Update dbo.[CliOrdLinImp_Pers] Set PrdCod = @sPrdCod
			Where origin = @sOrigin And id = @iId And id_lin = @iIdLin
		End
		Else If IsNull(@sPrdCod, '') = 'express'
		Begin
			Update dbo.[CliOrdLinImp_Pers] Set PrdCod = '--'
			Where origin = @sOrigin And id = @iId And id_lin = @iIdLin
		End
		Else
		Begin
			Update dbo.[CliOrdLinImp_Pers] Set PrdCod = null
			Where origin = @sOrigin And id = @iId And id_lin = @iIdLin
		End
		-- ----------------------------------------------------------
		Fetch Next From [cCursor] Into @sOrigin, @iId, @iIdLin, @sSku
	End
	Close [cCursor]
	Deallocate [cCursor]
End