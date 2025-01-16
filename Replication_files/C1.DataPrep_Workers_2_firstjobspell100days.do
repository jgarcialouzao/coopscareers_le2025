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

**First LM experience - wage-employment spell that lasted 100 or more days
gen dur = spellend_date - spellstart_date 
gen flag = 1 if dur>=100
bys idperson: egen Efirst = min(mofd(spellstart_date)) if flag==1 & status==1
drop flag dur
bys idperson (Efirst): replace Efirst = Efirst[1] if Efirst==.


foreach v in status socialeco partner creation_date legal2firm type2plant sector1d provinceplant skill contract ptime {
gen first_`v' = `v' if Efirst==mofd(spellstart_date)
bys idperson (first_`v'): replace first_`v'=first_`v'[1] if first_`v'==.	
}
format first_creation_date %td


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

qui compress

save ../dta/workers_monthly_firstjobspell100days.dta, replace


