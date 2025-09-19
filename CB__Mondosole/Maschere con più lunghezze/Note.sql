/*-- ---------------------------------------------
-- DbReadStringDictionary
dbo.[uspPrdFormTabLin_find] 1910,N'ZLD.I',4,N'Rete-Zanz-N-Alt',N'GRIGIA'
-- ---------------------------------------------
-- DbReadStringDictionary
dbo.[uspPrdFormTabLin_find] 1910,N'ZLD.I',5,N'Accessori-Zanz',N'Bianco'
-- ---------------------------------------------
-- DbReadStringDictionary
dbo.[uspPrdFormTabLin_find] 1910,N'ZLD.I',6,N'SI-NO',N'0'
-- ---------------------------------------------
-- DbReadStringDictionary
dbo.[uspPrdFormTabLin_find] 1910,N'ZLD.I',7,N'SI-NO',N'0'
-- ---------------------------------------------
-- DbReaderOpen
dbo.[uspVE_row_price] 1,11,41926,159907,N'22/01/2025',N'1499',N'',N'',N'BASE',N'ZLD.I',N'Z',1.00,N'',N'22',22.00,N'',100,2,0,0,100.00,0,0,0
-- ---------------------------------------------
-- DbReaderOpen
dbo.[uspVE_row_TM] N'ZLD.I',100,2,100.00,0,0,0,N'Bianco',N'0',N'0',0,0.000000,0.000000,0.000000
-- ---------------------------------------------
-- DbReadStringDictionary
dbo.[uspPrdFormTabLin_find] 1910,N'ZLD.I',4,N'Rete-Zanz-N-Alt',N'GRIGIA'
-- ---------------------------------------------
-- DbReadStringDictionary
dbo.[uspPrdFormTabLin_find] 1910,N'ZLD.I',5,N'Accessori-Zanz',N'Bianco'
-- ---------------------------------------------
-- DbReadStringDictionary
dbo.[uspPrdFormTabLin_find] 1910,N'ZLD.I',6,N'SI-NO',N'0'
-- ---------------------------------------------
-- DbReadStringDictionary
dbo.[uspPrdFormTabLin_find] 1910,N'ZLD.I',7,N'SI-NO',N'0'
-- ---------------------------------------------
-- DbReaderOpen
dbo.[uspVE_row_price] 1,11,41926,159907,N'22/01/2025',N'1499',N'',N'',N'BASE',N'ZLD.I',N'Z',1.00,N'',N'22',22.00,N'',100,2,0,0,100.00,120.00,0,0
-- ---------------------------------------------
-- DbReaderOpen
dbo.[uspVE_row_TM] N'ZLD.I',100,2,100.00,120.00,0,0,N'Bianco',N'0',N'0',0,0.000000,0.000000,0.000000


dbo.[uspVE_row_price](1,11,41926,159907,'22/01/2025','1499','','','BASE','ZLD.I','Z',1.00,'','22',22.00,'',100,2,0,0,100.00,100.00,0,0)
*/

/*
@bPromoCheck bit,           1
@iDocTip tinyint,           DocInfoGet("formdoctip")
@iUniqDoc int,              DocInfoGet("formdocuniq")
@iUniqLin int,              ValueGet("uniq", 0)
@sDocDta varchar(10),       DocInfoGet("formdocdta")
@sCliCod varchar(16),       AnaCod$
@sCliCat varchar(16),       ? CatCod da Mixana
@sAgeCod varchar(16),       AgeCod$
@sLstCod varchar(32),       LstCod$
@sPrdCod varchar(32),       PrdCod$
@sGrpCod varchar(32),       GrpCod$
@dPrdQta decimal(19, 6),    PrdQta
@sPrdSc varchar(16),        PrdSc$
@sIvaCod varchar(8),        IvaCod$
@dIvaAlq decimal(19, 2),    IvaAlq
@sPrzTabCod varchar(32),    PrzTabCod$
@iPrdUso smallint,          PrdUso
@iPrzTab smallint,          PrzTab
@iPrzTabRic smallint,       PrzTabRic
@bUseIvato bit,             0
@dMis1 decimal(19, 6),      A
@dMis2 decimal(19, 6),      C
@dMis3 decimal(19, 6),      0
@dMis4 decimal(19, 6),      0
*/

--#
If A > 0 Then
	Dim sSql$ = "dbo.[uspVE_row_price] 1," & Str(@46) & _
		"," & Str(@47) & "," & Str(@48) & _
		",'" & @49$ & "','" & AnaCod$ & "','','" & AgeCod$ & _
		"','" & LstCod$ & "','" & PrdCod$ & "','" & GrpCod$ & "'," & Str(PrdQta) & _
		",'" & PrdSc$ & "','" & IvaCod$ & "'," & Str(IvaAlq) & ",'" & PrzTabCod$ & _
		"'," & Str(PrdUso) & "," & Str(PrzTab) & "," & Str(PrzTabRic) & _
		",0," & Str(A) & "," & Str(C) & ",0,0"
	Dim prz2$ = DbRead(sSql$,"PrdPrz")
	If Val(prz2$)>0 Then
		PrzLst = PrzLst + Val(prz2$)
		PrdPrz = PrdPrz + Val(prz2$)
	EndIf
EndIf




MsgOk "0"
MsgOk @0
MsgOk @0$
MsgOk "1"
MsgOk @1
MsgOk @1$
MsgOk "2"
MsgOk @2
MsgOk @2$
MsgOk "3"
MsgOk @3
MsgOk @3$
MsgOk "4"
MsgOk @4
MsgOk @4$
MsgOk "5"
MsgOk @5
MsgOk @5$
MsgOk "6"
MsgOk @6
MsgOk @6$
MsgOk "7"
MsgOk @7
MsgOk @7$
MsgOk "8"
MsgOk @8
MsgOk @8$
MsgOk "9"
MsgOk @9
MsgOk @9$
MsgOk "10"
MsgOk @10
MsgOk @10$
MsgOk "11"
MsgOk @11
MsgOk @11$
MsgOk "12"
MsgOk @12
MsgOk @12$
MsgOk "13"
MsgOk @13
MsgOk @13$
MsgOk "14"
MsgOk @14
MsgOk @14$
MsgOk "15"
MsgOk @15
MsgOk @15$
MsgOk "16"
MsgOk @16
MsgOk @16$
MsgOk "17"
MsgOk @17
MsgOk @17$
MsgOk "18"
MsgOk @18
MsgOk @18$
MsgOk "19"
MsgOk @19
MsgOk @19$
MsgOk "20"
MsgOk @20
MsgOk @20$
MsgOk "21"
MsgOk @21
MsgOk @21$
MsgOk "22"
MsgOk @22
MsgOk @22$
MsgOk "23"
MsgOk @23
MsgOk @23$
MsgOk "24"
MsgOk @24
MsgOk @24$
MsgOk "25"
MsgOk @25
MsgOk @25$
MsgOk "26"
MsgOk @26
MsgOk @26$
MsgOk "27"
MsgOk @27
MsgOk @27$
MsgOk "28"
MsgOk @28
MsgOk @28$
MsgOk "29"
MsgOk @29
MsgOk @29$
MsgOk "30"
MsgOk @30
MsgOk @30$
MsgOk "31"
MsgOk @31
MsgOk @31$
MsgOk "32"
MsgOk @32
MsgOk @32$
MsgOk "33"
MsgOk @33
MsgOk @33$
MsgOk "34"
MsgOk @34
MsgOk @34$
MsgOk "35"
MsgOk @35
MsgOk @35$
MsgOk "36"
MsgOk @36
MsgOk @36$
MsgOk "37"
MsgOk @37
MsgOk @37$
MsgOk "38"
MsgOk @38
MsgOk @38$
MsgOk "39"
MsgOk @39
MsgOk @39$
MsgOk "40"
MsgOk @40
MsgOk @40$
MsgOk "41"
MsgOk @41
MsgOk @41$
MsgOk "42"
MsgOk @42
MsgOk @42$
MsgOk "43"
MsgOk @43
MsgOk @43$
MsgOk "44"
MsgOk @44
MsgOk @44$
MsgOk "45"
MsgOk @45
MsgOk @45$
MsgOk "46"
MsgOk @46
MsgOk @46$
MsgOk "47"
MsgOk @47
MsgOk @47$
MsgOk "48"
MsgOk @48
MsgOk @48$
MsgOk "49"
MsgOk @49
MsgOk @49$