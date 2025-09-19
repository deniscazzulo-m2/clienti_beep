/*
*
*
*
*/
CREATE VIEW [uvwGriotExportPrd_Pers]
AS
Select Concat(
MLIN.PrdForCod , ';' ,
Replace(IsNull(PRD.PrdDes, ''), ';', ',') , ';' ,
Replace(Cast(IsNull(PRZ.PrdPrz, 0.0) As varchar(32)), '.', ',') , ';' ,
Replace(Cast(IsNull(IVA.ItemValue, 0.0) As varchar(32)), '.', ',') , ';' ,
Replace(IsNull(MLIN.PrdLotto, ''), ';', ',') , ';' ,
Cast(Cast(
    (IsNull(Carichi, 0.0) - IsNull(Scarichi, 0.0)) - IsNull(ZTAB.TotQta, 0.0)
    As decimal(19, 0)) As varchar(32)) , ';' ,
Replace(IsNull(PRD.PrdDes, ''), ';', ',') , ';' ,
Replace(IsNull(PRD.PrdUM, ''), ';', ',')
 ) Riga
From
dbo.[MagMovLin] MLIN
Inner Join dbo.[PrdAna] PRD On MLIN.PrdCod = PRD.PrdCod
Left Join dbo.[PrdPrz] PRZ On PRZ.LstCod = 'BASE' And PRD.PrdCod = PRZ.PrdCod
Left Join dbo.[IvaTab] IVA On PRD.IvaCod = IVA.ItemID
Left Join (Select barcode Barcode, Sum(IsNull(PrdQta, 0.0)) TotQta From dbo.[ImportDDTDett_Pers] ZDETT Inner Join dbo.[ImportDDT_Pers] ZTST On ZDETT.UniqTst = ZTST.UniqRow
Where ZTST.Stato In('E', 'I')
group by barcode) ZTAB On ZTAB.Barcode = MLIN.PrdForCod
Where
Len(PrdForCod) > 0
And (IsNull(Carichi, 0.0) - IsNull(Scarichi, 0.0)) > IsNull(ZTAB.TotQta, 0.0)