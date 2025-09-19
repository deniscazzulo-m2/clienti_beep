/* 
*
*
*
*/
CREATE VIEW [uvwGriotExportPrdCheck_Pers]
AS
Select
MLIN.PrdForCod PrdForCod,
Cast(Cast(
    (IsNull(Carichi, 0.0) - IsNull(Scarichi, 0.0)) - IsNull(ZTAB.TotQta, 0.0)
     As decimal(19, 0)) As varchar(32)) Qta,
MLIN.PrdForCod BarCode,
MLIN.PrdCod PrdCod,
MLIN.PrdLotto PrdLotto
From
dbo.[MagMovLin] MLIN
Left Join (Select barcode Barcode, Sum(IsNull(PrdQta, 0.0)) TotQta From dbo.[ImportDDTDett_Pers] ZDETT Inner Join dbo.[ImportDDT_Pers] ZTST On ZDETT.UniqTst = ZTST.UniqRow
Where ZTST.Stato In('E', 'I')
group by barcode) ZTAB On ZTAB.barcode = MLIN.PrdForCod
Where
Len(PrdForCod) > 0
And (IsNull(Carichi, 0.0) - IsNull(Scarichi, 0.0)) > IsNull(ZTAB.TotQta, 0.0)
And (IsNull(Carichi, 0.0) - IsNull(Scarichi, 0.0) - IsNull(ZTAB.TotQta, 0.0)) > 999999