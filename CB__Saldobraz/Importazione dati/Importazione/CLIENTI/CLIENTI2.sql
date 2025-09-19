INSERT INTO [BpSaldobraz].[dbo].[tempClienti2] (
    [id]
	,[RagioneSociale]
	,[RagioneSocialeBr]
	,[PartitaIva]
	,[CodiceFiscale]
    ,[Indirizzo completo]
	,[Citta]
	,[CAP]
	,[Provincia]
	,[Nazione]
	,[Telefono]
	,[Email]
    ,[Email PEC]
	,[sdi]
	,[abi]
	,[cab]
	,[codpag]
	,[key]
    ,[IBAN]
    ,[Banca]
    ,[BancaNs]
    )

SELECT
concat(rtrim(ltrim(b.mastro)),'.',right('00000'+rtrim(ltrim(b.sottoc)),5)) 'id'--[id]
,rtrim(concat(rtrim(ltrim(a.ragsoccognome)),' ',rtrim(ltrim(a.ragsocnome)))) ragionesociale--[RagioneSociale]
,rtrim(ltrim(a.ricercabreve)) ricercabreve--[RagioneSocialeBr]
,case 
    when rtrim(ltrim(isnull([partitaiva],''))) not in ('00000000000','0','') then
        case
            when try_convert(decimal, rtrim(ltrim(a.partitaiva))) is not null then
                right(concat('00000000000',rtrim(ltrim(a.partitaiva))),11)
            else rtrim(ltrim(a.partitaiva)) end
    else 'N.A.' end piva--[PartitaIva]
,case 
    when rtrim(ltrim(isnull(a.codicefiscale,''))) not in ('0','') then
        case
            when try_convert(decimal, rtrim(ltrim(a.codicefiscale))) is not null 
            and rtrim(ltrim(a.codicefiscale)) = rtrim(ltrim(isnull([partitaiva],''))) then
                right(concat('00000000000',rtrim(ltrim(a.codicefiscale))),11)
            else rtrim(ltrim(a.codicefiscale)) end
    else null end cfis--[CodiceFiscale]
,rtrim(concat(rtrim(ltrim(a.indirizzofiscale)),' ',rtrim(ltrim(a.numcivicofiscale)))) indirizzo--[Indirizzo completo]
,rtrim(ltrim(a.comunefiscale)) citta--[Citta]
,case
    when rtrim(ltrim(isnull(a.capfiscale,''))) not in ('00000','0','') then
        rtrim(ltrim(a.capfiscale))
    else null end cap--[CAP]
,rtrim(ltrim(a.provinciafiscale)) provincia--[Provincia]
,CASE
    WHEN RTRIM(LTRIM(ISNULL([NazioneFiscale],''))) IN ('IT','I','ITA','ITAL') THEN 'ITALIA'
    WHEN RTRIM(LTRIM(ISNULL([NazioneFiscale],''))) IN ('A','AT','AUST') THEN 'AUSTRIA'
    WHEN RTRIM(LTRIM(ISNULL([NazioneFiscale],''))) IN ('BE') THEN 'BELGIO'
    WHEN RTRIM(LTRIM(ISNULL([NazioneFiscale],''))) IN ('BR') THEN 'BRASILE'
    WHEN RTRIM(LTRIM(ISNULL([NazioneFiscale],''))) IN ('BY') THEN 'BIELORUSSIA'
    WHEN RTRIM(LTRIM(ISNULL([NazioneFiscale],''))) IN ('CH','CHF','SW') THEN 'SVIZZERA'
    WHEN RTRIM(LTRIM(ISNULL([NazioneFiscale],''))) IN ('D','DE') THEN 'GERMANIA'
    WHEN RTRIM(LTRIM(ISNULL([NazioneFiscale],''))) IN ('EGIT') THEN 'EGITTO'
    WHEN RTRIM(LTRIM(ISNULL([NazioneFiscale],''))) IN ('ES','ESPA') THEN 'SPAGNA'
    WHEN RTRIM(LTRIM(ISNULL([NazioneFiscale],''))) IN ('ETHI') THEN 'ETIOPIA'
    WHEN RTRIM(LTRIM(ISNULL([NazioneFiscale],''))) IN ('FIN') THEN 'FINLANDIA'
    WHEN RTRIM(LTRIM(ISNULL([NazioneFiscale],''))) IN ('FR') THEN 'FRANCIA'
    WHEN RTRIM(LTRIM(ISNULL([NazioneFiscale],''))) IN ('IE') THEN 'IRLANDA'
    WHEN RTRIM(LTRIM(ISNULL([NazioneFiscale],''))) IN ('IN') THEN 'INDIA'
    WHEN RTRIM(LTRIM(ISNULL([NazioneFiscale],''))) IN ('MX') THEN 'MESSICO'
    WHEN RTRIM(LTRIM(ISNULL([NazioneFiscale],''))) IN ('NL') THEN 'OLANDA'
    WHEN RTRIM(LTRIM(ISNULL([NazioneFiscale],''))) IN ('PL','POL') THEN 'POLONIA'
    WHEN RTRIM(LTRIM(ISNULL([NazioneFiscale],''))) IN ('RO') THEN 'ROMANIA'
    WHEN RTRIM(LTRIM(ISNULL([NazioneFiscale],''))) IN ('RUSS','URSS') THEN 'RUSSIA'
    WHEN RTRIM(LTRIM(ISNULL([NazioneFiscale],''))) IN ('SA') THEN 'ARABIA SAUDITA'
    WHEN RTRIM(LTRIM(ISNULL([NazioneFiscale],''))) IN ('SI','SL') THEN 'SLOVENIA'
    WHEN RTRIM(LTRIM(ISNULL([NazioneFiscale],''))) IN ('SK','SLOV') THEN 'REP.SLOVACCA'
    WHEN RTRIM(LTRIM(ISNULL([NazioneFiscale],''))) IN ('US','USA') THEN 'STATI UNITI'
    ELSE NULL END nazione--[Nazione]
,concat(rtrim(ltrim(a.prefisso)),rtrim(ltrim(a.telefono))) 'telefono'--[Telefono]
,rtrim(ltrim(a.email)) email--[Email]
,rtrim(ltrim(a.emailpec)) emailpec--[Email PEC]
,rtrim(ltrim(ufficioipa)) sdi--[sdi]
,case
    when rtrim(ltrim(isnull([codabi1],''))) not in ('0','') then
        rtrim(ltrim([codabi1]))
    else null end abi--[abi]
,case
    when rtrim(ltrim(isnull([codcab1],''))) not in ('0','') then
        rtrim(ltrim([codcab1]))
    else null end cab
,case
    when rtrim(ltrim(isnull([codpag],''))) in ('001') then 'RB02'
    when rtrim(ltrim(isnull([codpag],''))) in ('002') then 'RD09'
    when rtrim(ltrim(isnull([codpag],''))) in ('003') then 'RB03'
    when rtrim(ltrim(isnull([codpag],''))) in ('004') then 'RB04'
    when rtrim(ltrim(isnull([codpag],''))) in ('005') then 'RD07'
    when rtrim(ltrim(isnull([codpag],''))) in ('006','204') then 'RB01'
    when rtrim(ltrim(isnull([codpag],''))) in ('007') then 'RD02'
    when rtrim(ltrim(isnull([codpag],''))) in ('008') then 'RD08'
    when rtrim(ltrim(isnull([codpag],''))) in ('009') then 'BB08'
    when rtrim(ltrim(isnull([codpag],''))) in ('010') then 'RD03'
    when rtrim(ltrim(isnull([codpag],''))) in ('012') then 'RD01'
    when rtrim(ltrim(isnull([codpag],''))) in ('014') then 'RD23'   
    when rtrim(ltrim(isnull([codpag],''))) in ('015') then 'RB20'
    when rtrim(ltrim(isnull([codpag],''))) in ('018') then 'PAGCON5'
    when rtrim(ltrim(isnull([codpag],''))) in ('019') then 'RD14'
    when rtrim(ltrim(isnull([codpag],''))) in ('020') then 'RD06'
    when rtrim(ltrim(isnull([codpag],''))) in ('021') then 'RB19'
    when rtrim(ltrim(isnull([codpag],''))) in ('022') then 'RB17'
    when rtrim(ltrim(isnull([codpag],''))) in ('027') then 'RD24'
    when rtrim(ltrim(isnull([codpag],''))) in ('028') then 'RB16'
    when rtrim(ltrim(isnull([codpag],''))) in ('050') then 'CARCRE'
    when rtrim(ltrim(isnull([codpag],''))) in ('061') then 'RD17'
    when rtrim(ltrim(isnull([codpag],''))) in ('065') then 'RD25'
    when rtrim(ltrim(isnull([codpag],''))) in ('070') then 'RD15'
    when rtrim(ltrim(isnull([codpag],''))) in ('071') then 'PF01'
    when rtrim(ltrim(isnull([codpag],''))) in ('075') then 'RD26'
    when rtrim(ltrim(isnull([codpag],''))) in ('101') then 'RD04'
    when rtrim(ltrim(isnull([codpag],''))) in ('104') then 'RD05'
    when rtrim(ltrim(isnull([codpag],''))) in ('105','449') then 'RB06'
    when rtrim(ltrim(isnull([codpag],''))) in ('106') then 'BB03'
    when rtrim(ltrim(isnull([codpag],''))) in ('107') then 'RB09'
    when rtrim(ltrim(isnull([codpag],''))) in ('114') then 'RB07' 
    when rtrim(ltrim(isnull([codpag],''))) in ('118') then 'RD20'
    when rtrim(ltrim(isnull([codpag],''))) in ('120') then 'RD16'
    when rtrim(ltrim(isnull([codpag],''))) in ('126') then 'RD21' 
    when rtrim(ltrim(isnull([codpag],''))) in ('137') then 'BB13'
    when rtrim(ltrim(isnull([codpag],''))) in ('202') then 'RB18'
    when rtrim(ltrim(isnull([codpag],''))) in ('205') then 'RB05'
    when rtrim(ltrim(isnull([codpag],''))) in ('21','426') then 'RB19'
    when rtrim(ltrim(isnull([codpag],''))) in ('220') then 'RB31'
    when rtrim(ltrim(isnull([codpag],''))) in ('318') then 'RB21'
    when rtrim(ltrim(isnull([codpag],''))) in ('402') then 'EFF'
    when rtrim(ltrim(isnull([codpag],''))) in ('415','435') then 'RB22'
    when rtrim(ltrim(isnull([codpag],''))) in ('417') then 'RB29'
    when rtrim(ltrim(isnull([codpag],''))) in ('425') then 'RB23'
    when rtrim(ltrim(isnull([codpag],''))) in ('429') then 'RB24'
    when rtrim(ltrim(isnull([codpag],''))) in ('430') then 'RB25'
    when rtrim(ltrim(isnull([codpag],''))) in ('432') then 'RB30'
    when rtrim(ltrim(isnull([codpag],''))) in ('443') then 'RB27'
    when rtrim(ltrim(isnull([codpag],''))) in ('446') then 'RB26'
    when rtrim(ltrim(isnull([codpag],''))) in ('A26') then 'RB28'
    else null end codpag--[codpag]
,concat(rtrim(ltrim(b.mastro)),'§',rtrim(ltrim(b.sottoc))) 'key'--[key]
,rtrim(ltrim(b.codiban)) iban--[iban]
,rtrim(ltrim(ragsociale)) banca--[banca]
,case
    when rtrim(ltrim(isnull([codabi1],''))) IN ('1005','01005') and rtrim(ltrim(isnull([codcab1],''))) = '30680' then '001'
    when rtrim(ltrim(isnull([codabi1],''))) IN ('2008','02008') and rtrim(ltrim(isnull([codcab1],''))) = '30685' then '002'
    when rtrim(ltrim(isnull([codabi1],''))) IN ('1030','01030') and rtrim(ltrim(isnull([codcab1],''))) = '30870' then '003'
    else null end bancans--[bancans]
From [Saldobraz].[dbo].[ANAA0000] a 
join [Saldobraz].[dbo].[CLIA0000] b on a.codanagrafico = b.codanagrafico 
left join [Saldobraz].[dbo].[TCAB0000] c on c.abi = b.codabi1 and c.cab=b.codcab1
left join [Saldobraz].[dbo].[CIPA0000] d on d.mastro = b.mastro and d.sottoc=b.sottoc
-- where rtrim(ltrim(a.ricercabreve)) not in ()