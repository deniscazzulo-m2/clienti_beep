/*
*
*	@iReturnType
*		0, 1: distinta di PRODUZIONE, da tabella DibaElabValues
*		 	0: compatta,  1: esplosione distinta
*		10, 11: distinta di PRODUZIONE, da tabella PrdPrzBuildDibaElab
*		 	10: compatta,  11: esplosione distinta
*		20, 21: distinta di PRODUZIONE, da tabella WorkOdpDibaElabValues
*		 	20: compatta,  21: esplosione distinta
*
*
*/
CREATE PROCEDURE [dbo].[uspDibaElab_return_Pers]
	@iElabID int,
	@iReturnType tinyint
AS
SET NOCOUNT ON
Declare @tbDibaCompact TABLE(
		[GroupSort] tinyint NULL,
		[DibaItemID] varchar(32) NULL,
		[LinCod] varchar(32) NULL,
		[LinTot] decimal(19, 6) NULL,
		[LinDes] varchar(256) NULL
		)

Set @iReturnType = IsNull(@iReturnType, 0)

If @iReturnType = 0
BEGIN
	--
	-- distinta PRODUZIONE, vista COMPATTA da DibaElabValues
	--
	INSERT @tbDibaCompact(GroupSort, DibaItemID, LinCod, LinTot, LinDes)
	Select
		1 As GroupSort,
		DibaItemID,
		LinCod,
		DibaTot As LinTot,
		LinDes
	From dbo.[DibaElabValues]
	Where ElabID = @iElabID
		And DibaItemID = '(i)'
		And IsNull(LinCod, '') Not In('-t-', '-tot-', '---')

	UNION
	
	Select
		2 As GroupSort,
		'(i)' As DibaItemID,
		'---' As LinCod,
		NULL As LinTot,
		NULL LinDes

	UNION
	
	Select
		3 As GroupSort,
		ELAB.DibaItemID,
		NULL As LinCod,
		Sum(ELAB.LinTot) As LinTot,
		Max(ANA.PrdDes) As LinDes
	From dbo.[DibaElabValues] ELAB
	Left Join dbo.[PrdAna] ANA On ANA.PrdCod = ELAB.DibaItemID
	Where ELAB.ElabID = @iElabID
		And IsNull(ELAB.ElabLiv, 0) = 0
		And ELAB.DibaItemID <> '(i)'
	Group By ELAB.DibaItemID

	UNION
	
	Select
		4 As GroupSort,
		'(i)' As DibaItemID,
		'---' As LinCod,
		NULL As LinTot,
		NULL LinDes

	UNION
	
	Select
		5 As GroupSort,
		DibaItemID,
		NULL As LinCod,
		Sum(LinTot) As LinTot,
		NULL As LinDes
	From dbo.[DibaElabValues]
	Where ElabID = @iElabID
		And IsNull(ElabLiv, 0) > 0
		And DibaItemID <> '(i)'
	Group By DibaItemID
	Having Sum(LinTot) <> 0


	-- ---------------------------------------------
	Update @tbDibaCompact Set
		LinDes = (
			Select TOP 1 LinDes
			From dbo.[DibaLin] LIN 
			Where LIN.LinCod = TB.DibaItemID
			)
	From @tbDibaCompact TB
	Where GroupSort = 5
	
	Update @tbDibaCompact Set
		LinDes = (
			Select TOP 1 PrdDes
			From dbo.[PrdAna] ANA  
			Where ANA.PrdCod = TB.DibaItemID
			)
	From @tbDibaCompact TB
	Where GroupSort = 5
		And IsNull(LinDes, '') = ''
	-- ---------------------------------------------
	Select *
	From @tbDibaCompact
	Order BY GroupSort, DibaItemID

END -- @iReturnType = 0

Else If @iReturnType = 1
BEGIN
	--
	-- esplosione DETTAGLIATA da DibaElabValues
	--
	Select
		ElabID, ElabLiv,
		DibaItemID,	IsSDiba,
		LinNum, LinCod,
		dbo.[udfMixAna_DES](0, 2, (dbo.[udfPrdCod_ForCod](LinCod))) ItemID, --PERS M2SISTEMI
		-- ANA.DisCod, 
		LinDes, LinUm, LinQta, LinPrz, LinCServ, LinTot, DibaTot,
		IsSMade,
		DibaRowID, DibaType, ElabRow, ElabDibaCod, ElabPrdCod,
		ElabStep, ElabSort, UniqRow
	From dbo.[DibaElabValues]
	Where ElabID = @iElabID
		And IsNull(LinCod, '') <> '#'
	Order By ElabStep, ElabSort, ElabRow
END -- @iReturnType = 1

Else If @iReturnType = 10
BEGIN
	--
	-- distinta PRODUZIONE, vista COMPATTA da PrdPrzBuildDibaElab
	--
	INSERT @tbDibaCompact(GroupSort, DibaItemID, LinCod, LinTot, LinDes)
	Select
		1 As GroupSort,
		DibaItemID,
		LinCod,
		DibaTot As LinTot,
		LinDes
	From dbo.[PrdPrzBuildDibaElab]
	Where ElabID = @iElabID
		And DibaItemID = '(i)'
		And IsNull(LinCod, '') Not In('-t-', '-tot-', '---')

	UNION
	
	Select
		2 As GroupSort,
		'(i)' As DibaItemID,
		'---' As LinCod,
		NULL As LinTot,
		NULL LinDes

	UNION
	
	Select
		3 As GroupSort,
		ELAB.DibaItemID,
		NULL As LinCod,
		Sum(ELAB.LinTot) As LinTot,
		Max(ANA.PrdDes) As LinDes
	From dbo.[PrdPrzBuildDibaElab] ELAB
	Left Join dbo.[PrdAna] ANA On ANA.PrdCod = ELAB.DibaItemID
	Where ELAB.ElabID = @iElabID
		And IsNull(ELAB.ElabLiv, 0) = 0
		And ELAB.DibaItemID <> '(i)'
	Group By ELAB.DibaItemID

	UNION
	
	Select
		4 As GroupSort,
		'(i)' As DibaItemID,
		'---' As LinCod,
		NULL As LinTot,
		NULL LinDes

	UNION
	
	Select
		5 As GroupSort,
		DibaItemID,
		NULL As LinCod,
		Sum(LinTot) As LinTot,
		NULL As LinDes
	From dbo.[PrdPrzBuildDibaElab]
	Where ElabID = @iElabID
		And IsNull(ElabLiv, 0) > 0
		And DibaItemID <> '(i)'
	Group By DibaItemID
	Having Sum(LinTot) <> 0


	-- ---------------------------------------------
	Update @tbDibaCompact Set
		LinDes = (
			Select TOP 1 LinDes
			From dbo.[DibaLin] LIN 
			Where LIN.LinCod = TB.DibaItemID
			)
	From @tbDibaCompact TB
	Where GroupSort = 5
	
	Update @tbDibaCompact Set
		LinDes = (
			Select TOP 1 PrdDes
			From dbo.[PrdAna] ANA  
			Where ANA.PrdCod = TB.DibaItemID
			)
	From @tbDibaCompact TB
	Where GroupSort = 5
		And IsNull(LinDes, '') = ''
	-- ---------------------------------------------
	Select *
	From @tbDibaCompact
	Order BY GroupSort, DibaItemID
END -- @iReturnType = 10

Else If @iReturnType = 11
BEGIN
	--
	-- esplosione DETTAGLIATA da PrdPrzBuildDibaElab
	--
	Select
		ElabID, ElabLiv,
		DibaItemID,	IsSDiba,
		LinNum, LinCod, LinDes, LinUm, LinQta, LinPrz, LinTot, DibaTot,
		IsSMade,
		DibaRowID, DibaType, ElabRow, ElabDibaCod, ElabPrdCod,
		ElabStep, ElabSort, UniqRow
	From dbo.[PrdPrzBuildDibaElab]
	Where ElabID = @iElabID
		And IsNull(LinCod, '') <> '#'
	Order By ElabStep, ElabSort, ElabRow
END -- @iReturnType = 11


Else If @iReturnType = 20
BEGIN
	--
	-- distinta PRODUZIONE, vista COMPATTA da WorkOdpDibaElabValues
	--
	INSERT @tbDibaCompact(GroupSort, DibaItemID, LinCod, LinTot, LinDes)
	Select
		1 As GroupSort,
		DibaItemID,
		LinCod,
		DibaTot As LinTot,
		LinDes
	From dbo.[WorkOdpDibaElabValues]
	Where ElabID = @iElabID
		And DibaItemID = '(i)'
		And IsNull(LinCod, '') Not In('-t-', '-tot-', '---')

	UNION
	
	Select
		2 As GroupSort,
		'(i)' As DibaItemID,
		'---' As LinCod,
		NULL As LinTot,
		NULL LinDes

	UNION
	
	Select
		3 As GroupSort,
		ELAB.DibaItemID,
		NULL As LinCod,
		Sum(ELAB.LinTot) As LinTot,
		Max(ANA.PrdDes) As LinDes
	From dbo.[WorkOdpDibaElabValues] ELAB
	Left Join dbo.[PrdAna] ANA On ANA.PrdCod = ELAB.DibaItemID
	Where ELAB.ElabID = @iElabID
		And IsNull(ELAB.ElabLiv, 0) = 0
		And ELAB.DibaItemID <> '(i)'
	Group By ELAB.DibaItemID

	UNION
	
	Select
		4 As GroupSort,
		'(i)' As DibaItemID,
		'---' As LinCod,
		NULL As LinTot,
		NULL LinDes

	UNION
	
	Select
		5 As GroupSort,
		DibaItemID,
		NULL As LinCod,
		Sum(LinTot) As LinTot,
		NULL As LinDes
	From dbo.[PrdPrzBuildDibaElab]
	Where ElabID = @iElabID
		And IsNull(ElabLiv, 0) > 0
		And DibaItemID <> '(i)'
	Group By DibaItemID
	Having Sum(LinTot) <> 0


	-- ---------------------------------------------
	Update @tbDibaCompact Set
		LinDes = (
			Select TOP 1 LinDes
			From dbo.[DibaLin] LIN 
			Where LIN.LinCod = TB.DibaItemID
			)
	From @tbDibaCompact TB
	Where GroupSort = 5
	
	Update @tbDibaCompact Set
		LinDes = (
			Select TOP 1 PrdDes
			From dbo.[PrdAna] ANA  
			Where ANA.PrdCod = TB.DibaItemID
			)
	From @tbDibaCompact TB
	Where GroupSort = 5
		And IsNull(LinDes, '') = ''
	-- ---------------------------------------------
	Select *
	From @tbDibaCompact
	Order BY GroupSort, DibaItemID
END -- @iReturnType = 20

Else If @iReturnType = 21
BEGIN
	--
	-- esplosione DETTAGLIATA da WorkOdpDibaElabValues
	--
	Select
		ElabID, ElabLiv,
		DibaItemID,	IsSDiba,
		LinNum, LinCod, LinDes, LinUm, LinQta
		-- , LinPrz, LinTot, DibaTot,
		IsSMade,
		DibaRowID, DibaType, ElabRow, ElabDibaCod, ElabPrdCod,
		ElabStep, ElabSort, UniqRow
	From dbo.[WorkOdpDibaElabValues]
	Where ElabID = @iElabID
		And IsNull(LinCod, '') <> '#'
	Order By ElabStep, ElabSort, ElabRow
END -- @iReturnType = 21