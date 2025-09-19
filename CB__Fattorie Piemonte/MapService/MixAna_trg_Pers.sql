If Exists(Select 1 From dbo.sysobjects where name = 'trgMixAna_OnDelete_Pers' And xtype = 'TR')
DROP TRIGGER [dbo].[trgMixAna_OnDelete_Pers]
GO

If Exists(Select 1 From dbo.sysobjects where name = 'trgMixAna_OnInsUpd_Pers' And xtype = 'TR')
DROP TRIGGER [dbo].[trgMixAna_OnInsUpd_Pers]
GO

/*
*
*
*
*/
CREATE TRIGGER [trgMixAna_OnDelete_Pers]
ON dbo.[MixAna]
FOR DELETE
AS
SET NOCOUNT ON
Declare @iItemType tinyint
Declare @sItemID varchar(16)

Declare [cCursor_MixAna_OnDelete_Pers] Cursor LOCAL FAST_FORWARD For
Select ItemType, ItemID From deleted
Open [cCursor_MixAna_OnDelete_Pers]
Fetch Next From [cCursor_MixAna_OnDelete_Pers] Into @iItemType, @sItemID
While (@@Fetch_Status <> -1)
Begin
	Set @iItemType = IsNull(@iItemType, 0)
	Set @sItemID = IsNull(@sItemID, '')

	Delete dbo.[Coord_Pers]
	Where IsNull(AnaType, 0) = @iItemType
		And IsNull(AnaCod, '') = @sItemID
		And Len(LTrim(RTrim(IsNull(DsmCod, '')))) = 0

	-- ----------------------------------------------------------
	Fetch Next From [cCursor_MixAna_OnDelete_Pers] Into @iItemType, @sItemID
End
Close [cCursor_MixAna_OnDelete_Pers]
Deallocate [cCursor_MixAna_OnDelete_Pers]
GO
/*
*
*
*
*/
CREATE TRIGGER [trgMixAna_OnInsUpd_Pers]
ON dbo.[MixAna]
FOR INSERT, UPDATE
AS
SET NOCOUNT ON
Declare @iItemType tinyint
Declare @sItemID varchar(16)
Declare @sIndBuild varchar(1024)

Declare [cCursor_MixAna_OnInsUpd_Pers] Cursor LOCAL FAST_FORWARD For
Select
	ItemType, ItemID,
	Upper(
		LTrim(RTrim(
			RTrim(LTrim(IsNull(Ind, ''))) + ' ' +
			RTrim(LTrim(IsNull(Loc, ''))) +
			Case When Upper(RTrim(LTrim(IsNull(GD.ItemName, '')))) <> Upper(RTrim(LTrim(IsNull(Loc, ''))))
			Then ' ' + RTrim(LTrim(IsNull(GD.ItemName, '')))
			Else ''
			End
		))
	) IndBuild
From
	inserted Left Join dbo.[GeoDistrict] GD On inserted.Pro = GD.ItemCode
Open [cCursor_MixAna_OnInsUpd_Pers]
Fetch Next From [cCursor_MixAna_OnInsUpd_Pers] Into @iItemType, @sItemID, @sIndBuild
While (@@Fetch_Status <> -1)
Begin
	Set @iItemType = IsNull(@iItemType, 0)
	Set @sItemID = IsNull(@sItemID, '')
	Set @sIndBuild = IsNull(@sIndBuild, '')

	If (@iItemType > 0) And Len(@sItemID) > 0
	Begin
		Delete dbo.[Coord_Pers]
		Where IsNull(AnaType, 0) = @iItemType
			And IsNull(AnaCod, '') = @sItemID
			And Len(LTrim(RTrim(IsNull(DsmCod, '')))) = 0

		If Len(@sIndBuild) > 0
			INSERT INTO dbo.[Coord_Pers]
			   	([AnaType]
			   	,[AnaCod]
			   	,[DsmCod]
			   	,[CoordLat]
			   	,[CoordLng]
			   	,[IndBuild]
			   	,[ElabErr])
			VALUES
				(@iItemType
				,@sItemID
				,''
				,NULL
				,NULL
				,@sIndBuild
			   	,0)
	End

	-- ----------------------------------------------------------
	Fetch Next From [cCursor_MixAna_OnInsUpd_Pers] Into @iItemType, @sItemID, @sIndBuild
End
Close [cCursor_MixAna_OnInsUpd_Pers]
Deallocate [cCursor_MixAna_OnInsUpd_Pers]
GO
