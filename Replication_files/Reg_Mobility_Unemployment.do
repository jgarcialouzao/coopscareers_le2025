


capture log close
log using "../tables/duration.log", replace

** MOBILITY -- transition to unemployment
use ../dta/workers_monthly.dta, clear
drop if status==4
gen lnw = ln((WEincome_CHK + SEincome + OEincome)/(WEdays + SEdays + OEdays))
keep if lnw!=.

drop *income* *days* legal* type* 

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
merge m:1 provinceplant year quarter using ../dta/urqprov_1985_2018.dta, keepusing(urate) keep(match) nogen
drop quarter provinceplant year
rename y year
rename urate urate_t0
gen urate_t0_2= urate_t0*urate_t0
gen urate_t0_3 = urate_t0*urate_t0_2

keep idperson lnw month_wobs coop_entry urate_t0 urate_t0_2 urate_t0_3 first_firm_age  firmage female educ month year pexp pygrad provincebirth first_sector1d first_ms first_hs first_ftime  coop reason idplant_new first_idplant

egen cluster = group(provincebirth pygrad)

egen idspell = group(idperson idplant_new)
bys idspell (month_wobs): gen sep = _n == _N


gen exit2NE_type = 0 if sep==0
bys idperson (month_wobs): replace exit2NE_type = 1 if month_wobs[_n+1] - month_wobs <=1 & sep==1  
bys idperson (month_wobs): replace exit2NE_type = 2 if month_wobs[_n+1] - month_wobs > 1 & sep==1 &  reason_endspell==51 // voluntary
bys idperson (month_wobs): replace exit2NE_type = 3 if month_wobs[_n+1] - month_wobs > 1 & sep==1 & (inlist(reason_endspell, 52, 54, 69, 77, 91, 92, 93, 94)) // involuntary
bys idperson (month_wobs): replace exit2NE_type = 4 if month_wobs[_n+1] - month_wobs > 1 & sep==1 &  exit2NE_type!=1 & exit2NE_type!=2 & exit2NE_type!=3 // other
replace exit2NE_type = 0 if month_wobs==707
replace exit2NE_type = 0 if exit2NE_type == .

gen exit2NE_dur = 0 if sep==0
bys idperson (month_wobs): replace exit2NE_dur = 1 if month_wobs[_n+1] - month_wobs <=1 & sep==1 
bys idperson (month_wobs): replace exit2NE_dur = 2 if month_wobs[_n+1] - month_wobs > 1 & month_wobs[_n+1] - month_wobs < 6 & sep==1 
bys idperson (month_wobs): replace exit2NE_dur = 3 if month_wobs[_n+1] - month_wobs >= 6 & month_wobs[_n+1] - month_wobs <= 12 & sep==1  
bys idperson (month_wobs): replace exit2NE_dur = 4 if month_wobs[_n+1] - month_wobs > 12 &  sep==1  
replace exit2NE_dur = 0 if month_wobs==707
replace exit2NE_dur = 0 if exit2NE_dur == .


mlogit exit2NE_type coop_entry i.month  i.pexp i.pygrad i.provincebirth urate_t0 urate_t0_2 urate_t0_3 first_firm_age i.educ female i.first_sector1d first_ms first_hs first_ftime, cluster(cluster) difficult ltol(0) tol(1e-6) technique(bhhh 5 bfgs 5 bhhh 10 bfgs 10 bhhh 15 bfgs 15 nr 150) iter(232)
outreg2 using ../tables/duration_coop_UEtype.tex , replace keep(coop_entry) ctitle("MLogit") tex(frag) nocons dec(3)  nonotes label


mlogit exit2NE_dur coop_entry i.month  i.pexp i.pygrad i.provincebirth urate_t0 urate_t0_2 urate_t0_3 first_firm_age i.educ female i.first_sector1d first_ms first_hs first_ftime, cluster(cluster) difficult ltol(0) tol(1e-6) technique(bhhh 15 bfgs 5 bhhh 10 bfgs 10 bhhh 15 bfgs 15 nr 150) iter(232)
outreg2 using ../tables/duration_coop_UEdur.tex , replace keep(coop_entry) ctitle("MLogit") tex(frag) nocons dec(3)  nonotes label
drop exit2NE_*

gen exit2NE_durtype = 0 if sep==0
bys idperson (month_wobs): replace exit2NE_durtype = 1 if month_wobs[_n+1] - month_wobs < 6 & sep==1 
bys idperson (month_wobs): replace exit2NE_durtype = 2 if month_wobs[_n+1] - month_wobs >= 6 & sep==1 & reason_endspell==51  // voluntary 2 unemployment
bys idperson (month_wobs): replace exit2NE_durtype = 3 if month_wobs[_n+1] - month_wobs >= 6 & (inlist(reason_endspell, 52, 54, 69, 77, 91, 92, 93, 94)) & sep==1  // involuntary 2 unemployment
bys idperson (month_wobs): replace exit2NE_durtype = 4 if month_wobs[_n+1] - month_wobs >= 6 & sep==1  & exit2NE_durtype!=1 & exit2NE_durtype!=2 & exit2NE_durtype!=3 // other 2 unemployment 
replace exit2NE_durtype = 0 if month_wobs==707
replace exit2NE_durtype = 0 if exit2NE_durtype == .

mlogit exit2NE_durtype coop_entry i.month  i.pexp i.pygrad i.provincebirth urate_t0 urate_t0_2 urate_t0_3 first_firm_age i.educ female i.first_sector1d first_ms first_hs first_ftime, cluster(cluster) difficult ltol(0) tol(1e-6) technique(bhhh 15 bfgs 5 bhhh 10 bfgs 10 bhhh 15 bfgs 15 nr 150) iter(232)
outreg2 using ../tables/duration_coop_UEdurtype.tex , replace keep(coop_entry) ctitle("MLogit") tex(frag) nocons dec(3)  nonotes label

log close 







