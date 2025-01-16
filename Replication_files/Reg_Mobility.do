
** MOBILITY
use ../dta/workers_monthly.dta, clear
drop if status==4

gen lnw = ln((WEincome_CHK + SEincome + OEincome)/(WEdays + SEdays + OEdays))
keep if lnw!=.

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

gen pexp = year - pygrad

*Add unemployment rate
**LM Entry
gen quarter = quarter(mdy(1,1,pygrad))
drop provinceplant
gen provinceplant = provincebirth 
rename year y 
gen year = pygrad + 1
merge m:1 provinceplant year quarter using ${path}\tables\urqprov_1985_2018.dta, keepusing(urate) keep(match) nogen
drop quarter provinceplant year
rename y year
rename urate urate_t0
gen urate_t0_2= urate_t0*urate_t0
gen urate_t0_3 = urate_t0*urate_t0_2


** Keep only variables needed
keep lnw coop_entry urate_t0 urate_t0_2 urate_t0_3 first_firm_age  firmage female educ month year pexp pygrad provincebirth first_sector1d first_ms first_hs first_ftime  coop sep* dur reason idplant_new first_idplant

egen cluster = group(provincebirth pygrad)

reghdfe sep coop_entry urate_t0 urate_t0_2 urate_t0_3 first_firm_age, absorb(female educ month year pexp pygrad provincebirth first_sector1d first_ms first_hs first_ftime ) cluster(provincebirth#pygrad) keepsing
outreg2 using ../tables/duration_coop.tex , replace keep(coop_entry) ctitle("LMP") tex(frag) nocons dec(3)  nonotes label

logit sep coop_entry i.month i.year i.pexp i.pygrad i.provincebirth urate_t0 urate_t0_2 urate_t0_3 first_firm_age i.educ female i.first_sector1d first_ms first_hs first_ftime, cluster(cluster) difficult ltol(0) tol(1e-6)
outreg2 using ../tables/duration_coop.tex , append keep(coop_entry) ctitle("Logit") tex(frag) nocons dec(3)  nonotes label

mlogit sep_type coop_entry i.month i.pexp i.pygrad i.provincebirth urate_t0 urate_t0_2 urate_t0_3 first_firm_age i.educ female i.first_sector1d first_ms first_hs first_ftime, cluster(cluster) difficult ltol(0) tol(1e-6)  technique(bhhh 15 bfgs 5 bhhh 10 bfgs 10 bhhh 15 bfgs 15 nr 150) iter(232)
outreg2 using ../tables/duration_coop.tex , append keep(coop_entry) ctitle("MLogit") tex(frag) nocons dec(3)  nonotes label


** Adding year effects leads to convergence issues, but the point estimates are not affected by including them or not
*mlogit sep_type coop_entry i.month i.year i.pexp i.pygrad i.provincebirth urate_t0 urate_t0_2 urate_t0_3 first_firm_age i.educ female i.first_sector1d first_ms first_hs first_ftime, cluster(cluster) difficult ltol(0) tol(1e-6)  technique(bhhh 15 bfgs 5 bhhh 10 bfgs 10 bhhh 15 bfgs 15 nr 150) iter(232)




