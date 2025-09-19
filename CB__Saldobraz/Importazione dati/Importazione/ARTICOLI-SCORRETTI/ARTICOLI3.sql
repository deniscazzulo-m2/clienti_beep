INSERT INTO [BpSaldobraz].[dbo].[PrdAna] (
    [PrdCod],
    [PrdDes],
    [PrdUm],
    [Info1],
    [IvaCod],
    [PrdHide],
    [PrdFabbPlan],
    [PrdUso],
    [RecCreate],
    [RecChange],
    [RecLocked]
    )
SELECT
CASE 
    WHEN LEN(RTRIM(LTRIM(ISNULL([Serie],'')))) > 0 AND LEN(RTRIM(LTRIM(ISNULL([Articolo],'')))) > 0 THEN CONCAT(RTRIM(LTRIM([Serie])),'_',RTRIM(LTRIM([Articolo]))) 
    ELSE CONCAT(RTRIM(LTRIM(ISNULL([Serie],''))),RTRIM(LTRIM(ISNULL([Articolo],'')))) END,
RTRIM(LTRIM(ISNULL([Descrizione],''))),
CASE 
    WHEN UPPER(LTRIM(RTRIM(ISNULL([UMMagazzino],'')))) IN ('H') THEN 'HH' 
    WHEN UPPER(LTRIM(RTRIM(ISNULL([UMMagazzino],'')))) IN ('KG','KG,','LG')THEN 'KG' 
    WHEN UPPER(LTRIM(RTRIM(ISNULL([UMMagazzino],'')))) IN ('KM') THEN 'KM' 
    WHEN UPPER(LTRIM(RTRIM(ISNULL([UMMagazzino],'')))) IN ('L','LT') THEN 'LT' 
    WHEN UPPER(LTRIM(RTRIM(ISNULL([UMMagazzino],'')))) IN ('M','MR','MT') THEN 'MT' 
    WHEN UPPER(LTRIM(RTRIM(ISNULL([UMMagazzino],'')))) IN ('N','NR','NR,') THEN 'NR' 
    WHEN UPPER(LTRIM(RTRIM(ISNULL([UMMagazzino],'')))) IN ('PZ') THEN 'PZ' 
    WHEN UPPER(LTRIM(RTRIM(ISNULL([UMMagazzino],'')))) IN ('SC') THEN 'SC' 
    
    WHEN UPPER(LTRIM(RTRIM(ISNULL([UMAcquisti],'')))) IN ('H') THEN 'HH' 
    WHEN UPPER(LTRIM(RTRIM(ISNULL([UMAcquisti],'')))) IN ('KG','KG,','LG')THEN 'KG' 
    WHEN UPPER(LTRIM(RTRIM(ISNULL([UMAcquisti],'')))) IN ('KM') THEN 'KM' 
    WHEN UPPER(LTRIM(RTRIM(ISNULL([UMAcquisti],'')))) IN ('L','LT') THEN 'LT' 
    WHEN UPPER(LTRIM(RTRIM(ISNULL([UMAcquisti],'')))) IN ('M','MR','MT') THEN 'MT' 
    WHEN UPPER(LTRIM(RTRIM(ISNULL([UMAcquisti],'')))) IN ('N','NNR','NR','NR,') THEN 'NR' 
    
    WHEN UPPER(LTRIM(RTRIM(ISNULL([UMVendite],'')))) IN ('H') THEN 'HH' 
    WHEN UPPER(LTRIM(RTRIM(ISNULL([UMVendite],'')))) IN ('KG','KG,')THEN 'KG' 
    WHEN UPPER(LTRIM(RTRIM(ISNULL([UMVendite],'')))) IN ('KM') THEN 'KM' 
    WHEN UPPER(LTRIM(RTRIM(ISNULL([UMVendite],'')))) IN ('LT') THEN 'LT' 
    WHEN UPPER(LTRIM(RTRIM(ISNULL([UMVendite],'')))) IN ('M','MT') THEN 'MT' 
    WHEN UPPER(LTRIM(RTRIM(ISNULL([UMVendite],'')))) IN ('N','NNR','NR','NR,') THEN 'NR' 

    ELSE 'NR' END,
RTRIM(LTRIM(ISNULL([QtaContabile],''))),
'01',
'0',
'3',
'10',
CAST(GETDATE() AS date),
CAST(GETDATE() AS date),
'0'
FROM [BpSaldobraz].[dbo].[tempArticoli] 