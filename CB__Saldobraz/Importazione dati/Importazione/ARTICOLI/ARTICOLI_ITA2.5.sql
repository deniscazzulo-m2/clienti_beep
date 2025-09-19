update [BpSaldobraz].[dbo].[tempArticoliIta] 
set categoria = SUBSTRING(categoria, PATINDEX('%[^0]%', categoria+'.'), LEN(categoria))