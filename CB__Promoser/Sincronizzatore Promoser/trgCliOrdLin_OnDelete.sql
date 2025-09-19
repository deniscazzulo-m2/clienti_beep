/*
*
*
*
*/
CREATE TRIGGER [dbo].[trgCliOrdLin_OnDelete]
ON [dbo].[CliOrdLin]
FOR DELETE
AS
SET NOCOUNT ON
Declare @iDocTip tinyint = 11
Declare @iDocTipFrom tinyint
Declare @iUniqLinFrom int

Delete dbo.[CliOrdLinPar]
Where UniqLin In(Select Uniq From deleted)

Update dbo.[CliOrdLinImp_Pers] Set Uniq = null
Where Uniq In(Select Uniq From deleted)

Update dbo.[CliOrdLinParImp_Pers] Set UniqLin = null, ParID = null
Where UniqLin In(Select Uniq From deleted)

Delete dbo.[CliOrdLinLife]
Where UniqLin In(Select Uniq From deleted)

Delete dbo.[CliOrdLinDiba]
Where UniqLin In(Select Uniq From deleted)

Delete dbo.[CliOrdLinDibaSH]
Where UniqLin In(Select Uniq From deleted)

Delete dbo.[DibaElabValues]
Where (ElabDocUniqLin In(Select Uniq From deleted))
	And (ElabDocTip = @iDocTip)

-- ===================================================================
-- allineamento evasione merce
--
Declare [cCursor] Cursor FAST_FORWARD LOCAL For
Select DocTipFrom, UniqLinFrom
From deleted
Where IsNull(UniqLinFrom, 0) <> 0

Open [cCursor]
Fetch Next From [cCursor] Into @iDocTipFrom, @iUniqLinFrom
While (@@Fetch_Status <> -1)
Begin
	Execute dbo.[uspDD_LinEvs_update] 1, @iDocTipFrom, @iUniqLinFrom
	-- ---------------------------------------------------------------
	Fetch Next From [cCursor] Into @iDocTipFrom, @iUniqLinFrom
End
Close [cCursor]
Deallocate [cCursor]
-- ===================================================================