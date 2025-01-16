* STATA 14
* MCVL - Data preparation: SS contributions information (earnings)
* Jose Garcia-Louzao

clear all
capture log close
capture program drop _all
set more 1
set seed 13

log using ../logfiles/laborincome.log, replace

global y1 = 2018
global y2 = 2017

**Group wage-information
use ../mcvl_stata/MCVL${y1}_wages.dta
forvalues y=$y2(-1)2005 {
merge 1:1 idperson idplant year_w using ../mcvl_stata/MCVL`y'_wages.dta
drop _merge
}

sort idperson idplant year_w 
keep if year_w>=1980 & year_w<=2018
save ../mcvl_stata/MCVL_wages.dta, replace


** Transform yearly panel to monthly panel - (2005-2016)
use ../mcvl_stata/MCVL_wages.dta, clear

drop wtot Nobs_w 

keep if year_w>=2005 & year_w<=2018

*Create unit to reshape data to get monthly observations
egen double unit=group(idperson idplant year_w)

fastreshape long w, i(unit) j(month_w) string

recode w 0=.

drop if w==.

*Create year-month date 
gen str tmp_month = month_w + string(year_w)
gen tmp_month2= date(tmp_month, "MY")
gen month_wobs = mofd(tmp_month2)
format month_wobs %tm
drop tmp* unit month_w 

compress 

save ../mcvl_stata/wages_m20052018.dta, replace


** Transform yearly panel to monthly panel - (1980-2004)
use ../mcvl_stata/MCVL_wages.dta, clear

drop wtot Nobs_w

keep if year_w>=1980 & year_w<=2004

*Create unit to reshape data to get monthly observations
egen double unit=group(idperson idplant year_w)

fastreshape long w, i(unit) j(month_w) string

recode w 0=.

drop if w==.

*Create year-month date 
gen str tmp_month = month_w + string(year_w)
gen tmp_month2= date(tmp_month, "MY")
gen month_wobs = mofd(tmp_month2)
format month_wobs %tm
drop tmp* unit month_w 

compress

save ../mcvl_stata/wages_m19802004.dta, replace


*Append files
use ../mcvl_stata/wages_m20052018.dta, clear
append using ../mcvl_stata/wages_m19802004.dta

save ../mcvl_stata/monthwages.dta, replace


log close
exit, clear


