/*
*	Aggiorna il numero progressivo
*	per un codice in NumUniq
*
*   Personalizzata per la sincronizzazione
*
*/
CREATE PROCEDURE [dbo].[uspNumUniqUpdate]
	@sItemID varchar(64),
	@iItemLast decimal(13)
AS
SET NOCOUNT ON

SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
BEGIN TRAN

If @sItemID = 'MixAna1'
Begin
    If EXISTs(
        Select ItemID
        From [BpSTUDIOISOARDI].dbo.[NumUniq]
        Where ItemID = @sItemID
        ) Or
        EXISTs(
        Select ItemID
        From [BpSPITGEST].dbo.[NumUniq]
        Where ItemID = @sItemID
        )
    Begin
        Update [BpSTUDIOISOARDI].dbo.[NumUniq] Set
            ItemLast = IsNull(@iItemLast, 0)
        Where ItemID = @sItemID
        
        Update [BpSPITGEST].dbo.[NumUniq] Set
            ItemLast = IsNull(@iItemLast, 0)
        Where ItemID = @sItemID
    End
    Else
    Begin
        Insert [BpSTUDIOISOARDI].dbo.[NumUniq](ItemID, ItemLast)
        Values(@sItemID, @iItemLast)
        
        Insert [BpSPITGEST].dbo.[NumUniq](ItemID, ItemLast)
        Values(@sItemID, @iItemLast)
    End
End
If EXISTs(
	Select ItemID
	From dbo.[NumUniq]
	Where ItemID = @sItemID
	)
Begin
	Update dbo.[NumUniq] Set
		ItemLast = IsNull(@iItemLast, 0)
	Where ItemID = @sItemID
End
Else
Begin
	Insert dbo.[NumUniq](ItemID, ItemLast)
	Values(@sItemID, @iItemLast)
End

COMMIT TRAN