declare @tab table (
	prdcod varchar(32),
	prdinfo varchar(MAX)
)
Declare @sCrLf char(2) = Char(13) + Char(10)

insert @tab(prdcod,prdinfo)
Select A.prdcod, concat(B.prddes,@sCrLf,A.prddes) 
From [PrdAna] A left join [PrdAna] B on
A.prdcod like concat(B.prdcod,'.%')-- And A.prdcod not like concat(B.prdcod,'.%.%')
where a.prdcod like '%.%' and a.prdcod not like '%.%.%'

update a 
set a.prdinfo=b.prdinfo
from [prdana] a inner join @tab b on b.prdcod=a.prdcod

delete from @tab

insert @tab(prdcod,prdinfo)
Select A.prdcod, concat(B.prdinfo,@sCrLf,A.prddes) 
From [PrdAna] A left join [PrdAna] B on
A.prdcod like concat(B.prdcod,'.%') And A.prdcod not like concat(B.prdcod,'.%.%')
where a.prdcod like '%.%.%'

update a 
set a.prdinfo=b.prdinfo
from [prdana] a inner join @tab b on b.prdcod=a.prdcod