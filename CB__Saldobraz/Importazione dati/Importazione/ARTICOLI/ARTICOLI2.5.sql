update [BpSaldobraz].[dbo].[tempArticoli] 
set peso = case 
	when umpeso = 'KG' then cast(replace(replace(peso,'.',''),',','.') as decimal(9,3)) 
	when umpeso = 'G' then cast(replace(replace(peso,'.',''),',','.') as decimal(9,3))/1000 
	else null end
