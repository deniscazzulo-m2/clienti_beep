INSERT INTO [BpSALDOBRAZ].[dbo].[PrdPrz] (
    [PrdCod],
    [LstCod],
    [PrdPrz],
    [RecCreate],
    [RecChange],
    [RecLocked]
    )
SELECT
case when LTRIM(RTRIM([codice])) like '0%' then RIGHT(LTRIM(RTRIM([codice])),9) else LTRIM(RTRIM([codice])) end,--[PrdCod]
'BASE',--[LstCod]
REPLACE(REPLACE(LTRIM(RTRIM([prezzo])),'.',''),',','.'),--[PrdPrz]
CAST(GETDATE() AS date),--[RecCreate]
CAST(GETDATE() AS date),--[RecChange]
'0'--[RecLocked]
FROM [BpSALDOBRAZ].[dbo].[tempListinoBase]