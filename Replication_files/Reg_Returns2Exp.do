
use ${path}\dta\workers_monthly.dta, clear


keep if status==1
gen contract_long = 0 if misscontract==1
replace contract_long = 1 if oec==0
replace contract_long = 2 if oec==1
keep idperson month_wobs month year spellstart_date aexp* WEincome_CHK WEdays sector1d provinceplant contract_long skill coop ftime firmage partner

*Daily wage
gen lnw = ln(WEincome/WEdays)


*Tenure 
gen tenure = datediff(spellstart_date, dofm(month_wobs+1), "day") 

*Annual

*Convert to days
gen tenure_days = tenure
gen tenure_sq_days=tenure_days^2
gen aexpE_days=aexpWE*360
gen aexpE_sq_days=(aexpE_days)^2
gen aexpWE_coop_days=aexpWE_coop*360
gen aexpWE_coop_aexpWE=aexpWE_coop_days*aexpE_days
gen aexpWE_coop_tenure_days=aexpWE_coop_days*tenure_days


qui reghdfe lnw aexpWE_coop_days aexpWE_coop_aexpWE tenure_days tenure_sq_days aexpE_days aexpE_sq_days firmage, absorb(idperson sector1d month year provinceplant skill ftime) cluster(idperson) keepsing
outreg2 using "${path}\tables\returns_experience_annual.tex", replace stnum(replace coef=coef*(10^6), replace se=se*(10^6)) keep(aexpWE_coop_days aexpWE_coop_aexpWE tenure_days tenure_sq_days aexpE_days aexpE_sq_days) tex /*
*/ nocons addtext(Current coop status, No) dec(3)nonotes

qui reghdfe lnw aexpWE_coop_days aexpWE_coop_aexpWE tenure_days tenure_sq_days aexpE_days aexpE_sq_days coop firmage, absorb(idperson sector1d month year provinceplant skill ftime) cluster(idperson) keepsing
outreg2 using "${path}\tables\returns_experience_annual.tex", append stnum(replace coef=coef*(10^6), replace se=se*(10^6)) keep(aexpWE_coop_days aexpWE_coop_aexpWE tenure_days tenure_sq_days aexpE_days aexpE_sq_days) tex /*
*/ nocons addtext(Current coop status, Yes) dec(3)nonotes

qui reghdfe lnw aexpWE_coop_days aexpWE_coop_aexpWE aexpWE_coop_tenure_days tenure_days tenure_sq_days aexpE_days aexpE_sq_days firmage , absorb(idperson sector1d month year provinceplant skill ftime) cluster(idperson) keepsing
outreg2 using "${path}\tables\returns_experience_annual.tex", append stnum(replace coef=coef*(10^6), replace se=se*(10^6)) keep(aexpWE_coop_days aexpWE_coop_aexpWE aexpWE_coop_tenure_days tenure_days tenure_sq_days aexpE_days aexpE_sq_days ) tex /*
*/ nocons addtext(Current coop status, No) dec(3)nonotes

qui reghdfe lnw aexpWE_coop_days aexpWE_coop_aexpWE aexpWE_coop_tenure_days tenure_days tenure_sq_days aexpE_days aexpE_sq_days coop firmage, absorb(idperson sector1d month year provinceplant skill ftime) cluster(idperson) keepsing
outreg2 using "${path}\tables\returns_experience_annual.tex", append stnum(replace coef=coef*(10^6), replace se=se*(10^6)) keep(aexpWE_coop_days aexpWE_coop_aexpWE aexpWE_coop_tenure_days tenure_days tenure_sq_days aexpE_days aexpE_sq_days ) tex /*
*/ nocons addtext(Current coop status, Yes) dec(3)nonotes

**Catch-up rate
predictnl rate_catch = 360*100*(_b[aexpWE_coop_days] + _b[aexpWE_coop_aexpWE]*1465 + _b[aexpWE_coop_aexpWE]*tenure_days), se(rate_catch_se)
gen ci_low = rate_catch - 1.96*rate_catch_se
gen ci_high = rate_catch + 1.96*rate_catch_se

bys rate_catch: keep if _n==1
keep rate_catch ci_* tenure_days
drop if tenure_days>3600

qui grstyle init
qui grstyle set plain, compact grid dotted /*no grid*/
qui grstyle color major_grid gs13
qui grstyle set symbol
qui grstyle set lpattern
qui grstyle set color hue, n(2)   
qui grstyle set color hue, n(2)   opacity(34): p#markfill


tw (line rate_catch tenure_days, lcolor("31 119 180") mcolor("31 119 180 %34")) (rarea ci_low ci_high tenure_days, color("31 119 180 %15") lwidth(none) sort),  yline(0, lcolor(black%25))  xtitle("Tenure") ytitle("Differential return")  ylabel(-1.8(0.3)0.3) xlabel(0 "0" 720 "2"  1440 "4"  2160 "6" 2880 "8" 3600 "10" ) legend(off)
qui graph export "${path}\figurescatchup_rate.png", as(png) replace


