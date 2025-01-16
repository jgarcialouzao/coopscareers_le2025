
use ${path}/dta/workers_monthly.dta, clear

gen lnw = ln((WEincome_CHK + SEincome + OEincome)/(WEdays + SEdays + OEdays))
keep if lnw!=.

*Potential experience (in years)
gen pexp = year - pygrad 

*Control Variables cop
gen first_firm_age = pygrad - yofd(first_creation)
gen first_ftime = first_ptime>95
gen first_ms = first_skill>3 & first_skill<8
gen first_hs = first_skill>=1 & first_skill<=3

** Keep only variables needed
keep idperson year month month_wobs lnw coop_entry pexp pygrad provincebirth female educ first_firm_age first_sector1d first_ms first_hs first_ftime status coop


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



gen selfemp = status==2
drop if status==4

forvalues n=1(1)15 {
gen coop_p`n' = coop_entry==1 & pexp==`n'	
}

preserve
/*
gen beta_basic=.
gen cilow_basic=.
gen cihigh_basic=.

reghdfe selfemp coop_p1-coop_p15, absorb(year pexp pygrad provincebirth) cluster(provincebirth##pygrad) keepsing
forvalues n=1(1)15 {
qui replace beta_basic  = _b[coop_p`n'] if coop_p`n'==1
qui replace cilow_basic = _b[coop_p`n'] - 1.96*_se[coop_p`n'] if coop_p`n'==1
qui replace cihigh_basic = _b[coop_p`n'] + 1.96*_se[coop_p`n'] if coop_p`n'==1	
}
*/
gen beta_full=.
gen cilow_full=.
gen cihigh_full=.
reghdfe selfemp coop_p1-coop_p15  urate_t0 urate_t0_2 urate_t0_3 first_firm_age, absorb(female educ month year pexp pygrad provincebirth first_sector1d first_ms first_hs first_ftime ) cluster(provincebirth#pygrad) keepsing
forvalues n=1(1)15 {
qui replace beta_full   = _b[coop_p`n'] if coop_p`n'==1
qui replace cilow_full  = _b[coop_p`n'] - 1.96*_se[coop_p`n'] if coop_p`n'==1
qui replace cihigh_full = _b[coop_p`n'] + 1.96*_se[coop_p`n'] if coop_p`n'==1	
}


keep if beta_full!=.
bys pexp: keep if _n == 1

qui grstyle init
qui grstyle set plain, compact grid dotted /*no grid*/
qui grstyle color major_grid gs13
qui grstyle set symbol
qui grstyle set lpattern
qui grstyle set color hue, n(2)   
qui grstyle set color hue, n(2)   opacity(34): p#markfill


tw (connect beta_full pexp, lcolor("31 119 180") mcolor("31 119 180 %34")) (rarea cilow_full cihigh_full pexp, color("31 119 180 %15") lwidth(none) sort),  yline(0, lcolor(black%25)) xlabel(1(1)15) xtitle("Labor market experience") ytitle("Self-employment status")   /*legend(order( 1 "Basic controls" 3 "All controls") col(3))*/ ylabel(-0.02(0.02)0.08) legend(off)
qui graph export "${path}/figures/selfemp_coopentry_pexp.png", as(png) replace
restore


preserve

/*
gen beta_basic=.
gen cilow_basic=.
gen cihigh_basic=.

reghdfe coop coop_p1-coop_p15, absorb(year pexp pygrad provincebirth) cluster(provincebirth##pygrad) keepsing
forvalues n=1(1)15 {
qui replace beta_basic  = _b[coop_p`n'] if coop_p`n'==1
qui replace cilow_basic = _b[coop_p`n'] - 1.96*_se[coop_p`n'] if coop_p`n'==1
qui replace cihigh_basic = _b[coop_p`n'] + 1.96*_se[coop_p`n'] if coop_p`n'==1	
}
*/

gen beta_full=.
gen cilow_full=.
gen cihigh_full=.
reghdfe coop coop_p1-coop_p15  urate_t0 urate_t0_2 urate_t0_3 first_firm_age, absorb(female educ month year pexp pygrad provincebirth first_sector1d first_ms first_hs first_ftime ) cluster(provincebirth#pygrad) keepsing
forvalues n=1(1)15 {
qui replace beta_full   = _b[coop_p`n'] if coop_p`n'==1
qui replace cilow_full  = _b[coop_p`n'] - 1.96*_se[coop_p`n'] if coop_p`n'==1
qui replace cihigh_full = _b[coop_p`n'] + 1.96*_se[coop_p`n'] if coop_p`n'==1	
}


keep if beta_full!=.
bys pexp: keep if _n == 1

qui grstyle init
qui grstyle set plain, compact grid dotted /*no grid*/
qui grstyle color major_grid gs13
qui grstyle set symbol
qui grstyle set lpattern
qui grstyle set color hue, n(2)   
qui grstyle set color hue, n(2)   opacity(34): p#markfill


tw (connect beta_full pexp, lcolor("31 119 180") mcolor("31 119 180 %34")) (rarea cilow_full cihigh_full pexp, color("31 119 180 %15") lwidth(none) sort) ,  yline(0, lcolor(black%25)) xlabel(1(1)15) xtitle("Labor market experience") ytitle("Cooperative")   /*legend(order( 1 "Basic controls" 3 "All controls") col(3))*/ ylabel(1(0.10)0)  legend(off)
qui graph export "${path}/figures/coop_coopentry_pexp.png", as(png) replace
restore
