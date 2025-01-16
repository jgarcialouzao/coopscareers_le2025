clear
*cap cd "C:\Users\Gabriel\Dropbox\ScarringCoop (1)\Stata\dta"
*cd "C:\Users\jgarcialouzao\Dropbox\ScarringCoop (1)\Stata\do\"
cd "C:\Users\1468466\Dropbox\ScarringCoop (1)\Stata\do"

clear all
capture log close
capture program drop _all
set more 1
set seed 13
set max_memory 200g
set segmentsize 3g
set cformat %5.4f
qui grstyle init
qui grstyle set plain, compact grid dotted /*no grid*/
qui grstyle color major_grid gs13
qui grstyle set symbol
qui grstyle set lpattern
qui grstyle set color hue, n(2)   
qui grstyle set color hue, n(2)   opacity(34): p#markfill


use "../dta/workers_yearly.dta", clear

//#1 Distribution of duration of first job by coop status (time spent, % lifetime income). 

egen year_firstjob=min(year), by(idperson)
gen z=1 if year==year_firstjob
gen lnfirstdays=ln(firstjob_days)
gen coop_entry = first_socialeco==2

//density plot: days at first job
set dp period
preserve
keep if z==1
twoway (kdensity lnfirstdays if coop_entry==0,  xlabel(0(2)10) xtitle("") lwidth(0.3) lcolor("255 141 61") mcolor("255 141 61 %34")) || (kdensity lnfirstdays if coop_entry==1, xlabel(0(2)10) lwidth(0.3) lcolor("31 119 180") mcolor("31 119 180 %34")),  graphr(color(white)) ytitle(Density)  legend(order( 1 "Conventional firms" 2 "Cooperatives"))  xtitle("(log) Days at first employer", size(small))
graph export "../figures/density_days_atfirstjob.png", as(png) replace 
restore

//bar plot: days at first job
gen time_firstjob=.
replace time_firstjob=1 if firstjob_days<90
replace time_firstjob=2 if firstjob_days>=90 & firstjob_days<360
replace time_firstjob=3 if firstjob_days>=365 & firstjob_days<720
replace time_firstjob=4 if firstjob_days>=720 & firstjob_days<1800
replace time_firstjob=5 if firstjob_days>=1800
replace time_firstjob=. if firstjob_days==.
label define time 1 "Less than 3 months" 2 "3 months-1 year" 3 "1-2 years" 4 "2-5 years" 5 "5 years or more" 
label values time_firstjob time
tab time_firstjob, g(t)

preserve 
keep if z==1
mat def B=J(5,2,.)
sum t1 if coop_entry==0
mat B[1,1]=r(mean)
sum t1 if coop_entry==1 
mat B[1,2]=r(mean)
sum t2 if coop_entry==0
mat B[2,1]=r(mean)
sum t2 if coop_entry==1 
mat B[2,2]=r(mean)
sum t3 if coop_entry==0
mat B[3,1]=r(mean)
sum t3 if coop_entry==1 
mat B[3,2]=r(mean)
sum t4 if coop_entry==0
mat B[4,1]=r(mean)
sum t4 if coop_entry==1 
mat B[4,2]=r(mean)
sum t5 if coop_entry==0
mat B[5,1]=r(mean)
sum t5 if coop_entry==1 
mat B[5,2]=r(mean)
mat list B
svmat B
drop if B1==.
gen time_firstjob2 = 1 in 1
replace time_firstjob2 = 2 in 2
replace time_firstjob2 = 3 in 3
replace time_firstjob2 = 4 in 4
replace time_firstjob2 = 5 in 5
label define time2 1 "3 months or less" 2 "3-12 months" 3 "1-2 years" 4 "2-5 years" 5 "5 or more years" 
label values time_firstjob2 time2

graph bar (asis) B1 B2, over(time_firstjob2, label(labsize(small))) ylabel(0(0.1).5, labsize(small))  ///
bar(1, color("255 141 61 %25") lwidth(medium)) bar(2, color("31 119 180 %25") lwidth(medium) lpattern(solid)) bargap(10) legend(order(1 "Conventional firms" 2 "Cooperatives") size(3)) ytitle("Fraction of workers", size(small)) graphregion (fcolor(white)) 
graph export "../figures/Time_at_firstjob.png", replace
restore




*longrun variables
bys idperson: egen longrun_income= total(WEincome_CHK + SEincome +OEincome)
bys idperson: egen longrun_days= total(WEdays + SEdays + OEdays)

gen share_income = firstjob_earnings / longrun_income
gen share_days = firstjob_days / longrun_days

keep if z==1
keep share* coop_entry
foreach v in share_income share_days {
gen firstjob_`v' = .
replace firstjob_`v'=1 if `v'<1/4
replace firstjob_`v'=2 if `v'>=1/4 & `v'<1/2
replace firstjob_`v'=3  if `v'>=1/2 & `v'<3/4
replace firstjob_`v'=4 if `v'>=3/4
}

preserve 
tab firstjob_share_days, g(t)
mat def B=J(4,2,.)
sum t1 if coop_entry==0
mat B[1,1]=r(mean)
sum t1 if coop_entry==1 
mat B[1,2]=r(mean)
sum t2 if coop_entry==0
mat B[2,1]=r(mean)
sum t2 if coop_entry==1 
mat B[2,2]=r(mean)
sum t3 if coop_entry==0
mat B[3,1]=r(mean)
sum t3 if coop_entry==1 
mat B[3,2]=r(mean)
sum t4 if coop_entry==0
mat B[4,1]=r(mean)
sum t4 if coop_entry==1 
mat B[4,2]=r(mean)
mat list B
svmat B
drop if B1==.
gen firstjob_share_days2=1 in 1
replace firstjob_share_days2=2 in 2
replace firstjob_share_days2=3  in 3
replace firstjob_share_days2=4 in 4
label define time2 1 "25% or less" 2 "25-50%" 3 "50-75%" 4 "75% or more"
label values firstjob_share_days2 time2

graph bar (asis) B1 B2, over(firstjob_share_days2, label(labsize(small))) ylabel(0(0.2)0.8, labsize(small))  ///
bar(1, color("255 141 61 %25") lwidth(medium)) bar(2, color("31 119 180 %25") lwidth(medium) lpattern(solid)) bargap(10) legend(order(1 "Conventional firms" 2 "Cooperatives") size(3)) ytitle("Fraction of workers", size(small)) graphregion (fcolor(white))
graph export "../figures/Firstjob_days_lifetime.png", replace
restore

preserve 
tab firstjob_share_income, g(t)
mat def B=J(4,2,.)
sum t1 if coop_entry==0
mat B[1,1]=r(mean)
sum t1 if coop_entry==1 
mat B[1,2]=r(mean)
sum t2 if coop_entry==0
mat B[2,1]=r(mean)
sum t2 if coop_entry==1 
mat B[2,2]=r(mean)
sum t3 if coop_entry==0
mat B[3,1]=r(mean)
sum t3 if coop_entry==1 
mat B[3,2]=r(mean)
sum t4 if coop_entry==0
mat B[4,1]=r(mean)
sum t4 if coop_entry==1 
mat B[4,2]=r(mean)
mat list B
svmat B
drop if B1==.
gen firstjob_share_income2=1 in 1
replace firstjob_share_income2=2 in 2
replace firstjob_share_income2=3  in 3
replace firstjob_share_income2=4 in 4
label define time2 1 "25% or less" 2 "25-50%" 3 "50-75%" 4 "75% or more"
label values firstjob_share_income2 time2

graph bar (asis) B1 B2, over(firstjob_share_income2, label(labsize(small))) ylabel(0(0.2)0.8, labsize(small))  ///
bar(1, color("255 141 61 %25") lwidth(medium)) bar(2, color("31 119 180 %25") lwidth(medium) lpattern(solid)) bargap(10) legend(order(1 "Conventional firms" 2 "Cooperatives") size(3)) ytitle("Fraction of workers", size(small)) graphregion (fcolor(white))
graph export "../figures/Firstjob_income_lifetime.png", replace
restore

