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

**First LM experience - first 12 months after graduation working half of the time (>180 days)
egen pid = group(idperson)
xtset pid month_wobs
tsfill
gen total_mdays = Edays
gen sum = l1.total_mdays + l2.total_mdays + l3.total_mdays + l4.total_mdays + l5.total_mdays + l6.total_mdays + l7.total_mdays + l8.total_mdays + l9.total_mdays + l10.total_mdays + l11.total_mdays + l12.total_mdays
gen flag = month_wobs if sum>180 & sum<.
format flag %tm
bys pid: egen min = min(flag)
gen Efirst  = min - 12
format Efirst  %tm

drop if month_wobs < Efirst 
drop if idperson==""
drop sum flag min pid

bys idperson (month_wobs): gen order = _n
replace order = 12 if order<12
replace order = . if order>12

gen first6 = order==12

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

foreach v in status socialeco partner creation_date size legal2firm type2plant sector1d provinceplant skill contract ptime {
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
qui gen firmage = yofd(dofm(month_wobs)) - yofd(creation_date)


*Ftime
gen ftime = ptime>95

drop municipality* idplantmain handicap selfemp_status regime merged idspell skill_start contract_start contract skill ptime ptime_start spellstart_old skill year

save ../dta/workers_monthly_firstjob_180daysin12months.dta, replace



/*
gen year = yofd(dofm(month_wobs))
egen idfirm_new = group(idfirm)

*Keep main job in a year: most days worked in the year
bys idperson idplant_new year: egen firmdays = total(Edays)
bys idperson year: egen maxdays=max(firmdays)


*Income and days compute total 
foreach v in WEdays SEdays OEdays UIdays WEincome WEincome_CHK SEincome OEincome UIincome {
bys idperson year: egen total`v' = total(`v')
replace `v' = total`v'
drop total`v'
}

*Worker time-varying variables compute the last of the year
foreach v in aexpE aexpWE aexpWE_coop aexpSE {
bys idperson year: gen last`v' = `v'[_N]
replace `v' = last`v' 
drop last`v'   
}

keep if firmdays==maxdays 

gcollapse (lastnm) first* WEdays SEdays OEdays UIdays WEincome WEincome_CHK SEincome OEincome UIincome mainlyGR strong_* Efirst aexpE aexpWE aexpWE_coop aexpSE  sector1d sector2d socialeco partner pygrad educ female datebirth provinceresidence provincebirth provinceaffil1 provinceplant creation_date size coop ms hs oec misscontract ftime firmage idfirm_new idplant_new spellstart_date spellend_date, by(idperson year)

*Urate
gen province = provincebirth 
rename year year_obs
gen year = pygrad
merge m:1 province year using "../dta/urate.dta",keep(1 3) nogen
drop year province
rename urate urate_t0
rename year_obs year
gen province = provinceplant
merge m:1 province year using "../dta/urate.dta", keep(1 3) keepusing(urate) nogen
rename urate urate_t
*Potential experience
gen pexp = year - pygrad 
*Tenure
qui gen ten = year - yofd(spellstart_date) + 1



