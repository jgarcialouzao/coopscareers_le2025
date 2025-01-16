
use ${path}/dta/workers_monthly.dta, clear
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
merge m:1 provinceplant year quarter using ${path}/dta/urqprov_1985_2018.dta, keepusing(urate) keep(match) nogen
drop quarter provinceplant year
rename y year
rename urate urate_t0
gen urate_t0_2= urate_t0*urate_t0
gen urate_t0_3 = urate_t0*urate_t0_2


**Worker Demographics
reghdfe lnw coop_entry urate_t0 urate_t0_2 urate_t0_3 first_firm_age if female==0, absorb(educ month year pexp pygrad provincebirth first_sector1d first_ms first_hs first_ftime) cluster(provincebirth#pygrad)
outreg2 using ${path}/tables/reg_coopentry_heterogeneity_wrkdemog.tex , replace keep(coop_entry) ctitle("Men")  tex(frag) nocons dec(3)  nonotes label

reghdfe lnw coop_entry urate_t0 urate_t0_2 urate_t0_3 first_firm_age if female==1, absorb(educ month year pexp pygrad provincebirth first_sector1d first_ms first_hs first_ftime) cluster(provincebirth#pygrad)
outreg2 using ${path}/tables/reg_coopentry_heterogeneity_wrkdemog.tex , append keep(coop_entry) ctitle("Women")  tex(frag) nocons dec(3)  nonotes label


reghdfe lnw coop_entry urate_t0 urate_t0_2 urate_t0_3 first_firm_age if educ!=3, absorb(female month year pexp pygrad provincebirth first_sector1d first_ms first_hs first_ftime) cluster(provincebirth#pygrad)
outreg2 using ${path}/tables/reg_coopentry_heterogeneity_wrkdemog.tex , append keep(coop_entry) ctitle("Non-College")  tex(frag) nocons dec(3)  nonotes label

reghdfe lnw coop_entry urate_t0 urate_t0_2 urate_t0_3 first_firm_age if educ==3, absorb(female month year pexp pygrad provincebirth first_sector1d first_ms first_hs first_ftime) cluster(provincebirth#pygrad)
outreg2 using ${path}/tables/reg_coopentry_heterogeneity_wrkdemog.tex , append keep(coop_entry) ctitle("College")  tex(frag) nocons dec(3)  nonotes label


