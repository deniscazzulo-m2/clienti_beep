/*
*
*
*
*/
CREATE TRIGGER [dbo].[trgCliOrd_OnDelete]
ON [dbo].[CliOrd]
FOR DELETE
AS
SET NOCOUNT ON
Declare @iDocTip tinyint = 11
Declare @sAttachFrom varchar(32) = dbo.[udfAttachFrom](@iDocTip, 0)

Delete dbo.[CliOrdPar]
Where UniqDoc In(Select Uniq From deleted)

Delete dbo.[CliOrdLin]
Where UniqDoc In(Select Uniq From deleted)

Update dbo.[CliOrdImp_Pers] Set Uniq = null
Where Uniq In(Select Uniq From deleted)

Update dbo.[CliOrdLinImp_Pers] Set UniqDoc = null
Where UniqDoc In(Select Uniq From deleted)

Update dbo.[CliOrdLinParImp_Pers] Set UniqDoc = null, ParID = null
Where UniqDoc In(Select Uniq From deleted)

Delete dbo.[MagMov]
Where Uniq In(
	Select DISTINCT UniqMov
	From dbo.[MagMovLin]
	Where (DocTipFrom = @iDocTip)
		And (UniqFrom In(Select Uniq From deleted))
	)

Delete dbo.[Attach]
Where AttachFrom = @sAttachFrom
	And (DocID In(Select Cast(Uniq As varchar(32)) From deleted))
	And (DocTip = @iDocTip)