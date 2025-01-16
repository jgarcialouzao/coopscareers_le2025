* STATA 14
* MCVL: Data preparation: Laboral data - Time-varying spell characteristics of job spells
* Jose Garcia-Louzao


clear all
capture log close
capture program drop _all
set more 1
set seed 13

log using ../logfiles/jobtvcharacteristics.log, replace


global y1 = 2018
global y2 = 2017

use year_mcvl idperson spellstart_date spellend_date idfirm idplant skill contract ptime D* type1plant type2plant regime reason_endspell using ../mcvl_stata/MCVL${y1}_laboral.dta, clear

*Drop spells with missing start or end date
drop if spellstart_date==. | spellend_date==.

*Drop spells with negative length
drop if spellend_date<spellstart_date

*Drop spells that refer to admin adjustments; not real employment spells
drop if reason_endspell==60 | reason_endspell==81

*Drop non-employment spells
drop if (type1plant > 749 & type1plant < 760) 
drop if type1plant==400 
drop if type2plant==4100 

*Drop other regimes that do not correspond to wage-employment relations
drop if (regime>=521 & regime<=540)
drop if regime==138 | regime==140 | regime==161 | regime==611 | regime==640 | regime==721 | regime==740 | regime==825 | regime==831 | regime==840 | regime==940 | regime==1211 | regime==1221 | regime==1240


*Drop spells that finished before start of the observation window
drop if spellend_date<mdy(1,1,2005)


forvalues y=$y2(-1)2005 {
append using ../mcvl_stata/MCVL`y'_laboral.dta, keep(year_mcvl idperson spellstart_date spellend_date idfirm idplant skill contract ptime D* type1plant type2plant regime reason_endspell)

*Drop spells with missing start or end date
drop if spellstart_date==. | spellend_date==.

*Drop spells with negative length
drop if spellend_date<spellstart_date

*Drop spells that refer to admin adjustments; not real employment spells
drop if reason_endspell==60 | reason_endspell==81

*Drop non-employment spells
drop if (type1plant > 749 & type1plant < 760) 
drop if type1plant==400 
drop if type2plant==4100 

*Drop other regimes that do not correspond to wage-employment relations
drop if (regime>=521 & regime<=540)
drop if regime==138 | regime==140 | regime==161 | regime==611 | regime==640 | regime==721 | regime==740 | regime==825 | regime==831 | regime==840 | regime==940 | regime==1211 | regime==1221 | regime==1240


*Drop spells that finished before start of the observation window
drop if spellend_date<mdy(1,1,2005)

}
keep year_mcvl idperson spellstart_date spellend_date idfirm idplant skill contract ptime D*

*rename time-varying variables
rename skill skill_tv
label variable skill_tv "skill (time-varying)"
rename ptime ptime_tv
label variable ptime_tv "ptime coefficient (time-varying)"
rename contract contract_tv
label variable contract_tv "type of contract (time-varying)"



*For on-going spells from one year to another adjust end date to the end of the current year
gen spellend_date_obs=mdy(12,31,year_mcvl) if spellend_date>mdy(12,31,year_mcvl)
replace spellend_date_obs=spellend_date if spellend_date_obs==.
format spellend_date_obs %td

*If observations is of a year when spell already finish, drop 
gen year_obs = yofd(spellend_date_obs)

drop if year_obs<year_mcvl


**Job characteristics hiring 
preserve 
*Starting year - unique for the first observed 
sort idperson spellstart_date spellend_date idplant year_mcvl
bys idperson spellstart_date idplant: gegen minyear = min(year_mcvl)
gen year_start = year_mcvl if year_mcvl == minyear
replace year_start = yofd(spellstart_date) if year_start!=yofd(spellstart_date) & year_start!=.
keep if year_start!=.
sort idperson idplant year_start year_mcvl spellend_date
bys idperson idplant year_start: keep if _n==1
save ../mcvl_stata/jobchar_entry.dta, replace
restore

*Keep last obs per worker-plant match
gen spellstart_date_obs=mdy(1,1,year_obs) if spellstart_date<mdy(1,1,year_obs)
replace spellstart_date_obs = spellstart_date if spellstart_date_obs ==.
format spell* %td

gen d = spellend_date_obs - spellstart_date_obs + 1 
replace ptime_tv = 100 if ptime_tv == . 
gen dptime = d*ptime

replace idfirm = idplant if idfirm==""

*could get a bit more of variation if exploit changes within contract 
*gegen rowmean = rowmean (D1ptime_oldptime D2ptime_oldptime)

gcollapse (sum) year_days = d dptime (lastnm) skill_tv contract_tv, by(idperson idplant year_obs)

gen ptime_tv = dptime / year_days

compress
save ../mcvl_stata/job_tvchar.dta, replace





