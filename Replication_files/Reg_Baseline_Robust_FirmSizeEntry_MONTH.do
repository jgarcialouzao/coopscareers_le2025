* STATA 16
* MCVL - Regressions - Robustness


clear all
capture log close
capture program drop _all
set more 1
set seed 13
set max_memory 200g
set segmentsize 3g
set cformat %5.4f




use ../dta/workers_monthly.dta, clear
keep if pygrad>=1999
*Dependent variable: log daily income, log annual income, and log annual days
gen lnw = ln((WEincome_CHK + SEincome + OEincome)/(WEdays + SEdays + OEdays))

*Potential experience (in years)
gen pexp = year - pygrad 

*Control Variables
gen first_firm_age = pygrad - yofd(first_creation)
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

reghdfe lnw coop_entry  urate_t0 urate_t0_2 urate_t0_3 first_firm_age, absorb(female educ month year pexp pygrad provincebirth first_sector1d first_ms first_hs first_ftime ) cluster(provincebirth#pygrad) keepsing
outreg2 using ../tables/reg_coopentry_robustness_fsize.tex , replace keep(coop_entry) ctitle("Cohorts_1999-2003") tex(frag) nocons dec(3) nonotes label


**Firm size: workers who are observed first time during a period when we have firm size information
*Selected-sample, the coefficients are substantially different to the baseline or even the same cohort groups without restricting the period when they are observed first time. Why??
use ../dta/workers_monthly.dta, clear
keep if yofd(dofm(Efirst))>2004

*Add size of first employment
gen year_mcvl = yofd(dofm(Efirst)) 
replace year_mcvl = . if year_mcvl<2004
rename idplant idplant_tmp
gen idplant = idplant_tmp if idplant_new == first_idplant
bys idperson (month_wobs): replace idplant = idplant[_n-1] if idplant==""
drop *size*
merge m:1 idplant year_mcvl using ../dta/fpanel.dta, keepusing(size) keep(matched)
drop year_mcvl _merge 

gen logsize = ln(size+1)
drop year
gen year = yofd(dofm(month_wobs))
egen idfirm_new = group(idfirm)


*Dependent variable: log daily income, log annual income, and log annual days
gen lnw = ln((WEincome_CHK + SEincome + OEincome)/(WEdays + SEdays + OEdays))

*Potential experience (in years)
gen pexp = year - pygrad 

*Control Variables
gen first_firm_age = pygrad - yofd(first_creation)
gen first_ftime = first_ptime>95
gen first_ms = first_skill>3 & first_skill<8
gen first_hs = first_skill>=1 & first_skill<=3

** Keep only variables needed
keep idperson year month month_wobs lnw coop_entry pexp pygrad provincebirth female educ first_firm_age first_sector1d first_ms first_hs first_ftime logsize


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

reghdfe lnw coop_entry  urate_t0 urate_t0_2 urate_t0_3 first_firm_age, absorb(female educ month year pexp pygrad provincebirth first_sector1d first_ms first_hs first_ftime ) cluster(provincebirth#pygrad) keepsing
outreg2 using ../tables/reg_coopentry_robustness_fsize.tex , append keep(coop_entry) ctitle("Cohorts_1999-2003: First job after 2004") tex(frag) nocons dec(3)  nonotes label

reghdfe lnw coop_entry  urate_t0 urate_t0_2 urate_t0_3 first_firm_age logsize, absorb(female educ month year pexp pygrad provincebirth first_sector1d first_ms first_hs first_ftime ) cluster(provincebirth#pygrad) keepsing
outreg2 using ../tables/reg_coopentry_robustness_fsize.tex , append keep(coop_entry logsize) ctitle("Cohorts_1999-2003: First job after 2004 + Firm Size Entry") tex(frag) nocons dec(3)  nonotes label
