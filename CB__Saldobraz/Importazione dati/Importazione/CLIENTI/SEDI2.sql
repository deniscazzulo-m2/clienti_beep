INSERT INTO [BpSaldobraz].[dbo].[tempSedi] (
    [ItemType]
    ,[ItemID]
    ,[ItemDes]
    ,[Ind]
    ,[Cap]
    ,[Loc]
    ,[Pro]
    ,[Naz]
    )

SELECT
'1' itemtype--[ItemType]
,concat(rtrim(ltrim(b.mastro)),'.',right(concat('00000',rtrim(ltrim(b.sottoc))),5)) 'ItemID'--[ItemID]
,rtrim(concat(rtrim(ltrim(a.ragsoccognome)),' ',rtrim(ltrim(a.ragsocnome)))) ragsociale--[ItemDes]
,rtrim(concat(rtrim(ltrim(a.indirizzofiscale)),' ',rtrim(ltrim(a.numcivicofiscale)))) indirizzo--[Ind]
,case
    when rtrim(ltrim(isnull(a.capfiscale,''))) not in ('00000','0','') then
        rtrim(ltrim(a.capfiscale))
    else null end cap--[CAP]
,rtrim(ltrim(a.comunefiscale)) citta--[loc]
,rtrim(ltrim(a.provinciafiscale)) provincia--[Pro]
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
    ELSE NULL END nazione--[Naz]
From [Saldobraz].[dbo].[CLIA0000] c 
join [Saldobraz].[dbo].[DESM0000] b on c.mastro = b.mastro and c.sottoc=b.sottoc left
join [Saldobraz].[dbo].[ANAA0000] a on b.codanagrafico = a.codanagrafico