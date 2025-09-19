/*
*
*
*
*/
CREATE PROCEDURE [uspGriotPrepFile_Pers]
	@sTomorrow varchar(1)
AS
SET NOCOUNT ON

Declare @sSQL varchar(8000)
Declare @sFolder varchar(1024) = ''
Declare @sMsg varchar(1024) = ''
Declare @sCmd varchar(1024)

Declare @iCnt int = 0

Select @sFolder = ItemValue From dbo.[ImportDDTPar_Pers] Where ItemID = 'TX'
Set @sFolder = RTrim(LTrim(IsNull(@sFolder, '')))

If Len(@sFolder) = 0
	Set @sMsg = 'Parametro relativo alla cartella di lavoro TX mancante o non valido'

If Len(@sMsg) = 0
Begin

	Set @sFolder = Replace(@sFolder, '/', '\')
	If Right(@sFolder, 1) <> '\'
		Set @sFolder = @sFolder + '\'

	Set @sCmd = 'del /Q ' + @sFolder + 'articoli*.txt'
	Exec master.dbo.xp_cmdshell @sCmd, NO_OUTPUT

	If Upper(RTrim(LTrim(IsNull(@sTomorrow, '')))) In('', '0', 'N')
		Select @sSQL = 'bcp "Select Riga From [BpGRIOT].[dbo].[uvwGriotExportCli_Pers] Where Riga Is Not Null Order By Riga" queryout "' + @sFolder + 'Clienti.txt" -c -t"	" -Usa -Pbarberadoc -S "NB-GRIOT\BEEP" -T'
	Else
		Select @sSQL = 'bcp "Select Riga From [BpGRIOT].[dbo].[uvwGriotExportCliTomorrow_Pers] Where Riga Is Not Null Order By Riga" queryout "' + @sFolder + 'Clienti.txt" -c -t"	" -Usa -Pbarberadoc -S "NB-GRIOT\BEEP" -T'

	Exec master.dbo.xp_cmdshell @sSQL, NO_OUTPUT


	Select @sSQL = 'bcp "Select Riga From [BpGRIOT].[dbo].[uvwGriotExportPrd_Pers] Where Riga Is Not Null Order By Riga" queryout "' + @sFolder + 'articoli00.txt" -c -t"	" -Usa -Pbarberadoc -S "NB-GRIOT\BEEP" -T'

	Exec master.dbo.xp_cmdshell @sSQL, NO_OUTPUT
End

If Len(@sMsg) = 0
	Set @sMsg = 'Operazione effettuata.'

Select @sMsg Res