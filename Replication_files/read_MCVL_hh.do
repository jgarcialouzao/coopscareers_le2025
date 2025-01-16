* STATA 12
* READ_MCVL_CONV_JGL.DO (READ ORIGINAL MCVL IN ASCII - CONVIVIENTES/HOUSEHOLD MEMBERS)
* Jose Garcia-Louzao
* Sep 2015

clear all
capture log close
capture program drop _all
set more 1

log using logs\read_MCVL_hh.log, replace


program define check
     list in 1/10, abbrev(4)
     sum
     describe
end

program define readconviv

if `1'==2018 | `1'==2017 | `1'==2016 | `1'==2015 | `1'==2014 | `1'==2013 | `1'==2012 | `1'==2011 | `1'==2010 | `1'==2009 | `1'==2008 | `1'==2007 | `1'==2006 | `1'==2005 {

infix str15 idperson 1-15 str6 nacimiento 17-22 sexo 24 str6 nacimiento1 26-31 sexo1 33 str6 nacimiento2 35-40 sexo2 42 str6 nacimiento3 44-49 sexo3 51 str6 nacimiento4 53-58 sexo4 60 str6 nacimiento5 62-67 sexo5 69 str6 nacimiento6 71-76 sexo6 78 str6 nacimiento7 80-85 sexo7 87 str6 nacimiento8 89-94 sexo8 96 str6 nacimiento9 98-103 sexo9 105 using ../mcvl_orig/MCVL`1'`2'.`3', clear

}

gen year_mcvl=`1'
label variable year_mcvl  "year when person was sampled/observed"
check

*person ID 
codebook idperson
label variable idperson "person ID"
duplicates list, abbrev(4)
duplicates drop
bys idperson: gen Nobs=_N
tab Nobs

*!!!JGL: the birth date of some (less 1%) the sampled individual is strange 
*birth date of sampled individual
codebook nacimiento
replace nacimiento="" if nacimiento=="000000"
gen birthdate=date(nacimiento, "YM")
format birthdate %td
label variable birthdate "date of birth"
tab birthdate, missing
gen yearbirth=year(birthdate)
tab yearbirth, missing
gen monthbirth=month(birthdate)
tab monthbirth, missing

*gender
tab sexo, missing
ren sexo female
recode female 1=0 2=1
tab female, missing


*!!!JGL: when cleaning the data we have to look carefully at birth dates. For instance, in 2013 there are members of HH born in 2014.
*birth date of HH member #1
codebook nacimiento1
replace nacimiento1="" if nacimiento1=="000000"
gen birthdate1=date(nacimiento1, "YM")
format birthdate1 %td
label variable birthdate1 "date of birth of HH member #1"
tab birthdate1, missing
gen yearbirth1=year(birthdate1)
tab yearbirth1, missing
gen monthbirth1=month(birthdate1)
tab monthbirth1, missing

*gender of HH member #1
tab sexo1, missing
ren sexo1 female1
recode female1 1=0 2=1
tab female1, missing

*birth date of HH member #2
codebook nacimiento2
replace nacimiento2="" if nacimiento2=="000000"
gen birthdate2=date(nacimiento2, "YM")
format birthdate2 %td
label variable birthdate2 "date of birth of HH member #2"
tab birthdate2, missing
gen yearbirth2=year(birthdate2)
tab yearbirth2, missing
gen monthbirth2=month(birthdate2)
tab monthbirth2, missing

*gender of HH member #2
tab sexo2, missing
ren sexo2 female2
recode female2 1=0 2=1
tab female2, missing

*birth date of HH member #3
codebook nacimiento3
replace nacimiento3="" if nacimiento3=="000000"
gen birthdate3=date(nacimiento3, "YM")
format birthdate3 %td
label variable birthdate3 "date of birth of HH member #3"
tab birthdate3, missing
gen yearbirth3=year(birthdate3)
tab yearbirth3, missing
gen monthbirth3=month(birthdate3)
tab monthbirth3, missing

*gender of HH member #3
tab sexo3, missing
ren sexo3 female3
recode female3 1=0 2=1
tab female3, missing

*birth date of HH member #4
codebook nacimiento4
replace nacimiento4="" if nacimiento4=="000000"
gen birthdate4=date(nacimiento4, "YM")
format birthdate4 %td
label variable birthdate4 "date of birth of HH member #4"
tab birthdate4, missing
gen yearbirth4=year(birthdate4)
tab yearbirth4, missing
gen monthbirth4=month(birthdate4)
tab monthbirth4, missing

*gender of HH member #4
tab sexo4, missing
ren sexo4 female4
recode female4 1=0 2=1
tab female4, missing

*birth date of HH member #5
codebook nacimiento5
replace nacimiento5="" if nacimiento5=="000000"
gen birthdate5=date(nacimiento5, "YM")
format birthdate5 %td
label variable birthdate5 "date of birth of HH member #5"
tab birthdate5, missing
gen yearbirth5=year(birthdate5)
tab yearbirth5, missing
gen monthbirth5=month(birthdate5)
tab monthbirth5, missing

*gender of HH member #5
tab sexo5, missing
ren sexo5 female5
recode female5 1=0 2=1
tab female5, missing

*birth date of HH member #6
codebook nacimiento6
replace nacimiento6="" if nacimiento6=="000000"
gen birthdate6=date(nacimiento6, "YM")
format birthdate6 %td
label variable birthdate6 "date of birth of HH member #6"
tab birthdate6, missing
gen yearbirth6=year(birthdate6)
tab yearbirth6, missing
gen monthbirth6=month(birthdate6)
tab monthbirth6, missing

*gender of HH member #6
tab sexo6, missing
ren sexo6 female6
recode female6 1=0 2=1
tab female6, missing

*birth date of HH member #7
codebook nacimiento7
replace nacimiento7="" if nacimiento7=="000000"
gen birthdate7=date(nacimiento7, "YM")
format birthdate7 %td
label variable birthdate7 "date of birth of HH member #7"
tab birthdate7, missing
gen yearbirth7=year(birthdate7)
tab yearbirth7, missing
gen monthbirth7=month(birthdate7)
tab monthbirth7, missing

*gender of HH member #7
tab sexo7, missing
ren sexo7 female7
recode female7 1=0 2=1
tab female7, missing

*birth date of HH member #8
codebook nacimiento8
replace nacimiento8="" if nacimiento8=="000000"
gen birthdate8=date(nacimiento8, "YM")
format birthdate8 %td
label variable birthdate8 "date of birth of HH member #8"
tab birthdate8, missing
gen yearbirth8=year(birthdate8)
tab yearbirth8, missing
gen monthbirth8=month(birthdate8)
tab monthbirth8, missing

*gender of HH member #8
tab sexo8, missing
ren sexo8 female8
recode female8 1=0 2=1
tab female8, missing

*birth date of HH member #9
codebook nacimiento9
replace nacimiento9="" if nacimiento9=="000000"
gen birthdate9=date(nacimiento9, "YM")
format birthdate9 %td
label variable birthdate9 "date of birth of HH member #9"
tab birthdate9, missing
gen yearbirth9=year(birthdate9)
tab yearbirth9, missing
gen monthbirth9=month(birthdate9)
tab monthbirth9, missing

*gender of HH member #9
tab sexo9, missing
ren sexo9 female9
recode female9 1=0 2=1
tab female9, missing   



keep  idperson year_mcvl female birthdate female1 birthdate1 female2 birthdate2 female3 birthdate3 female4 birthdate4 female5 birthdate5 female6 birthdate6 female7 birthdate7 female8 birthdate female9 birthdate9 
order idperson year_mcvl female birthdate female1 birthdate1 female2 birthdate2 female3 birthdate3 female4 birthdate4 female5 birthdate5 female6 birthdate6 female7 birthdate7 female8 birthdate female9 birthdate9 
compress       year_mcvl female birthdate female1 birthdate1 female2 birthdate2 female3 birthdate3 female4 birthdate4 female5 birthdate5 female6 birthdate6 female7 birthdate7 female8 birthdate female9 birthdate9  
  
  describe
  sum 
  save ../mcvl_stata/MCVL`1'_conviv.dta, replace

end 

readconviv 2018 "CONVIVIR_CDF" txt
readconviv 2017 "CONVIVIR_CDF" txt
readconviv 2016 "CONVIVIR_CDF" txt
readconviv 2015 "CONVIVIR_CDF" txt
readconviv 2014 "CONVIVIR_CDF" txt
readconviv 2013 "CONVIVIR_CDF" txt
readconviv 2012 "CONVIVIR_CDF" txt
readconviv 2011 "CONVIVIR_CDF" txt
readconviv 2010 "_CONVIVIR_CDF" txt
readconviv 2009 "_CONVIVIR_CDF" txt
readconviv 2008 "_CONVIVI" trs
readconviv 2007 "_CONVIVI" trs
readconviv 2006 "_CONVIVI" trs
readconviv 2005 "_CONVIVI" trs


log close
exit, clear
