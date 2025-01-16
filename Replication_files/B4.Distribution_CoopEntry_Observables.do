* STATA 16
* MCVL - Observed ability
* Jose Garcia-Louzao


clear all
capture log close
capture program drop _all
set more 1
set seed 13
set max_memory 200g
set segmentsize 3g
set cformat %5.4f


use ../dta/workers_monthly.dta, clear

*Dependent variable: log daily income, log annual income, and log annual days
gen lnw = ln((WEincome_CHK + SEincome + OEincome)/(WEdays + SEdays + OEdays))
keep if lnw!=.

keep idperson coop_entry educ first_skill
rename first_skill skill

bys idperson: keep if _n==1

keep idperson coop_entry educ skill 

*Education
gen primary = educ==1
label var primary "Primary education"
gen secondary = educ==2
label var secondary "Secondary education"
gen tertiary = educ==3
label var tertiary "Tertirary education"

*Skill
gen vh_skill = skill==1
label var vh_skill "Very-high-skill"

gen h_skill = skill>=2 & skill<=3
label var h_skill "High-skill"

gen mh_skill = skill==4
label var mh_skill "Medium-high-skill"

gen ml_skill = skill>=5 & skill<=7
label var ml_skill "Medium-low-skill"

gen l_skill = skill>=8 
label var l_skill "Low-skill"


lab def coop_entry 0 "Conventional firm" 1 "Cooperative", modify

estpost tabstat tertiary secondary  primary  vh_skill h_skill mh_skill ml_skill l_skill , by(coop_entry) statistics(mean)



esttab  using ../tables/desc_obs_skills.tex, replace cells("tertiary  secondary  primary vh_skill h_skill mh_skill ml_skill l_skill") noobs nomtitle nonumber label  varwidth(20)
