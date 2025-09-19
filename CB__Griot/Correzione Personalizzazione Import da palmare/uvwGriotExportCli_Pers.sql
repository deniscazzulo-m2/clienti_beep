/*
*
*
*
*/
CREATE VIEW [uvwGriotExportCli_Pers]
AS
Select Concat(
Case When Len(RTrim(LTrim(IsNull(B.ItemIDSede, '')))) = 0 Then A.ItemID Else A.ItemID + '-' + RTrim(LTrim(IsNull(B.ItemIDSede, ''))) End , ';' ,
RTrim(Left(Replace(RTrim(LTrim(IsNull(A.ItemDes, ''))), ';', ','), 50)) , ';' ,
RTrim(LTrim(IsNull(A.PIva, ''))) , ';' ,
RTrim(LTrim(IsNull(A.CFis, ''))) , ';' ,
Replace(RTrim(LTrim(IsNull(Case When Len(RTrim(LTrim(IsNull(B.ItemIDSede, '')))) = 0 Then A.Ind Else B.Ind End, ''))), ';', ',') , ';' ,
Replace(RTrim(LTrim(IsNull(Case When Len(RTrim(LTrim(IsNull(B.ItemIDSede, '')))) = 0 Then A.CAP Else B.CAP End, ''))), ';', ',') , ';' ,
Replace(RTrim(LTrim(IsNull(Case When Len(RTrim(LTrim(IsNull(B.ItemIDSede, '')))) = 0 Then A.Loc Else B.Loc End, ''))), ';', ',') , ';' ,
Case When RTrim(LTrim(IsNull(A.LstCod, ''))) In ('','BASE') Then '00' Else RTrim(LTrim(IsNull(A.LstCod, ''))) End , ';' ,
Replace(IsNull(Z.Tel1, ''), ';', ',') , ';' ,
IsNull(PagCod, '') , ';' ,
RTrim(LTrim(IsNull(Case When Len(RTrim(LTrim(IsNull(B.AgeCod, '')))) = 0 Then A.AgeCod Else B.AgeCod End, '')))
) Riga
From
dbo.[MixAna] A Inner Join dbo.[uvwGRIOTDoubleCliDsm_Pers] B On A.ItemID = B.ItemID
Left Join (
    Select ItemType, ItemID, Tel1, 
    row_number() over (partition by lower(ItemID) order by ItemDefault DESC) rn
    From dbo.[MixAnaRif] Where Len(RTrim(LTrim(IsNull(Tel1, '')))) > 0) Z 
    On Z.ItemType = A.ItemType And Z.ItemID = A.ItemID And Z.rn = 1
Where A.ItemType = 1 And A.Tab1 = 'SI' And IsNull(A.ItemHide, 0) = 0