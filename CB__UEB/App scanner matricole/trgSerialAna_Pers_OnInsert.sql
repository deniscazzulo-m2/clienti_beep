/* 
*
*
*
*/
CREATE TRIGGER [trgSerialAna_Pers_OnInsert]
ON dbo.[SerialAna_Pers]
INSTEAD OF INSERT
AS
SET NOCOUNT ON
DECLARE @iNumero decimal(13) = 0
DECLARE @sTesto varchar(32) = ''
	
DECLARE [cCursor] CURSOR LOCAL FAST_FORWARD FOR 
SELECT SerialScan FROM inserted WHERE CHARINDEX('@',SerialScan) > 0

IF ISNULL((SELECT COUNT(*) FROM inserted WHERE CHARINDEX('@',SerialScan) > 0), 0) > 0
BEGIN
 	OPEN [cCursor]
 	FETCH NEXT FROM [cCursor] INTO @sTesto
 	WHILE @@Fetch_Status <> -1
	BEGIN
		EXECUTE dbo.[uspNumUniqNext_out] 'SerialAna_Pers', @iNumero OUTPUT
		
	  	INSERT dbo.[SerialAna_Pers] (
			Uniq, 
			Machine, 
			SerialScan, 
			ScanDta, 
			ScanOra
		) 
		VALUES (
			@iNumero,
			SUBSTRING(@sTesto , LEN(@sTesto) - CHARINDEX('@',REVERSE(@sTesto)) + 2, LEN(@sTesto)),
			SUBSTRING(@sTesto , 0, LEN(@sTesto) -  CHARINDEX('@',REVERSE(@sTesto)) + 1),
			CONVERT(DATE, GETDATE()),
			CONVERT(TIME, GETDATE())
		)
		-- ----------------------------------------------------------
	 	FETCH NEXT FROM [cCursor] INTO @sTesto
 	END
	CLOSE [cCursor]
END
DEALLOCATE [cCursor]