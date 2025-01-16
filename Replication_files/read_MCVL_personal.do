* STATA 14
* READ_MCVL_PERSONAL.DO (READ ORIGINAL MCVL IN ASCII: PERSONAL DATA)
* Jose Garcia-Louzao
* Jan 2016
******************************************
clear all
capture log close
capture program drop _all
set more 1


log using logs\read_MCVL_personal.log, replace

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
}


program define check
     list in 1/10, abbrev(4)
     sum
     describe
end



*** read datos personales

program define readpersonal
   if `1'!=2004 {
      infix str15 idperson 1-15 str6 fechanacimiento 17-22 sexo 24 str3 nacionalidade 26-28 provincebirth 30-31 provinceaffil1 33-34 domicilio 36-40 str6 fechamuerte 42-47 str3 paisnacimiento 49-51 str2 educacion 53-54 using ../mcvl_orig/MCVL`1'`2'.`3', clear
   }
   else {
      infix str15 idperson 1-15 str8 fechanacimiento 17-24 sexo 26 str3 nacionalidade 28-30 provinceaffil1 35-36 domicilio 38-42 str6 fechamuerte 44-49 using ../mcvl_orig/MCVL`1'_`2'.`3', clear
   }
   gen year=`1'
   label variable year  "year when person was sampled/observed"
   check

   * id

   label variable idperson "person ID"
   codebook idperson
   duplicates list, abbrev(4)
   duplicates drop
   bys idperson: gen Nobs=_N
   tab Nobs

   * date of death 

   codebook fechamuerte
   replace fechamuerte="" if fechamuerte=="000000"
   gen datedeath=date(fechamuerte, "YM")
   format datedeath %td
   gen yeardeath=year(datedeath) 
   gen monthdeath=month(datedeath) 
   label variable datedeath "date of death"
   label variable yeardeath "year of death"
   label variable monthdeath "month of death"
   tab datedeath, missing
   tab yeardeath, missing
   tab monthdeath, missing
 
   * date of birth

   if year!=2004 {
      codebook fechanacimiento
      replace fechanacimiento="" if fechanacimiento=="000000"
      gen datebirth=date(fechanacimiento, "YM")
   }
   else {
      codebook fechanacimiento
      replace fechanacimiento="" if fechanacimiento=="00000000"
      gen datebirth=date(fechanacimiento, "YMD")
      gen daybirth=day(datebirth) 
      label variable daybirth "day of birth"
      tab daybirth, missing
   }
   gen yearbirth=year(datebirth) 
   gen monthbirth=month(datebirth) 

   format datebirth %td
   label variable datebirth "date of birth"
   label variable yearbirth "year of birth"
   label variable monthbirth "month of birth"
   tab yearbirth, missing
   tab monthbirth, missing
 
   * gender

   tab sexo, missing
   ren sexo female
   recode female 0 9=. 1=0 2=1
   tab female, missing

   * nationality 

   tab nacionalidade, missing
   gen nacion=substr(nacion,2,2)
   gen nationality=real(nacion)
   recode nationality 99=.
   label values nationality countrylb
   label variable nationality "nationality"
   tab nationality, missing
 
   * country of birth

   if year!=2004  {
     tab paisnacimiento, missing
     gen pais=substr(paisnacimiento,2,2)
     gen countrybirth=real(pais)
     recode countrybirth 99=.
     label values countrybirth countrylb
     label variable countrybirth "country of birth"
     tab countrybirth, missing
   }
 
   * current residence: province and municipality (first two digits identify province)

   gen provinceresidence = int(domicilio/1000)   
   
   * municipalities > 40 thousand inhabitants
   tab domicilio, missing
   recode domicilio 0=.
   ren domicilio municipality
   label values municipality municipalitylb
   tab municipality, missing

   * smaller municipalities have code province*1000
   label values municipality municipalitysmalllb
   label variable municipality "residence: municipality (or province, if small munic.)"
   tab municipality, missing

   * province: 1st affiliacion with SS, residence

   foreach v in affil1 residence {
      recode province`v' 0=.
      label values province`v' provincelb
      label variable province`v' "province of `v'"
      tab province`v', missing
   }
   label variable provinceaffil1 "province of 1st affiliation SSecurity"


   * province birth

   if year!=2004 {
      recode provincebirth 0=.
      label values provincebirth provincelb
      label variable provincebirth "province of birth"
      tab provincebirth, missing
   }

      * education
   if year!=2004 {
      tab educacion, missing
      replace educacion="" if educacion=="C0"
      gen education=real(educacion)
      tab education, missing
      label values education educationlb
      tab education, missing
   }

   if year!=2004 {
      keep    idperson year female datebirth datedeath nationality countrybirth municipality provinceresidence provincebirth provinceaffil1 education
      order   idperson year female datebirth datedeath nationality countrybirth municipality provinceresidence provincebirth provinceaffil1 education
      compress         year female datebirth datedeath nationality countrybirth municipality provinceresidence provincebirth provinceaffil1 education
   }
   else {
      keep    idperson year female datebirth datedeath nationality              municipality provinceresidence               provinceaffil1
      order   idperson year female datebirth datedeath nationality              municipality provinceresidence               provinceaffil1
      compress         year female datebirth datedeath nationality              municipality provinceresidence               provinceaffil1
   }
   describe
   sum 
   save ../mcvl_stata/MCVL`1'_personal.dta, replace
end
/* 1: year
   2: original file name
   3: original file extension */
readpersonal 2018 "PERSONAL_CDF" txt   
readpersonal 2017 "PERSONAL_CDF" txt   
readpersonal 2016 "PERSONAL_CDF" txt   
readpersonal 2015 "PERSONAL_CDF" txt   
readpersonal 2014 "PERSONAL_CDF" txt   
readpersonal 2013 "PERSONAL_CDF" txt
readpersonal 2012 "PERSONAL_CDF" txt
readpersonal 2011 "PERSONAL_CDF" TXT
readpersonal 2010 "_PERSONAL_CDF" TXT
readpersonal 2009 "_PERSONAL_CDF" TXT
readpersonal 2008 "_PERSANON"     trs
readpersonal 2007 "_PERSANON"     TRS
readpersonal 2006 "_PERSANON"     trs
readpersonal 2005 "_PERSANON"     trs
*/
*readpersonal 2004 "PERSANON"     txt


log close
exit, clear

