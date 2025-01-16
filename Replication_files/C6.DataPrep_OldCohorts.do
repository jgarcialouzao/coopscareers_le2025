* STATA 16
* MCVL - Create worker panel
* Jose Garcia-Louzao

clear all
capture log close
capture program drop _all
set more 1
set seed 13
set segmentsize 3g
set niceness 10

*Last MCVL year
global maxy = 2018

use ../dta/wpanel.dta, clear

*Valid info on personal traits
qui drop if datebirth==. | female==. | (nationality==. & countrybirth==. & provincebirth==.) | education == .

*Only Spanish born cohorts
qui drop if countrybirth!=0 | nationality!=0
drop datedeath countrybirth nationality year_mcvl

*Drop inviduals born in Ceuta/Melilla
qui drop if provincebirth>50

*Set education to max level to define graduation
qui bys idperson: egen max=max(education)
qui replace education = max // highest education attainment
qui drop max

*Education categories
qui g educ=.
qui replace educ=1 if education<=32
qui replace educ=2 if education>=40 & education<=43
qui replace educ=3 if education>=44 & education!=.
label define educlb 0 "Missing ed." 1 "Primary ed. (or less)" 2 "Secondary ed." 3 "Tertiary ed.", modify
label values educ educlb
qui drop education

*Predicted graduation year 
*Education specific, refers to the year when they turn the official graduation age
*We follow workers after that year
qui gen pygrad = .
qui replace pygrad  = yofd(datebirth) + 16 if educ==1
qui replace pygrad  = yofd(datebirth) + 18 if educ==2
qui replace pygrad  = yofd(datebirth) + 23 if educ==3


*Keep graduation cohorts to follow them for 15 years
qui keep if pygrad>=1984 & pygrad<=2003

bys idperson: keep if _n == 1

*Regular wage-employment
merge 1:m idperson  using ../dta/contempspells.dta, keep(match)
drop _m
gen status = 1

*Firm info and embedded restrictions
merge m:1 idplant using ../dta/firms.dta , keep(match) keepusing(creation_date provinceplant sector1d socialeco partner legal* type*)
qui drop _m

*Add other employment spells (self-employment and other regimes)
append using ../dta/contotherspells.dta
replace status = 2 if (regime>=521 & regime<=540)
replace status = 3 if status==.


**Add unemployment spells
append using ../dta/contuispells.dta
replace status = 4 if ui==1
drop ui

label define statuslb 1 "Wage-Employment" 2 "Self-Employment" 3 "Other Employment Forms" 4 "Unemploment Insurance", modify
label values status statuslb
label var status "LM Status"

drop coop soleprop_we coop_we coop_worker_we coop_partner_we ls_we ls_worker_we ls_partner_we kfirm_we

foreach v in pygrad educ datebirth provincebirth female  {
bys idperson (`v'): replace `v' = `v'[1] if `v'==.
}

*Drop spells starting after last year in the data
drop if spellstart_date>mdy(12,31,$maxy)

*Remove any spell that occur before graduation
drop if yofd(spellstart_date)<=pygrad

*Create idspell
gegen idspell = group(idperson spellstart_date spellend_date idplant)
gegen idplant_new = group(idplant)

**Transform dataset to individual-spell-month format
qui gen month_startspell=mofd(spellstart_date)
qui gen month_endspell=mofd(spellend_date)
qui replace month_endspell = mofd(mdy(12,31,$maxy)) if spellend_date > mdy(12,31,$maxy)

*Number of monthly observations to be expanded
qui gen nobs_spellmonth = (month_endspell - month_startspell) + 1

compress

keep if pygrad>=1984 & pygrad<1990

expand nobs_spellmonth

*Monthly variable
qui gen month_wobs=month_startspell
qui bys idspell (month_wobs): replace month_wobs = month_wobs + _n - 1
qui format month_wobs %tm
qui drop month_start* month_end* nobs_*

qui gen time = yofd(dofm(month_wobs)) - pygrad
drop if time>30
drop time

*Count days worked in a month
*First and last day of a month
gen first=dofm(month_wobs)
gen last=dofm(month_wobs + 1) - 1

gen 	days = .
replace days = spellend_date - first + 1 if spellstart_date<=first & spellend_date<last
replace days = last - spellstart_date + 1 if spellstart_date>first & spellend_date>=last
replace days = spellend_date - spellstart_date + 1  if spellstart_date>first & spellend_date<last

*SS computes month-daily caps by dividing by 360 days per year - 30 days each month
replace days = 30 if spellstart_date<=first & spellend_date>=last
drop first last 

qui gen tmp = mofd(spellstart_old)
gen idplant_final = idplant
foreach v in idplant skill ptime contract {
qui replace `v'= `v'_start if month_wobs<tmp
}
replace idplant = idplant_final if idplant==""
qui drop tmp 

*Earnings are reported in a monthly basis for worker-plant matches - if more than one spell with the same employer in a given month, then collapse days and keep last obs
bys idperson idplant month_wobs: gegen tmp = total(days)
bys idperson idplant month_wobs: gen nobs = _N
replace days = tmp if nobs>1
replace days = 30 if days>30  & days!=.
bys idperson idplant month_wobs (spellend_date): keep if _n == _N
drop tmp nobs* 

*Add monthly income
merge 1:1 idperson idplant month_wobs using ../dta/selfemp_wages19802018.dta, keep(1 3) keepusing(w)
qui drop _m
qui rename w selfempw
merge 1:1 idperson idplant month_wobs using ../dta/wages_m19802004.dta, keep(1 3) keepusing(w)
qui drop _m
qui rename w w8404
merge 1:1 idperson idplant month_wobs using ../dta/wages_m20052018.dta, keep(1 3) keepusing(w)
qui drop _m
qui gen monthlyw = w8404 if yofd(dofm(month_wobs))<2005 
qui replace monthlyw = w if  yofd(dofm(month_wobs))>=2005 
qui replace monthlyw = selfempw if monthlyw==.
qui drop w8404 w selfempw
qui replace monthlyw=. if monthlyw<1
*Recover missing information on wages if we have consecutive observations within same plant
gen negmobs = -month_wobs
qui bys idperson (month_wobs): replace monthlyw = monthlyw[_n-1]   if monthlyw==.   & idfirm==idfirm[_n-1] & status!=4 & status[_n-1]!=4
qui bys idperson (negmobs):    replace monthlyw = monthlyw[_n-1]   if monthlyw==.   & idfirm==idfirm[_n-1] & status!=4 & status[_n-1]!=4
qui drop negmobs

*Real terms
qui merge m:1 month_wobs using  ../dta/cpi2018m.dta, keep(1 3) keepusing(cpi2018)
qui drop _m 
qui replace monthlyw = monthlyw/(cpi2018/100)
keep if monthlyw>1 & monthlyw<.

*Censored earnings
gen year = yofd(dofm(month_wobs))
gen month = month(dofm(month_wobs))
gen group = skill
merge m:1 year month group using ../dta/realbounds.dta, nogen keep (1 3)
gen topcoded = monthlyw>=max_base & monthlyw<. & status==1
replace monthlyw = max_base if topcoded==1
*Daily wages
qui gen dailyw = monthlyw/days
qui replace dailyw = max_base/30 if dailyw>=max_base/30 & dailyw<.

*Corrected earnings
merge 1:1 idperson idplant month_wobs using ../dta/simwages_CHK.dta, nogen keep(1 3)
qui gen monthlyw_CHK = dailyw_CHK*days
qui replace monthlyw_CHK = monthlyw if monthlyw_CHK == . & monthlyw!=.
replace dailyw_CHK = dailyw if dailyw_CHK==. & dailyw!=.


/*
qui replace idplant = idplant_final
qui drop idplant_final idplant_start
*/

*If more than one observation in a month, keep main employer (wage-employment observation, highest earnings, highest working days) but add-up days and income -- differentiate between employment types
bys idperson month_wobs: gen nobs = _N
bys idperson month_wobs status: egen total= total(days)
replace total = 30 if total>30
gen WEdays = total if status==1
gen SEdays = total if status==2
gen OEdays = total if status==3
gen UIdays = total if status==4

foreach v in UI WE OE SE {
replace `v'days = 0 if `v'days==.	
}

replace days = 0 if status==4
bys idperson month_wobs: egen Edays = total(days)
replace Edays = 30 if Edays>30 & status!=4
drop total
bys idperson month_wobs status: egen income = total(monthlyw)
gen WEincome = income if status==1
gen SEincome = income if status==2
gen OEincome = income if status==3
gen UIincome = income if status==4

foreach v in UI WE OE SE {
replace `v'income= 0 if `v'income==.	
}

bys idperson month_wobs status: egen income_CHK = total(monthlyw_CHK)
gen WEincome_CHK = income_CHK if status==1
replace WEincome_CHK= 0 if WEincome_CHK==.	
bys idperson month_wobs: egen censored = total(topcoded)
drop income income_CHK

bys idperson month_wobs: egen Eincome= total(monthlyw)
drop if nobs>1 & status!=1
drop nobs 
bys idperson month_wobs: gen nobs = _N
bys idperson month_wobs: egen max = max(monthlyw)
drop if nobs>1 & monthlyw!=max
drop nobs max monthlyw
bys idperson month_wobs: gen nobs = _N
bys idperson month_wobs: egen max = max(days)
drop if nobs>1 & days!=max
drop nobs max days
bys idperson month_wobs (spellend_date): keep if _n == _N

*Add size of first employment
gen year_mcvl = yofd(dofm(month_wobs)) 
replace year_mcvl = 2005 if year_mcvl<2005
merge m:1 idplant year_mcvl using ../dta/fpanel.dta, keepusing(size) keep(1 3)
drop year_mcvl _merge cpi

compress

save ../dta/fullpanel_pygrad_1984_1988.dta, replace


**First LM experience - first 6 months after graduation working 100 or more days
egen pid = group(idperson)
xtset pid month_wobs
tsfill
gen total_mdays = Edays
gen sum = l1.total_mdays + l2.total_mdays + l3.total_mdays + l4.total_mdays + l5.total_mdays + l6.total_mdays
gen flag = month_wobs if sum>=100 & sum<.
format flag %tm
bys pid: egen min = min(flag)
gen Efirst  = min - 6
format Efirst  %tm

drop if month_wobs < Efirst 
drop if idperson==""
drop sum flag min pid

bys idperson (month_wobs): gen order = _n
replace order = 6 if order<6
replace order = . if order>6

gen first6 = order==6

*Days worked, income, employers in the first LM experience
bys idperson order: egen first6_days=total(Edays)
label var first6_days "Days worked First 6M"
replace first6_days = . if order==.
bys idperson order: egen first6_earnings=total(Eincome)
replace first6_earnings = . if order==.
label var first6_earnings "Earnings First 6M"
bys idperson idplant (month_wobs): gen one = _n == 1
bys idperson order: egen first6_employers=total(one)
replace first6_employers = . if order==.
drop one
label var first6_employers "No. Employers First 6M"
replace ptime = 100 if ptime==.
bys idperson order: egen first6_ptime=mean(ptime)
label var first6_ptime "Part-time First 6M"
replace first6_ptime = . if order==.

foreach v in days earnings employers ptime {
bys idperson (first6_`v'): replace first6_`v'=first6_`v'[1] if first6_`v'==.
}

*First main employer, more time employed during first 6 months -- if there is a tie, select first
bys idperson idplant order: egen total_days = sum(Edays)
bys idperson order: egen max_days = max(total_days)
gen first_idplant= idplant_new if max_days==total_days	&  first6==1
bys idperson (first_idplant): replace first_idplant=first_idplant[1] if first_idplant==.	
bys idperson: egen sd = sd(first_idplant)
bys idperson (month_wobs): replace first_idplant = idplant_new[1] if sd!=0
drop sd 

foreach v in status socialeco partner creation_date legal2firm type2plant sector1d provinceplant skill contract ptime {
gen first_`v' = `v' if first_idplant==idplant_new 
bys idperson (first_`v'): replace first_`v'=first_`v'[1] if first_`v'==.	
}
format first_creation_date %td
drop order  total_mdays total_days max_days

*Remove workers whose first job was very late, refers to UI, or was in Public Sector or Ceuta/Melilla
drop if yofd(dofm(Efirst )) - pygrad > 5
keep if first_status==1
drop if first_socialeco > 4
drop if (first_legal2firm>=11 & first_legal2firm<=14) | first_type2plant<5081 | first_sector1d>=13 | first_provinceplant>50

*Cooperative variables
qui gen coop_entry = first_socialeco==2
qui gen coop = socialeco==2
replace partner = 0 if socialeco!=2

*LM Experience
*Actual
qui bys idperson (month_wobs): gen aexpE = sum(Edays)/360
qui bys idperson (month_wobs): gen aexpWE = sum(WEdays)/360
qui bys idperson (month_wobs): gen aexpWE_coop = sum(WEdays)/360 if coop==1
qui replace aexpWE_coop = 0 if coop==0
qui bys idperson (month_wobs): gen aexpSE = sum(SEdays)/360 
qui replace aexpSE = 0 if status!=2

*Skill groups
gen ms = skill>3 & skill<8
label var ms "Mid-skill occ."
gen hs = skill>=1 & skill<=3
label var hs "High-skill occ."

*Contract
qui g oec = contract==1|contract==3|contract==65|contract==100|contract==139|contract==189|contract==200|contract==239|contract==289| ///
contract==8|contract==9|contract==11|contract==12|contract==13|contract==20|contract==23|contract==28|contract==29|contract==30|contract==31|contract==32|contract==33|contract==35|contract==38|contract==40|contract==41|contract==42|contract==43|contract==44|contract==45|contract==46|contract==47|contract==48|contract==49|contract==50|contract==51|contract==52|contract==59|contract==60|contract==61|contract==62|contract==63|contract==69|contract==70|contract==71|contract==80|contract==81|contract==86|contract==88|contract==89|contract==90|contract==91|contract==98|contract==101|contract==102|contract==109|contract==130|contract==131|contract==141|contract==150|contract==151|contract==152|contract==153|contract==154|contract==155|contract==156|contract==157|contract==186|contract==209|contract==230|contract==231|contract==241|contract==250|contract==251|contract==252|contract==253|contract==254|contract==255|contract==256|contract==257
label var oec "Open-ended contract"

qui g misscontract = contract==. | contract==0

*Firm age
replace creation_date = spellstart_date if creation_date>spellstart_date & creation_date!=. 
replace creation_date = spellstart_date if status==2 | status==3
qui gen firmage = yofd(dofm(month_wobs)) - yofd(creation_date)


*Ftime
gen ftime = ptime>95

drop municipality* idplantmain handicap selfemp_status regime merged idspell skill_start contract_start contract ptime ptime_start

*Total income and days in firt job
gen flag = 1 if first_idplant == idplant_new
*Ensure it refers to the first relationship: i.e. avoid including future new relationships with the first employer 
bys idperson flag (month_wobs): gen flag1 = 1 if (month_wobs - month_wobs[_n-1]<3)
bys idperson flag (month_wobs): replace flag1 = 1 if _n==1
bys idperson flag (month_wobs): replace flag1 = . if flag1[_n-1]==. & _n!=1
replace flag = . if flag1==.

bys idperson flag: egen firstjob_earnings    = total(WEincome_CHK)
replace firstjob_earnings = . if flag==.
bys idperson flag: egen firstjob_days        = total(WEdays)
replace firstjob_days = . if flag==.
drop flag*
foreach v in firstjob_earnings firstjob_days {
bys idperson (`v'): replace `v' = `v'[1] if `v'==.	
}

*Identify workers with more than 60 percent of their working life under regular wage-employment 
bys idperson: egen actual_days = total(Edays)
bys idperson: egen actual_wedays = total(WEdays)
gen mainlyGR = actual_wedays/actual_days  >= 0.6
label var mainlyGR "Individuals >= 60% of time under regular wage-employment "
drop actual_wedays actual_days

*Identify workers with sufficient LM attachment
** THERE ARE WORKERS WHO WE ONLY OBSERVE FOR 6 MONTHS!
*bys idperson (month_wobs): gen last = month_wobs[_N]
*gen days_afterfirstjob = 360*(yofd(dofm(last+1)) - yofd(dofm(Efirst)))
gen days_afterfirstjob = 360*15
bys idperson: egen actual_days = total(Edays)
gen strong_attachment30 = actual_days/days_afterfirstjob  >= 0.3
label var strong_attachment30 "Workers with sufficient LM attachment: work >= 30% time"
gen strong_attachment50 = actual_days/days_afterfirstjob  >= 0.5
label var strong_attachment50 "Workers with sufficient LM attachment: work >= 50% time"
drop actual_days  days_afterfirstjob 


qui compress

save ../dta/monthly_1984_1988.dta, replace



use ../dta/monthly_1984_1988.dta, clear

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
merge m:1 provinceplant year quarter using ../dta/urqprov_1985_2018.dta, keepusing(urate) keep(match) nogen
drop quarter provinceplant year
rename y year
rename urate urate_t0
gen urate_t0_2= urate_t0*urate_t0
gen urate_t0_3 = urate_t0*urate_t0_2


reghdfe lnw coop_entry  urate_t0 urate_t0_2 urate_t0_3 first_firm_age if pexp<=15, absorb(female educ month year pexp pygrad provincebirth first_sector1d first_ms first_hs first_ftime ) cluster(provincebirth#pygrad) keepsing
outreg2 using ../tables/reg_coopentry_baseline_m_19841989.tex , replace keep(coop_entry) addtext(Additional controls include indicators for: calendar year (34), potential experience (15), province of birth (50), pygrad(20). Column 2 includes gender and education (2 dummies) as additional controls. Column 3 adds a polynomial of the provincial unemployment rate at graduation year in the province of birth. Column 4 adds age of first employer, and indicators for sector of first employer (11), first job is full-time (1), and skill-level of first job (2). Standard errors cluster at provincebirth-graduation year level.) tex(frag) nocons dec(3) nonotes label

reghdfe lnw coop_entry  urate_t0 urate_t0_2 urate_t0_3 first_firm_age, absorb(female educ month year pexp pygrad provincebirth first_sector1d first_ms first_hs first_ftime ) cluster(provincebirth#pygrad) keepsing
outreg2 using ../tables/reg_coopentry_baseline_m_19841989.tex , append keep(coop_entry) addtext(Additional controls include indicators for: calendar year (34), potential experience (15), province of birth (50), pygrad(20). Column 2 includes gender and education (2 dummies) as additional controls. Column 3 adds a polynomial of the provincial unemployment rate at graduation year in the province of birth. Column 4 adds age of first employer, and indicators for sector of first employer (11), first job is full-time (1), and skill-level of first job (2). Standard errors cluster at provincebirth-graduation year level.)  tex(frag) nocons dec(3)  nonotes label



/*

*ARELLANO-BOVER (2020) ESTIMATION STYLE

bys idperson: egen total_income = total(WEincome_CHK + SEincome + OEincome)
bys idperson: egen total_minw   = total(min_base)
bys idperson: egen total_days   = total(WEdays + SEdays + OEdays)

*keep if total_days/360>=3
*keep if total_income>=total_minw/4

*These are AB restrictions
*qui keep if yofd(datebirth)>=1968 & yofd(datebirth)<=1983
*qui gen age = yofd(dofm(month_wobs)) - yofd(datebirth)
*drop if age>35
*keep if mainlyGR==1
*keep if strong_attachment50==1

drop Eincome Edays 

egen Eincome = rsum(WEincome_CHK SEincome OEincome)
egen Edays   = rsum(WEdays SEdays OEday)
egen ALLincome = rsum(WEincome_CHK SEincome OEincome UIincome)

foreach v in Edays ALLincome Eincome {
bys idperson: egen total= total(`v') 
gen log_`v' = ln(total)  
drop `v' total 
}


foreach v in E {
 gen log_`v'dailyw = log_`v'income - log_`v'days  
}

*replace coop = 1 if status==2 & coop_entry==1
bys idperson: egen total = total(coop)
bys idperson: gen  nobs = _N
gen always = (total/nobs)==1
label var always "Always Same Firm Type"
drop total nobs

gen first_firm_age = pygrad- yofd(first_creation)
gen first_ftime = first_ptime>95
gen first_ms = first_skill>3 & first_skill<8
gen first_hs = first_skill>=1 & first_skill<=3

bys idperson: keep if _n == _N


gen quarter = quarter(mdy(1,1,pygrad))
drop provinceplant 
gen provinceplant = provincebirth 
rename year y
gen year = pygrad + 1
merge m:1 provinceplant year quarter using ../dta/urqprov_1985_2018.dta, keepusing(urate) keep(match) nogen
drop quarter provinceplant year 
rename urate urate_t0
gen urate_t0_2= urate_t0*urate_t0
gen urate_t0_3 = urate_t0*urate_t0_2



reghdfe log_ALLincome coop_entry urate_t0 urate_t0_2 urate_t0_3 , absorb(female educ pygrad provincebirth) cluster(provincebirth#pygrad)
outreg2 using ../tables/reg_coopentry_AB_c19841989.tex , replace keep(coop_entry) ctitle(All income) tex(frag) nocons dec(3)  nonotes label

reghdfe log_Eincome coop_entry urate_t0 urate_t0_2 urate_t0_3 , absorb(female educ pygrad provincebirth) cluster(provincebirth#pygrad)
outreg2 using ../tables/reg_coopentry_AB_c19841989.tex , append keep(coop_entry) ctitle(Earnings)  tex(frag) nocons dec(3)  nonotes label

reghdfe log_Edailyw coop_entry urate_t0  urate_t0_2 urate_t0_3 , absorb(female educ pygrad provincebirth) cluster(provincebirth#pygrad)
outreg2 using ../tables/reg_coopentry_AB_c19841989.tex , append keep(coop_entry) ctitle(Avg. daily wage) tex(frag) nocons dec(3)  nonotes label

reghdfe log_Edays coop_entry urate_t0 urate_t0_2 urate_t0_3 , absorb(female educ pygrad provincebirth) cluster(provincebirth#pygrad)
outreg2 using ../tables/reg_coopentry_AB_c19841989.tex , append keep(coop_entry) ctitle(Days worked) tex(frag) nocons dec(3)  nonotes label


reghdfe log_ALLincome coop_entry urate_t0 urate_t0_2 urate_t0_3 first_firm_age , absorb(female educ pygrad provincebirth first_sector1d first_ms first_hs first_ftime) cluster(provincebirth#pygrad)
outreg2 using ../tables/reg_coopentry_AB_c19841989_controls.tex , replace keep(coop_entry) ctitle(All income) tex(frag) nocons dec(3)  nonotes label

reghdfe log_Eincome coop_entry urate_t0 urate_t0_2 urate_t0_3 first_firm_age , absorb(female educ pygrad provincebirth first_sector1d first_ms first_hs first_ftime) cluster(provincebirth#pygrad)
outreg2 using ../tables/reg_coopentry_AB_c19841989_controls.tex , append keep(coop_entry) ctitle(Earnings)  tex(frag) nocons dec(3)  nonotes label

reghdfe log_Edailyw coop_entry urate_t0 urate_t0_2 urate_t0_3 first_firm_age , absorb(female educ pygrad provincebirth first_sector1d first_ms first_hs first_ftime) cluster(provincebirth#pygrad)
outreg2 using ../tables/reg_coopentry_AB_c19841989_controls.tex , append keep(coop_entry) ctitle(Avg. daily wage) tex(frag) nocons dec(3)  nonotes label

reghdfe log_Edays coop_entry urate_t0 urate_t0_2 urate_t0_3 first_firm_age , absorb(female educ pygrad provincebirth first_sector1d first_ms first_hs first_ftime) cluster(provincebirth#pygrad)
outreg2 using ../tables/reg_coopentry_AB_c19841989_controls.tex , append keep(coop_entry) ctitle(Days worked) tex(frag) nocons dec(3)  nonotes label
