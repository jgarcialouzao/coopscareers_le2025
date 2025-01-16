
* STATA 16
* MCVL - Regressions: Robustness first job definition
* Jose Garcia-Louzao


clear all
capture log close
capture program drop _all
set more 1
set seed 13
set max_memory 200g
set segmentsize 3g
set cformat %5.4f

use ../dta/workers_monthly_firstjobspell100days.dta, clear

 
*Dependent variable: log daily income, log annual income, and log annual days
gen lnw = ln((WEincome_CHK + SEincome + OEincome)/(WEdays + SEdays + OEdays))

gen year = yofd(dofm(month_wobs)) 

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
gen year = pygrad + 1
merge m:1 provinceplant year quarter using ../dta/urqprov_1985_2018.dta, keepusing(urate) keep(match) nogen
drop quarter provinceplant year
rename y year
rename urate urate_t0
gen urate_t0_2= urate_t0*urate_t0
gen urate_t0_3 = urate_t0*urate_t0_2

reghdfe lnw coop_entry urate_t0 urate_t0_2 urate_t0_3 first_firm_age , absorb(female educ month year pexp pygrad provincebirth first_sector1d first_ms first_hs first_ftime) cluster(provincebirth#pygrad) keepsing
outreg2 using ../tables/reg_coopentry_robustness1.tex , replace keep(coop_entry) ctitle("Job spell 100 days") tex(frag) nocons dec(3)  nonotes label


use ../dta/workers_monthly_firstjob_180daysin12months.dta, clear

*Dependent variable: log daily income, log annual income, and log annual days
gen lnw = ln((WEincome_CHK + SEincome + OEincome)/(WEdays + SEdays + OEdays))

gen year = yofd(dofm(month_wobs)) 

*Potential experience (in years)
gen pexp = year - pygrad 

*Control Variables
gen first_firm_age = year - yofd(first_creation)
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
gen year = pygrad + 1
merge m:1 provinceplant year quarter using ../dta/urqprov_1985_2018.dta, keepusing(urate) keep(match) nogen
drop quarter provinceplant year
rename y year
rename urate urate_t0
gen urate_t0_2= urate_t0*urate_t0
gen urate_t0_3 = urate_t0*urate_t0_2

reghdfe lnw coop_entry urate_t0 urate_t0_2 urate_t0_3 first_firm_age , absorb(female educ month year pexp pygrad provincebirth first_sector1d first_ms first_hs first_ftime) cluster(provincebirth#pygrad) keepsing
outreg2 using ../tables/reg_coopentry_robustness1.tex , append keep(coop_entry) ctitle("180 days in 12 months") tex(frag) nocons dec(3) nonotes 



use ../dta/workers_monthly.dta, clear
drop if yofd(dofm(Efirst )) - pygrad > 3

*Dependent variable: log daily income, log annual income, and log annual days
gen lnw = ln((WEincome_CHK + SEincome + OEincome)/(WEdays + SEdays + OEdays))

*Potential experience (in years)
gen pexp = year - pygrad 

*Control Variables
gen first_firm_age = year - yofd(first_creation)
gen first_ftime = first_ptime>95
gen first_ms = first_skill>3 & first_skill<8
gen first_hs = first_skill>=1 & first_skill<=3

** Keep only variables needed
keep idperson year month month_wobs lnw coop_entry pexp pygrad provincebirth female educ first_firm_age first_sector1d first_ms first_hs first_ftime


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


reghdfe lnw coop_entry urate_t0 urate_t0_2 urate_t0_3 first_firm_age , absorb(female educ month year pexp pygrad provincebirth first_sector1d first_ms first_hs first_ftime) cluster(provincebirth#pygrad) keepsing
outreg2 using ../tables/reg_coopentry_robustness1.tex , append keep(coop_entry) ctitle("1st job within 3 years") tex(frag) nocons dec(3)  nonotes label

