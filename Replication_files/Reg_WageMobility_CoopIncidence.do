

use ${path}\dta\workers_monthly.dta, clear

*Dependent variable: log daily income, log annual income, and log annual days
gen lnw = ln((WEincome_CHK + SEincome + OEincome)/(WEdays + SEdays + OEdays))

*Potential experience (in years)
gen pexp = year - pygrad 

drop *income* *days* legal* type* 

egen idspell = group(idperson idplant_new)
bys idspell (month_wobs): gen dur = _n

bys idspell (month_wobs): gen sep = _n == _N

replace sep = 0 if reason_endspell==0

gen sep_type = 0 if sep==0
replace sep_type = 1 if sep==1 & reason_endspell==51  // voluntary
replace sep_type = 2 if sep == 1 & (inlist(reason_endspell, 52, 54, 69, 77, 91, 92, 93, 94))
replace sep_type= 3  if sep==1 & sep_type!=1 & sep_type!=2 // other



*Control Variables
gen first_firm_age = pygrad - yofd(first_creation)
gen first_ftime = first_ptime>95
gen first_ms = first_skill>3 & first_skill<8
gen first_hs = first_skill>=1 & first_skill<=3

** Keep only variables needed
keep idperson year month month_wobs lnw coop_entry pexp pygrad provincebirth female educ first_firm_age first_sector1d first_ms first_hs first_ftime aexpWE_coop aexpWE sep_type

*Add unemployment rate
**LM Entry
gen quarter = quarter(mdy(1,1,pygrad))
gen provinceplant = provincebirth 
rename year y 
gen year = pygrad + 1
merge m:1 provinceplant year quarter using ${path}\dta\urqprov_1985_2018.dta, keepusing(urate) keep(match) nogen
drop quarter provinceplant year
rename y year
rename urate urate_t0
gen urate_t0_2= urate_t0*urate_t0
gen urate_t0_3 = urate_t0*urate_t0_2


bys idperson: egen max=max(aexpWE_coop)
bys idperson: egen max1=max(aexpWE)
*gen ratioexp_coop=max/max1

by idperson: gen obsnum = _n
gen ratioexp_coop=max/max1 if obsnum==1
egen ratioexp_coop2=max(ratioexp_coop), by(idperson)


*Split sample of coop_entry==1 por mediana 0.31
 

sum ratioexp_coop2 if coop_entry==1, d


gen coop_entry2=0 if coop_entry==0
replace coop_entry2 = 1 if coop_entry==1 & ratioexp_coop2>0 & ratioexp_coop2<=0.31
replace coop_entry2 = 2 if coop_entry==1 & ratioexp_coop2>0.31 & ratioexp_coop2<=1

reghdfe lnw i.coop_entry2  urate_t0 urate_t0_2 urate_t0_3 first_firm_age, absorb(female educ month year pexp pygrad provincebirth first_sector1d first_ms first_hs first_ftime ) cluster(provincebirth#pygrad) keepsing
outreg2 using ../tables/reg_coopentry_baseline_ratio_med2.tex , replace  keep(coop_entry2)  tex(frag) nocons dec(3)  nonotes label

mlogit sep_type i.coop_entry2 i.month i.pexp i.pygrad i.provincebirth urate_t0 urate_t0_2 urate_t0_3 first_firm_age i.educ female i.first_sector1d first_ms first_hs first_ftime, cluster(cluster) difficult ltol(0) tol(1e-6)  technique(bhhh 15 bfgs 5 bhhh 10 bfgs 10 bhhh 15 bfgs 15 nr 150) iter(232)
outreg2 using ../tables/reg_coopentry_baseline_ratio_med2.tex , append keep(coop_entry2)  tex(frag) nocons dec(3)  nonotes label
