CREATE TABLE [tempProdotti]( 
    [id] INT IDENTITY(1,1) 
    , [Cod.] nvarchar(512) NULL
	, [Descrizione] nvarchar(512) NULL
	, [Tipologia] nvarchar(512) NULL
	, [Categoria] nvarchar(512) NULL
	, [Sottocategoria] nvarchar(512) NULL
	, [Cod. Udm] nvarchar(512) NULL
	, [Cod. Iva] nvarchar(512) NULL
	, [Listino 1] nvarchar(512) NULL
	, [Listino 2] nvarchar(512) NULL
	, [Listino 3] nvarchar(512) NULL
	, [Formula listino 1] nvarchar(512) NULL
	, [Formula listino 2] nvarchar(512) NULL
	, [Formula listino 3] nvarchar(512) NULL
	, [Note] nvarchar(512) NULL
	, [Cod. a barre] nvarchar(512) NULL
	, [Classe provvigione] nvarchar(512) NULL
	, [Internet] nvarchar(512) NULL
	, [Produttore] nvarchar(512) NULL
	, [Extra 1] nvarchar(512) NULL
	, [Extra 2] nvarchar(512) NULL
	, [Extra 3] nvarchar(512) NULL
	, [Extra 4] nvarchar(512) NULL
	, [Cod. fornitore] nvarchar(512) NULL
	, [Fornitore] nvarchar(512) NULL
	, [Cod. prod. forn.] nvarchar(512) NULL
	, [Prezzo forn.] nvarchar(512) NULL
	, [Note fornitura] nvarchar(512) NULL
	, [Ord. a multipli di] nvarchar(512) NULL
	, [Gg. ordine] nvarchar(512) NULL
	, [Scorta min.] nvarchar(512) NULL
	, [Ubicazione] nvarchar(512) NULL
	, [Tot. q.ta caricata] nvarchar(512) NULL
	, [Tot. q.ta scaricata] nvarchar(512) NULL
	, [Q.ta giacenza] nvarchar(512) NULL
	, [Q.ta impegnata] nvarchar(512) NULL
	, [Q.ta disponibile] nvarchar(512) NULL
	, [Q.ta in arrivo] nvarchar(512) NULL
	, [Vendita media mensile] nvarchar(512) NULL
	, [Stima data fine magazz.] nvarchar(512) NULL
	, [Stima data prossimo ordine] nvarchar(512) NULL
	, [Data primo carico] nvarchar(512) NULL
	, [Data ultimo carico] nvarchar(512) NULL
	, [Data ultimo scarico] nvarchar(512) NULL
	, [Costo medio dacq.] nvarchar(512) NULL
	, [Ultimo costo dacq.] nvarchar(512) NULL
	, [Prezzo medio vend.] nvarchar(512) NULL
	, [Stato magazzino] nvarchar(512) NULL
	, [Immagine] nvarchar(512) NULL
	)