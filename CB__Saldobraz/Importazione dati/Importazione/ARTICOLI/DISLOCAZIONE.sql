insert into [BpSaldobraz].[dbo].[prdmag](prdcod,magcod,posmag)
Select prdcod,'LOCALE',dislocazione From [BpSaldobraz].[dbo].[prdana] a join [Saldobraz].[dbo].[ARTH0000] b 
on a.prdcod = b.articolo and right(concat('0',a.catcod),2) = right(concat('0',rtrim(ltrim(b.serie))),2)
where serie in ('1','01','29') and len(dislocazione)=3 
and (rtrim(ltrim(articolo))<>'850010200' or dislocazione<>'30F')