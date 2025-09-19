INSERT INTO [DATABASE].[dbo].[PrdAna] (
    [PrdCod],--[Cod.]
    [PrdDes],--[Cod.]
    [PrdDesExt],--[Descrizione]
    [GrpCod],--[Tipologia]
    [CatCod],--[Categoria]
    [TreeCod],--[Sottocategoria]
    [PrdUm],--[Cod. Udm]
    [IvaCod],--[Cod. Iva]
    [Info1],--[Listino 1]
    [Info2],--[Listino 2]
    [Info3],--[Listino 3]
    [Info4],--[Formula listino 2]
    [Info5],--[Formula listino 3]
    [PrdInfo],--[Note]
    [Info6],--[Cod. a barre]
    [Info7],--[Produttore]
    [Info8],--[Cod. fornitore]+[Cod. prod. forn.]
    [Info9],--[Prezzo forn.]+[Gg. ordine]
    [QtaMin],--[Scorta min.]
    [PrdHide],
    [PrdFabbPlan],
    [PrdUso],
    [RecCreate],
    [RecChange],
    [RecLocked]
    )
SELECT
dbo.[udfPrdCodAccorciato_pers](LTRIM(RTRIM([Cod.]))),
LTRIM(RTRIM(ISNULL([Cod.],''))),
LTRIM(RTRIM(ISNULL([Descrizione],''))),
CASE 
    WHEN LTRIM(RTRIM(ISNULL([Tipologia],''))) = 'Art. con magazzino' THEN 'ARTICOLI' 
    WHEN LTRIM(RTRIM(ISNULL([Tipologia],''))) = 'Art. con magazzino (taglie/colori)' THEN 'ARTICOLI_TC' 
    WHEN LTRIM(RTRIM(ISNULL([Tipologia],''))) = 'Servizio' THEN 'SERVIZI' 
    ELSE LTRIM(RTRIM(ISNULL([Tipologia],''))) END,
LTRIM(RTRIM(ISNULL([Categoria],''))),
LTRIM(RTRIM(ISNULL([Sottocategoria],''))),
CASE 
    WHEN LTRIM(RTRIM(ISNULL([Cod. Udm],''))) IN ('cl') THEN 'CC' 
    WHEN LTRIM(RTRIM(ISNULL([Cod. Udm],''))) IN ('l')THEN 'LT' 
    WHEN LTRIM(RTRIM(ISNULL([Cod. Udm],''))) IN ('mt') THEN 'MT' 
    WHEN LTRIM(RTRIM(ISNULL([Cod. Udm],''))) IN ('rotolo','pz') THEN 'PZ' 
    WHEN LTRIM(RTRIM(ISNULL([Cod. Udm],''))) IN ('kg') THEN 'KG' 
    ELSE LTRIM(RTRIM(ISNULL([Cod. Udm],''))) END,
CASE WHEN LTRIM(RTRIM(ISNULL([Cod. Iva],''))) = '22' THEN '01'
    ELSE LTRIM(RTRIM(ISNULL([Cod. Iva],''))) END,
LTRIM(RTRIM(ISNULL([Listino 1],''))),
LTRIM(RTRIM(ISNULL([Listino 2],''))),
LTRIM(RTRIM(ISNULL([Listino 3],''))),
LTRIM(RTRIM(ISNULL([Formula listino 2],''))),
LTRIM(RTRIM(ISNULL([Formula listino 3],''))),
LTRIM(RTRIM(ISNULL([Note],''))),
LTRIM(RTRIM(ISNULL([Cod. a barre],''))),
LTRIM(RTRIM(ISNULL([Produttore],''))),
CONCAT(
    LTRIM(RTRIM(ISNULL([Cod. fornitore],''))),';',
    LTRIM(RTRIM(ISNULL([Cod. prod. forn.],'')))),
CONCAT(
    LTRIM(RTRIM(ISNULL([Prezzo forn.],''))),';',
    LTRIM(RTRIM(ISNULL([Gg. ordine],'')))),
LTRIM(RTRIM(ISNULL([Scorta min.],''))),
'0',
'3',
'10',
CAST(GETDATE() as DATE),
CAST(GETDATE() as DATE),
'0'
FROM [DATABASE].[dbo].[tempProdotti]
