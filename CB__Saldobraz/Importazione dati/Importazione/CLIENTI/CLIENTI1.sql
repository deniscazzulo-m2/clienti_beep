CREATE TABLE [tempClienti2]( 
    [id] nvarchar(512) NULL-- Vecchio codice di Dylog del cliente come per fornitori
	,[RagioneSociale] nvarchar(512) NULL
	,[RagioneSocialeBr] nvarchar(512) NULL-- Descrizione breve
	,[PartitaIva] nvarchar(512) NULL
	,[CodiceFiscale] nvarchar(512) NULL
	,[Indirizzo completo] nvarchar(512) NULL
	,[Citta] nvarchar(512) NULL
	,[CAP] nvarchar(512) NULL
	,[Provincia] nvarchar(512) NULL
	,[Nazione] nvarchar(512) NULL
	,[Telefono] nvarchar(512) NULL
	,[Email] nvarchar(512) NULL
	,[Email PEC] nvarchar(512) NULL
	,[sdi] nvarchar(512) NULL
	,[abi] nvarchar(512) NULL-- Banca (Nome banca, Iban, abi e Cab)
	,[cab] nvarchar(512) NULL-- Banca (Nome banca, Iban, abi e Cab)
	,[codpag] nvarchar(512) NULL-- Metodo di pagamento
	,[key] nvarchar(512) NULL
    ,[IBAN] nvarchar(512) NULL-- Banca (Nome banca, Iban, abi e Cab)
    ,[Banca] nvarchar(512) NULL-- Banca (Nome banca, Iban, abi e Cab)
    ,[BancaNs] nvarchar(512) NULL-- Banca di Saldobraz su cui appoggiano il pagamenti se indicata
	)
	










