* STATA 16
* MCVL - Final Monthly Panel
* Jose Garcia-Louzao

clear all
capture log close
capture program drop _all
set more 1
set seed 13
set max_memory 200g
set segmentsize 3g


foreach y in 1984 1997 {
preserve
tempfile pygrad`y'
use ../dta/fullpanel_pygrad`y'.dta, clear

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
save `pygrad`y''
restore
}

use `pygrad1997', clear
append using `pygrad1984'


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
drop actual_days  days_afterfirstjob last


qui compress

save ../dta/workers_monthly.dta, replace


