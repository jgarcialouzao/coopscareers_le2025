* STATA 14
* 14h
* READ_MCVL_LABORAL.DO (READ ORIGINAL MCVL IN ASCII: DATOS LABORALES Y DEL EMPLEADOR)
* Ana Rute Cardoso & Jose Garcia-Louzao
* Jan 2016

clear all
capture log close
capture program drop _all
set more 1

log using logs\read_MCVL_laboral.log, replace

quietly {
do labels/labelcountry
do labels/labelprovince
do labels/labelmunicipality
do labels/labelmunicipalitysmall
do labels/labeleducation
do labels/labelregime
do labels/labelskill
do labels/labelcontract
do labels/labelreasonspell
do labels/labelCNAE93
do labels/labelCNAE09
do labels/labellegal1
do labels/labellegal2
do labels/labeltype1plant
do labels/labeltype2plant
do labels/labelselfemp_status
}
program define check
     list in 1/3
     describe
     sum
end



*** read datos afiliados

program define readafiliad



   if `1'==2018  | `1'==2017 | `1'==2016 | `1'==2015 | `1'==2014 | `1'==2013 {
      infix str15 idperson 1-15 regimen 17-20 grupo 22-23 contrato 25-27 coef 29-31 str8 fechaalta 33-40 str8 fechabaja 42-49 causabaja 51-52 minusvalia 54-55 str13 cuentasecund 57-69 domiciliocuentasecund 71-75 activecoC09C 77-79 numerotrab 81-86 str8 fechaalta1 88-95 tiporelacionlaboral 97-99 colectivotrab 101-104 tipoempleador 106 str1 juridica 108 str15 juridicid 110-124 str13 cuentaprinc 126-138 domiciliosocial 140-141 str8 modif1contratofecha 143-150 modif1tipocontrato 152-154 modif1coef 156-158 str8 modif2contratofecha 160-167 modif2tipocontrato 169-171 modif2coef 173-175 str8 modif1grupofecha 177-184 modif1grupo 186-187 activecoC93C 189-191 str1 tseta 193 selfemp_status 195-196 str8 fechaefectoalta 198-205 str8 fechaefectobaja 207-214 using ../mcvl_orig/MCVL`1'`3'.`4', clear
   }   
   if `1'==2012 | `1'==2011 | `1'==2010 {
      infix str15 idperson 1-15 regimen 17-20 grupo 22-23 contrato 25-27 coef 29-31 str8 fechaalta 33-40 str8 fechabaja 42-49 causabaja 51-52 minusvalia 54-55 str13 cuentasecund 57-69 domiciliocuentasecund 71-75 activecoC09C 77-79 numerotrab 81-86 str8 fechaalta1 88-95 tiporelacionlaboral 97-99 colectivotrab 101-104 tipoempleador 106 str1 juridica 108 str15 juridicid 110-124 str13 cuentaprinc 126-138 domiciliosocial 140-141 str8 modif1contratofecha 143-150 modif1tipocontrato 152-154 modif1coef 156-158 str8 modif2contratofecha 160-167 modif2tipocontrato 169-171 modif2coef 173-175 str8 modif1grupofecha 177-184 modif1grupo 186-187 activecoC93C 189-191 using ../mcvl_orig/MCVL`1'`3'.`4', clear
   }   
   if `1'==2009 {
      infix str15 idperson 1-15 regimen 17-20 grupo 22-23 contrato 25-27 coef 29-31 str8 fechaalta 33-40 str8 fechabaja 42-49 causabaja 51-52 minusvalia 54-55 str13 cuentasecund 57-69 domiciliocuentasecund 71-75 activecoC09C 77-79 numerotrab 81-86 str8 fechaalta1 88-95 tiporelacionlaboral 97-99 colectivotrab 101-104 tipoempleador 106 str1 juridica 108 str15 juridicid 110-124 str13 cuentaprinc 126-138 domiciliosocial 140-141 str8 modif1contratofecha 143-150 modif1tipocontrato 152-154 modif1coef 156-158 str8 modif2contratofecha 160-167 modif2tipocontrato 169-171 modif2coef 173-175 str8 modif1grupofecha 177-184 modif1grupo 186-187 using ../mcvl_orig/MCVL`1'_`3'.`4', clear
   }
   if  `1'==2008 | `1'==2007 |  `1'==2006 |  `1'==2005 {
      infix str15 idperson 1-15 regimen 17-20 grupo 22-23 contrato 25-27 coef 29-31 str8 fechaalta 33-40 str8 fechabaja 42-49 causabaja 51-52 minusvalia 54-55 str13 cuentasecund 57-69 domiciliocuentasecund 71-75 activecoC93C 77-79 numerotrab 81-86 str8 fechaalta1 88-95 tiporelacionlaboral 97-99 colectivotrab 101-104 tipoempleador 106 str1 juridica 108 str15 juridicid 110-124 str13 cuentaprinc 126-138 domiciliosocial 140-141 str8 modif1contratofecha 143-150 modif1tipocontrato 152-154 modif1coef 156-158 str8 modif2contratofecha 160-167 modif2tipocontrato 169-171 modif2coef 173-175 str8 modif1grupofecha 177-184 modif1grupo 186-187 using ../mcvl_orig/MCVL`1'_`3'.`4', clear
   }
   if `1'==2004 {
      infile str15 idperson regimen grupo contrato coef str8 fechaalta str8 fechabaja causabaja minusvalia str13 cuentasecund domiciliocuentasecund activecoC93C numerotrab str8 fechaalta1 tiporelacionlaboral colectivotrab tipoempleador str1 juridica str13 cuentaprinc domiciliosocial using ../mcvl_orig/MCVL`1'_`3'.`4', clear
   } 
   check
   gen year=`1' 
   label variable year  "year when person was sampled/observed"

   ** WORKER/SPELL ATTRIBUTES

   codebook idperson
   label variable idperson "person ID"
 
   * regime contribution Social Security
   tab regimen, missing
   ren regimen regime
   label values regime regimelb
   label variable regime "regime contribution Social Security"
   tab regime, missing

   * skill (grupo cotizacion)
   tab grupo, missing
   ren grupo skill
   label values skill skilllb
   label variable skill "skill (group contribution S.Sec.)"
   tab skill, missing
   
   * type of contract
   tab contrato, missing
   ren contrato contract
   label values contract contractlb
   label variable contract "contract type"
   tab contract, missing
 
   * part-time
   if year!=2004 {
      recode coef 0=.     /* full-time */
      gen ptime=int(coef/10)
	  tab ptime
      label variable ptime "part-time (%ftime)"
   }
   else  {
      recode coef 0=.     /* full-time */
      gen ptime = int(coef/10)
	  tab ptime
      label variable ptime "part-time (%ftime)"
   }

   * date start and end of spell in Social Security
   foreach v in alta baja {
      codebook fecha`v'
      replace fecha`v'="" if fecha`v'=="000000"
      * but on-going spells kept original coding by Social Security: December 31 of following year 
   }
   gen spellstart_date = date(fechaalta, "YMD")
   gen spellend_date   = date(fechabaja, "YMD")
 
   foreach v in start end {
     format spell`v'_date %td
     label variable spell`v'_date "date spell `v'"
     
     foreach t in year month day {
        gen spell`v'_`t'=`t'(spell`v'_date) 
        label variable spell`v'_`t' "`t'  spell `v'"
        tab spell`v'_`t', missing
     }
   }

  
   * reason end spell in Social Security
   tab causabaja, missing
   ren causabaja reason_endspell
   label values reason_endspell reasonspelllb
   label variable reason_endspell "reason why spell ended"
   tab reason_endspell, missing
   
   *Between 2008 and 2013, typo in the ending date of on-going spells, correct it (see Documentation)
  if year==2013 | year == 2012 | year==2011 | year == 2010 | year==2009 | year == 2008 {
replace spellend_date=mdy(12,31,year+1) if spellend_date==mdy(12,31,year) & reason_endspell==0
   }

   
   *Homogeneize ending date for on-going spells, from 2017 onwards year = 2099 instead of year+1
  if year==2018 | year == 2017 {
replace spellend_date=mdy(12,31,year+1) if spellend_date==mdy(12,31,2099) & reason_endspell==0
   }
    

   * handicap
   tab minusvalia, missing
   ren minusvalia handicap
   label variable handicap "degree handicap (%)"
   tab handicap, missing


   * changes in contract, skill, and part-time within an employment spell /* this coding by the Social Security of changes in contract, skill, and part-time seem to have some inconsistencies; suspect that it'll be better to disregard these variables on  "modificaciones" */
   *!!!JGL: documentation says that there are many wrong values in these "modificaciones" until 2010 (included)
   if year!=2004 {
    * changes in contract or ptime within same spell

      * dates of change 
      foreach v in modif1contrato modif2contrato modif1grupo {
         codebook `v'fecha
         replace `v'fecha="" if `v'fecha=="000000"
         gen `v'date = date(`v'fecha, "YMD")
         format `v'date %td
      }

      foreach i in 1 2 {
         ren modif`i'contratodate D`i'contract_date
         codebook D`i'contract_date
      }
      ren modif1grupodate D1skill_date
      codebook D1skill_date

      label variable D1contract_date "date of 1st change contract"
      label variable D2contract_date "date of 2nd change contract"
      label variable D1skill_date    "date of 1st change skill group"
     
      * type contract and ptime
      foreach i in 1 2 {
          tab modif`i'tipocontrato, missing
          ren modif`i'tipocontrato D`i'contract_oldcontract
          label values D`i'contract_oldcontract contractlb
          tab D`i'contract_oldcontract, missing

          sum modif`i'coef, detail
          recode modif`i'coef 0=.     /* full-time */
          gen D`i'ptime_oldptime = int(modif`i'coef/10)  /* ptime before change reported in per-thousand */
          tab D`i'ptime_oldptime, missing
      }

      label variable D1contract_oldcontract "type contract before 1st change"
      label variable D2contract_oldcontract "type contract before 2nd change"
      *assert contract==D1contract_old
      display "'contract till 1st modification' is NOT same as 'inital contract' & not missing:" // contract is not initial contract, it's current contract
      count if D1contract_old!=contract & D1contract_old!=.

      label variable D1ptime_oldptime "ptime before 1st change (%ftime)"
      label variable D2ptime_oldptime "ptime before 2nd change (%ftime)"
      * assert ptime==D1ptime_oldptime
      display "'part-time till 1st modification' is NOT same as 'inital part-time' & not missing:" // ptime is current part-time
      count if D1ptime_oldptime!=ptime & D1ptime_old!=.

      * change skill (grupo)
      tab modif1grupo, missing
      ren modif1grupo D1skill_oldskill
      label values D1skill_oldskill skilllb
      label variable D1skill_oldskill "skill before 1st change"
      tab D1skill_oldskill, missing
      *assert D1skill_oldskill==skill
      display "'skill till 1st modification' is NOT same as 'inital skill' & not missing:" // skill is current skill
      count if D1skill_oldskill!=skill & D1skill_oldskill!=.
   }


   *** EMPLOYER ATTRIBUTES

   ** FIRM

   * ID firm
   if year!=2004 {
      codebook juridicid
      replace juridicid="" if juridicid=="000000000000000"
      ren juridicid idfirm
      label variable idfirm "firm juridical ID" 
   }

    * legal setting
   tab tipoempleador, missing
   tab juridica, missing
   tab tipoempleador juridica, missing

   ren tipoempleador legal1firm
   *!!!JGL: letter values cannot be read as numbe, they appear as missing but they should be the same as 0 (see Documentation)
   recode legal1firm .=0
   label values legal1firm legal1lb
   label variable legal1firm "individual/sole proprietor firm"
   tab legal1firm, missing

   #delimit ;
   replace juridica="1" if juridica=="A"; replace juridica="2" if juridica=="B"; replace juridica="3" if juridica=="C"; replace juridica="4" if juridica=="D"; replace juridica="5" if juridica=="E"; replace juridica="6" if juridica=="F"; replace juridica="7" if juridica=="G"; replace juridica="8" if juridica=="H"; replace juridica="9" if juridica=="J"; replace juridica="10" if juridica=="N"; replace juridica="11" if juridica=="P"; replace juridica="12" if juridica=="Q"; replace juridica="13" if juridica=="R"; replace juridica="14" if juridica=="S"; replace juridica="15" if juridica=="U"; replace juridica="16" if juridica=="V"; replace juridica="17" if juridica=="W";
   #delimit cr

   gen legal2firm=real(juridica) 
   label values legal2firm legal2lb
   label variable legal2firm "legal setting of firm"
   tab legal2firm, missing
   replace legal2firm=88 if legal1firm!=9
   label values legal2firm legal2lb
   tab legal2firm, missing

  * type plant - contribution account
  
   tab tiporelacionlaboral, missing
   ren tiporelacionlaboral type1plant
   label values type1plant type1plantlb
   label variable type1plant "type of plant-employee relationship"
   tab type1plant, missing

   tab colectivotrab, missing
   ren colectivotrab type2plant
   label values type2plant type2plantlb
   label variable type2plant "type of plant (public admin., priv. firm,...)"
   tab type2plant, missing

   ** MAINPLANT ="cuenta principal", meaning main unit defined by FIRM/PROVINCE/REGIME SSecurity
                 /* equivalent to FIRM / HEADQUARTERS */
   ** PLANT     ="cuenta secundaria", meaning unit other than the main one, defined by FIRM/PROVINCE/REGIME SSecurity


   * mainplant and (other) plant(s): ID, province, and regime Social Security

   foreach p in princ secund {
      codebook cuenta`p'
   }
   
   ren cuentaprinc  idplantmain
   ren cuentasecund idplant
   label variable idplantmain  "main plant ID (main unit firm/region/regimeSS, i.e. 'CCC principal')"
   label variable idplant      "plant ID (unit firm/region/regimeSS, i.e. 'CCC secundario')"

   foreach p in plantmain plant {
      gen regimen`p'=substr(id`p',1,4)
      tab regimen`p', missing
      gen regime`p'=real(regimen`p')
      label values regime`p' regimelb
      tab  regime`p', missing

      gen prov`p'=substr(id`p',5,2)
      tab prov`p', missing
      gen province`p'=real(prov`p')
      label values province`p' provincelb
      tab  province`p', missing
   }
   tab regimeplant if regimeplantmain==1911, nolab
   tab regimeplant if regimeplantmain==3011, nolab

   label variable regimeplant       "regime S.Sec. of plant"
   label variable regimeplantmain   "regime S.Sec. of main plant"
   label variable provinceplant     "province of plant"
   label variable provinceplantmain "province of main plant (from S.Sec. records: 'CCC principal')"

   * check province main plant
   tab domiciliosocial, missing
   *!!!JGL: they are not exactly equal
   count if domiciliosocial!=provinceplantmain & domiciliosocial!=0
   ren domiciliosocial province2plantmain
   label values province2plantmain provincelb
   label variable province2plantmain "province of main plant (from Tesorería S.Sec.)"
   tab province2plantmain, missing


   ** PLANT

   * address: municipality

   tab domiciliocuentasecund, missing
   ren domiciliocuentasec   municipalityplant
   label values municipalityplant municipalitylb
   tab municipalityplant, missing
   label values municipalityplant municipalitysmalllb
   label variable municipalityplant "address plant: municipality (or province, if small munic.)"
   tab municipalityplant, missing
   gen province2plant=int(municipalityplant/1000)
   *!!!JGL: in this case the rate of coincidence is larger
   count if province2plant!=provinceplant & province2plant!=0
 

   * economic activity
   if year==2018 | year==2017 | year==2016 | year==2015 | year==2014 | year==2013 | year==2012 | year==2011 | year==2010 { 
      foreach d in 93 09 {
         tab activecoC`d'C, missing
         ren activecoC`d'C CNAE`d'
         label values CNAE`d' CNAE`d'lb
         label variable CNAE`d' "industry (CNAE`d')"
		 *!!!JGL: Value zeros should be considered as no info? What do we do with values which are not labelled?
         tab CNAE`d', missing
      }
   }
   if year==2009 {    
      foreach d in 09 {
         tab activecoC`d'C, missing
         ren activecoC`d'C CNAE`d'
         label values CNAE`d' CNAE`d'lb
         label variable CNAE`d' "industry (CNAE`d')"
         tab CNAE`d', missing
      }
   }
   if year==2008 | year==2007  | year==2006  | year==2005  | year==2004 {
     foreach d in 93 {
         tab activecoC`d'C, missing
         ren activecoC`d'C CNAE`d'
         label values CNAE`d' CNAE`d'lb
         label variable CNAE`d' "industry (CNAE`d')"
         tab CNAE`d', missing
     }
   }

   
   * employment
   sum numerotrab, detail
   display "type1firm with size>=10,000:"
   tab type1plant if numerotrab>=10000
   display "type2firm with size>=10,000:"
   tab type2plant if numerotrab>=10000
   ren numerotrab size 
   label variable size "number of employees"

   * date creation 
   codebook fechaalta1
   gen creation_date=date(fechaalta1, "YMD")
   format creation_date %td
   label variable creation_date "date creation"
   codebook creation_date
  if year==2018 | year==2017 | year==2016 | year==2015 | year==2014 | year==2013 {
   *SETA - especial system for agricultural workers 
   label variable tseta "especial system for agricultural workers"
   
   *Type of relation for the self-employed
	label variable selfemp_status "type of relation of the self-employed"
  
 
    * date start and end of spell in Social Security
   foreach v in efectoalta efectobaja {
      codebook fecha`v'
      replace fecha`v'="" if fecha`v'=="000000"
      * but on-going spells kept original coding by Social Security: December 31 of following year
	   
   }
   gen spellstart_effdate = date(fechaefectoalta, "YMD")
   gen spellend_effdate   = date(fechaefectobaja, "YMD")
   
   foreach v in start end {
     format spell`v'_effdate %td
     label variable spell`v'_effdate "effective date spell `v'"
     
    
   }
   }
   if year==2018 | year==2017 | year==2016 | year==2015 | year==2014 | year==2013 {
      keep     year idperson idfirm idplantmain idplant regime skill contract ptime handicap spellstart_date spellstart_effdate spellend_date spellend_effdate reason_endspell selfemp_status legal1firm legal2firm type1plant type2plant regimeplantmain provinceplantmain province2plantmain regimeplant provinceplant province2plant municipalityplant CNAE93 CNAE09 size creation_date D1contract_date D2contract_date D1contract_oldcontract D2contract_oldcontract D1ptime_oldptime D2ptime_oldptime D1skill_date D1skill_oldskill
      order    year idperson idfirm idplantmain idplant regime skill contract ptime handicap spellstart_date spellstart_effdate spellend_date spellend_effdate reason_endspell selfemp_status legal1firm legal2firm type1plant type2plant regimeplantmain provinceplantmain province2plantmain regimeplant provinceplant province2plant municipalityplant CNAE93 CNAE09 size creation_date D1contract_date D2contract_date D1contract_oldcontract D2contract_oldcontract D1ptime_oldptime D2ptime_oldptime D1skill_date D1skill_oldskill
      compress year                                     regime skill contract ptime handicap spellstart_date spellstart_effdate spellend_date spellend_effdate reason_endspell selfemp_status legal1firm legal2firm type1plant type2plant regimeplantmain provinceplantmain province2plantmain regimeplant provinceplant province2plant municipalityplant CNAE93 CNAE09 size creation_date D1contract_date D2contract_date D1contract_oldcontract D2contract_oldcontract D1ptime_oldptime D2ptime_oldptime D1skill_date D1skill_oldskill

   
   }
   if year==2012 | year==2011 | year==2010 {
      keep     year idperson idfirm idplantmain idplant regime skill contract ptime handicap spellstart_date spellend_date reason_endspell legal1firm legal2firm type1plant type2plant regimeplantmain provinceplantmain province2plantmain regimeplant provinceplant province2plant municipalityplant CNAE93 CNAE09 size creation_date D1contract_date D2contract_date D1contract_oldcontract D2contract_oldcontract D1ptime_oldptime D2ptime_oldptime D1skill_date D1skill_oldskill
      order    year idperson idfirm idplantmain idplant regime skill contract ptime handicap spellstart_date spellend_date reason_endspell legal1firm legal2firm type1plant type2plant regimeplantmain provinceplantmain province2plantmain regimeplant provinceplant province2plant municipalityplant CNAE93 CNAE09 size creation_date D1contract_date D2contract_date D1contract_oldcontract D2contract_oldcontract D1ptime_oldptime D2ptime_oldptime D1skill_date D1skill_oldskill
      compress year                                     regime skill contract ptime handicap spellstart_date spellend_date reason_endspell legal1firm legal2firm type1plant type2plant regimeplantmain provinceplantmain province2plantmain regimeplant provinceplant province2plant municipalityplant CNAE93 CNAE09 size creation_date D1contract_date D2contract_date D1contract_oldcontract D2contract_oldcontract D1ptime_oldptime D2ptime_oldptime D1skill_date D1skill_oldskill
   }
   if year==2009  {
      keep     year idperson idfirm idplantmain idplant regime skill contract ptime handicap spellstart_date spellend_date reason_endspell legal1firm legal2firm type1plant type2plant regimeplantmain provinceplantmain province2plantmain regimeplant provinceplant province2plant municipalityplant        CNAE09 size creation_date D1contract_date D2contract_date D1contract_oldcontract D2contract_oldcontract D1ptime_oldptime D2ptime_oldptime D1skill_date D1skill_oldskill
      order    year idperson idfirm idplantmain idplant regime skill contract ptime handicap spellstart_date spellend_date reason_endspell legal1firm legal2firm type1plant type2plant regimeplantmain provinceplantmain province2plantmain regimeplant provinceplant province2plant municipalityplant        CNAE09 size creation_date D1contract_date D2contract_date D1contract_oldcontract D2contract_oldcontract D1ptime_oldptime D2ptime_oldptime D1skill_date D1skill_oldskill
      compress year                                     regime skill contract ptime handicap spellstart_date spellend_date reason_endspell legal1firm legal2firm type1plant type2plant regimeplantmain provinceplantmain province2plantmain regimeplant provinceplant province2plant municipalityplant        CNAE09 size creation_date D1contract_date D2contract_date D1contract_oldcontract D2contract_oldcontract D1ptime_oldptime D2ptime_oldptime D1skill_date D1skill_oldskill
   }
   if year==2008 | year==2007 | year==2006 | year==2005 {
      keep     year idperson idfirm idplantmain idplant regime skill contract ptime handicap spellstart_date spellend_date reason_endspell legal1firm legal2firm type1plant type2plant regimeplantmain provinceplantmain province2plantmain regimeplant provinceplant province2plant municipalityplant CNAE93        size creation_date D1contract_date D2contract_date D1contract_oldcontract D2contract_oldcontract D1ptime_oldptime D2ptime_oldptime D1skill_date D1skill_oldskill
      order    year idperson idfirm idplantmain idplant regime skill contract ptime handicap spellstart_date spellend_date reason_endspell legal1firm legal2firm type1plant type2plant regimeplantmain provinceplantmain province2plantmain regimeplant provinceplant province2plant municipalityplant CNAE93        size creation_date D1contract_date D2contract_date D1contract_oldcontract D2contract_oldcontract D1ptime_oldptime D2ptime_oldptime D1skill_date D1skill_oldskill
      compress year                                     regime skill contract ptime handicap spellstart_date spellend_date reason_endspell legal1firm legal2firm type1plant type2plant regimeplantmain provinceplantmain province2plantmain regimeplant provinceplant province2plant municipalityplant CNAE93        size creation_date D1contract_date D2contract_date D1contract_oldcontract D2contract_oldcontract D1ptime_oldptime D2ptime_oldptime D1skill_date D1skill_oldskill
   }
   if year==2004 {
      keep     year idperson        idplantmain idplant regime skill contract ptime handicap spellstart_date spellend_date reason_endspell legal1firm legal2firm type1plant type2plant regimeplantmain provinceplantmain province2plantmain regimeplant provinceplant province2plant municipalityplant CNAE93        size creation_date 
      order    year idperson        idplantmain idplant regime skill contract ptime handicap spellstart_date spellend_date reason_endspell legal1firm legal2firm type1plant type2plant regimeplantmain provinceplantmain province2plantmain regimeplant provinceplant province2plant municipalityplant CNAE93        size creation_date 
      compress year                                     regime skill contract ptime handicap spellstart_date spellend_date reason_endspell legal1firm legal2firm type1plant type2plant regimeplantmain provinceplantmain province2plantmain regimeplant provinceplant province2plant municipalityplant CNAE93        size creation_date 
   }
   describe
   sum
   save ../mcvl_stata/tmpMCVL`1'_laboral`2'.dta, replace
end
/* 1: year 
   2: round (1, 2, 3)
   3: name original file
   4: extensao original file   */

/*   
readafiliad 2018 1 AFILIAD1_CDF TXT
readafiliad 2018 2 AFILIAD2_CDF TXT
readafiliad 2018 3 AFILIAD3_CDF TXT 
readafiliad 2018 4 AFILIAD4_CDF TXT  

readafiliad 2017 1 AFILIAD1_CDF TXT
readafiliad 2017 2 AFILIAD2_CDF TXT
readafiliad 2017 3 AFILIAD3_CDF TXT 
readafiliad 2017 4 AFILIAD4_CDF TXT      

readafiliad 2016 1 AFILIAD1_CDF TXT
readafiliad 2016 2 AFILIAD2_CDF TXT
readafiliad 2016 3 AFILIAD3_CDF TXT 
readafiliad 2016 4 AFILIAD4_CDF TXT  

readafiliad 2015 1 AFILIAD1_CDF TXT
readafiliad 2015 2 AFILIAD2_CDF TXT
readafiliad 2015 3 AFILIAD3_CDF TXT 
readafiliad 2015 4 AFILIAD4_CDF TXT      
   
readafiliad 2014 1 AFILIAD1_CDF TXT
readafiliad 2014 2 AFILIAD2_CDF TXT
readafiliad 2014 3 AFILIAD3_CDF TXT 
readafiliad 2014 4 AFILIAD4_CDF TXT   

readafiliad 2013 1 AFILIAD1_CDF TXT
readafiliad 2013 2 AFILIAD2_CDF TXT
readafiliad 2013 3 AFILIAD3_CDF TXT 
readafiliad 2013 4 AFILIAD4_CDF TXT
*/
readafiliad 2012 1 AFILIAD1_CDF TXT
readafiliad 2012 2 AFILIAD2_CDF TXT
readafiliad 2012 3 AFILIAD3_CDF TXT 

readafiliad 2011 1 .F2013.AFILIA1_CDF TXT
readafiliad 2011 2 .F2013.AFILIA2_CDF TXT
readafiliad 2011 3 .F2013.AFILIA3_CDF TXT

readafiliad 2010 1 _AFILIAD1_CDF TXT
readafiliad 2010 2 _AFILIAD2_CDF TXT
readafiliad 2010 3 _AFILIAD3_CDF TXT

readafiliad 2009 1 AFILIAD1_CDF TXT
readafiliad 2009 2 AFILIAD2_CDF TXT
readafiliad 2009 3 AFILIAD3_CDF TXT

readafiliad 2008 1 AFILANON1 trs
readafiliad 2008 2 AFILANON2 trs
readafiliad 2008 3 AFILANON3 trs

readafiliad 2007 1 AFILANON1 trs
readafiliad 2007 2 AFILANON2 trs
readafiliad 2007 3 AFILANON3 trs

readafiliad 2006 1 AFILANON1 trs
readafiliad 2006 2 AFILANON2 trs
readafiliad 2006 3 AFILANON3 trs


readafiliad 2005 1 AFILANON1 trs
readafiliad 2005 2 AFILANON2 trs
readafiliad 2005 3 AFILANON3 trs

/*
readafiliad 2004 1 AFILANON1 txt
readafiliad 2004 2 AFILANON2 txt
readafiliad 2004 3 AFILANON3 txt
*/


* append all 3 files of labor market data
forvalues i=2005(1)2012 {
   use ../mcvl_stata/tmpMCVL`i'_laboral1.dta, clear
   append using ../mcvl_stata/tmpMCVL`i'_laboral2.dta
   append using ../mcvl_stata/tmpMCVL`i'_laboral3.dta

  
*Drop duplicated spells
bys idperson spellstart_date spellend_date idplant: keep if _n == 1

   rename year year_mcvl
   
   describe
   sum
   save ../mcvl_stata/MCVL`i'_laboral.dta, replace
}

forvalues i=2005(1)2012 {
   erase ../mcvl_stata/tmpMCVL`i'_laboral1.dta
   erase ../mcvl_stata/tmpMCVL`i'_laboral2.dta
   erase ../mcvl_stata/tmpMCVL`i'_laboral3.dta
 }

forvalues i=2013(1)2018 {
   use ../mcvl_stata/tmpMCVL`i'_laboral1.dta, clear
   append using ../mcvl_stata/tmpMCVL`i'_laboral2.dta
   append using ../mcvl_stata/tmpMCVL`i'_laboral3.dta
   append using ../mcvl_stata/tmpMCVL`i'_laboral4.dta
   
*Drop duplicated spells
bys idperson spellstart_date spellend_date idplant: keep if _n == 1
   
rename year year_mcvl


  describe
   sum
   save ../mcvl_stata/MCVL`i'_laboral.dta, replace
}
forvalues i=2013(1)2018 {
   erase ../mcvl_stata/tmpMCVL`i'_laboral1.dta
   erase ../mcvl_stata/tmpMCVL`i'_laboral2.dta
   erase ../mcvl_stata/tmpMCVL`i'_laboral3.dta
   erase ../mcvl_stata/tmpMCVL`i'_laboral4.dta
   
}
log close
exit, clear

