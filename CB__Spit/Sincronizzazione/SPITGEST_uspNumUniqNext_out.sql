/*
*	Acquisisce il successivo numero progressivo
*	per un codice in NumUniq e lo ritorna come parametro
*
*   Personalizzata per la sincronizzazione
*
*/
CREATE PROCEDURE [dbo].[uspNumUniqNext_out]
	@sItemID varchar(64),
	@iItemNext decimal(13) OUTPUT
AS
SET NOCOUNT ON

Set @iItemNext = 0

SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
BEGIN TRAN

If EXISTs(
	Select ItemID
	From dbo.[NumUniq]
	Where ItemID = @sItemID
	)
Begin
	Update dbo.[NumUniq] Set
		@iItemNext = ItemLast = IsNull(ItemLast, 0) + 1
	Where ItemID = @sItemID
End
Else
Begin
	Set @iItemNext = 1

	Insert dbo.[NumUniq](ItemID, ItemLast)
	Values(@sItemID, @iItemNext)
End

If @sItemID = 'MixAna1'
Begin
    If EXISTs(
        Select ItemID
        From [BpSPIT].dbo.[NumUniq]
        Where ItemID = @sItemID
        ) Or
        EXISTs(
        Select ItemID
        From [BpSTUDIOISOARDI].dbo.[NumUniq]
        Where ItemID = @sItemID
        )
    Begin
        Update [BpSPIT].dbo.[NumUniq] Set
            ItemLast = @iItemNext
        Where ItemID = @sItemID
        
        Update [BpSTUDIOISOARDI].dbo.[NumUniq] Set
            ItemLast = @iItemNext
        Where ItemID = @sItemID
    End
    Else
    Begin
        Insert [BpSPIT].dbo.[NumUniq](ItemID, ItemLast)
        Values(@sItemID, @iItemNext)
        
        Insert [BpSTUDIOISOARDI].dbo.[NumUniq](ItemID, ItemLast)
        Values(@sItemID, @iItemNext)
    End
End

COMMIT TRAN