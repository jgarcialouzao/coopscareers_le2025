* STATA 16
* MCVL - Descriptive Statistics
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

*DESCRIPTIVE POOLED SAMPLE - FULL CAREER

*These are AB restrictions
*qui keep if yofd(datebirth)>=1968 & yofd(datebirth)<=1983
*qui gen age = yofd(dofm(month_wobs)) - yofd(datebirth)
*drop if age>35
*keep if mainlyGR==1
*keep if strong==1

*High-school
qui gen highschool = educ==2
label var highschool "High-school"

*College
qui gen college = educ==3
label var college "College"


*Two sectos
qui gen manuf = sector1d==2
label var manuf  "Manufacturing"
qui gen construction = sector1d==3
label var construction "Construction"

*Located in 4 largest metropolitan areas (Madrid, Barcelona, Sevilla, Valencia)
gen bigcity= 1 if provinceplant==8 | provinceplant==28 | provinceplant==41 | provinceplant==46
recode bigcity .=0
label var bigcity "Big city"

*Young firmage
label var firmage "Firm age"
gen young = firmage<3
label var young "Young firm"

foreach v in E {
gen dailyw`v' = `v'income/`v'days  
label var dailyw`v' "Daily income `v'" 
}

label var aexpE "Actual experience (yr)"  

gen tmp = year - yofd(dofm(Efirst )) + 1

gen working_share = 100*aexpE / tmp

label var working_share "Time worked since first job (%)"

label var coop "Main job in cooperative"
label var ftime "Full-time job"
gen ten = int((month_wobs - mofd(spellstart_date)))/12
label var ten   "Tenure (yr)"
qui gen age =  int((month_wobs - mofd(datebirth)))/12
label var age   "Age (yr)"

gen coop_entry = first_socialeco==2
gen selfemp = status==2
label var selfemp "Self-Employed"


foreach n in 0 1 {

estpost summarize female age aexpE working_share highschool college dailywE selfemp ms hs oec ftime ten coop firmage manuf construction bigcity  if coop_entry==`n' 
est store desc_coop_entry`n'_all

}
esttab desc_coop_entry0_all desc_coop_entry1_all using ../tables/desc_monthly.tex, replace cells("mean(fmt(%13.2fc))") label

