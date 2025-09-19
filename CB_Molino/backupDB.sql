USE [BpMOLINOMARTINETTO];
GO
SET NOCOUNT ON;
SET XACT_ABORT ON;

-- Helper per creare la tabella di bck se non esiste (schema-only)
-- e poi popolarla con INSERT INTO ... SELECT *
-- Ripeti per ogni tabella coinvolta

------------------------------------------------------------
-- PrdAna
------------------------------------------------------------
IF OBJECT_ID('dbo.PrdAna_bck','U') IS NULL
    SELECT TOP (0) * INTO dbo.PrdAna_bck FROM dbo.PrdAna;
ELSE
    TRUNCATE TABLE dbo.PrdAna_bck;
INSERT INTO dbo.PrdAna_bck SELECT * FROM dbo.PrdAna;

------------------------------------------------------------
-- PrdPrz
------------------------------------------------------------
IF OBJECT_ID('dbo.PrdPrz_bck','U') IS NULL
    SELECT TOP (0) * INTO dbo.PrdPrz_bck FROM dbo.PrdPrz;
ELSE
    TRUNCATE TABLE dbo.PrdPrz_bck;
INSERT INTO dbo.PrdPrz_bck SELECT * FROM dbo.PrdPrz;

------------------------------------------------------------
-- PrdDes
------------------------------------------------------------
IF OBJECT_ID('dbo.PrdDes_bck','U') IS NULL
    SELECT TOP (0) * INTO dbo.PrdDes_bck FROM dbo.PrdDes;
ELSE
    TRUNCATE TABLE dbo.PrdDes_bck;
INSERT INTO dbo.Prddes_bck SELECT * FROM dbo.PrdDes;

------------------------------------------------------------
-- PrdFor
------------------------------------------------------------
IF OBJECT_ID('dbo.PrdFor_bck','U') IS NULL
    SELECT TOP (0) * INTO dbo.PrdFor_bck FROM dbo.PrdFor;
ELSE
    TRUNCATE TABLE dbo.PrdFor_bck;
INSERT INTO dbo.PrdFor_bck SELECT * FROM dbo.PrdFor;

------------------------------------------------------------
-- PrdForHistory
------------------------------------------------------------
IF OBJECT_ID('dbo.PrdForHistory_bck','U') IS NULL
    SELECT TOP (0) * INTO dbo.PrdForHistory_bck FROM dbo.PrdForHistory;
ELSE
    TRUNCATE TABLE dbo.PrdForHistory_bck;
INSERT INTO dbo.PrdForHistory_bck SELECT * FROM dbo.PrdForHistory;

------------------------------------------------------------
-- PrdForPromo
------------------------------------------------------------
IF OBJECT_ID('dbo.PrdForPromo_bck','U') IS NULL
    SELECT TOP (0) * INTO dbo.PrdForPromo_bck FROM dbo.PrdForPromo;
ELSE
    TRUNCATE TABLE dbo.PrdForPromo_bck;
INSERT INTO dbo.PrdForPromo_bck SELECT * FROM dbo.PrdForPromo;

------------------------------------------------------------
-- PrdMin
------------------------------------------------------------
IF OBJECT_ID('dbo.PrdMin_bck','U') IS NULL
    SELECT TOP (0) * INTO dbo.PrdMin_bck FROM dbo.PrdMin;
ELSE
    TRUNCATE TABLE dbo.PrdMin_bck;
INSERT INTO dbo.PrdMin_bck SELECT * FROM dbo.PrdMin;

------------------------------------------------------------
-- PrdMag
------------------------------------------------------------
IF OBJECT_ID('dbo.PrdMag_bck','U') IS NULL
    SELECT TOP (0) * INTO dbo.PrdMag_bck FROM dbo.PrdMag;
ELSE
    TRUNCATE TABLE dbo.PrdMag_bck;
INSERT INTO dbo.PrdMag_bck SELECT * FROM dbo.PrdMag;

------------------------------------------------------------
-- PrdMagCli
------------------------------------------------------------
IF OBJECT_ID('dbo.PrdMagCli_bck','U') IS NULL
    SELECT TOP (0) * INTO dbo.PrdMagCli_bck FROM dbo.PrdMagCli;
ELSE
    TRUNCATE TABLE dbo.PrdMagCli_bck;
INSERT INTO dbo.PrdMagCli_bck SELECT * FROM dbo.PrdMagCli;

------------------------------------------------------------
-- PrdPrzAdd
------------------------------------------------------------
IF OBJECT_ID('dbo.PrdPrzAdd_bck','U') IS NULL
    SELECT TOP (0) * INTO dbo.PrdPrzAdd_bck FROM dbo.PrdPrzAdd;
ELSE
    TRUNCATE TABLE dbo.PrdPrzAdd_bck;
INSERT INTO dbo.PrdPrzAdd_bck SELECT * FROM dbo.PrdPrzAdd;

------------------------------------------------------------
-- MixAnaAlias
------------------------------------------------------------
IF OBJECT_ID('dbo.MixAnaAlias_bck','U') IS NULL
    SELECT TOP (0) * INTO dbo.MixAnaAlias_bck FROM dbo.MixAnaAlias;
ELSE
    TRUNCATE TABLE dbo.MixAnaAlias_bck;
INSERT INTO dbo.MixAnaAlias_bck SELECT * FROM dbo.MixAnaAlias;

------------------------------------------------------------
-- PrdUm2
------------------------------------------------------------
IF OBJECT_ID('dbo.PrdUm2_bck','U') IS NULL
    SELECT TOP (0) * INTO dbo.PrdUm2_bck FROM dbo.PrdUm2;
ELSE
    TRUNCATE TABLE dbo.PrdUm2_bck;
INSERT INTO dbo.PrdUm2_bck SELECT * FROM dbo.PrdUm2;

------------------------------------------------------------
-- VndPro
------------------------------------------------------------
IF OBJECT_ID('dbo.VndPro_bck','U') IS NULL
    SELECT TOP (0) * INTO dbo.VndPro_bck FROM dbo.VndPro;
ELSE
    TRUNCATE TABLE dbo.VndPro_bck;
INSERT INTO dbo.VndPro_bck SELECT * FROM dbo.VndPro;

------------------------------------------------------------
-- PrdLotAna
------------------------------------------------------------
IF OBJECT_ID('dbo.PrdLotAna_bck','U') IS NULL
    SELECT TOP (0) * INTO dbo.PrdLotAna_bck FROM dbo.PrdLotAna;
ELSE
    TRUNCATE TABLE dbo.PrdLotAna_bck;
INSERT INTO dbo.PrdLotAna_bck SELECT * FROM dbo.PrdLotAna;

------------------------------------------------------------
-- SupplyMaterial
------------------------------------------------------------
IF OBJECT_ID('dbo.SupplyMaterial_bck','U') IS NULL
    SELECT TOP (0) * INTO dbo.SupplyMaterial_bck FROM dbo.SupplyMaterial;
ELSE
    TRUNCATE TABLE dbo.SupplyMaterial_bck;
INSERT INTO dbo.SupplyMaterial_bck SELECT * FROM dbo.SupplyMaterial;

------------------------------------------------------------
-- Attach
------------------------------------------------------------
TRUNCATE TABLE dbo.Attach_bck;

-- 2) Costruisci la lista colonne (copincolla il risultato) e usa IDENTITY_INSERT
--    Oppure usa questo blocco dinamico minimo:
DECLARE @cols nvarchar(max) = STUFF((
    SELECT N',' + QUOTENAME(c.name)
    FROM sys.columns c
    WHERE c.object_id = OBJECT_ID(N'dbo.Attach')
      AND c.is_computed = 0
    ORDER BY c.column_id
    FOR XML PATH(''), TYPE
).value('.', 'nvarchar(max)'), 1, 1, N'');

SET IDENTITY_INSERT dbo.Attach_bck ON;
EXEC(N'INSERT INTO dbo.Attach_bck (' + @cols + N') SELECT ' + @cols + N' FROM dbo.Attach;');
SET IDENTITY_INSERT dbo.Attach_bck OFF;

------------------------------------------------------------
-- (Opzionale) Verifica rowcount
------------------------------------------------------------
SELECT 'PrdAna' AS TableName, (SELECT COUNT(*) FROM dbo.PrdAna) AS Src, (SELECT COUNT(*) FROM dbo.PrdAna_bck) AS Bkp
UNION ALL SELECT 'PrdPrz', (SELECT COUNT(*) FROM dbo.PrdPrz), (SELECT COUNT(*) FROM dbo.PrdPrz_bck)
UNION ALL SELECT 'PrdDes', (SELECT COUNT(*) FROM dbo.PrdDes), (SELECT COUNT(*) FROM dbo.PrdDes_bck)
UNION ALL SELECT 'PrdFor', (SELECT COUNT(*) FROM dbo.PrdFor), (SELECT COUNT(*) FROM dbo.PrdFor_bck)
UNION ALL SELECT 'PrdForHistory', (SELECT COUNT(*) FROM dbo.PrdForHistory), (SELECT COUNT(*) FROM dbo.PrdForHistory_bck)
UNION ALL SELECT 'PrdForPromo', (SELECT COUNT(*) FROM dbo.PrdForPromo), (SELECT COUNT(*) FROM dbo.PrdForPromo_bck)
UNION ALL SELECT 'PrdMin', (SELECT COUNT(*) FROM dbo.PrdMin), (SELECT COUNT(*) FROM dbo.PrdMin_bck)
UNION ALL SELECT 'PrdMag', (SELECT COUNT(*) FROM dbo.PrdMag), (SELECT COUNT(*) FROM dbo.PrdMag_bck)
UNION ALL SELECT 'PrdMagCli', (SELECT COUNT(*) FROM dbo.PrdMagCli), (SELECT COUNT(*) FROM dbo.PrdMagCli_bck)
UNION ALL SELECT 'PrdPrzAdd', (SELECT COUNT(*) FROM dbo.PrdPrzAdd), (SELECT COUNT(*) FROM dbo.PrdPrzAdd_bck)
UNION ALL SELECT 'MixAnaAlias', (SELECT COUNT(*) FROM dbo.MixAnaAlias), (SELECT COUNT(*) FROM dbo.MixAnaAlias_bck)
UNION ALL SELECT 'PrdUm2', (SELECT COUNT(*) FROM dbo.PrdUm2), (SELECT COUNT(*) FROM dbo.PrdUm2_bck)
UNION ALL SELECT 'VndPro', (SELECT COUNT(*) FROM dbo.VndPro), (SELECT COUNT(*) FROM dbo.VndPro_bck)
UNION ALL SELECT 'PrdLotAna', (SELECT COUNT(*) FROM dbo.PrdLotAna), (SELECT COUNT(*) FROM dbo.PrdLotAna_bck)
UNION ALL SELECT 'SupplyMaterial', (SELECT COUNT(*) FROM dbo.SupplyMaterial), (SELECT COUNT(*) FROM dbo.SupplyMaterial_bck)
UNION ALL SELECT 'Attach', (SELECT COUNT(*) FROM dbo.Attach), (SELECT COUNT(*) FROM dbo.Attach_bck);
