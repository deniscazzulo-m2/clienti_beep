BEGIN TRANSACTION;
DECLARE @tActions TABLE (MergeAction VARCHAR(10), tableName VARCHAR(32));

MERGE [BpSTUDIOISOARDI].[dbo].[MixAnaRif] T USING (
    SELECT
        *
    FROM
        [BpSPIT].[dbo].[MixAnaRif]
    WHERE
        [ItemType] = '1'
) S ON T.[ItemID] = S.[ItemID]
AND T.[ItemType] = S.[ItemType]
AND T.[ItemIDSede] = S.[ItemIDSede]
AND T.[ItemIDRif] = S.[ItemIDRif]
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

SELECT MergeAction, tableName, COUNT(*) 
FROM @tActions  
GROUP BY MergeAction, tableName;

ROLLBACK TRANSACTION;