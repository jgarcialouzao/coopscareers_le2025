* STATA 16
* MCVL - Regressions robustness to censoring
* Jose Garcia-Louzao


clear all
capture log close
capture program drop _all
set more 1
set seed 13
set max_memory 200g
set segmentsize 3g
set cformat %5.4f

/*
ssc install ftools, replace
ssc install reghdfe, replace
ssc install outreg2, replace
*/

use ../dta/workers_monthly.dta, clear

*Dependent variable: log daily income, log annual income, and log annual days
gen lnw_CHK = ln((WEincome_CHK + SEincome + OEincome)/(WEdays + SEdays + OEdays))
gen lnw = ln((WEincome + SEincome + OEincome)/(WEdays + SEdays + OEdays))

*Potential experience (in years)
gen pexp = year - pygrad 

*Control Variables
gen first_firm_age = pygrad - yofd(first_creation)
gen first_ftime = first_ptime>95
gen first_ms = first_skill>3 & first_skill<8
gen first_hs = first_skill>=1 & first_skill<=3

** Keep only variables needed
keep idperson year month month_wobs lnw* coop_entry pexp pygrad provincebirth female educ first_firm_age first_sector1d first_ms first_hs first_ftime censored topcoded

*Add unemployment rate
**LM Entry
gen quarter = quarter(mdy(1,1,pygrad))
gen provinceplant = provincebirth 
rename year y 
gen year = pygrad +1
merge m:1 provinceplant year quarter using ../dta/urqprov_1985_2018.dta, keepusing(urate) keep(match) nogen
drop quarter provinceplant year
rename y year
rename urate urate_t0
gen urate_t0_2= urate_t0*urate_t0
gen urate_t0_3 = urate_t0*urate_t0_2




reghdfe lnw_CHK coop_entry urate_t0 urate_t0_2 urate_t0_3 first_firm_age,  absorb(female educ month year pexp pygrad provincebirth first_sector1d first_ms first_hs first_ftime ) cluster(provincebirth#pygrad) keepsing
outreg2 using ../tables/reg_coopentry_robustness_cens.tex , replace keep(coop_entry) ctitle("Corrected")  tex(frag) nocons dec(3)  nonotes label

reghdfe lnw coop_entry urate_t0 urate_t0_2 urate_t0_3 first_firm_age,  absorb(female educ month  year pexp pygrad provincebirth first_sector1d first_ms first_hs first_ftime ) cluster(provincebirth#pygrad) keepsing
outreg2 using ../tables/reg_coopentry_robustness_cens.tex , append keep(coop_entry) ctitle("Censored")  tex(frag) nocons dec(3)  nonotes label

reghdfe lnw coop_entry urate_t0 urate_t0_2 urate_t0_3 first_firm_age if censored==0, absorb(female educ month  year pexp pygrad provincebirth first_sector1d first_ms first_hs first_ftime ) cluster(provincebirth#pygrad) keepsing
outreg2 using ../tables/reg_coopentry_robustness_cens.tex , append keep(coop_entry)   tex(frag) ctitle("No censored") nocons dec(3)  nonotes label

reghdfe lnw coop_entry urate_t0 urate_t0_2 urate_t0_3 first_firm_age if topcoded==0, absorb(female educ month  year pexp pygrad provincebirth first_sector1d first_ms first_hs first_ftime ) cluster(provincebirth#pygrad) keepsing
outreg2 using ../tables/reg_coopentry_robustness_cens.tex , append keep(coop_entry)   tex(frag) ctitle("No censored main job") nocons dec(3)  nonotes label





