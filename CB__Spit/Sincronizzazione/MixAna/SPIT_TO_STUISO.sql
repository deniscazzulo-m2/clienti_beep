BEGIN TRANSACTION;
DECLARE @tActions TABLE (MergeAction VARCHAR(10), tableName VARCHAR(32));

MERGE [BpSTUDIOISOARDI].[dbo].[MixAna] T USING (
    SELECT
        *
    FROM
        [BpSPIT].[dbo].[MixAna]
    WHERE
        [ItemType] = '1'
) S ON T.[ItemID] = S.[ItemID]
AND T.[ItemType] = S.[ItemType]
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

SELECT MergeAction, tableName, COUNT(*) 
FROM @tActions  
GROUP BY MergeAction, tableName;

ROLLBACK TRANSACTION;