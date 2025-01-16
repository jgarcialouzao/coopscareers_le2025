* STATA 16
* MCVL - Regressions: Robustness type of cooperative/sociedades laborales
* Jose Garcia-Louzao


clear all
capture log close
capture program drop _all
set more 1
set seed 13
set cformat %5.4f

/*
ssc install ftools, replace
ssc install reghdfe, replace
ssc install outreg2, replace
*/

*cap cd "C:\Users\busgbu\Dropbox\ScarringCoop (1)\Stata"

use ../dta/workers_monthly.dta, clear



*Dependent variable: log daily income, log annual income, and log annual days
gen lnw = ln((WEincome_CHK + SEincome + OEincome)/(WEdays + SEdays + OEdays))

*Potential experience (in years)
gen pexp = year - pygrad 

*Control Variables
gen first_firm_age = pygrad - yofd(first_creation)
gen first_ftime = first_ptime>95
gen first_ms = first_skill>3 & first_skill<8
gen first_hs = first_skill>=1 & first_skill<=3


gen coop_entry_b = 0
replace coop_entry_b = 1 if first_socialeco==2 & first_partner==0
replace coop_entry_b = 2 if first_socialeco==2 & first_partner==1

gen ls_entry= first_socialeco==3

gen coop_sl_entry= (coop_entry==1 | first_socialeco==3)
gen coop_entry_c = (first_socialeco==2 & first_type2plant==5161)




** Keep only variables needed
keep idperson year month month_wobs lnw coop_entry coop_entry_b coop_sl_entry ls_entry coop_entry_c pexp pygrad provincebirth female educ first_firm_age first_sector1d first_ms first_hs first_ftime first_partner first_socialeco


*Add unemployment rate
**LM Entry
gen quarter = quarter(mdy(1,1,pygrad))
gen provinceplant = provincebirth 
rename year y 
gen year = pygrad + 1
merge m:1 provinceplant year quarter using ../dta/urqprov_1985_2018.dta, keepusing(urate) keep(match) nogen
drop quarter provinceplant year
rename y year
rename urate urate_t0
gen urate_t0_2= urate_t0*urate_t0
gen urate_t0_3 = urate_t0*urate_t0_2


//Including entry at coop+sociedades laborales

reghdfe lnw coop_sl_entry  urate_t0 urate_t0_2 urate_t0_3 first_firm_age, absorb(female educ month year pexp pygrad provincebirth first_sector1d first_ms first_hs first_ftime ) cluster(provincebirth#pygrad) keepsing
outreg2 using ../tables/reg_coopentry_robust_cooptype.tex , replace keep(coop_sl_entry) ctitle("Including Labour Societies") tex(frag) nocons dec(3) nonotes label

**Only worker coops: legal code
reghdfe lnw coop_entry_c  urate_t0 urate_t0_2 urate_t0_3 first_firm_age, absorb(female educ month year pexp pygrad provincebirth first_sector1d first_ms first_hs first_ftime ) cluster(provincebirth#pygrad) keepsing
outreg2 using ../tables/reg_coopentry_robust_cooptype.tex , append keep(coop_entry_c) ctitle("Only worker coops") tex(frag) nocons dec(3) nonotes label


*Only worker coops: restricting to manufacturing
reghdfe lnw coop_entry urate_t0 urate_t0_2 urate_t0_3 first_firm_age if first_sector1d==2, absorb(female educ month year pexp pygrad provincebirth first_ms first_hs first_ftime ) cluster(provincebirth#pygrad) keepsing
outreg2 using ../tables/reg_coopentry_robust_cooptype.tex , append keep(coop_entry) ctitle("Only Manufacturing") tex(frag) nocons dec(3) nonotes label

*partners/employees
reghdfe lnw i.coop_entry_b urate_t0 urate_t0_2 urate_t0_3 first_firm_age, absorb(female educ month year pexp pygrad provincebirth first_sector1d first_ms first_hs first_ftime ) cluster(provincebirth#pygrad) keepsing
outreg2 using ../tables/reg_coopentry_robust_cooptype.tex , append keep(1.coop_entry_b 2.coop_entry_b) ctitle("Partners/employees") tex(frag) nocons dec(3) nonotes label



