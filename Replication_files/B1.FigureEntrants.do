* STATA 16
* MCVL - Descriptive Figures
* Jose Garcia-Louzao


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




*1) Observations and entry conditions by type of firm
use ../dta/workers_yearly.dta, clear

bys idperson: keep if _n == 1

gen nowrk = 1

gen coop_entry = first_socialeco==2

gcollapse (sum) nowrk (mean) urate_t0,  by(coop_entry pygrad)

tw (connect nowrk pygrad if coop_entry==0, lcolor("255 141 61") mcolor("255 141 61 %34")) (connect nowrk pygrad if coop_entry==1, yaxis(2) lcolor("31 119 180") mcolor("31 119 180 %34")), ylabel(160(20)260, axis(2))  legend(order( 1 "Conventional firms" 2 "Cooperatives (right)"))  xtitle("Graduation year", size(small)) ytitle("Number of workers") ytitle("Number of workers", axis(2) size(small))  xlabel(1984(2)2003) ylabel(8000(1000)12000)
qui graph export "../figures/workers_pygrad.png", as(png) replace

tw (connect urate pygrad if coop_entry==0, lcolor("255 141 61") mcolor("255 141 61 %34")) (connect urate pygrad if coop_entry==1, lcolor("31 119 180") mcolor("31 119 180 %34")), legend(order( 1 "Conventional firms" 2 "Cooperatives"))  xtitle("Graduation Year", size(small)) ytitle("Provincial uemployment rate", size(small)) xlabel(1984(2)2003)
qui graph export "../figures/urate_pygrad.png", as(png) replace







