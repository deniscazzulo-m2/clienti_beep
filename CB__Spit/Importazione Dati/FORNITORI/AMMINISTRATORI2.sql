INSERT INTO [BpSpit].[dbo].[tempAmministratori] 
([Nome],[Contatti],[Studio],[Condomini],[Contratti]) 
SELECT * FROM (VALUES
('AMMINISTRAZIONE BENI IMMOBILI DOTT QUATTROCCHI DIEGO','amministrazionebeniimmobili@gmail.com - amministrazionebeniimmobili@gmail.comTelefono: 3393595299','MONCALIERI (MONCALIERI)P.ZZA VITTORIO EMANUELE II , 2','20 condomini','1 contratto'),
('Giulio Bellone Sviluppatore','bellonegiulio@gmail.com - bellonegiulio@gmail.comTelefono: 3737449581','','1 condomini','Nessun contratto'),
('DE ROSA LAURA','lauraderosa.amministrazioni@gmail.com - lauraderosa.amministrazioni@gmail.comTelefono: 0113143899','TORINOVIA ONORATO VIGLIANI 189','1 condomini','Nessun contratto'),
('INCORVAIA RAG ANTONIO','info@antonioincorvaia.it - info@antonioincorvaia.itTelefono: 0175600031','saluzzo  (saluzzo )via martiri  della liberazione 5','7 condomini','Nessun contratto'),
('STUDIO GAIDO PUSSET GENNERO','geotecnicoamministrazioni@gmail.com - geotecnicoamministrazioni@gmail.comTelefono: 0121514467','VILLARPEROSAVIA NAZIONALE','1 condomini','Nessun contratto'),
('GEOM DAMILANO ALESSIO','alessio_damilano@yahoo.it - alessio_damilano@yahoo.itTelefono: 3392766264','FOSSANO  (FOSSANO )PIAZZA DOMPE'' 1','7 condomini','Nessun contratto'),
('STUDIO PICCONE SAS','studio.piccone@libero.it - studio.piccone@libero.itTelefono: 3395415168','torino via bibiana 34','2 condomini','Nessun contratto'),
('GEOM MAGNANO MARCO','Magnano.geomarco@gmail.com - Magnano.geomarco@gmail.com','CAVOURVIA GIOLITTI 53','2 condomini','Nessun contratto'),
('LORENZO FORZINETTI','lorenzo@forzinetti.it - lorenzo@forzinetti.itTelefono: 3351661809','CERVERE','2 condomini','Nessun contratto'),
('CENTRO SERVIZI DI RIZZO ADRIANO','censervizi@libero.it - censervizi@libero.itTelefono: 3929709934','PINEROLO  (PINEROLO )VIA CARLO ALBERTO 2','29 condomini','1 contratto')
) x([Nome],[Contatti],[Studio],[Condomini],[Contratti])