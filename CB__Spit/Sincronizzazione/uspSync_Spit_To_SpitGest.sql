/* 
*
*
*
*/
CREATE PROCEDURE [uspSync_Spit_To_SpitGest]
AS
SET NOCOUNT ON

INSERT INTO dbo.[ZLogSync_Pers](
	ItemValue
	, ItemDate)
VALUES(
	'SINCRONIZZAZIONE // SPIT -> SPIT_GEST // Inizio sincronizzazione'
	, Cast(GETDATE() As smalldatetime));
	
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
BEGIN TRAN
	
	DECLARE @tActions TABLE (MergeAction VARCHAR(10), tableName VARCHAR(32));

	MERGE [BpSPITGEST].[dbo].[MixAna] T USING (
	    SELECT
	        *
	    FROM
	        [BpSPIT].[dbo].[MixAna]
	    WHERE
	        [ItemType] = '1'
	) S ON RTRIM(LTRIM(ISNULL(T.[ItemID],''))) = RTRIM(LTRIM(ISNULL(S.[ItemID],'')))
	AND RTRIM(LTRIM(ISNULL(T.[ItemType],''))) = RTRIM(LTRIM(ISNULL(S.[ItemType],'')))
	WHEN MATCHED
	AND (
	    [BpSPIT].[dbo].[udfSync_DiffToBool](T.[ItemUse], S.[ItemUse]) = 1
	    OR [BpSPIT].[dbo].[udfSync_DiffToBool](T.[ItemDesShort], S.[ItemDesShort]) = 1
	    OR [BpSPIT].[dbo].[udfSync_DiffToBool](T.[ItemDes], S.[ItemDes]) = 1
	    OR [BpSPIT].[dbo].[udfSync_DiffToBool](T.[Ind], S.[Ind]) = 1
	    OR [BpSPIT].[dbo].[udfSync_DiffToBool](T.[Loc], S.[Loc]) = 1
	    OR [BpSPIT].[dbo].[udfSync_DiffToBool](T.[Cap], S.[Cap]) = 1
	    OR [BpSPIT].[dbo].[udfSync_DiffToBool](T.[Pro], S.[Pro]) = 1
	    OR [BpSPIT].[dbo].[udfSync_DiffToBool](T.[Reg], S.[Reg]) = 1
	    OR [BpSPIT].[dbo].[udfSync_DiffToBool](T.[Naz], S.[Naz]) = 1
	    OR [BpSPIT].[dbo].[udfSync_DiffToBool](T.[ItemAlert], S.[ItemAlert]) = 1
	    OR [BpSPIT].[dbo].[udfSync_DiffToBool](T.[PIva], S.[PIva]) = 1
	    OR [BpSPIT].[dbo].[udfSync_DiffToBool](T.[CFis], S.[CFis]) = 1
	    OR [BpSPIT].[dbo].[udfSync_DiffToBool](T.[NumMat], S.[NumMat]) = 1
	    OR [BpSPIT].[dbo].[udfSync_DiffToBool](T.[Language], S.[Language]) = 1
	    OR [BpSPIT].[dbo].[udfSync_DiffToBool](T.[ItemPriority], S.[ItemPriority]) = 1
	    OR [BpSPIT].[dbo].[udfSync_DiffToBool](T.[ItemIDStat], S.[ItemIDStat]) = 1
	    OR [BpSPIT].[dbo].[udfSync_DiffToBool](T.[ItemIDFat], S.[ItemIDFat]) = 1
	    OR [BpSPIT].[dbo].[udfSync_DiffToBool](T.[ItemIDOther], S.[ItemIDOther]) = 1
	    OR [BpSPIT].[dbo].[udfSync_DiffToBool](T.[PosArc], S.[PosArc]) = 1
	    OR [BpSPIT].[dbo].[udfSync_DiffToBool](T.[FepaType], S.[FepaType]) = 1
	    OR [BpSPIT].[dbo].[udfSync_DiffToBool](T.[FepaEsgIva], S.[FepaEsgIva]) = 1
	    OR [BpSPIT].[dbo].[udfSync_DiffToBool](T.[FepaDest], S.[FepaDest]) = 1
	    OR [BpSPIT].[dbo].[udfSync_DiffToBool](T.[FepaPec], S.[FepaPec]) = 1
	) THEN
	UPDATE
	SET
	    T.[ItemUse] = [BpSPIT].[dbo].[udfSync_DiffToVal](T.[ItemUse], S.[ItemUse]),
	    T.[ItemDesShort] = [BpSPIT].[dbo].[udfSync_DiffToVal](T.[ItemDesShort], S.[ItemDesShort]),
	    T.[ItemDes] = [BpSPIT].[dbo].[udfSync_DiffToVal](T.[ItemDes], S.[ItemDes]),
	    T.[Ind] = [BpSPIT].[dbo].[udfSync_DiffToVal](T.[Ind], S.[Ind]),
	    T.[Loc] = [BpSPIT].[dbo].[udfSync_DiffToVal](T.[Loc], S.[Loc]),
	    T.[Cap] = [BpSPIT].[dbo].[udfSync_DiffToVal](T.[Cap], S.[Cap]),
	    T.[Pro] = [BpSPIT].[dbo].[udfSync_DiffToVal](T.[Pro], S.[Pro]),
	    T.[Reg] = [BpSPIT].[dbo].[udfSync_DiffToVal](T.[Reg], S.[Reg]),
	    T.[Naz] = [BpSPIT].[dbo].[udfSync_DiffToVal](T.[Naz], S.[Naz]),
	    T.[ItemAlert] = [BpSPIT].[dbo].[udfSync_DiffToVal](T.[ItemAlert], S.[ItemAlert]),
	    T.[PIva] = [BpSPIT].[dbo].[udfSync_DiffToVal](T.[PIva], S.[PIva]),
	    T.[CFis] = [BpSPIT].[dbo].[udfSync_DiffToVal](T.[CFis], S.[CFis]),
	    T.[NumMat] = [BpSPIT].[dbo].[udfSync_DiffToVal](T.[NumMat], S.[NumMat]),
	    T.[Language] = [BpSPIT].[dbo].[udfSync_DiffToVal](T.[Language], S.[Language]),
	    T.[ItemPriority] = [BpSPIT].[dbo].[udfSync_DiffToVal](T.[ItemPriority], S.[ItemPriority]),
	    T.[ItemIDStat] = [BpSPIT].[dbo].[udfSync_DiffToVal](T.[ItemIDStat], S.[ItemIDStat]),
	    T.[ItemIDFat] = [BpSPIT].[dbo].[udfSync_DiffToVal](T.[ItemIDFat], S.[ItemIDFat]),
	    T.[ItemIDOther] = [BpSPIT].[dbo].[udfSync_DiffToVal](T.[ItemIDOther], S.[ItemIDOther]),
	    T.[PosArc] = [BpSPIT].[dbo].[udfSync_DiffToVal](T.[PosArc], S.[PosArc]),
	    T.[FepaType] = [BpSPIT].[dbo].[udfSync_DiffToVal](T.[FepaType], S.[FepaType]),
	    T.[FepaEsgIva] = [BpSPIT].[dbo].[udfSync_DiffToVal](T.[FepaEsgIva], S.[FepaEsgIva]),
	    T.[FepaDest] = [BpSPIT].[dbo].[udfSync_DiffToVal](T.[FepaDest], S.[FepaDest]),
	    T.[FepaPec] = [BpSPIT].[dbo].[udfSync_DiffToVal](T.[FepaPec], S.[FepaPec]),
	    T.[RecChange] = CAST(GETDATE() AS DATE),
	    T.[RecChangeUserID] = '-1'
	    WHEN NOT MATCHED BY TARGET THEN
	INSERT
	    (
	        [ItemID],
	        [ItemType],
	        [ItemUse],
	        [ItemDesShort],
	        [ItemDes],
	        [Ind],
	        [Loc],
	        [Cap],
	        [Pro],
	        [Reg],
	        [Naz],
	        [ItemAlert],
	        [PIva],
	        [CFis],
	        [NumMat],
	        [Language],
	        [ItemPriority],
	        [ItemIDStat],
	        [ItemIDFat],
	        [ItemIDOther],
	        [PosArc],
	        [FepaType],
	        [FepaEsgIva],
	        [FepaDest],
	        [FepaPec],
	        [RecCreate],
	        [RecUserID],
	        [RecChange],
	        [RecChangeUserID]
	    )
	VALUES
	    (
	        S.[ItemID],
	        S.[ItemType],
	        S.[ItemUse],
	        S.[ItemDesShort],
	        S.[ItemDes],
	        S.[Ind],
	        S.[Loc],
	        S.[Cap],
	        S.[Pro],
	        S.[Reg],
	        S.[Naz],
	        S.[ItemAlert],
	        S.[PIva],
	        S.[CFis],
	        S.[NumMat],
	        S.[Language],
	        S.[ItemPriority],
	        S.[ItemIDStat],
	        S.[ItemIDFat],
	        S.[ItemIDOther],
	        S.[PosArc],
	        S.[FepaType],
	        S.[FepaEsgIva],
	        S.[FepaDest],
	        S.[FepaPec],
	        CAST(GETDATE() AS DATE),
	        '-1',
	        CAST(GETDATE() AS DATE),
	        '-1'
	    )
	OUTPUT
	  $action, 'MixAna' INTO @tActions;
	  
	 MERGE [BpSPITGEST].[dbo].[MixAnaAlias] T USING (
	    SELECT
	        *
	    FROM
	        [BpSPIT].[dbo].[MixAnaAlias]
	    WHERE
	        [ItemType] = '1'
	) S ON RTRIM(LTRIM(ISNULL(T.[ItemID],''))) = RTRIM(LTRIM(ISNULL(S.[ItemID],'')))
	AND RTRIM(LTRIM(ISNULL(T.[ItemType],''))) = RTRIM(LTRIM(ISNULL(S.[ItemType],'')))
	AND RTRIM(LTRIM(ISNULL(T.[AliasID],''))) = RTRIM(LTRIM(ISNULL(S.[AliasID],'')))
	WHEN NOT MATCHED BY TARGET THEN
	INSERT
	    (
	        [ItemID],
	        [ItemType],
	        [AliasType],
	        [AliasID],
	        [AliasRevision],
	        [AliasDefault],
	        [AliasHide],
	        [PrintOnLabel],
	        [DivideOnLabel],
	        [ItemInfo]
	    )
	VALUES
	    (
	        S.[ItemID],
	        S.[ItemType],
	        S.[AliasType],
	        S.[AliasID],
	        S.[AliasRevision],
	        S.[AliasDefault],
	        S.[AliasHide],
	        S.[PrintOnLabel],
	        S.[DivideOnLabel],
	        S.[ItemInfo]
	    )
	OUTPUT
	  $action, 'MixAnaAlias' INTO @tActions;
	  
	  MERGE [BpSPITGEST].[dbo].[MixAnaRif] T USING (
	    SELECT
	        *
	    FROM
	        [BpSPIT].[dbo].[MixAnaRif]
	    WHERE
	        [ItemType] = '1'
	) S ON RTRIM(LTRIM(ISNULL(T.[ItemID],''))) = RTRIM(LTRIM(ISNULL(S.[ItemID],'')))
	AND RTRIM(LTRIM(ISNULL(T.[ItemType],''))) = RTRIM(LTRIM(ISNULL(S.[ItemType],'')))
	AND RTRIM(LTRIM(ISNULL(T.[ItemIDSede],''))) = RTRIM(LTRIM(ISNULL(S.[ItemIDSede],'')))
	AND RTRIM(LTRIM(ISNULL(T.[ItemIDRif],''))) = RTRIM(LTRIM(ISNULL(S.[ItemIDRif],'')))
	WHEN NOT MATCHED BY TARGET THEN
	INSERT
	    (
	        [ItemID],
	        [ItemType],
	        [ItemIDSede],
	        [ItemIDRif],
	        [ItemDefault],
	        [ItemUse],
	        [ItemDes],
	        [WhoTitle],
	        [WhoName],
	        [WhoPos],
	        [Tel1],
	        [Tel2],
	        [Tel3],
	        [MailAddress],
	        [MailAddressPEC],
	        [VoIP1],
	        [VoIP2],
	        [VoIP3],
	        [ItemInfo],
	        [RecCreate],
	        [RecUserID],
	        [RecChange],
	        [RecChangeUserID]
	    )
	VALUES
	    (
	        S.[ItemID],
	        S.[ItemType],
	        S.[ItemIDSede],
	        S.[ItemIDRif],
	        S.[ItemDefault],
	        S.[ItemUse],
	        S.[ItemDes],
	        S.[WhoTitle],
	        S.[WhoName],
	        S.[WhoPos],
	        S.[Tel1],
	        S.[Tel2],
	        S.[Tel3],
	        S.[MailAddress],
	        S.[MailAddressPEC],
	        S.[VoIP1],
	        S.[VoIP2],
	        S.[VoIP3],
	        S.[ItemInfo],
	        CAST(GETDATE() AS DATE),
	        '-1',
	        CAST(GETDATE() AS DATE),
	        '-1'
	    )
	OUTPUT
	  $action, 'MixAnaRif' INTO @tActions;
	  
	  MERGE [BpSPITGEST].[dbo].[MixAnaSedi] T USING (
	    SELECT
	        *
	    FROM
	        [BpSPIT].[dbo].[MixAnaSedi]
	    WHERE
	        [ItemType] = '1'
	) S ON RTRIM(LTRIM(ISNULL(T.[ItemID],''))) = RTRIM(LTRIM(ISNULL(S.[ItemID],'')))
	AND RTRIM(LTRIM(ISNULL(T.[ItemType],''))) = RTRIM(LTRIM(ISNULL(S.[ItemType],'')))
	AND RTRIM(LTRIM(ISNULL(T.[ItemIDSede],''))) = RTRIM(LTRIM(ISNULL(S.[ItemIDSede],'')))
	WHEN NOT MATCHED BY TARGET THEN
	INSERT
	    (
	        [ItemID],
	        [ItemType],
	        [ItemIDSede],
	        [ItemUse],
	        [ItemDsm],
	        [ItemDes],
	        [Ind],
	        [Cap],
	        [Loc],
	        [Pro],
	        [Reg],
	        [Naz],
	        [Language],
	        [www],
	        [LstCod],
	        [PagCod],
	        [Sconti],
	        [GrpCod],
	        [CatCod],
	        [AgeCod],
	        [PrvCla],
	        [PrvFix],
	        [PrvFixOff],
	        [ShipCod],
	        [VetCod],
	        [VetCod2],
	        [AerCod],
	        [ShipPayCod],
	        [TrMezzo],
	        [TrPorto],
	        [TrImballo],
	        [TrFDeposito],
	        [TrSendWay],
	        [Info1],
	        [Info2],
	        [Info3],
	        [Info4],
	        [Info5],
	        [Info6],
	        [Info7],
	        [Info8],
	        [Info9],
	        [Tab1],
	        [Tab2],
	        [Tab3],
	        [Tab4],
	        [Tab5],
	        [Tab6],
	        [Tab7],
	        [Tab8],
	        [Tab9],
	        [ItemInfo],
	        [RecCreate],
	        [RecUserID],
	        [RecChange],
	        [RecChangeUserID]
	    )
	VALUES
	    (
	        S.[ItemID],
	        S.[ItemType],
	        S.[ItemIDSede],
	        S.[ItemUse],
	        S.[ItemDsm],
	        S.[ItemDes],
	        S.[Ind],
	        S.[Cap],
	        S.[Loc],
	        S.[Pro],
	        S.[Reg],
	        S.[Naz],
	        S.[Language],
	        S.[www],
	        S.[LstCod],
	        S.[PagCod],
	        S.[Sconti],
	        S.[GrpCod],
	        S.[CatCod],
	        S.[AgeCod],
	        S.[PrvCla],
	        S.[PrvFix],
	        S.[PrvFixOff],
	        S.[ShipCod],
	        S.[VetCod],
	        S.[VetCod2],
	        S.[AerCod],
	        S.[ShipPayCod],
	        S.[TrMezzo],
	        S.[TrPorto],
	        S.[TrImballo],
	        S.[TrFDeposito],
	        S.[TrSendWay],
	        S.[Info1],
	        S.[Info2],
	        S.[Info3],
	        S.[Info4],
	        S.[Info5],
	        S.[Info6],
	        S.[Info7],
	        S.[Info8],
	        S.[Info9],
	        S.[Tab1],
	        S.[Tab2],
	        S.[Tab3],
	        S.[Tab4],
	        S.[Tab5],
	        S.[Tab6],
	        S.[Tab7],
	        S.[Tab8],
	        S.[Tab9],
	        S.[ItemInfo],
	        CAST(GETDATE() AS DATE),
	        '-1',
	        CAST(GETDATE() AS DATE),
	        '-1'
	    )
	OUTPUT
	  $action, 'MixAnaSedi' INTO @tActions;

	IF ISNULL((SELECT TOP 1 1 FROM @tActions),0) = 1
	BEGIN
		INSERT INTO dbo.[ZLogSync_Pers](
			ItemValue
			, ItemDate)
		SELECT 'SINCRONIZZAZIONE // SPIT -> SPIT_GEST // Tabella: ' + L.nome + ' // Azione: ' + L.azione + ' // Righe afflitte: ' + CAST(L.numero as VARCHAR), Cast(GETDATE() As smalldatetime)
		FROM (SELECT MergeAction 'azione', tableName 'nome', COUNT(*) 'numero' FROM @tActions GROUP BY MergeAction, tableName) L;
	END
	ELSE
	BEGIN
		INSERT INTO dbo.[ZLogSync_Pers](
			ItemValue
			, ItemDate)
		VALUES(
			'SINCRONIZZAZIONE // SPIT -> SPIT_GEST // Nessuna azione richiesta'
			, Cast(GETDATE() As smalldatetime));
	END

	IF ISNULL((SELECT TOP 1 [ItemLast] FROM [BpSPIT].[dbo].[NumUniq] WHERE [ItemId] = 'MixAna1'),0) > ISNULL((SELECT TOP 1 [ItemLast] FROM [BpSPITGEST].[dbo].[NumUniq] WHERE [ItemId] = 'MixAna1'),0)
	BEGIN
		IF EXISTS(
			SELECT [ItemID]
			FROM [BpSPITGEST].dbo.[NumUniq]
			WHERE [ItemID] = 'MixAna1'
			)
		BEGIN
			UPDATE [BpSPITGEST].dbo.[NumUniq] SET
				[ItemLast] = ISNULL((SELECT TOP 1 [ItemLast] FROM [BpSPIT].[dbo].[NumUniq] WHERE [ItemId] = 'MixAna1'),0)
			WHERE [ItemID] = 'MixAna1'
		END
		ELSE
		BEGIN
			INSERT [BpSPITGEST].dbo.[NumUniq]([ItemID], [ItemLast])
			SELECT TOP 1 [ItemID], [ItemLast] FROM [BpSPIT].[dbo].[NumUniq] WHERE [ItemId] = 'MixAna1'
		END
	END

COMMIT TRAN

INSERT INTO dbo.[ZLogSync_Pers](
	ItemValue
	, ItemDate)
VALUES(
	'SINCRONIZZAZIONE // SPIT -> SPIT_GEST // Fine sincronizzazione'
	, Cast(GETDATE() As smalldatetime));