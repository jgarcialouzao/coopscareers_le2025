* STATA 16
* MCVL - Regressions - Monthly Frequency
* Jose Garcia-Louzao


clear all
capture log close
capture program drop _all
set more 1
set seed 13
set cformat %5.4f

qui grstyle init
qui grstyle set plain, compact grid dotted /*no grid*/
qui grstyle color major_grid gs13
qui grstyle set symbol
qui grstyle set lpattern
qui grstyle set color hue, n(2)   
qui grstyle set color hue, n(2)   opacity(34): p#markfill 

/*
ssc install ftools, replace
ssc install reghdfe, replace
ssc install outreg2, replace
ssc install addplot, replace
*/

use ../dta/workers_monthly.dta, clear
drop if status==4

bys idperson: egen total_income = total(WEincome_CHK + SEincome + OEincome)
bys idperson: egen total_minw   = total(min_base)
bys idperson: egen total_days   = total(WEdays + SEdays + OEdays)

keep if total_days/360>=3
keep if total_income>=total_minw/4

*Dependent variable: log daily income, log annual income, and log annual days
gen lnw = ln((WEincome_CHK + SEincome + OEincome)/(WEdays + SEdays + OEdays))

bys idperson: egen total= total((WEincome_CHK + SEincome + OEincome)/(WEdays + SEdays + OEdays)) 
gen pid0= ln(total)

gen lnw1 = ln((WEincome_CHK + SEincome + OEincome)/(WEdays + SEdays + OEdays))
gen pexp = year - pygrad 
gen tenure = int(datediff(spellstart_date, dofm(month_wobs+1), "day") /360)

keep idperson pid0 lnw pexp aexp* tenure firmage year month provinceplant sector1d skill ftime coop* 


qui reghdfe lnw c.aexpWE##c.aexpWE c.tenure##c.tenure firmage, absorb(year month provinceplant sector1d skill ftime coop pid2 = idperson) keepsing 

qui reghdfe lnw c.aexpWE##c.aexpWE c.aexpWE_coop##c.aexpWE c.tenure##c.tenure firmage, absorb(year month provinceplant sector1d skill ftime coop pid3 = idperson) keepsing 


*HETEROGENEOUS RETURN
gen toler=0.0001 
gen distance=1
gen pid_fe_het = pid3

while (distance>toler) {
qui: reghdfe lnw  c.aexpWE##c.aexpWE##c.pid_fe_het c.aexpWE_coop##c.aexpWE##c.pid_fe_het c.tenure##c.tenure firmage, absorb(year month provinceplant sector1d skill ftime coop pid4 = idperson) keepsing

egen diff=mean(abs(pid4 - pid_fe_het))
replace distance = diff
drop diff
sum distance
drop  pid_fe_het
gen  pid_fe_het = pid4
drop  pid4
}

drop if pid2==.
bys idperson: keep if _n == 1
keep idperson coop_entry pid*

preserve
bys coop_entry: egen pbot = pctile(pid0), p(0.1)
bys coop_entry: egen ptop = pctile(pid0), p(99.9)
keep if pbot<=pid0 & pid0<=ptop
qui egen mean_sm = mean(pid0) if coop_entry==0
qui egen mean_Kecon = mean(mean_sm)
qui gen pid0_norm = pid0 - mean_Kecon


tw (kdensity pid0_norm if coop_entry==0, lcolor("255 141 61") mcolor("255 141 61 %34")) (kdensity pid0_norm if coop_entry==1, lcolor("31 119 180") mcolor("31 119 180 %34")),   legend(order( 1 "Conventional firms" 2 "Cooperatives"))  xtitle("Liftime earnings") xlabel(-5(1)2) ytitle("Density") ylabel(0(0.2)1) 
qui graph export "../figures/lifetime_coop.png", as(png) replace

*qui sum pid0_norm if coop_entry==0, d
*local K = `r(p50)'
*qui sum pid0_norm if coop_entry==1, d
*local coop = `r(p50)'
*tw (kdensity pid0_norm if coop_entry==0, lcolor("255 141 61") mcolor("255 141 61 %34")) (kdensity pid0_norm if coop_entry==1, lcolor("31 119 180") mcolor("31 119 180 %34")) (pcarrowi 0.78 -0.45 0.88 0.015 (6) "Median Coop Worker", mlabsize(relative1p5) mlabcolor("31 119 180") mcolor("31 119 180") lcolor("31 119 180") lwidth(thin) mlwidth(thin) msize(medsmall) barbsize(medsmall)) (pcarrowi 0.7 0.9 0.4 0.09 (1) "Median Conventional Worker", mlabsize(relative1p5) mlabcolor("255 141 61") mcolor("255 141 61") lcolor("255 141 61") lpattern(shortdash) lwidth(thin) mlwidth(thin) msize(medsmall) barbsize(medsmall)),   legend(order( 1 "Conventional firms" 2 "Cooperatives"))  xtitle("Liftime earnings") xlabel(-5(1)2) ytitle("Density") ylabel(0(0.2)1) xline(`K', lcolor("255 141 61 %40")) xline(`coop', lcolor("31 119 180 %40"))
*qui graph export "../figures/lifetime_coop.png", as(png) replace
restore


preserve
bys coop_entry: egen pbot = pctile(pid2), p(0.1)
bys coop_entry: egen ptop = pctile(pid2), p(99.9)
keep if pbot<=pid2 & pid2<=ptop
qui egen mean_sm = mean(pid2) if coop_entry==0
qui egen mean_Kecon = mean(mean_sm)
qui gen pid2_norm = pid2 - mean_Kecon
qui drop mean*

tw (kdensity pid2_norm if coop_entry==0, lcolor("255 141 61") mcolor("255 141 61 %34")) (kdensity pid2_norm if coop_entry==1, lcolor("31 119 180") mcolor("31 119 180 %34")),   legend(order( 1 "Conventional firms" 2 "Cooperatives"))  xtitle("Worker fixed-effects") xlabel(-3(1)2) ytitle("Density") 
qui graph export "../figures/fe_mincer_actual.png", as(png) replace
restore

preserve
bys coop_entry: egen pbot = pctile(pid3), p(0.1)
bys coop_entry: egen ptop = pctile(pid3), p(99.9)
keep if pbot<=pid3 & pid3<=ptop
qui egen mean_sm = mean(pid3) if coop_entry==0
qui egen mean_Kecon = mean(mean_sm)
qui gen pid3_norm = pid3 - mean_Kecon
qui drop mean*

tw (kdensity pid3_norm if coop_entry==0, lcolor("255 141 61") mcolor("255 141 61 %34")) (kdensity pid3_norm if coop_entry==1, lcolor("31 119 180") mcolor("31 119 180 %34")),   legend(order( 1 "Conventional firms" 2 "Cooperatives"))  xtitle("Worker fixed effects") xlabel(-3(1)2) ytitle("Density") ylabel(0(0.4)2) 
qui graph export "../figures/fe_mincer_actual_coop.png", as(png) replace 
restore


preserve
bys coop_entry: egen pbot = pctile(pid_fe), p(0.1)
bys coop_entry: egen ptop = pctile(pid_fe), p(99.9)
keep if pbot<=pid_fe & pid_fe<=ptop
qui egen mean_sm = mean(pid_fe) if coop_entry==0
qui egen mean_Kecon = mean(mean_sm)
qui gen pid4_norm = pid_fe - mean_Kecon
qui drop mean*

tw (kdensity pid4_norm if coop_entry==0, lcolor("255 141 61") mcolor("255 141 61 %34")) (kdensity pid4_norm if coop_entry==1, lcolor("31 119 180") mcolor("31 119 180 %34")),   legend(order( 1 "Conventional firms" 2 "Cooperatives"))  xtitle("Worker fixed effects") xlabel(-2(0.5)1) ytitle("Density") ylabel(0(0.4)2.8) 
qui graph export "../figures/fe_mincer_actual_coop_het.png", as(png) replace 
restore
