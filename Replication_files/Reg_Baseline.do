* STATA 16
* MCVL - Regressions - Monthly Frequency
* Jose Garcia-Louzao


clear all
capture log close
capture program drop _all
set more 1
set seed 13
set cformat %5.4f


use ${path}\dta\workers_monthly.dta, clear
*Dependent variable: log daily income, log annual income, and log annual days
gen lnw = ln((WEincome_CHK + SEincome + OEincome)/(WEdays + SEdays + OEdays))

*Potential experience (in years)
gen pexp = year - pygrad 


/*
*Raw profiles of average log daily income
preserve
qui grstyle init
qui grstyle set plain, compact grid dotted /*no grid*/
qui grstyle color major_grid gs13
qui grstyle set symbol
qui grstyle set lpattern
qui grstyle set color hue, n(2)   
qui grstyle set color hue, n(2)   opacity(34): p#markfill 

qui reg lnw i.year i.month i.educ female
predict res, res
gen lnw_res = _b[_cons] + res

gcollapse (mean) lnw lnw_res, by(coop_entry pexp)

tw (connect lnw pexp if coop_entry==0, lcolor("255 141 61") mcolor("255 141 61 %34")) (connect lnw pexp if coop_entry==1, lcolor("31 119 180") mcolor("31 119 180 %34")),  legend(order( 1 "Convetional firms" 2 "Cooperatives"))  xtitle("Labor market experience", size(small)) ytitle("Log daily income", size(small))  xlabel(1(1)15)  ylabel(3.2(0.2)4)

qui graph export "../figures/lnw_pexp_m.png", as(png) replace

tw (connect lnw_res pexp if coop_entry==0, lcolor("255 141 61") mcolor("255 141 61 %34")) (connect lnw_res pexp if coop_entry==1, lcolor("31 119 180") mcolor("31 119 180 %34")),  legend(order( 1 "Convetional firms" 2 "Cooperatives"))  xtitle("Labor market experience", size(small)) ytitle("Log daily income", size(small))  xlabel(1(1)15)  ylabel(2.6(0.2)3.4)
qui graph export "../figures/lnw_pexp_net_m.png", as(png) replace
restore
*/

*Control Variables
gen first_firm_age = pygrad - yofd(first_creation)
gen first_ftime = first_ptime>95
gen first_ms = first_skill>3 & first_skill<8
gen first_hs = first_skill>=1 & first_skill<=3

** Keep only variables needed
keep idperson year month month_wobs lnw coop_entry pexp pygrad provincebirth female educ first_firm_age first_sector1d first_ms first_hs first_ftime Efirst first_provinceplant

*Add unemployment rate
**LM Entry
gen quarter = quarter(mdy(1,1,pygrad))
gen provinceplant = provincebirth 
rename year y 
gen year = pygrad + 1
merge m:1 provinceplant year quarter using  ${path}\dta\urqprov_1985_2018.dta, keepusing(urate) keep(match) nogen
drop quarter provinceplant year
rename y year
rename urate urate_t0
gen urate_t0_2= urate_t0*urate_t0
gen urate_t0_3 = urate_t0*urate_t0_2

*Baseline regression sequentially extended to include controls
*1: lnw on coop_entry, conditional on calendar year, potential experience, graduation cohort and province of lm at entry [here I am using the province of birth to avoid the endogeneity of province at entry if there is mobility, when matching the unemployment rate we also use province birth --we can change it. But as descriptive stats suggests, around 85% of the people have their first job in the province of birth, so results should not change dramatically.]

reghdfe lnw coop_entry, absorb(month year pexp pygrad provincebirth) cluster(provincebirth##pygrad) keepsing
outreg2 using  ${path}\tables\reg_coopentry_baseline_m.tex , replace keep(coop_entry) addtext(Additional controls include indicators for: calendar year (34), potential experience (15), province of birth (50), pygrad(20). Column 2 includes gender and education (2 dummies) as additional controls. Column 3 adds a polynomial of the provincial unemployment rate at graduation year in the province of birth. Column 4 adds age of first employer, and indicators for sector of first employer (11), first job is full-time (1), and skill-level of first job (2). Standard errors cluster at provincebirth-graduation year level.) tex(frag) nocons dec(3) nonotes label

*2: 1+ gender and education

reghdfe lnw coop_entry , absorb(female educ month year pexp pygrad provincebirth) cluster(provincebirth#pygrad) keepsing
outreg2 using ${path}\tables\reg_coopentry_baseline_m.tex , append keep(coop_entry) addtext(Additional controls include indicators for: calendar year (34), potential experience (15), province of birth (50), pygrad(20). Column 2 includes gender and education (2 dummies) as additional controls. Column 3 adds a polynomial of the provincial unemployment rate at graduation year in the province of birth. Column 4 adds age of first employer, and indicators for sector of first employer (11), first job is full-time (1), and skill-level of first job (2). Standard errors cluster at provincebirth-graduation year level.) tex(frag) nocons dec(3)  nonotes label


*2: 2+ unemployment rate at entry (cubic poynomial)

reghdfe lnw coop_entry urate_t0 urate_t0_2 urate_t0_3, absorb(female educ month year pexp pygrad provincebirth) cluster(provincebirth#pygrad) keepsing
outreg2 using ${path}\tables\reg_coopentry_baseline_m.tex , append keep(coop_entry)  addtext(Additional controls include indicators for: calendar year (34), potential experience (15), province of birth (50), pygrad(20). Column 2 includes gender and education (2 dummies) as additional controls. Column 3 adds a polynomial of the provincial unemployment rate at graduation year in the province of birth. Column 4 adds age of first employer, and indicators for sector of first employer (11), first job is full-time (1), and skill-level of first job (2). Standard errors cluster at provincebirth-graduation year level.) tex(frag) nocons dec(3)  nonotes label

*3: job and firm characteristics of first employer

reghdfe lnw coop_entry  urate_t0 urate_t0_2 urate_t0_3 first_firm_age, absorb(female educ month year pexp pygrad provincebirth first_sector1d first_ms first_hs first_ftime ) cluster(provincebirth#pygrad) keepsing

outreg2 using ${path}\tables\reg_coopentry_baseline_m.tex , append keep(coop_entry) addtext(Additional controls include indicators for: calendar year (34), potential experience (15), province of birth (50), pygrad(20). Column 2 includes gender and education (2 dummies) as additional controls. Column 3 adds a polynomial of the provincial unemployment rate at graduation year in the province of birth. Column 4 adds age of first employer, and indicators for sector of first employer (11), first job is full-time (1), and skill-level of first job (2). Standard errors cluster at provincebirth-graduation year level.)  tex(frag) nocons dec(3)  nonotes label

*4: IV based on Arellano-Bover (2024)
preserve 
*keep idperson female provincebirth educ pygrad coop_entry
gen yfirst = yofd(dofm(Efirst)) - 1
bys idperson: keep if _n == 1
gcollapse (count) N_entrants = coop_entry (sum) N_coop_entrants = coop_entry, by(provincebirth pygrad educ female)
tempfile iv
save `iv', replace
restore

** Leave one out instrument
merge m:1 pygrad provincebirth educ female using `iv', keep(1 3)  
drop _merge

gen  iv = (N_coop_entrants - coop_entry)/(N_entrants-1) if first_provinceplant==provincebirth & yofd(dofm(Efirst))==pygrad+1
replace iv = N_coop_entrants / N_entrants if iv==.

egen cluster = group(provincebirth pygrad)


ivreghdfe lnw (coop_entry = iv) urate_t0 urate_t0_2 urate_t0_3 first_firm_age, absorb(female educ month year pexp pygrad provincebirth first_sector1d first_ms first_hs first_ftime ) cluster(cluster)  first
outreg2 using ${path}\tables\reg_coopentry_baseline_m.tex , append keep(coop_entry) addtext(Additional controls include indicators for: calendar year (34), potential experience (15), province of birth (50), pygrad(20). Column 2 includes gender and education (2 dummies) as additional controls. Column 3 adds a polynomial of the provincial unemployment rate at graduation year in the province of birth. Column 4 adds age of first employer, and indicators for sector of first employer (11), first job is full-time (1), and skill-level of first job (2). Standard errors cluster at provincebirth-graduation year level.)  tex(frag) nocons dec(3)  nonotes label


qui reghdfe coop_entry iv urate_t0 urate_t0_2 urate_t0_3 first_firm_age, absorb(female educ month year pexp pygrad provincebirth first_sector1d first_ms first_hs first_ftime ) cluster(cluster)
gen fstat = round( (_b[iv]/_se[iv])^2, 0.01)	

****************************************************		
****************************************************

*Penalty over experience
forvalues n=1(1)15 {
gen coop_p`n' = coop_entry==1 & pexp==`n'	
}

gen beta_basic=.
gen cilow_basic=.
gen cihigh_basic=.

reghdfe lnw coop_p1-coop_p15 , absorb(year month pexp pygrad provincebirth) cluster(provincebirth##pygrad) keepsing
forvalues n=1(1)15 {
qui replace beta_basic  = _b[coop_p`n'] if coop_p`n'==1
qui replace cilow_basic = _b[coop_p`n'] - 1.96*_se[coop_p`n'] if coop_p`n'==1
qui replace cihigh_basic = _b[coop_p`n'] + 1.96*_se[coop_p`n'] if coop_p`n'==1	
}

gen beta_full=.
gen cilow_full=.
gen cihigh_full=.
reghdfe lnw coop_p1-coop_p15 urate_t0 urate_t0_2 urate_t0_3 first_firm_age, absorb(female educ month year pexp pygrad provincebirth first_sector1d first_ms first_hs first_ftime ) cluster(provincebirth#pygrad) keepsing
forvalues n=1(1)15 {
qui replace beta_full   = _b[coop_p`n'] if coop_p`n'==1
qui replace cilow_full  = _b[coop_p`n'] - 1.96*_se[coop_p`n'] if coop_p`n'==1
qui replace cihigh_full = _b[coop_p`n'] + 1.96*_se[coop_p`n'] if coop_p`n'==1	
}

preserve
keep if beta_basic!=.
bys pexp: keep if _n == 1
set scheme s2color
qui grstyle init
qui grstyle set plain, compact grid dotted /*no grid*/
qui grstyle color major_grid gs13
qui grstyle set symbol
qui grstyle set lpattern
qui grstyle set color hue, n(2)   
qui grstyle set color hue, n(2)   opacity(34): p#markfill


tw (connect beta_basic pexp, lcolor("255 141 61") mcolor("255 141 61 %34")) (rarea cilow_basic cihigh_basic pexp, color("255 141 61 %15") lwidth(none) sort) (connect beta_full pexp, lcolor("31 119 180") mcolor("31 119 180 %34")) (rarea cilow_full cihigh_full pexp, color("31 119 180 %15") lwidth(none) sort) ,  yline(0, lcolor(black%25)) xlabel(1(1)15) xtitle("Labor market experience", size(small)) ytitle("Estimated gap", size(small))   legend(order( 1 "Basic controls" 3 "All controls") col(3) pos(6)) ylabel(-0.12(0.02)0.06) 
qui graph export "${path}\figures\lnw_coopentry_pexp_m.png", as(png) replace
restore


/*
*Penalty over experience/education
forvalues n=1(1)15 {
gen coop_p`n' = coop_entry==1 & pexp==`n'	
}

gen beta_lowedu=.
gen cilow_lowedu=.
gen cihigh_lowedu=.

reghdfe lnw coop_p1-coop_p15 urate_t0 urate_t0_2 urate_t0_3 first_firm_age if (educ==1 | educ==2), absorb(female month year pexp pygrad provincebirth first_sector1d first_ms first_hs first_ftime ) cluster(provincebirth##pygrad) keepsing
forvalues n=1(1)15 {
qui replace beta_lowedu  = _b[coop_p`n'] if coop_p`n'==1
qui replace cilow_lowedu = _b[coop_p`n'] - 1.96*_se[coop_p`n'] if coop_p`n'==1
qui replace cihigh_lowedu = _b[coop_p`n'] + 1.96*_se[coop_p`n'] if coop_p`n'==1	
}

gen beta_highedu=.
gen cilow_highedu=.
gen cihigh_highedu=.
reghdfe lnw coop_p1-coop_p15 urate_t0 urate_t0_2 urate_t0_3 first_firm_age if educ==3, absorb(female month year pexp pygrad provincebirth first_sector1d first_ms first_hs first_ftime ) cluster(provincebirth#pygrad) keepsing
forvalues n=1(1)15 {
qui replace beta_highedu   = _b[coop_p`n'] if coop_p`n'==1
qui replace cilow_highedu  = _b[coop_p`n'] - 1.96*_se[coop_p`n'] if coop_p`n'==1
qui replace cihigh_highedu = _b[coop_p`n'] + 1.96*_se[coop_p`n'] if coop_p`n'==1	
}

preserve
keep if beta_lowedu!=.
bys pexp: keep if _n == 1

qui grstyle init
qui grstyle set plain, compact grid dotted /*no grid*/
qui grstyle color major_grid gs13
qui grstyle set symbol
qui grstyle set lpattern
qui grstyle set color hue, n(2)   
qui grstyle set color hue, n(2)   opacity(34): p#markfill


tw (connect beta_lowedu pexp, lcolor("31 119 180") mcolor("31 119 180 %50")) (rarea cilow_lowedu cihigh_lowedu pexp, color("31 119 180 %25") lwidth(none) sort) (connect beta_highedu pexp, lcolor("31 119 180") mcolor("31 119 180 %30")) (rarea cilow_highedu cihigh_highedu pexp, color("31 119 180 %15") lwidth(none) sort) ,  yline(0, lcolor(black%25)) xlabel(1(1)15) xtitle("Labor market experience", size(small)) ytitle("Log daily income gap", size(small))   legend(order( 1 "Non-college" 3 "College") col(3)) ylabel(-0.18(0.02)0.06) 
qui graph export "../figures/lnw_coopentry_pexp_m_education.png", as(png) replace
restore
*/


***************************************************************
********Oster bound**************************************

egen clus=group(provincebirth pygrad)
reg lnw coop_entry  urate_t0 urate_t0_2 urate_t0_3 first_firm_age female i.educ i.month i.year i.pexp i.pygrad i.provincebirth i.first_sector1d first_ms first_hs first_ftime, cluster(clus) 

gen rmax = 1.3*`e(r2)'

psacalc beta coop_entry, delta(0) rmax(.41795 ) 
psacalc beta coop_entry, delta(1) rmax(.41795 ) 
psacalc beta coop_entry, delta(11) rmax(.41795 ) 

psacalc delta coop_entry, beta(0) rmax(.41795) 


***************************************************************
********Reg sensitivity -correr en 16 SE or 17 SE?**************************************

local y lnw
local x coop_entry
local w1 urate_t0 urate_t0_2 urate_t0_3 first_firm_age female i.educ i.first_sector1d first_ms first_hs first_ftime
local w0 i.month i.year i.pexp i.pygrad i.provincebirth
local w `w1' `w0'
local SE cluster(clus)
reg `y' `x' `w', `SE' 
regsensitivity `y' `x' `w'

