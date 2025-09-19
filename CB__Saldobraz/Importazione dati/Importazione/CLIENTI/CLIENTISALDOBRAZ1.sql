CREATE TABLE [tempClienti]( 
    [id] INT IDENTITY(1,1) 
	,[RagioneSociale] nvarchar(512) NULL
	,[PartitaIva] nvarchar(512) NULL
	,[CodiceFiscale] nvarchar(512) NULL
	,[Indirizzo completo] nvarchar(512) NULL
	,[Citta] nvarchar(512) NULL
	,[CAP] nvarchar(512) NULL
	,[Provincia] nvarchar(512) NULL
	,[Nazione] nvarchar(512) NULL
	,[Telefono] nvarchar(512) NULL
	,[Cellulare] nvarchar(512) NULL
	,[Email] nvarchar(512) NULL
	,[Email PEC] nvarchar(512) NULL
	,[CodiceDestinatario] nvarchar(512) NULL
	)