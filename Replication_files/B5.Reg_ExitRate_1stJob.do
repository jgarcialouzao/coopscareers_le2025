* STATA 16
* MCVL - Exit from first job
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
keep idperson idplant_new pygrad provincebirth month_wobs female educ first_* socialeco status spellstart_date spellend_date reason_endspell
drop if status==4
foreach v in socialeco status spellstart_date idplant_new reason_endspell {
bys idperson (month_wobs): gen next`v' = `v'[_n+1] if idplant_new!=idplant_new[_n+1]
}

egen idspell = group(idperson idplant_new spellstart_date)
bys idperson (month_wobs): replace idspell = idspell[_n-1] if idplant_new==idplant_new[_n-1] & (month_wobs - month_wobs[_n-1]<3)

gen tmp = spellstart_date if idplant_new == first_idplant
bys idperson: egen min = min(tmp)
drop if spellstart_date < min
drop tmp min

keep if idplant_new == first_idplant
bys idperson idplant_new spellstart_date: gen n = _n==1
bys idperson idplant_new (month_wobs): replace n = 0 if month_wobs - month_wobs[_n-1]<3
bys idperson idplant_new: gen order = sum(n)
drop if order>1
drop n order

gen quarter= qofd(dofm(month_wobs))
bys idperson quarter (month_wobs): keep if _n == _N
bys idperson (quarter): gen dur = _n
bys idperson (quarter): gen sep = _n == _N
replace sep = 0 if reason==0
drop quarter

gen coop_entry = first_socialeco==2

*Type of transition by destination state
gen j2j_switch    =  sep ==1  & (int((nextspellstart_date - spellend_date + 1)/30) <= 1) & nextstatus==1 & first_socialeco!=nextsocialeco //another job,switch ownership
gen j2j_same      =  sep ==1  & (int((nextspellstart_date - spellend_date + 1)/30) <= 1) & nextstatus==1 & first_socialeco==nextsocialeco //another job
gen j2se   =  sep ==1  & (int((nextspellstart_date - spellend_date + 1)/30) <= 1) & nextstatus==2 
gen j2ne   =  sep ==1  & (int((nextspellstart_date - spellend_date + 1)/30) >= 6)& nextstatus!=4 //non-employment
gen j2ub   =  sep ==1  & nextstatus==4 // unemployment insurance

*Type of transition by type of separation
gen voluntary = sep==1 & reason_endspell==51  
gen involuntary = sep == 1 & (inlist(reason_endspell, 52, 54, 69, 77, 91, 92, 93, 94))
gen other = sep==1 & voluntary==0 & involuntary==0

*Voluntary
gen j2j_switch_vol =  voluntary ==1  & (int((nextspellstart_date - spellend_date + 1)/30) <= 1) & nextstatus==1 & first_socialeco!=nextsocialeco //another job,switch ownership
gen j2j_same_vol   =  voluntary ==1  & (int((nextspellstart_date - spellend_date + 1)/30) <= 1) & nextstatus==1 & first_socialeco==nextsocialeco //another job
gen j2se_vol   =  voluntary ==1  & (int((nextspellstart_date - spellend_date + 1)/30) <= 1) & nextstatus==2 
gen j2ne_vol   =  voluntary ==1  & (int((nextspellstart_date - spellend_date + 1)/30) >= 6)  //non-employment

*Involuntary
gen j2j_switch_invol =  involuntary ==1  & (int((nextspellstart_date - spellend_date + 1)/30) <= 1) & nextstatus==1 & first_socialeco!=nextsocialeco //another job,switch ownership
gen j2j_same_invol =  involuntary ==1  & (int((nextspellstart_date - spellend_date + 1)/30) <= 1) & nextstatus==1 & first_socialeco==nextsocialeco //another job
gen j2se_invol   =  involuntary ==1  & (int((nextspellstart_date - spellend_date + 1)/30) <= 1)   & nextstatus==2 
gen j2ne_invol   =  involuntary ==1  & (int((nextspellstart_date - spellend_date + 1)/30) >= 6)    //non-employment


preserve

gen sep_type = 0 
replace sep_type = 1 if voluntary==1
replace sep_type = 2 if involuntary==1
replace sep_type= 3  if other==1

gen quarter = quarter(mdy(1,1,pygrad))
gen provinceplant = provincebirth 
gen year = pygrad + 1
merge m:1 provinceplant year quarter using ../dta/urqprov_1985_2018.dta, keepusing(urate) keep(match) nogen
rename urate urate_t0
gen urate_t0_2= urate_t0*urate_t0
gen urate_t0_3 = urate_t0*urate_t0_2

*Control Variables cop
gen first_firm_age = pygrad - yofd(first_creation)
gen first_ftime = first_ptime>95
gen first_ms = first_skill>3 & first_skill<8
gen first_hs = first_skill>=1 & first_skill<=3

egen cluster = group(provincebirth pygrad)
gen q    = quarter(dofm(month_wobs))
mlogit sep_type coop_entry c.dur##c.dur#coop_entry urate* i.pygrad i.q i.provincebirth educ female first_firm_age i.first_sector1d first_ms first_hs first_ftime,  cluster(cluster) base(0) difficult ltol(0) tol(1e-7)
outreg2 using ../tables/exit_first_job.tex , replace keep(coop_entry) ctitle("MLogit") tex(frag) nocons dec(3)  nonotes label
restore

preserve
keep if dur<=20
gcollapse (mean) voluntary involuntary other j2*, by(coop_entry dur)

qui grstyle init
qui grstyle set plain, compact grid dotted /*no grid*/
qui grstyle color major_grid gs13
qui grstyle set symbol
qui grstyle set lpattern
qui grstyle set color hue, n(4)   
qui grstyle set color hue, n(4)   opacity(34): p#markfill

forvalues n=0/1 {
tw (connect voluntary dur if coop_entry==`n') (connect involuntary dur if coop_entry==`n') (connect other dur if coop_entry==`n'),  legend(order( 1 "Employee-initiated" 2 "Employer-initiated" 3 "Other reason") size(small) col(3))  xtitle("Duration of first job (quarters)", size(small)) ytitle("Empirical hazard rate", size(small))  xlabel(1(1)20)  ylabel(0(0.05)0.2)
qui graph export "../figures/hz_typesep_coop`n'.png", as(png) replace
	
tw (connect j2j_switch dur if coop_entry==`n') (connect j2j_same dur if coop_entry==`n') (connect j2se dur if coop_entry==`n') (connect j2ne dur if coop_entry==`n'),  legend(order( 1 "Job-to-job, switch"  3 "Job-to-selfemployment" 2 "Job-to-job, same" 4 "Job-to-nonemployment" ) size(small) col(2))  xtitle("Duration of first job (quarters)", size(small)) ytitle("Empirical hazard rate", size(small))  xlabel(1(1)20)  ylabel(0(0.03)0.15)
qui graph export "../figures/hz_typedestination_coop`n'.png", as(png) replace	
/*
tw (connect j2j_switch_vol dur if coop_entry==`n') (connect j2j_same_vol dur if coop_entry==`n') (connect j2se_vol dur if coop_entry==`n') (connect j2ne_vol dur if coop_entry==`n'),  legend(order( 1 "Job-to-job, switch"  3 "Job-to-selfemployment" 2 "Job-to-job, same" 4 "Job-to-nonemployment" ) size(small) col(2))  xtitle("Duration of first job (quarters)", size(small)) ytitle("Empirical hazard rate", size(small))  xlabel(1(1)20)  ylabel(0(0.005)0.03)
qui graph export "../figures/hz_typedestination_voluntary_coop`n'.png", as(png) replace	
	
tw (connect j2j_switch_invol dur if coop_entry==`n') (connect j2j_same_invol dur if coop_entry==`n') (connect j2se_invol dur if coop_entry==`n') (connect j2ne_invol dur if coop_entry==`n'),  legend(order( 1 "Job-to-job, switch"  3 "Job-to-selfemployment" 2 "Job-to-job, same" 4 "Job-to-nonemployment" ) size(small) col(2))  xtitle("Duration of first job (quarters)", size(small)) ytitle("Empirical hazard rate", size(small))  xlabel(1(1)20)  ylabel(0(0.02)0.10)
qui graph export "../figures/hz_typedestination_involuntary_coop`n'.png", as(png) replace
*/	
}
restore


