If Exists(Select 1 From dbo.sysobjects where name = 'trgMixAnaSedi_OnDelete_Pers' And xtype = 'TR')
DROP TRIGGER [dbo].[trgMixAnaSedi_OnDelete_Pers]
GO

If Exists(Select 1 From dbo.sysobjects where name = 'trgMixAnaSedi_OnInsUpd_Pers' And xtype = 'TR')
DROP TRIGGER [dbo].[trgMixAnaSedi_OnInsUpd_Pers]
GO

/*
*
*
*
*/
CREATE TRIGGER [trgMixAnaSedi_OnDelete_Pers]
ON dbo.[MixAnaSedi]
FOR DELETE
AS
SET NOCOUNT ON
Declare @iItemType tinyint
Declare @sItemID varchar(16)
Declare @sItemIDSede varchar(16)

Declare [cCursor_MixAnaSedi_OnDelete_Pers] Cursor LOCAL FAST_FORWARD For
Select ItemType, ItemID, ItemIDSede From deleted
Open [cCursor_MixAnaSedi_OnDelete_Pers]
Fetch Next From [cCursor_MixAnaSedi_OnDelete_Pers] Into @iItemType, @sItemID, @sItemIDSede
While (@@Fetch_Status <> -1)
Begin
	Set @sItemIDSede = RTrim(LTrim(IsNull(@sItemIDSede, '')))

	Delete dbo.[Coord_Pers]
	Where IsNull(AnaType, 0) = @iItemType
		And IsNull(AnaCod, '') = @sItemID
		And LTrim(RTrim(IsNull(DsmCod, ''))) = @sItemIDSede

	-- ----------------------------------------------------------
	Fetch Next From [cCursor_MixAnaSedi_OnDelete_Pers] Into @iItemType, @sItemID, @sItemIDSede
End
Close [cCursor_MixAnaSedi_OnDelete_Pers]
Deallocate [cCursor_MixAnaSedi_OnDelete_Pers]
GO
/*
*
*
*
*/
CREATE TRIGGER [trgMixAnaSedi_OnInsUpd_Pers]
ON dbo.[MixAnaSedi]
FOR INSERT, UPDATE
AS
SET NOCOUNT ON
Declare @iItemType tinyint
Declare @sItemID varchar(16)
Declare @sItemIDSede varchar(16)
Declare @sIndBuild varchar(1024)

Declare [cCursor_MixAnaSedi_OnInsUpd_Pers] Cursor LOCAL FAST_FORWARD For
Select
	ItemType, ItemID, ItemIDSede,
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
Open [cCursor_MixAnaSedi_OnInsUpd_Pers]
Fetch Next From [cCursor_MixAnaSedi_OnInsUpd_Pers] Into @iItemType, @sItemID, @sItemIDSede, @sIndBuild
While (@@Fetch_Status <> -1)
Begin
	Set @iItemType = IsNull(@iItemType, 0)
	Set @sItemID = IsNull(@sItemID, '')
	Set @sItemIDSede = RTrim(LTrim(IsNull(@sItemIDSede, '')))
	Set @sIndBuild = IsNull(@sIndBuild, '')

	If (@iItemType > 0) And Len(@sItemID) > 0 And Len(@sItemIDSede) > 0
	Begin
		Delete dbo.[Coord_Pers]
		Where IsNull(AnaType, 0) = @iItemType
			And IsNull(AnaCod, '') = @sItemID
			And LTrim(RTrim(IsNull(DsmCod, ''))) = @sItemIDSede

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
				,@sItemIDSede
				,NULL
				,NULL
				,@sIndBuild
			   	,0)
	End

	-- ----------------------------------------------------------
	Fetch Next From [cCursor_MixAnaSedi_OnInsUpd_Pers] Into @iItemType, @sItemID, @sItemIDSede, @sIndBuild
End
Close [cCursor_MixAnaSedi_OnInsUpd_Pers]
Deallocate [cCursor_MixAnaSedi_OnInsUpd_Pers]
GO
