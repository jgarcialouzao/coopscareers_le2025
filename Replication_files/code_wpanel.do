* STATA 14
* MCVL - Data preparation: Personal information
* Jose Garcia-Louzao
* Jan 2016

clear all
capture log close
capture program drop _all
set more 1
set seed 13


log using ../logfiles/workerpanel.log, replace


global y1 = 2018


*Append year files
use ../mcvl_stata/MCVL2005_personal.dta, clear
forvalues y=2006(1)$y1 {
append using ../mcvl_stata/MCVL`y'_personal.dta
}
sort idperson year

*Check for duplicate idperson-year observations
*Drop age out of legal boundaries to work
bys idperson year: gen dup = _N
bys year: gen age = year - year(datebirth)
drop if dup>1 & (age<16 | age>65)
drop dup  age
*Some individuals appear twice, varying the amount of information available, drop missing
bys idperson year: gen dup = _N
drop if (dup > 1) & (datebirth==. | female==. | nationality==. | countrybirth==. | provinceresidence==. | provincebirth==. | provinceaffil1==.)
drop dup
*Some repeats refer to rare individuals s.th. ID number still in use prior to computerisation of ID records - drop all of them (very few observations
bys idperson year: gen dup = _N
drop if dup>1
drop dup 

*Balance the panel	
egen tmp=group(idperson)
xtset tmp year
tsfill, full

gsort tmp -year
bys tmp: replace idperson=idperson[_n-1] if idperson==""
sort tmp year
bys tmp: replace idperson=idperson[_n-1] if idperson==""

drop tmp
	
*Assign missing variables using longitudinal dimension of the data	
foreach var in female datebirth nationality countrybirth municipality provinceresidence provincebirth provinceaffil1 {
gsort idperson -year
bys idperson: replace `var'=`var'[_n-1] if `var'==.
sort idperson year
bys idperson: replace `var'=`var'[_n-1] if `var'==.
}
*Some individuals report Spanish nationality in the early years, and then it changes to be non-Spaniards.. in those cases, assign latest nationality reported
recode nationality 0=.
gsort idperson -year
bys idperson: replace nationality = nationality[_n-1] if nationality==.
recode nationality .=0

*Correct inconsistencies in individual time-invariant variables - assign mode
foreach var in female datebirth countrybirth provincebirth provinceaffil1 {
bys idperson: egen mode_`var'=mode(`var'), maxmode
replace `var'=mode_`var'
}
format datebirth %td
drop mode_*

*Set coding errors to missing in education variable (see documentation)
replace education = . if (education >  0 & education < 10) | (education > 11 & education < 20)
replace education = . if (education > 22 & education < 30) | (education > 32 & education < 40) | education > 48

*Impute backwards education using most recent data - set age 25 as threshold for tertiary education (education>=44)
gen age = year - yofd(datebirth)

qui g negtime = -year
qui bys idperson (negtime):  replace education=education[_n-1] if education[_n-1]!=. & (education[_n-1]>=education | education==.) & age>=25
qui bys idperson (negtime):  replace education=education[_n-1] if education[_n-1]!=. & education==. & education[_n-1]<44 &  age<25
qui bys idperson (negtime):  replace education=40 if education[_n-1]!=.  & education==. & education[_n-1]>=44 &  age<25

bys idperson (year): replace education=education[_n-1] if education==. 
*Correct some typos: individuals with lower educational attainment as they become older
bys idperson (year): replace education=education[_n-1] if education[_n-1]!=. & education[_n-1]>education & age[_n-1]<age
*Use longitudinal dimension to recover missing education using closest education observed
foreach var in education {
bys idperson (negtime): replace `var'=`var'[_n-1] if `var'==.
}
*Before 22 workers cannot have tertiary education, set the education to previous level
bys idperson (negtime): replace education=40 if education>=44 &  age<22 & education!=.
rename year year_mcvl
drop negtime age

sort idperson year_mcvl
save ../mcvl_stata/wpanel.dta, replace


/*
*Add information on household members
preserve
use ../mcvl_stata/MCVL2005_conviv.dta, clear
forvalues y=2006(1)2016 {
append using ../mcvl_stata/MCVL`y'_conviv.dta
}
*Drop duplicates in terms of 4 unique variables
bys idperson year_mcvl female birthdate: gen nobs = _n
drop if nobs>1
save ../mcvl_stata/hhmembers.dta, replace
restore

gen birthdate = datebirth
merge 1:1 idperson year_mcvl birthdate female using ../mcvl_stata/hhmembers.dta 

save ../mcvl_stata/individual_hh.dta, replace

exit, clear







