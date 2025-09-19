INSERT INTO [DATABASE].[dbo].[PrdAna] (
    [PrdCod],--[Cod. a barre]
    [PrdDes],--[Cod.]+[Colore]+[Taglia]
    [PrdDesExt],--[Descrizione]
    [PrdUm],--[Cod. Udm]
    [IvaCod],--[tempProdotti].[Cod. Iva]
    [PrzTabCod],--[Cod.]
    [PrdHide],
    [PrdFabbPlan],
    [PrdUso],
    [RecCreate],
    [RecChange],
    [RecLocked]
    )
SELECT
dbo.[udfPrdCodAccorciato_pers](
CASE 
WHEN ISNULL([Cod. a barre],'') = '' THEN CONCAT(ISNULL(LTRIM(RTRIM([Cod.])),'-'),'/',ISNULL(LTRIM(RTRIM([Taglia])),'-'),'/',ISNULL(LTRIM(RTRIM([Colore])),'-'))
ELSE LTRIM(RTRIM([Cod. a barre])) END
),--[PrdCod]
CONCAT(LTRIM(RTRIM(ISNULL([Cod.],'')))
,' | COLORE: ',LTRIM(RTRIM(ISNULL([Colore],'')))
,' | TAGLIA: ',LTRIM(RTRIM(ISNULL([Taglia],'')))),--[PrdDes]
LTRIM(RTRIM(ISNULL([Descrizione],''))),--[PrdDesExt]
CASE 
    WHEN LTRIM(RTRIM(ISNULL([Udm],''))) IN ('cl') THEN 'CC' 
    WHEN LTRIM(RTRIM(ISNULL([Udm],''))) IN ('l')THEN 'LT' 
    WHEN LTRIM(RTRIM(ISNULL([Udm],''))) IN ('mt') THEN 'MT' 
    WHEN LTRIM(RTRIM(ISNULL([Udm],''))) IN ('rotolo','pz') THEN 'PZ' 
    WHEN LTRIM(RTRIM(ISNULL([Udm],''))) IN ('kg') THEN 'KG' 
    ELSE LTRIM(RTRIM(ISNULL([Udm],''))) END,--[PrdUm]
ISNULL(
    (SELECT TOP 1 [IvaCod] FROM dbo.[PrdAna] WHERE [PrdCod] = dbo.[udfPrdCodAccorciato_pers](LTRIM(RTRIM([Cod.]))))
    ,''),--[IvaCod]
dbo.[udfPrdCodAccorciato_pers](LTRIM(RTRIM([Cod.]))),--[PrzTabCod]
'0',--[PrdHide]
'3',--[PrdFabbPlan]
'10',--[PrdUso]
CAST(GETDATE() as DATE),--[RecCreate]
CAST(GETDATE() as DATE),--[RecChange]
'0'--[RecLocked]
FROM [DATABASE].[dbo].[tempTaglie]
