BEGIN TRANSACTION;
DECLARE @tActions TABLE (MergeAction VARCHAR(10), tableName VARCHAR(32));

MERGE [BpSPIT].[dbo].[MixAnaSedi] T USING (
    SELECT
        *
    FROM
        [BpSTUDIOISOARDI].[dbo].[MixAnaSedi]
    WHERE
        [ItemType] = '1'
) S ON T.[ItemID] = S.[ItemID]
AND T.[ItemType] = S.[ItemType]
AND T.[ItemIDSede] = S.[ItemIDSede]
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

SELECT MergeAction, tableName, COUNT(*) 
FROM @tActions  
GROUP BY MergeAction, tableName;

ROLLBACK TRANSACTION;