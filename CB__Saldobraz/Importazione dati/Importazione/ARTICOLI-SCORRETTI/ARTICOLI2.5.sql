CREATE TABLE [#tmpMin](
    [id] INT
	,[Serie] nvarchar(512) NULL
	,[Articolo] nvarchar(512) NULL
	)
CREATE TABLE [#tmpMax](
    [id] INT
	,[Serie] nvarchar(512) NULL
	,[Articolo] nvarchar(512) NULL
	)

INSERT [#tmpMin](
	  id
	, Serie
	, Articolo
	)
SELECT MIN(id) id, t.serie, t.articolo 
          FROM tempArticoli t
      GROUP BY t.articolo, t.serie
        HAVING COUNT(*) > 1

INSERT [#tmpMax](
	  id
	, Serie
	, Articolo
	)
SELECT MAX(id) id, t.serie, t.articolo 
          FROM tempArticoli t
      GROUP BY t.articolo, t.serie
        HAVING COUNT(*) > 1
		
UPDATE t1  SET 
Articolo = CONCAT(t1.Articolo,'_A')
FROM [tempArticoli] t1 JOIN [#tmpMin] t2 ON t1.id = t2.id
		
UPDATE t1 SET 
Articolo = CONCAT(t1.Articolo,'_B')
FROM [tempArticoli] t1 JOIN [#tmpMax] t2 ON t1.id = t2.id
		