* STATA 16
* MCVL - Create worker panel
* Jose Garcia-Louzao

clear all
capture log close
capture program drop _all
set more 1
set seed 13
set segmentsize 3g
set niceness 10

*Last MCVL year
global maxy = 2018

use  ${path}/dta/wpanel.dta, clear

*Valid info on personal traits
qui drop if datebirth==. | female==. | (nationality==. & countrybirth==. & provincebirth==.) | education == .

*Only Spanish born cohorts
qui drop if countrybirth!=0 | nationality!=0
drop datedeath countrybirth nationality year_mcvl

*Drop inviduals born in Ceuta/Melilla
qui drop if provincebirth>50

*Set education to max level to define graduation
qui bys idperson: egen max=max(education)
qui replace education = max // highest education attainment
qui drop max

*Education categories
qui g educ=.
qui replace educ=1 if education<=32
qui replace educ=2 if education>=40 & education<=43
qui replace educ=3 if education>=44 & education!=.
label define educlb 0 "Missing ed." 1 "Primary ed. (or less)" 2 "Secondary ed." 3 "Tertiary ed.", modify
label values educ educlb
qui drop education

*Predicted graduation year 
*Education specific, refers to the year when they turn the official graduation age
*We follow workers after that year
qui gen pygrad = .
qui replace pygrad  = yofd(datebirth) + 16 if educ==1
qui replace pygrad  = yofd(datebirth) + 18 if educ==2
qui replace pygrad  = yofd(datebirth) + 23 if educ==3


*Keep graduation cohorts to follow them for 15 years
qui keep if pygrad>=1984 & pygrad<=2003

bys idperson: keep if _n == 1

*Regular wage-employment
merge 1:m idperson  using  ${path}/dta/contempspells.dta, keep(match)
drop _m
gen status = 1

*Firm info and embedded restrictions
merge m:1 idplant using  ${path}/dta/firms.dta , keep(match) keepusing(creation_date provinceplant sector1d socialeco partner legal* type*)
qui drop _m

*Add other employment spells (self-employment and other regimes)
append using ../dta/contotherspells.dta
replace status = 2 if (regime>=521 & regime<=540)
replace status = 3 if status==.

**Add unemployment spells
append using  ${path}/dta/contuispells.dta
replace status = 4 if ui==1
drop ui

label define statuslb 1 "Wage-Employment" 2 "Self-Employment" 3 "Other Employment Forms" 4 "Unemploment Insurance", modify
label values status statuslb
label var status "LM Status"

drop coop soleprop_we coop_we coop_worker_we coop_partner_we ls_we ls_worker_we ls_partner_we kfirm_we

foreach v in pygrad educ datebirth provincebirth female  {
bys idperson (`v'): replace `v' = `v'[1] if `v'==.
}

*Drop spells starting after last year in the data
drop if spellstart_date>mdy(12,31,$maxy)

*Remove any spell that occur before graduation
drop if yofd(spellstart_date)<=pygrad

*Create idspell
gegen idspell = group(idperson spellstart_date spellend_date idplant)
gegen idplant_new = group(idplant)

**Transform dataset to individual-spell-month format
qui gen month_startspell=mofd(spellstart_date)
qui gen month_endspell=mofd(spellend_date)
qui replace month_endspell = mofd(mdy(12,31,$maxy)) if spellend_date > mdy(12,31,$maxy)

*Number of monthly observations to be expanded
qui gen nobs_spellmonth = (month_endspell - month_startspell) + 1

compress

foreach y in 1984 1997 {
preserve
keep if pygrad>=`y' & pygrad<`y'+13

expand nobs_spellmonth

*Monthly variable
qui gen month_wobs=month_startspell
qui bys idspell (month_wobs): replace month_wobs = month_wobs + _n - 1
qui format month_wobs %tm
qui drop month_start* month_end* nobs_*

qui gen time = yofd(dofm(month_wobs)) - pygrad
drop if time>15
drop time

*Count days worked in a month
*First and last day of a month
gen first=dofm(month_wobs)
gen last=dofm(month_wobs + 1) - 1

gen 	days = .
replace days = spellend_date - first + 1 if spellstart_date<=first & spellend_date<last
replace days = last - spellstart_date + 1 if spellstart_date>first & spellend_date>=last
replace days = spellend_date - spellstart_date + 1  if spellstart_date>first & spellend_date<last

*SS computes month-daily caps by dividing by 360 days per year - 30 days each month
replace days = 30 if spellstart_date<=first & spellend_date>=last
drop first last 

qui gen tmp = mofd(spellstart_old)
gen idplant_final = idplant
foreach v in idplant skill ptime contract {
qui replace `v'= `v'_start if month_wobs<tmp
}
replace idplant = idplant_final if idplant==""
qui drop tmp 

*Earnings are reported in a monthly basis for worker-plant matches - if more than one spell with the same employer in a given month, then collapse days and keep last obs
bys idperson idplant month_wobs: gegen tmp = total(days)
bys idperson idplant month_wobs: gen nobs = _N
replace days = tmp if nobs>1
replace days = 30 if days>30  & days!=.
bys idperson idplant month_wobs (spellend_date): keep if _n == _N
drop tmp nobs* 

*Add monthly income
merge 1:1 idperson idplant month_wobs using  ${path}/dta/selfemp_wages19802018.dta, keep(1 3) keepusing(w)
qui drop _m
qui rename w selfempw
merge 1:1 idperson idplant month_wobs using  ${path}/dta/wages_m19802004.dta, keep(1 3) keepusing(w)
qui drop _m
qui rename w w8404
merge 1:1 idperson idplant month_wobs using  ${path}/dta/wages_m20052018.dta, keep(1 3) keepusing(w)
qui drop _m
qui gen monthlyw = w8404 if yofd(dofm(month_wobs))<2005 
qui replace monthlyw = w if  yofd(dofm(month_wobs))>=2005 
qui replace monthlyw = selfempw if monthlyw==.
qui drop w8404 w selfempw
qui replace monthlyw=. if monthlyw<1
*Recover missing information on wages if we have consecutive observations within same plant
gen negmobs = -month_wobs
qui bys idperson (month_wobs): replace monthlyw = monthlyw[_n-1]   if monthlyw==.   & idfirm==idfirm[_n-1] & status!=4 & status[_n-1]!=4
qui bys idperson (negmobs):    replace monthlyw = monthlyw[_n-1]   if monthlyw==.   & idfirm==idfirm[_n-1] & status!=4 & status[_n-1]!=4
qui drop negmobs

*Real terms
qui merge m:1 month_wobs using   ${path}/dta/cpi2018m.dta, keep(1 3) keepusing(cpi2018)
qui drop _m 
qui replace monthlyw = monthlyw/(cpi2018/100)
keep if monthlyw>1 & monthlyw<.

*Censored earnings
gen year = yofd(dofm(month_wobs))
gen month = month(dofm(month_wobs))
gen group = skill
merge m:1 year month group using  ${path}/dta/realbounds.dta, nogen keep (1 3)
gen topcoded = monthlyw>=max_base & monthlyw<. & status==1
replace monthlyw = max_base if topcoded==1
*Daily wages
qui gen dailyw = monthlyw/days
qui replace dailyw = max_base/30 if dailyw>=max_base/30 & dailyw<.

*Corrected earnings
merge 1:1 idperson idplant month_wobs using  ${path}/dta/simwages_CHK.dta, nogen keep(1 3)
qui gen monthlyw_CHK = dailyw_CHK*days
qui replace monthlyw_CHK = monthlyw if monthlyw_CHK == . & monthlyw!=.
replace dailyw_CHK = dailyw if dailyw_CHK==. & dailyw!=.


/*
qui replace idplant = idplant_final
qui drop idplant_final idplant_start
*/

*If more than one observation in a month, keep main employer (wage-employment observation, highest earnings, highest working days) but add-up days and income -- differentiate between employment types
bys idperson month_wobs: gen nobs = _N
bys idperson month_wobs status: egen total= total(days)
replace total = 30 if total>30
gen WEdays = total if status==1
gen SEdays = total if status==2
gen OEdays = total if status==3
gen UIdays = total if status==4

foreach v in UI WE OE SE {
replace `v'days = 0 if `v'days==.	
}

replace days = 0 if status==4
bys idperson month_wobs: egen Edays = total(days)
replace Edays = 30 if Edays>30 & status!=4
drop total
bys idperson month_wobs status: egen income = total(monthlyw)
gen WEincome = income if status==1
gen SEincome = income if status==2
gen OEincome = income if status==3
gen UIincome = income if status==4

foreach v in UI WE OE SE {
replace `v'income= 0 if `v'income==.	
}

bys idperson month_wobs status: egen income_CHK = total(monthlyw_CHK)
gen WEincome_CHK = income_CHK if status==1
replace WEincome_CHK= 0 if WEincome_CHK==.	
bys idperson month_wobs: egen censored = total(topcoded)
drop income income_CHK

bys idperson month_wobs: egen Eincome= total(monthlyw)
drop if nobs>1 & status!=1
drop nobs 
bys idperson month_wobs: gen nobs = _N
bys idperson month_wobs: egen max = max(monthlyw)
drop if nobs>1 & monthlyw!=max
drop nobs max monthlyw
bys idperson month_wobs: gen nobs = _N
bys idperson month_wobs: egen max = max(days)
drop if nobs>1 & days!=max
drop nobs max days
bys idperson month_wobs (spellend_date): keep if _n == _N

*Add size of first employment
gen year_mcvl = yofd(dofm(month_wobs)) 
replace year_mcvl = 2005 if year_mcvl<2005
merge m:1 idplant year_mcvl using  ${path}./dta/fpanel.dta, keepusing(size) keep(1 3)
drop year_mcvl _merge cpi

compress

save  ${path}/dta/fullpanel_pygrad`y'.dta, replace
restore
}
