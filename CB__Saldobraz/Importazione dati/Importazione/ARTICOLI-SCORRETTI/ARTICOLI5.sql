CREATE TABLE [tempArticoli2](
	serie nvarchar(512) null,
	articolo nvarchar(512) null,
	descrizione nvarchar(512) null
)

insert [tempArticoli2](serie,articolo,descrizione) Select serie,
case when len(replace(rtrim(articolo),'.',''))<9 then
right('000000000'+replace(rtrim(articolo),'.',''),9)
else replace(rtrim(articolo),'.','') end articolo
,descrizione From [tempArticoli] where serie = '1' and 
case when len(replace(rtrim(articolo),'.',''))<9 then
right('000000000'+replace(rtrim(articolo),'.',''),9)
else replace(rtrim(articolo),'.','') end not in (select prdcod from prdana);

WITH cte AS (
  SELECT articolo, 
     row_number() OVER(PARTITION BY articolo order by articolo) AS [rn]
  FROM [tempArticoli2]
)
delete cte WHERE [rn] > 1

select * from [tempArticoli2]