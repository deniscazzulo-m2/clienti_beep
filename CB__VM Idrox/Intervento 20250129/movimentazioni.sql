insert magmovlin(UniqMov,LinNum,MagCod,PrdCod,PrdDes,PrdForCod,MovCau,MovUm,Scarichi,RowCreate,RowChange,RowLocked,RowPrinted)
select 1484,--UniqMov
ROW_NUMBER() OVER (ORDER BY PrdCod),--LinNum
'LOCALE',--MagCod
PrdCod,--PrdCod
PrdDes,--PrdDes
dbo.[udfPrdCod_ForCod_COD](PrdCod,dbo.[udfPrdCod_ForCod](PrdCod)),--PrdForCod
'999',--MovCau
PrdUm,--MovUm
dbo.[udfMM_esistenza](PrdCod,'LOCALE'),--Scarichi
CAST(GETDATE() AS date),--RowCreate
CAST(GETDATE() AS date),--RowChange
0,--RowLocked
0--RowPrinted
From prdAna where isnull(catcod,'')='CEMBRE' and isnull(treecod,'') not in 
('MORSETTI','FERRAMENTA','IDRAULICA','TUBI/GUAINE','CANALINE','CAVI','CORDINA','CORDINA AWG')