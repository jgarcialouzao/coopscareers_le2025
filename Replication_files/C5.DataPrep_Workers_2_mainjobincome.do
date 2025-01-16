* STATA 16
* MCVL - Main job based on income
* Jose Garcia-Louzao

clear all
capture log close
capture program drop _all
set more 1
set seed 13
set max_memory 200g
set segmentsize 3g


use ../dta/workers_monthly.dta, clear
drop year
gen year = yofd(dofm(month_wobs))
egen idfirm_new = group(idfirm)

*Keep main job in a year: most days worked in the year
bys idperson idplant_new year: egen firmincome = total(WEincome_CHK + SEincome + OEincome)
bys idperson year: egen maxincome=max(firmincome)


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

keep if firmincome==maxincome 

gcollapse (lastnm) first* WEdays SEdays OEdays UIdays WEincome WEincome_CHK SEincome OEincome UIincome mainlyGR strong_* Efirst aexpE aexpWE aexpWE_coop aexpSE  sector1d sector2d socialeco partner pygrad educ female datebirth provinceresidence provincebirth provinceaffil1 provinceplant creation_date size coop ms hs oec misscontract ftime firmage idfirm_new idplant_new spellstart_date spellend_date, by(idperson year)

*Urate
gen province = provincebirth 
rename year year_obs
gen year = pygrad
merge m:1 province year using "../dta/urate.dta", keep(1 3) nogen
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


save ../dta/workers_yearly_mainjobincome.dta, replace


