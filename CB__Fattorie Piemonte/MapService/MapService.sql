If Exists(Select 1 From dbo.sysobjects where name = 'udfFormatNum_Pers' And xtype In('FN', 'IF', 'TF'))
DROP FUNCTION [dbo].[udfFormatNum_Pers]
GO

/* 
*
*/
CREATE FUNCTION [udfFormatNum_Pers]
(
	@dNum decimal(19, 6)
)
RETURNS varchar(16)
AS
BEGIN
	Declare @sNum varchar(16) = Replace(RTrim(LTrim(Cast(IsNull(@dNum, 0.0) As varchar(16)))), ',', '.')

	If CharIndex('.', @sNum) > 0
	Begin
		While Right(@sNum, 1) = '0'
			Set @sNum = Left(@sNum, Len(@sNum) - 1)

		If Right(@sNum, 1) = '.'
			Set @sNum = Left(@sNum, Len(@sNum) - 1)

		If Len(@sNum) = 0
			Set @sNum = '0'
	End

	RETURN @sNum
END
GO
If Exists(Select 1 From dbo.sysobjects where name = 'udfXMLorHTML_text_Pers' And xtype In('FN', 'IF', 'TF'))
DROP FUNCTION [dbo].[udfXMLorHTML_text_Pers]
GO

/* 
*
*/
CREATE FUNCTION [udfXMLorHTML_text_Pers]
(
	@sText nvarchar(2048)
)
RETURNS nvarchar(2048)
AS
BEGIN
-- <	&lt;	&#60;
-- >	&gt;	&#62;
-- "	&quot;	&#34; -> Assimilato anche “
-- &	&amp;	&#38;
-- '	&apos;	&#39; -> Assimilati anche ‘ e ’

	Set @sText = IsNull(@sText, '')

	Set @sText = Replace(@sText, '<', '&lt;')
	Set @sText = Replace(@sText, '>', '&gt;')
	Set @sText = Replace(@sText, '“', '&quot;')
	Set @sText = Replace(@sText, '"', '&quot;')
	Set @sText = Replace(@sText, '&', '&amp;')
	Set @sText = Replace(@sText, '‘', '&apos;')
	Set @sText = Replace(@sText, '’', '&apos;')

	Set @sText = Replace(@sText, '''', '&apos;')

	Set @sText = Replace(@sText, '°', '&ordm;')
	Set @sText = Replace(@sText, '¶', '&para;')

	Set @sText = Replace(@sText COLLATE Latin1_General_CS_AS, 'à' COLLATE Latin1_General_CS_AS, '&agrave;')
	Set @sText = Replace(@sText COLLATE Latin1_General_CS_AS, 'á' COLLATE Latin1_General_CS_AS, '&aacute;')
	Set @sText = Replace(@sText COLLATE Latin1_General_CS_AS, 'è' COLLATE Latin1_General_CS_AS, '&egrave;')
	Set @sText = Replace(@sText COLLATE Latin1_General_CS_AS, 'é' COLLATE Latin1_General_CS_AS, '&eacute;')
	Set @sText = Replace(@sText COLLATE Latin1_General_CS_AS, 'ì' COLLATE Latin1_General_CS_AS, '&igrave;')
	Set @sText = Replace(@sText COLLATE Latin1_General_CS_AS, 'í' COLLATE Latin1_General_CS_AS, '&iacute;')
	Set @sText = Replace(@sText COLLATE Latin1_General_CS_AS, 'ò' COLLATE Latin1_General_CS_AS, '&ograve;')
	Set @sText = Replace(@sText COLLATE Latin1_General_CS_AS, 'ó' COLLATE Latin1_General_CS_AS, '&oacute;')
	Set @sText = Replace(@sText COLLATE Latin1_General_CS_AS, 'ù' COLLATE Latin1_General_CS_AS, '&ugrave;')
	Set @sText = Replace(@sText COLLATE Latin1_General_CS_AS, 'ú' COLLATE Latin1_General_CS_AS, '&uacute;')
	Set @sText = Replace(@sText COLLATE Latin1_General_CS_AS, 'ø' COLLATE Latin1_General_CS_AS, '&oslash')
	Set @sText = Replace(@sText COLLATE Latin1_General_CS_AS, 'ç' COLLATE Latin1_General_CS_AS, '&ccedil;')

	Set @sText = Replace(@sText COLLATE Latin1_General_CS_AS, 'À' COLLATE Latin1_General_CS_AS, '&Agrave;')
	Set @sText = Replace(@sText COLLATE Latin1_General_CS_AS, 'Á' COLLATE Latin1_General_CS_AS, '&Aacute;')
	Set @sText = Replace(@sText COLLATE Latin1_General_CS_AS, 'È' COLLATE Latin1_General_CS_AS, '&Egrave;')
	Set @sText = Replace(@sText COLLATE Latin1_General_CS_AS, 'É' COLLATE Latin1_General_CS_AS, '&Eacute;')
	Set @sText = Replace(@sText COLLATE Latin1_General_CS_AS, 'Ì' COLLATE Latin1_General_CS_AS, '&Igrave;')
	Set @sText = Replace(@sText COLLATE Latin1_General_CS_AS, 'Í' COLLATE Latin1_General_CS_AS, '&Iacute;')
	Set @sText = Replace(@sText COLLATE Latin1_General_CS_AS, 'Ò' COLLATE Latin1_General_CS_AS, '&Ograve;')
	Set @sText = Replace(@sText COLLATE Latin1_General_CS_AS, 'Ó' COLLATE Latin1_General_CS_AS, '&Oacute;')
	Set @sText = Replace(@sText COLLATE Latin1_General_CS_AS, 'Ù' COLLATE Latin1_General_CS_AS, '&Ugrave;')
	Set @sText = Replace(@sText COLLATE Latin1_General_CS_AS, 'Ú' COLLATE Latin1_General_CS_AS, '&Uacute;')
	Set @sText = Replace(@sText COLLATE Latin1_General_CS_AS, 'Ø' COLLATE Latin1_General_CS_AS, '&Oslash')
	Set @sText = Replace(@sText COLLATE Latin1_General_CS_AS, 'Ç' COLLATE Latin1_General_CS_AS, '&Ccedil;')

	RETURN @sText
END
GO
If Exists(Select 1 From dbo.sysobjects where name = 'uspBuildHTMLMap_Pers' And xtype = 'P')
DROP PROCEDURE [dbo].[uspBuildHTMLMap_Pers]
GO

/*
*
* Procedura che si occupa di costruire una mappa HTML con le specifiche delle API di Google Maps per evidenziare le zone di consegna dell'inevaso ordini.
*
*/
CREATE PROCEDURE [uspBuildHTMLMap_Pers]
AS

SET NOCOUNT ON

-- --------------------------------------------------------------------------------
-- DICHIARAZIONI ED INIZIALIZZAZIONE
-- --------------------------------------------------------------------------------

Declare @sRottura varchar(128)
Declare @iAnaType tinyint
Declare @sAnaCod varchar(16)
Declare @sAnaDes varchar(256)
Declare @sDsmCod varchar(16)
Declare @sIndBuild varchar(256)
Declare @sTel varchar(256)
Declare @dCoordLat decimal(19, 6)
Declare @dCoordLng decimal(19, 6)
Declare @sRGB varchar(8)
Declare @sPrdCod varchar(16)
Declare @sPrdDes varchar(256)
Declare @iNumPrd int
Declare @iNumCat int
Declare @sCatCod varchar(32)
Declare @dRimanenza decimal(19, 6)
Declare @sPezzatura varchar(256)
Declare @dPrezzo decimal(19, 6)
Declare @dTotaleLinea decimal(19, 6)
Declare @dTotale decimal(19, 6)
Declare @dTotaleQta decimal(19, 6)
Declare @sCommenti varchar(256)

Declare @sRottura_Prec varchar(128) = ''
Declare @dCoordLat_Prec decimal(19, 6)
Declare @dCoordLng_Prec decimal(19, 6)
Declare @sRGB_Prec varchar(8)
Declare @iNumPrd_Prec int
Declare @iNumCat_Prec int

Declare @sPrezzo varchar(16)
Declare @sRimanenza varchar(16)
Declare @sTotaleLinea varchar(16)
Declare @sTotale varchar(16)
Declare @sTotaleQta varchar(16)

Declare @sCoordLat_Prec varchar(16)
Declare @sCoordLng_Prec varchar(16)

Declare @sSpace07 varchar(8) = Space(7)
Declare @sSpace10 varchar(16) = Space(10)
Declare @sSpace13 varchar(16) = Space(13)
Declare @sSpace40 varchar(64) = Space(40)

Declare @sSpace53 varchar(64) = Space(53)

Declare @sTab varchar(2) = CHAR(9)
Declare @sTabDouble varchar(2) = @sTab + @sTab

Declare @sPreFooterLine000 varchar(1024) = @sTab + 'var map = new google.maps.Map(document.getElementById(''map''), {'
Declare @sPreFooterLine001 varchar(1024) = @sTabDouble + 'center: new google.maps.LatLng({0}, {1}),'
Declare @sPreFooterLine002 varchar(1024) = @sTabDouble + 'zoom: {2},'
Declare @sPreFooterLine003 varchar(1024) = @sTabDouble + 'mapTypeId: google.maps.MapTypeId.ROADMAP'
Declare @sPreFooterLine004 varchar(1024) = @sTab + '});'

Declare @sDBName varchar(1024) = DB_NAME()

Declare @bExist bit
Declare @iLen int
Declare @iPos int
Declare @iCnt int
Declare @iElabID int = 0
Declare @sElabID varchar(16) = ''
Declare @sCmd varchar(1024) = ''

Declare @sCmdClear varchar(1024) = ''

Declare @sMapHTMLFileNameHeaderWithPath varchar(1024) = ''
Declare @sMapHTMLFileNameFooterWithPath varchar(1024) = ''

Declare @sMapHTMLFileNameHeaderWithoutPath varchar(1024) = ''
Declare @sMapHTMLFileNameFooterWithoutPath varchar(1024) = ''

Declare @sMapHTMLFileNameModelWithPath varchar(1024) = ''

Declare @sMapHTMLFileNameWithPath varchar(1024) = ''
Declare @sMapHTMLFileNameWithoutPath varchar(1024) = ''

Declare @sMapHTMLFileNameWithPath_TMP varchar(1024) = ''
Declare @sMapHTMLFileNameWithoutPath_TMP varchar(1024) = ''

Declare @sMapHTMLPathClient varchar(1024) = ''
Declare @sMapHTMLFileNameWithPathClient varchar(1024) = ''

Declare @bDelMapHTMLFileNameWithPath_TMP bit = 0

Declare @sCenterCoordLat varchar(32)
Declare @sCenterCoordLng varchar(32)
Declare @sZoom varchar(4)

Declare @tbCmdRes TABLE(
	[Res] varchar(1024) NULL,
	[UniqRow] int IDENTITY
)

Declare @sMsg varchar(1024) = ''

If Len(RTrim(LTrim(IsNull(@sDBName, '')))) = 0
	Set @sMsg = 'Non rilevato il nome del database. Impossibile procedere.'

If Len(@sMsg) = 0
Begin
	Execute dbo.[uspNumUniqNext_out] 'MapElab_Pers', @iElabID OUTPUT

	If IsNull(@iElabID, 0) <= 0
		Set @sMsg = 'Recupero identificativo operazione fallito. Impossibile procedere.'
End

-- --------------------------------------------------------------------------------
-- VERIFICA ED EVENTUALE RECUPERO COORDINATE
-- --------------------------------------------------------------------------------

If Len(@sMsg) = 0
Begin
	Set @sElabID = RTrim(LTrim(Cast(@iElabID As varchar(16))))

	Set @iCnt = 0
	Select @iCnt = Count(*) From dbo.[Coord_Pers] Where ((CoordLat Is Null) Or (CoordLng Is Null)) And IsNull(ElabErr, 0) = 0

	If IsNull(@iCnt, 0) > 0
	Begin
		Set @sCmd = ''
		Select @sCmd = ItemValue From dbo.[CoordPar_Pers] Where ItemID = 'CMD'
		Set @sCmd = RTrim(LTrim(IsNull(@sCmd, ''))) + ' ' + @sElabID

		If Len(@sCmd) = 0
			Set @sMsg = 'Comando di recupero coordinate non trovato. Impossibile procedere.'

		If Len(@sMsg) = 0
		Begin
			Delete From @tbCmdRes

			Insert Into @tbCmdRes(Res)
			Execute master.dbo.xp_cmdshell @sCmd

			Set @bExist = 0
			Select Top 1 @bExist = 1 From @tbCmdRes Where Res = 'OK'
			If IsNull(@bExist, 0) = 0
				Set @sMsg = 'Recupero coordinate fallito. Impossibile procedere.'
		End
	End
End

-- --------------------------------------------------------------------------------
-- LETTURA E CONTROLLO PARAMETRI
-- --------------------------------------------------------------------------------

If Len(@sMsg) = 0
Begin
	Select @sCenterCoordLat = Upper(ItemValue) From dbo.[CoordPar_Pers] Where ItemID = 'CenterCoordLat'
	Set @sCenterCoordLat = Replace(Replace(Replace(Replace(Replace(RTrim(LTrim(IsNull(@sCenterCoordLat, ''))), ',', '.'), ' ', '_'), 'D', '_'), 'E', '_'), '+', '_')

	If Len(@sCenterCoordLat) = 0
		Set @sMsg = 'Coordinata centro mappa latitudine mancante. Impossibile procedere.'
	Else
		If IsNumeric(@sCenterCoordLat) = 0
			Set @sMsg = 'Coordinata centro mappa latitudine errata. Impossibile procedere.'
End

If Len(@sMsg) = 0
Begin
	Select @sCenterCoordLng = Upper(ItemValue) From dbo.[CoordPar_Pers] Where ItemID = 'CenterCoordLng'
	Set @sCenterCoordLng = Replace(Replace(Replace(Replace(Replace(RTrim(LTrim(IsNull(@sCenterCoordLng, ''))), ',', '.'), ' ', '_'), 'D', '_'), 'E', '_'), '+', '_')

	If Len(@sCenterCoordLng) = 0
		Set @sMsg = 'Coordinata centro mappa latitudine mancante. Impossibile procedere.'
	Else
		If IsNumeric(@sCenterCoordLng) = 0
			Set @sMsg = 'Coordinata centro mappa longitudine errata. Impossibile procedere.'
End

If Len(@sMsg) = 0
Begin
	Select @sZoom = Upper(ItemValue) From dbo.[CoordPar_Pers] Where ItemID = 'Zoom'
	Set @sZoom = Replace(Replace(Replace(Replace(Replace(Replace(Replace(RTrim(LTrim(IsNull(@sZoom, ''))), ',', '_'), '.', '_'), ' ', '_'), 'D', '_'), 'E', '_'), '-', '_'), '+', '_')

	If Len(@sZoom) = 0
		Set @sMsg = 'Valore parametro zoom mappa mancante. Impossibile procedere.'
	Else
		If IsNumeric(@sZoom) = 0
			Set @sMsg = 'Valore parametro zoom mappa errato. Impossibile procedere.'
End

If Len(@sMsg) = 0
Begin
	Select @sMapHTMLPathClient = ItemValue From dbo.[CoordPar_Pers] Where ItemID = 'MapHTMLPathClient'
	Set @sMapHTMLPathClient = Replace(RTrim(LTrim(IsNull(@sMapHTMLPathClient, ''))), '/', '\')

	If Len(@sMapHTMLPathClient) > 0
	Begin
		If Right(@sMapHTMLPathClient, 1) <> '\'
			Set @sMapHTMLPathClient = @sMapHTMLPathClient + '\'
	End
	Else
		Set @sMsg = 'Parametro path client mappa HTML mancante e/o errato. Impossibile procedere.'
End

If Len(@sMsg) = 0
Begin
	Select @sMapHTMLFileNameHeaderWithPath = ItemValue From dbo.[CoordPar_Pers] Where ItemID = 'MapHTMLFileNameHeader'
	Set @sMapHTMLFileNameHeaderWithPath = Replace(RTrim(LTrim(IsNull(@sMapHTMLFileNameHeaderWithPath, ''))), '/', '\')

	Select @sMapHTMLFileNameFooterWithPath = ItemValue From dbo.[CoordPar_Pers] Where ItemID = 'MapHTMLFileNameFooter'
	Set @sMapHTMLFileNameFooterWithPath = Replace(RTrim(LTrim(IsNull(@sMapHTMLFileNameFooterWithPath, ''))), '/', '\')

	If (Len(@sMapHTMLFileNameHeaderWithPath) = 0) Or (Len(@sMapHTMLFileNameFooterWithPath) = 0) Or (Upper(@sMapHTMLFileNameHeaderWithPath) = Upper(@sMapHTMLFileNameFooterWithPath))
		Set @sMsg = 'Parametri header e footer mappa HTML mancanti e/o errati. Impossibile procedere.'
End

If Len(@sMsg) = 0
Begin
	Set @bExist = 0
	Set @iLen = Len(@sMapHTMLFileNameHeaderWithPath)
	Set @iPos = CharIndex('\', Reverse(@sMapHTMLFileNameHeaderWithPath))
	If @iPos > 0
	Begin
		Set @iPos = @iLen - Case When @iPos = 0 Then @iLen Else @iPos - 1 End
		If @iPos > 0
			Set @sMapHTMLFileNameHeaderWithoutPath = LTrim(RTrim(Right(@sMapHTMLFileNameHeaderWithPath, @iLen - @iPos)))
	End

	If Len(@sMapHTMLFileNameHeaderWithoutPath) > 0
	Begin
		Delete From @tbCmdRes
		Set @sCmd = 'dir ' + @sMapHTMLFileNameHeaderWithPath + ' /B'
		Insert Into @tbCmdRes(Res)
		Execute master.dbo.xp_cmdshell @sCmd

		Select Top 1 @bExist = 1 From @tbCmdRes Where CharIndex(@sMapHTMLFileNameHeaderWithoutPath, Res) > 0
		
		If IsNull(@bExist, 0) = 0
			Set @sMsg = 'File header mappa HTML non trovato. Impossibile procedere.'
	End

	If Len(@sMsg) = 0
	Begin
		Set @bExist = 0
		Set @iLen = Len(@sMapHTMLFileNameFooterWithPath)
		Set @iPos = CharIndex('\', Reverse(@sMapHTMLFileNameFooterWithPath))
		If @iPos > 0
		Begin
			Set @iPos = @iLen - Case When @iPos = 0 Then @iLen Else @iPos - 1 End
			If @iPos > 0
				Set @sMapHTMLFileNameFooterWithoutPath = LTrim(RTrim(Right(@sMapHTMLFileNameFooterWithPath, @iLen - @iPos)))
		End

		If Len(@sMapHTMLFileNameFooterWithoutPath) > 0
		Begin
			Delete From @tbCmdRes
			Set @sCmd = 'dir ' + @sMapHTMLFileNameFooterWithPath + ' /B'
			Insert Into @tbCmdRes(Res)
			Execute master.dbo.xp_cmdshell @sCmd

			Select Top 1 @bExist = 1 From @tbCmdRes Where CharIndex(@sMapHTMLFileNameFooterWithoutPath, Res) > 0

			If IsNull(@bExist, 0) = 0
				Set @sMsg = 'File footer mappa HTML non trovato. Impossibile procedere.'
		End
	End
End

If Len(@sMsg) = 0
Begin
	Select @sMapHTMLFileNameModelWithPath = ItemValue From dbo.[CoordPar_Pers] Where ItemID = 'MapHTMLFileNameModel'
	Set @sMapHTMLFileNameModelWithPath = Replace(RTrim(LTrim(IsNull(@sMapHTMLFileNameModelWithPath, ''))), '/', '\')

	If (Len(@sMapHTMLFileNameModelWithPath) = 0) Or (Upper(@sMapHTMLFileNameHeaderWithPath) = Upper(@sMapHTMLFileNameModelWithPath)) Or (Upper(@sMapHTMLFileNameFooterWithPath) = Upper(@sMapHTMLFileNameModelWithPath))
		Set @sMsg = 'Parametro modello mappa HTML mancante e/o errato. Impossibile procedere.'
End

If Len(@sMsg) = 0
Begin
	Set @sMapHTMLFileNameWithPath = Replace(@sMapHTMLFileNameModelWithPath, '{DB}', @sDBName)
	Set @sMapHTMLFileNameWithPath = Replace(@sMapHTMLFileNameWithPath, '{ID}', @sElabID)
	Set @sMapHTMLFileNameWithPath = RTrim(LTrim(@sMapHTMLFileNameWithPath))
	
	If Len(@sMapHTMLFileNameWithPath) = 0
		Set @sMsg = 'Impossibile ricavare il nome del file mappa da costruire. Impossibile procedere.'
End

If Len(@sMsg) = 0
	If (Upper(@sMapHTMLFileNameHeaderWithPath) = Upper(@sMapHTMLFileNameWithPath)) Or (Upper(@sMapHTMLFileNameFooterWithPath) = Upper(@sMapHTMLFileNameWithPath))
		Set @sMsg = 'Parametro modello mappa HTML errato. Impossibile procedere.'

-- --------------------------------------------------------------------------------
-- PREPARAZIONE E VERIFICA DEI FILE DI SUPPORTO
-- --------------------------------------------------------------------------------

If Len(@sMsg) = 0
Begin
	Set @bExist = 0

	Set @iLen = Len(@sMapHTMLFileNameWithPath)
	Set @iPos = CharIndex('\', Reverse(@sMapHTMLFileNameWithPath))
	If @iPos > 0
	Begin
		Set @iPos = @iLen - Case When @iPos = 0 Then @iLen Else @iPos - 1 End
		If @iPos > 0
			Set @sMapHTMLFileNameWithoutPath = LTrim(RTrim(Right(@sMapHTMLFileNameWithPath, @iLen - @iPos)))
	End

	If Len(@sMapHTMLFileNameWithoutPath) > 0
	Begin
		Delete From @tbCmdRes
		Set @sCmd = 'dir ' + @sMapHTMLFileNameWithPath + ' /B'
		Insert Into @tbCmdRes(Res)
		Execute master.dbo.xp_cmdshell @sCmd

		Select Top 1 @bExist = 1 From @tbCmdRes Where CharIndex(@sMapHTMLFileNameWithoutPath, Res) > 0
		If IsNull(@bExist, 0) = 1
		Begin
			Set @bExist = 0

			Set @sCmd = 'del ' + @sMapHTMLFileNameWithPath + ' /Q'
			Execute master.dbo.xp_cmdshell @sCmd, NO_OUTPUT

			Delete From @tbCmdRes
			Set @sCmd = 'dir ' + @sMapHTMLFileNameWithPath + ' /B'
			Insert Into @tbCmdRes(Res)
			Execute master.dbo.xp_cmdshell @sCmd

			Select Top 1 @bExist = 1 From @tbCmdRes Where CharIndex(@sMapHTMLFileNameWithoutPath, Res) > 0
			If IsNull(@bExist, 0) = 1
				Set @sMsg = 'File mappa da costruire già esistente e non cancellabile. Impossibile procedere.'
		End
	End
End

If Len(@sMsg) = 0
Begin
	Set @bExist = 0

	Set @sMapHTMLFileNameWithPath_TMP = @sMapHTMLFileNameWithPath + '.tmp.txt'
	Set @sMapHTMLFileNameWithoutPath_TMP = @sMapHTMLFileNameWithoutPath + '.tmp.txt'

	Delete From @tbCmdRes
	Set @sCmd = 'dir ' + @sMapHTMLFileNameWithPath_TMP + ' /B'
	Insert Into @tbCmdRes(Res)
	Execute master.dbo.xp_cmdshell @sCmd

	Select Top 1 @bExist = 1 From @tbCmdRes Where CharIndex(@sMapHTMLFileNameWithoutPath_TMP, Res) > 0
	If IsNull(@bExist, 0) = 1
	Begin
		Set @bExist = 0

		Set @sCmd = 'del ' + @sMapHTMLFileNameWithPath_TMP + ' /Q'
		Execute master.dbo.xp_cmdshell @sCmd, NO_OUTPUT

		Delete From @tbCmdRes
		Set @sCmd = 'dir ' + @sMapHTMLFileNameWithPath_TMP + ' /B'
		Insert Into @tbCmdRes(Res)
		Execute master.dbo.xp_cmdshell @sCmd

		Select Top 1 @bExist = 1 From @tbCmdRes Where CharIndex(@sMapHTMLFileNameWithoutPath_TMP, Res) > 0
		If IsNull(@bExist, 0) = 1
			Set @sMsg = 'File mappa transitorio da costruire già esistente e non cancellabile. Impossibile procedere.'
	End
End

If Len(@sMsg) = 0
Begin
	Set @sCmd = 'copy ' + @sMapHTMLFileNameHeaderWithPath + ' ' + @sMapHTMLFileNameWithPath_TMP
	Execute master.dbo.xp_cmdshell @sCmd, NO_OUTPUT

	Delete From @tbCmdRes
	Set @sCmd = 'dir ' + @sMapHTMLFileNameWithPath_TMP + ' /B'
	Insert Into @tbCmdRes(Res)
	Execute master.dbo.xp_cmdshell @sCmd

	Select Top 1 @bExist = 1 From @tbCmdRes Where CharIndex(@sMapHTMLFileNameWithoutPath_TMP, Res) > 0
	If IsNull(@bExist, 0) = 0
		Set @sMsg = 'Creazione file transitorio mappa fallita. Impossibile procedere.'
End

-- --------------------------------------------------------------------------------
-- CICLO DI ELABORAZIONE
-- --------------------------------------------------------------------------------

If Len(@sMsg) = 0
Begin

	Set @bDelMapHTMLFileNameWithPath_TMP = 1

	Set @sCmd = 'echo. >> ' + @sMapHTMLFileNameWithPath_TMP
	Execute master.dbo.xp_cmdshell @sCmd, NO_OUTPUT
	Set @sCmd = 'echo. >> ' + @sMapHTMLFileNameWithPath_TMP
	Execute master.dbo.xp_cmdshell @sCmd, NO_OUTPUT

	Set @iCnt = 0

	Declare cCursor_BuildHTMLMap Cursor FAST_FORWARD For
	Select
		RTrim(LTrim(Cast(IsNull(ORD.AnaType, 0) As varchar(8)))) + '%%%' + IsNull(ORD.AnaCod, '') + '%%%' + RTrim(LTrim(IsNull(ORD.DsmCod, ''))) Rottura,
		ORD.AnaType AnaType,
		Replace(dbo.[udfXMLorHTML_text_Pers](ORD.AnaCod), '&', '^&') AnaCod,
		Replace(dbo.[udfXMLorHTML_text_Pers](RTrim(LTrim(Left(ANA.ItemDes, 128)))), '&', '^&') ItemDes,
		Replace(dbo.[udfXMLorHTML_text_Pers](RTrim(LTrim(IsNull(ORD.DsmCod, '')))), '&', '^&') DsmCod,
		Replace(dbo.[udfXMLorHTML_text_Pers](RTrim(LTrim(Left(COO.IndBuild, 128)))), '&', '^&') IndBuild,
		Replace(dbo.[udfXMLorHTML_text_Pers](RTrim(LTrim(Left((Select Top 1 RTrim(LTrim(IsNull(ZRIF.Tel1, ''))) + Case When Len(RTrim(LTrim(IsNull(ZRIF.Tel1, '')))) > 0 And Len(RTrim(LTrim(IsNull(ZRIF.Tel2, '')))) > 0 Then ' - ' Else '' End + RTrim(LTrim(IsNull(ZRIF.Tel2, ''))) + Case When ((Len(RTrim(LTrim(IsNull(ZRIF.Tel1, '')))) > 0) Or (Len(RTrim(LTrim(IsNull(ZRIF.Tel2, '')))) > 0)) And (Len(RTrim(LTrim(IsNull(ZRIF.Tel3, '')))) > 0) Then ' - ' Else '' End + RTrim(LTrim(IsNull(ZRIF.Tel3, ''))) From dbo.[MixAnaRif] ZRIF Where ZRIF.ItemType = ORD.AnaType And ZRIF.ItemID = ORD.AnaCod Order By IsNull(ZRIF.ItemDefault, 0) DESC, ZRIF.ItemIDRif ASC), 128)))), '&', '^&') Tel,
		IsNull(COO.CoordLat, 0.0) CoordLat,
		IsNull(COO.CoordLng, 0.0) CoordLng,
		Case When Len(RTrim(LTrim(IsNull(IndBuild, '')))) > 0 Then IsNull((
			Select Top 1
				Case When IsNull(ColorARGB, 0) <> 0 Then RIGHT(CONVERT(VARCHAR(8), CONVERT(VARBINARY(8), ColorARGB), 2), 6) Else 'FFFFFF' End
			From
				dbo.[PrdAna] ZPRD
				Left Join dbo.[CatCol_Pers] ZCCOL On ZPRD.CatCod = ZCCOL.ItemID
				Left Join [WnDataSystem].dbo.[SystemColors] ZCOL On ZCCOL.CatColor = ZCOL.ColorName
			Where
				ZPRD.CatCod In(
					Select
						ZZPRD.CatCod
					From
						dbo.[CliOrdLin] ZLIN
						Inner Join dbo.[CliOrd] ZORD On ZLIN.UniqDoc = ZORD.Uniq
						Inner Join dbo.[MixAna] ZANA On ZORD.AnaType = ZANA.ItemType And ZORD.AnaCod = ZANA.ItemID
						Inner Join dbo.[PrdAna] ZZPRD On ZLIN.PrdCod = ZZPRD.PrdCod
						Left Join dbo.[Coord_Pers] ZCOO On ZORD.AnaType = ZCOO.AnaType And ZORD.AnaCod = ZCOO.AnaCod And ZORD.DsmCod = ZCOO.DsmCod
					Where
						ZANA.ItemType = ORD.AnaType And ZANA.ItemID = ORD.AnaCod And RTrim(LTrim(IsNull(ZORD.DsmCod, ''))) = RTrim(LTrim(IsNull(ORD.DsmCod, '')))
						And (IsNull(ZLIN.QtaEvs, 0.0) < IsNull(ZLIN.PrdQta, 0.0))
						And IsNull(ZLIN.LinStat, 0) < 30
						And Len(RTrim(LTrim(IsNull(ZCOO.IndBuild, '')))) > 0
				)
			Group By
				ZPRD.CatCod, Case When IsNull(ColorARGB, 0) <> 0 Then RIGHT(CONVERT(VARCHAR(8), CONVERT(VARBINARY(8), ColorARGB), 2), 6) Else 'FFFFFF' End
			Order By
				Count(*) DESC
		), 'FFFFFF') Else 'FFFFFF' End RGB,
		Replace(dbo.[udfXMLorHTML_text_Pers](LIN.PrdCod), '&', '^&') PrdCod,
		-- Replace(dbo.[udfXMLorHTML_text_Pers](RTrim(LTrim(Left(PRD.PrdDes, 39)))), '&', '^&') PrdDes,
        Replace(dbo.[udfXMLorHTML_text_Pers](RTrim(LTrim(Left(PRD.PrdDes, 52)))), '&', '^&') PrdDes,
		Case When Len(RTrim(LTrim(IsNull(IndBuild, '')))) > 0 Then IsNull((	
			Select
				Count(Distinct ZLIN.PrdCod)
			From
				dbo.[CliOrdLin] ZLIN
				Inner Join dbo.[CliOrd] ZORD On ZLIN.UniqDoc = ZORD.Uniq
				Inner Join dbo.[MixAna] ZANA On ZORD.AnaType = ZANA.ItemType And ZORD.AnaCod = ZANA.ItemID
				Left Join dbo.[Coord_Pers] ZCOO On ZORD.AnaType = ZCOO.AnaType And ZORD.AnaCod = ZCOO.AnaCod And ZORD.DsmCod = ZCOO.DsmCod
			Where
				ZANA.ItemType = ORD.AnaType And ZANA.ItemID = ORD.AnaCod And RTrim(LTrim(IsNull(ZORD.DsmCod, ''))) = RTrim(LTrim(IsNull(ORD.DsmCod, '')))
				And (IsNull(ZLIN.QtaEvs, 0.0) < IsNull(ZLIN.PrdQta, 0.0))
				And IsNull(ZLIN.LinStat, 0) < 30
				And Len(RTrim(LTrim(IsNull(ZCOO.IndBuild, '')))) > 0
		), 0) Else 0 End NumPrd,
		Case When Len(RTrim(LTrim(IsNull(IndBuild, '')))) > 0 Then IsNull((	
			Select
				Count(Distinct IsNull(ZPRD.CatCod, ''))
			From
				dbo.[CliOrdLin] ZLIN
				Inner Join dbo.[CliOrd] ZORD On ZLIN.UniqDoc = ZORD.Uniq
				Inner Join dbo.[MixAna] ZANA On ZORD.AnaType = ZANA.ItemType And ZORD.AnaCod = ZANA.ItemID
				Inner Join dbo.[PrdAna] ZPRD On ZLIN.PrdCod = ZPRD.PrdCod
				Left Join dbo.[Coord_Pers] ZCOO On ZORD.AnaType = ZCOO.AnaType And ZORD.AnaCod = ZCOO.AnaCod And ZORD.DsmCod = ZCOO.DsmCod
			Where
				ZANA.ItemType = ORD.AnaType And ZANA.ItemID = ORD.AnaCod And RTrim(LTrim(IsNull(ZORD.DsmCod, ''))) = RTrim(LTrim(IsNull(ORD.DsmCod, '')))
				And (IsNull(ZLIN.QtaEvs, 0.0) < IsNull(ZLIN.PrdQta, 0.0))
				And IsNull(ZLIN.LinStat, 0) < 30
				And Len(RTrim(LTrim(IsNull(ZCOO.IndBuild, '')))) > 0
		), 0) Else 0 End NumCat,
		Replace(dbo.[udfXMLorHTML_text_Pers](PRD.CatCod), '&', '^&') CatCod,
		IsNull(Sum(IsNull(PrdQta, 0.0) - IsNull(QtaEvs, 0.0)), 0.0) Rimanenza,
		Replace(dbo.[udfXMLorHTML_text_Pers](RTrim(LTrim(Left(PRD.Info1, 12)))), '&', '^&') Pezzatura,
		IsNull(LIN.PrdPrz2, 0.0) Prezzo,
		IsNull(LIN.PrdPrz2, 0.0) * IsNull(Sum(IsNull(PrdQta, 0.0) - IsNull(QtaEvs, 0.0)), 0.0) TotaleLinea,
		Replace(dbo.[udfXMLorHTML_text_Pers](RTrim(LTrim(Left(PRD.PrdInfo, 80)))), '&', '^&') Commenti
	From
		dbo.[CliOrdLin] LIN
		Inner Join dbo.[CliOrd] ORD On LIN.UniqDoc = ORD.Uniq
		Inner Join dbo.[PrdAna] PRD On LIN.PrdCod = PRD.PrdCod
		Inner Join dbo.[MixAna] ANA On ORD.AnaType = ANA.ItemType And ORD.AnaCod = ANA.ItemID
		Left Join dbo.[Coord_Pers] COO On ORD.AnaType = COO.AnaType And ORD.AnaCod = COO.AnaCod And ORD.DsmCod = COO.DsmCod
		Left Join dbo.[MixAnaSedi] DSM On ORD.AnaType = DSM.ItemType And ORD.AnaCod = DSM.ItemID And ORD.DsmCod = DSM.ItemIDSede
		Left Join dbo.[GeoDistrict] GDANA On ANA.Pro = GDANA.ItemCode
		Left Join dbo.[GeoDistrict] GDDSM On DSM.Pro = GDDSM.ItemCode
	Where
		(IsNull(QtaEvs, 0.0) < IsNull(PrdQta, 0.0))
		And IsNull(LinStat, 0) < 30
		And Len(
		Case When Len(RTrim(LTrim(IsNull(ORD.DsmCod, '')))) > 0 Then
			LTrim(RTrim(
				RTrim(LTrim(IsNull(DSM.Ind, ''))) + ' ' +
				RTrim(LTrim(IsNull(DSM.Loc, ''))) +
				Case When Upper(RTrim(LTrim(IsNull(GDDSM.ItemName, '')))) <> Upper(RTrim(LTrim(IsNull(DSM.Loc, ''))))
				Then ' ' + RTrim(LTrim(IsNull(GDDSM.ItemName, '')))
				Else ''
				End
			))
		Else
			LTrim(RTrim(
				RTrim(LTrim(IsNull(ANA.Ind, ''))) + ' ' +
				RTrim(LTrim(IsNull(ANA.Loc, ''))) +
				Case When Upper(RTrim(LTrim(IsNull(GDANA.ItemName, '')))) <> Upper(RTrim(LTrim(IsNull(ANA.Loc, ''))))
				Then ' ' + RTrim(LTrim(IsNull(GDANA.ItemName, '')))
				Else ''
				End
			))
		End) > 0
	Group By
		ORD.AnaType,
		ORD.AnaCod,
		ANA.ItemDes,
		RTrim(LTrim(IsNull(ORD.DsmCod, ''))),
		IndBuild,
		IsNull(COO.CoordLat, 0.0),
		IsNull(COO.CoordLng, 0.0),
		LIN.PrdCod,
		PRD.PrdDes,
		PRD.CatCod,
		PRD.Info1,
		IsNull(LIN.PrdPrz2, 0.0),
		PRD.PrdInfo
	Order By
		ORD.AnaType,
		ORD.AnaCod,
		RTrim(LTrim(IsNull(ORD.DsmCod, ''))),
		PRD.PrdDes

	Open cCursor_BuildHTMLMap
	Fetch Next From cCursor_BuildHTMLMap Into
		@sRottura,
		@iAnaType,
		@sAnaCod,
		@sAnaDes,
		@sDsmCod,
		@sIndBuild,
		@sTel,
		@dCoordLat,
		@dCoordLng,
		@sRGB,
		@sPrdCod,
		@sPrdDes,
		@iNumPrd,
		@iNumCat,
		@sCatCod,
		@dRimanenza,
		@sPezzatura,
		@dPrezzo,
		@dTotaleLinea,
		@sCommenti

	While @@Fetch_Status <> -1
	BEGIN
		If @sRottura <> @sRottura_Prec
		Begin
			If @iCnt > 0
			Begin
				Set @sTotale = dbo.[udfFormatNum_Pers](@dTotale)
				Set @sTotaleQta = RTrim(LTrim(Cast(Cast(Round(@dTotaleQta, 0) As int) As varchar(16))))
				Set @sCoordLat_Prec = dbo.[udfFormatNum_Pers](@dCoordLat_Prec)
				Set @sCoordLng_Prec = dbo.[udfFormatNum_Pers](@dCoordLng_Prec)

				Set @sCmd = 'echo ' + @sTabDouble + '+ ''^<br^>^<br^>^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp; Totale Ordine^&nbsp;^&nbsp;' + @sTotale + '^&euro;^</font^>'' >> ' + @sMapHTMLFileNameWithPath_TMP
				Execute master.dbo.xp_cmdshell @sCmd, NO_OUTPUT

				Set @sCmd = 'echo ' + @sTabDouble + ', ' + @sCoordLat_Prec + ', ' + @sCoordLng_Prec + ', ' + RTrim(LTrim(Cast(@iCnt As varchar(8)))) + ', "https://chart.apis.google.com/chart?chst=d_map_xpin_letter&chld=pin' + Case When @iNumPrd_Prec = 1 Then '' Else '_star' End + '|' + @sTotaleQta + '|' + @sRGB_Prec + '|ffffff|000000" >> ' + @sMapHTMLFileNameWithPath_TMP
				Execute master.dbo.xp_cmdshell @sCmd, NO_OUTPUT

				Set @sCmd = 'echo ' + @sTabDouble + '], >> ' + @sMapHTMLFileNameWithPath_TMP
				Execute master.dbo.xp_cmdshell @sCmd, NO_OUTPUT
			End

			Set @iCnt += 1
			Set @dTotale = 0.0
			Set @dTotaleQta = 0.0

			Set @sCmd = 'echo ' + @sTabDouble + '[ >> ' + @sMapHTMLFileNameWithPath_TMP
			Execute master.dbo.xp_cmdshell @sCmd, NO_OUTPUT

			Set @sCmd = 'echo ' + @sTabDouble + '''^<font face="courier" size="2"^>'' >> ' + @sMapHTMLFileNameWithPath_TMP
			Execute master.dbo.xp_cmdshell @sCmd, NO_OUTPUT

			Set @sCmd = 'echo ' + @sTabDouble + '+ ''^<strong^>' + @sAnaCod + ' - ' + @sAnaDes + '^</strong^>'' >> ' + @sMapHTMLFileNameWithPath_TMP
			Execute master.dbo.xp_cmdshell @sCmd, NO_OUTPUT

			Set @sCmd = 'echo ' + @sTabDouble + '+ ''^<br^>' + @sIndBuild + ''' >> ' + @sMapHTMLFileNameWithPath_TMP
			Execute master.dbo.xp_cmdshell @sCmd, NO_OUTPUT

			Set @sCmd = 'echo ' + @sTabDouble + '+ ''^<br^>' + @sTel + ''' >> ' + @sMapHTMLFileNameWithPath_TMP
			Execute master.dbo.xp_cmdshell @sCmd, NO_OUTPUT

			Set @sCmd = 'echo ' + @sTabDouble + '+ ''^<br^>^<br^>PRODOTTO^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;PREZZO^&nbsp;^&nbsp;^&nbsp;^&nbsp;QT.A`^&nbsp;^&nbsp;TOTALE^<br^>'' >> ' + @sMapHTMLFileNameWithPath_TMP
			Execute master.dbo.xp_cmdshell @sCmd, NO_OUTPUT
		End

		Set @sPrezzo = dbo.[udfFormatNum_Pers](@dPrezzo)
		Set @sRimanenza = dbo.[udfFormatNum_Pers](@dRimanenza)
		Set @sTotaleLinea = dbo.[udfFormatNum_Pers](@dTotaleLinea)

		-- Set @sCmd = 'echo ' + @sTabDouble + '+ ''^<br^>' + Replace(Left(@sPrdDes + @sSpace40, 40) + Left(@sPezzatura + @sSpace13, 13) + Left(@sPrezzo + @sSpace10, 10) + Left(@sRimanenza + @sSpace07, 7) + Left(@sTotaleLinea + @sSpace10, 10), ' ', '^&nbsp;') + ''' >> ' + @sMapHTMLFileNameWithPath_TMP
        Set @sCmd = 'echo ' + @sTabDouble + '+ ''^<br^>' + Replace(Left(@sPrdDes + @sSpace53, 53) + Left(@sPrezzo + @sSpace10, 10) + Left(@sRimanenza + @sSpace07, 7) + Left(@sTotaleLinea + @sSpace10, 10), ' ', '^&nbsp;') + ''' >> ' + @sMapHTMLFileNameWithPath_TMP
		Execute master.dbo.xp_cmdshell @sCmd, NO_OUTPUT

		If Len(@sCommenti) > 0
		Begin
			Set @sCmd = 'echo ' + @sTabDouble + '+ ''^<br^>^<strong^>' + @sCommenti + '^</strong^>^<br^>'' >> ' + @sMapHTMLFileNameWithPath_TMP
			Execute master.dbo.xp_cmdshell @sCmd, NO_OUTPUT
		End

		Set @sRottura_Prec = @sRottura

		Set @sRGB_Prec = @sRGB
		Set @dCoordLat_Prec = @dCoordLat
		Set @dCoordLng_Prec = @dCoordLng
		Set @iNumPrd_Prec = @iNumPrd
		Set @iNumCat_Prec = @iNumCat

		Set @dTotale += @dTotaleLinea
		Set @dTotaleQta += @dRimanenza

		Fetch Next From cCursor_BuildHTMLMap Into
			@sRottura,
			@iAnaType,
			@sAnaCod,
			@sAnaDes,
			@sDsmCod,
			@sIndBuild,
			@sTel,
			@dCoordLat,
			@dCoordLng,
			@sRGB,
			@sPrdCod,
			@sPrdDes,
			@iNumPrd,
			@iNumCat,
			@sCatCod,
			@dRimanenza,
			@sPezzatura,
			@dPrezzo,
			@dTotaleLinea,
			@sCommenti
	END

	Close cCursor_BuildHTMLMap
	Deallocate cCursor_BuildHTMLMap

	If @iCnt = 0
		Set @sMsg = 'Nessuna linea ordine con rimanenza rilevata. Operazione annullata.'

	If Len(@sMsg) = 0
	Begin
		Set @sTotale = dbo.[udfFormatNum_Pers](@dTotale)
		Set @sTotaleQta = RTrim(LTrim(Cast(Cast(Round(@dTotaleQta, 0) As int) As varchar(16))))
		Set @sCoordLat_Prec = dbo.[udfFormatNum_Pers](@dCoordLat_Prec)
		Set @sCoordLng_Prec = dbo.[udfFormatNum_Pers](@dCoordLng_Prec)

		Set @sCmd = 'echo ' + @sTabDouble + '+ ''^<br^>^<br^>^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp;^&nbsp; Totale Ordine^&nbsp;^&nbsp;' + @sTotale + '^&euro;^</font^>'' >> ' + @sMapHTMLFileNameWithPath_TMP
		Execute master.dbo.xp_cmdshell @sCmd, NO_OUTPUT

		Set @sCmd = 'echo ' + @sTabDouble + ', ' + @sCoordLat_Prec + ', ' + @sCoordLng_Prec + ', ' + RTrim(LTrim(Cast(@iCnt As varchar(8)))) + ', "https://chart.apis.google.com/chart?chst=d_map_xpin_letter&chld=pin' + Case When @iNumPrd_Prec = 1 Then '' Else '_star' End + '|' + @sTotaleQta + '|' + @sRGB_Prec + '|ffffff|000000" >> ' + @sMapHTMLFileNameWithPath_TMP
		Execute master.dbo.xp_cmdshell @sCmd, NO_OUTPUT

		Set @sCmd = 'echo ' + @sTabDouble + '] >> ' + @sMapHTMLFileNameWithPath_TMP
		Execute master.dbo.xp_cmdshell @sCmd, NO_OUTPUT

		Set @sCmd = 'echo ' + @sTab + ']; >> ' + @sMapHTMLFileNameWithPath_TMP
		Execute master.dbo.xp_cmdshell @sCmd, NO_OUTPUT

-- --------------------------------------------------------------------------------
-- AGGANCIO PARAMETRI DI CENTRATURA MAPPA E ZOOM
-- --------------------------------------------------------------------------------

		Set @sCmd = 'echo. >> ' + @sMapHTMLFileNameWithPath_TMP
		Execute master.dbo.xp_cmdshell @sCmd, NO_OUTPUT
		Set @sCmd = 'echo. >> ' + @sMapHTMLFileNameWithPath_TMP
		Execute master.dbo.xp_cmdshell @sCmd, NO_OUTPUT
		Set @sCmd = 'echo ' + @sPreFooterLine000 + ' >> ' + @sMapHTMLFileNameWithPath_TMP
		Execute master.dbo.xp_cmdshell @sCmd, NO_OUTPUT
		Set @sCmd = 'echo ' + Replace(Replace(@sPreFooterLine001, '{0}', @sCenterCoordLat), '{1}', @sCenterCoordLng) + ' >> ' + @sMapHTMLFileNameWithPath_TMP
		Execute master.dbo.xp_cmdshell @sCmd, NO_OUTPUT
		Set @sCmd = 'echo ' + Replace(@sPreFooterLine002, '{2}', @sZoom) + ' >> ' + @sMapHTMLFileNameWithPath_TMP
		Execute master.dbo.xp_cmdshell @sCmd, NO_OUTPUT
		Set @sCmd = 'echo ' + @sPreFooterLine003 + ' >> ' + @sMapHTMLFileNameWithPath_TMP
		Execute master.dbo.xp_cmdshell @sCmd, NO_OUTPUT
		Set @sCmd = 'echo ' + @sPreFooterLine004 + ' >> ' + @sMapHTMLFileNameWithPath_TMP
		Execute master.dbo.xp_cmdshell @sCmd, NO_OUTPUT
		Set @sCmd = 'echo. >> ' + @sMapHTMLFileNameWithPath_TMP
		Execute master.dbo.xp_cmdshell @sCmd, NO_OUTPUT
		Set @sCmd = 'echo. >> ' + @sMapHTMLFileNameWithPath_TMP

-- --------------------------------------------------------------------------------
-- COSTRUZIONE OUTPUT FILE FINALE
-- --------------------------------------------------------------------------------

		Set @sCmd = 'copy /B ' + @sMapHTMLFileNameWithPath_TMP + ' + ' + @sMapHTMLFileNameFooterWithPath + ' ' + @sMapHTMLFileNameWithPath
		Execute master.dbo.xp_cmdshell @sCmd, NO_OUTPUT

		Delete From @tbCmdRes
		Set @sCmd = 'dir ' + @sMapHTMLFileNameWithPath + ' /B'
		Insert Into @tbCmdRes(Res)
		Execute master.dbo.xp_cmdshell @sCmd

		Select Top 1 @bExist = 1 From @tbCmdRes Where CharIndex(@sMapHTMLFileNameWithoutPath, Res) > 0
		If IsNull(@bExist, 0) = 0
			Set @sMsg = 'Creazione file mappa fallita. Impossibile procedere.'
	End
End

-- --------------------------------------------------------------------------------
-- FINE OPERAZIONI ED USCITA
-- --------------------------------------------------------------------------------

If @bDelMapHTMLFileNameWithPath_TMP <> 0
Begin
	Set @sCmd = 'del ' + @sMapHTMLFileNameWithPath_TMP + ' /Q'
	Execute master.dbo.xp_cmdshell @sCmd, NO_OUTPUT

	Select @sCmdClear = ItemValue From dbo.[CoordPar_Pers] Where ItemID = 'CMDCLEAR'
	Set @sCmdClear = RTrim(LTrim(IsNull(@sCmdClear, '')))
	If Len(@sCmdClear) > 0
		Execute master.dbo.xp_cmdshell @sCmdClear, NO_OUTPUT
End

If Len(@sMsg) = 0
	Set @sMsg = 'OK|' + @sMapHTMLPathClient + @sMapHTMLFileNameWithoutPath
Else
	Set @sMsg = 'KO|' + @sMsg

Select @sMsg Res
GO
