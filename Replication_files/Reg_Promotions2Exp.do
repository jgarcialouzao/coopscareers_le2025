
//Transition between profesional categories, broad groups. Promotions. Gabriel Burdin

use ${path}\dta\workers_monthly.dta, clear
*Dependent variable: log daily income, log annual income, and log annual days
gen lnw = ln((WEincome_CHK + SEincome + OEincome)/(WEdays + SEdays + OEdays))

keep if lnw!=.

*Potential experience (in years)
gen pexp = year - pygrad 

keep if status==1
gen contract_long = 0 if misscontract==1
replace contract_long = 1 if oec==0
replace contract_long = 2 if oec==1

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


replace skill = D1skill_oldskill if dofm(month_wobs)<D1skill_date & skill<D1skill_oldskill & D1skill_date!=.
drop D1* 


replace skill=10 if (skill==11 | skill==12 | skill==13)
replace first_skill=10 if (first_skill==11 | first_skill==12 | first_skill==13)

*Inverted order (low to high skill)
gen skillb=.
replace skillb=1 if skill==10
replace skillb=2 if skill==9
replace skillb=3 if skill==8
replace skillb=4 if skill==7
replace skillb=5 if skill==6
replace skillb=6 if skill==5
replace skillb=7 if skill==4
replace skillb=8 if skill==3
replace skillb=9 if skill==2
replace skillb=10 if skill==1


/*
*Inverted order (low to high skill)
gen first_skillb=.
replace first_skillb=1 if first_skill==10
replace first_skillb=2 if first_skill==9
replace first_skillb=3 if first_skill==8
replace first_skillb=4 if first_skill==7
replace first_skillb=5 if first_skill==6
replace first_skillb=6 if first_skill==5
replace first_skillb=7 if first_skill==4
replace first_skillb=8 if first_skill==3
replace first_skillb=9 if first_skill==2
replace first_skillb=10 if first_skill==1

egen year_lastjob=max(month_wobs), by(idperson)
gen n=1 if month_wobs==year_lastjob

gen last_skill=skillb if n==1 & status==1
egen last_skill2b=max(last_skill), by(idperson)
*/
*duration_skill
bys idperson skillb (month_wobs): gen skill_tenure = sum(tenure_days)
gen skill_tenure_sq=skill_tenure^2

*Regs returns to coop experience in terms of promotion chances
egen pid = group(idperson)


bys idperson (month_wobs): gen promotion = skillb[_n+1]>skillb & skillb[_n+1]!=.
bys idperson (month_wobs): gen demotion  = skillb>skillb[_n+1] & skillb[_n+1]!=.

*Promotion without demotions
bys idperson: egen max=max(demotion)
gen promotion2 = .
replace promotion2 = 0 if promotion==0 & max==0
replace promotion2 = 1 if promotion==1 & max==0

*Promotion without demotions and only to high-level
gen promotion3    = .
replace promotion3    = 0 if promotion==0 & max==0
bys idperson (month_wobs): replace promotion3    = 0 if promotion==1 &  skillb[_n+1]<8 & max==0 
bys idperson (month_wobs): replace promotion3    = 1 if promotion==1 &  skillb[_n+1]>=8 & max==0 

/*
*Transition professional categories coop==0
preserve
*keep if n==1
drop if first_skillb==. | last_skill2b==.
gen ones=1 if status==1
collapse (count) ones if status==1 & coop_entry==0, by(first_skillb last_skill2b)
fillin first_skillb last_skill2b
replace ones=0 if ones==.
sum ones
replace ones=ones/`r(sum)'
two contour ones first_skillb last_skill2b, heatmap scheme(s1mono) ccuts(0(0.001)0.01) interp(none) ///
clegend(off) plotregion(lcolor(white)) ecolor(orange*0.4) ///
xtitle("Current professional category") ytitle("First professional category") ///
    xlabel(1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "10", angle(0)) ///
    ylabel(1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "10", angle(0)) ///
	title("A. First employer: conventional firm", size (3))
*graph export "C:\Users\Gabriel\Dropbox\ScarringCoop (1)\Results\Descriptive Stats\professionalCAT_heatmap_capital.png", replace
restore

*Transition professional categories coop==1

preserve
drop if first_skillb==. | last_skill2b==.
gen ones=1 if status==1
collapse (count) ones if status==1 & coop_entry==1, by(first_skillb last_skill2b)
fillin first_skillb last_skill2b
replace ones=0 if ones==.
sum ones
replace ones=ones/`r(sum)'
two contour ones first_skillb last_skill2b, heatmap scheme(s1mono) ccuts(0(0.001)0.01) interp(none) ///
clegend(off) plotregion(lcolor(white)) ecolor(eltblue) ///
xtitle("Current professional category") ytitle("First professional category") ///
    xlabel(1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "10", angle(0)) ///
    ylabel(1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "10", angle(0)) ///
	title("B. First employer: cooperative firm", size (3))
graph export "../figures/professionalCAT_heatmap_coop.png", replace
restore
*/

 *Return of coop experience on promotion
 
keep lnw month_wobs promo* aexpWE_coop_days aexpWE_coop_aexpWE  aexpE_days aexpE_sq_days skill_tenure skill_tenure_sq firmage idperson sector1d month year provinceplant skillb*  ftime coop  aexpWE_coop_tenure_days tenure_days tenure_sq_days

reghdfe promotion aexpWE_coop_days aexpWE_coop_aexpWE aexpWE_coop_tenure_days  tenure_days tenure_sq_days aexpE_days aexpE_sq_days  firmage, absorb(idperson sector1d month year provinceplant skillb ftime) cluster(idperson) keepsing
outreg2 using "${path}\tables/returns_experience_promo.tex", replace stnum(replace coef=coef*(10^6), replace se=se*(10^6)) keep(aexpWE_coop_days aexpWE_coop_aexpWE aexpWE_coop_tenure_days aexpE_days aexpE_sq_days tenure_days tenure_sq_days) tex /*
*/ nocons addtext(Current coop status, No) dec(3) nonotes

reghdfe promotion aexpWE_coop_days aexpWE_coop_aexpWE aexpWE_coop_tenure_days  tenure_days tenure_sq_days aexpE_days aexpE_sq_days coop firmage, absorb(idperson sector1d month year provinceplant skillb ftime) cluster(idperson) keepsing
outreg2 using "${path}\tables/returns_experience_promo.tex", append stnum(replace coef=coef*(10^6), replace se=se*(10^6)) keep(aexpWE_coop_days aexpWE_coop_aexpWE aexpWE_coop_tenure_days aexpE_days aexpE_sq_days tenure_days tenure_sq_days) tex /*
*/ nocons addtext(Current coop status, Yes) dec(3) nonotes


reghdfe promotion2 aexpWE_coop_days aexpWE_coop_aexpWE aexpWE_coop_tenure_days tenure_days tenure_sq_days aexpE_days aexpE_sq_days firmage, absorb(idperson sector1d month year provinceplant skillb ftime) cluster(idperson) keepsing
outreg2 using "${path}\tables/returns_experience_promo.tex", append stnum(replace coef=coef*(10^6), replace se=se*(10^6)) keep(aexpWE_coop_days aexpWE_coop_aexpWE aexpWE_coop_tenure_days aexpE_days aexpE_sq_days tenure_days tenure_sq_days) tex /*
*/ nocons addtext(Current coop status, No) dec(3) nonotes

reghdfe promotion2 aexpWE_coop_days aexpWE_coop_aexpWE aexpWE_coop_tenure_days tenure_days tenure_sq_days aexpE_days aexpE_sq_days coop firmage, absorb(idperson sector1d month year provinceplant skillb ftime) cluster(idperson) keepsing
outreg2 using "${path}\tables/returns_experience_promo.tex", append stnum(replace coef=coef*(10^6), replace se=se*(10^6)) keep(aexpWE_coop_days aexpWE_coop_aexpWE aexpWE_coop_tenure_days aexpE_days aexpE_sq_days tenure_days tenure_sq_days) tex /*
*/ nocons addtext(Current coop status, Yes) dec(3) nonotes


reghdfe promotion3 aexpWE_coop_days aexpWE_coop_aexpWE aexpWE_coop_tenure_days tenure_days tenure_sq_days aexpE_days aexpE_sq_days firmage, absorb(idperson sector1d month year provinceplant skillb ftime) cluster(idperson) keepsing
outreg2 using "${path}\tables/returns_experience_promo.tex", append stnum(replace coef=coef*(10^6), replace se=se*(10^6)) keep(aexpWE_coop_days aexpWE_coop_aexpWE aexpWE_coop_tenure_days aexpE_days aexpE_sq_days tenure_days tenure_sq_days) tex /*
*/ nocons addtext(Current coop status, No) dec(3) nonotes

reghdfe promotion3 aexpWE_coop_days aexpWE_coop_aexpWE aexpWE_coop_tenure_days tenure_days tenure_sq_days aexpE_days aexpE_sq_days coop firmage, absorb(idperson sector1d month year provinceplant skillb ftime) cluster(idperson) keepsing
outreg2 using "${path}\tables/returns_experience_promo.tex", append stnum(replace coef=coef*(10^6), replace se=se*(10^6)) keep(aexpWE_coop_days aexpWE_coop_aexpWE aexpWE_coop_tenure_days aexpE_days aexpE_sq_days tenure_days tenure_sq_days) tex /*
*/ nocons addtext(Current coop status, Yes) dec(3) nonotes

