BEGIN TRANSACTION;
DECLARE @tActions TABLE (MergeAction VARCHAR(10), tableName VARCHAR(32));

MERGE [BpSPIT].[dbo].[MixAnaAlias] T USING (
    SELECT
        *
    FROM
        [BpSTUDIOISOARDI].[dbo].[MixAnaAlias]
    WHERE
        [ItemType] = '1'
) S ON T.[ItemID] = S.[ItemID]
AND T.[ItemType] = S.[ItemType]
AND T.[AliasID] = S.[AliasID]
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

SELECT MergeAction, tableName, COUNT(*) 
FROM @tActions  
GROUP BY MergeAction, tableName;

ROLLBACK TRANSACTION;