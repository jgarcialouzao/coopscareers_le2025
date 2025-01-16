* STATA 14
* MCVL - Data preparation: Employer information
* Jose Garcia-Louzao

clear all
capture log close
capture program drop _all
set more 1
set seed 13

log using ../logfiles/firmpanel.log, replace


global y1 = 2018
global y2 = 2017

*Append all information from laboral data to build a plant panel
use year_mcvl idperson spellstart_* spellend_* reason_endspell idplant idfirm idplantmain regime size creation_date CNAE09 CNAE93 legal1firm legal2firm type1plant type2plant provinceplant municipalityplant ptime using ../mcvl_stata/MCVL${y1}_laboral.dta, clear

*Drop spells with missing start or end date
drop if spellstart_date==. | spellend_date==.

*Drop spells with negative length
drop if spellend_date<spellstart_date

*Drop spells that refer to admin adjustments; not real employment spells
drop if reason_endspell==60 | reason_endspell==81

*Drop non-employment spells
drop if (type1plant > 749 & type1plant < 760) 
drop if type1plant==400 
drop if type2plant==4100 

*Keep general regime: CCCs can be considered as plants - identify all normal employees in a province
keep if regime==111

*Extraction date: last spell end date within general regime - guarantees the extraction date is the following day
*satisfies documendation (e.g. MCVL_organizacion_2006 and see extdate of 2006)
*Recode date end on-going spells from 31decyear+1 to 31decyear
replace spellend_date=mdy(12,31,year_mcvl) if spellend_date==mdy(12,31,year_mcvl+1) & reason_endspell==0
gegen extdate   =  max(spellend_date + 1)  if regime == 111  
replace spellend_date=mdy(12,31,year_mcvl+1) if spellend_date==mdy(12,31,year_mcvl) & reason_endspell==0

*Keep one observation per plant
bys idplant year_mcvl: gegen mode = mode(CNAE09), maxmode
drop if CNAE09!=mode
drop mode
bys idplant: keep if _n==1

forvalues y=$y2(-1)2010 {
append using ../mcvl_stata/MCVL`y'_laboral.dta, keep(year_mcvl idperson spellstart_date spellend_date reason_endspell idplant idfirm idplantmain regime size creation_date CNAE09 CNAE93 legal1firm legal2firm type1plant type2plant provinceplant municipalityplant ptime )

*Drop spells with missing start or end date
drop if spellstart_date==. | spellend_date==.

*Drop spells with negative length
drop if spellend_date<spellstart_date

*Drop spells that refer to admin adjustments; not real employment spells
drop if reason_endspell==60 | reason_endspell==81

*Drop non-employment spells
drop if (type1plant > 749 & type1plant < 760) 
drop if type1plant==400 
drop if type2plant==4100 

*Keep general regime: CCCs can be considered as plants - identify all normal employees in a province
keep if regime==111

*Proxy for extraction date
*Recode date end on-going spells from 31decyear+1 to 31decyear
replace spellend_date=mdy(12,31,year_mcvl) if spellend_date==mdy(12,31,year_mcvl+1) & reason_endspell==0 & year_mcvl==`y'
gegen tmpend   = max(spellend_date + 1) if regime == 111 & year_mcvl==`y'
replace spellend_date=mdy(12,31,year_mcvl+1) if spellend_date==mdy(12,31,year_mcvl) & reason_endspell==0 & year_mcvl==`y'

replace extdate   = tmpend   if year_mcvl==`y'

drop tmpend

*Keep one observation per plant
bys idplant year_mcvl: gegen mode = mode(CNAE09), maxmode
drop if CNAE09!=mode
drop mode
bys idplant year_mcvl: keep if _n==1
}



append using ../mcvl_stata/MCVL2009_laboral.dta, keep(year_mcvl idperson spellstart_date spellend_date reason_endspell idplant idfirm idplantmain regime size creation_date CNAE09 legal1firm legal2firm type1plant type2plant provinceplant municipalityplant ptime)

*Drop spells with missing start or end date
drop if spellstart_date==. | spellend_date==.

*Drop spells with negative length
drop if spellend_date<spellstart_date

*Drop spells that refer to admin adjustments; not real employment spells
drop if reason_endspell==60 | reason_endspell==81

*Drop non-employment spells
drop if (type1plant > 749 & type1plant < 760) 
drop if type1plant==400 
drop if type2plant==4100 

*Keep general regime: CCCs can be considered as plants - identify all normal employees in a province
keep if regime==111

*Proxy for extraction date
*Recode date end on-going spells from 31decyear+1 to 31decyear
replace spellend_date=mdy(12,31,year_mcvl) if spellend_date==mdy(12,31,year_mcvl+1) & reason_endspell==0 & year_mcvl==2009
gegen tmpend   = max(spellend_date + 1) if regime == 111 & year_mcvl==2009
replace spellend_date=mdy(12,31,year_mcvl+1) if spellend_date==mdy(12,31,year_mcvl) & reason_endspell==0 & year_mcvl==2009

replace extdate   = tmpend   if year_mcvl==2009
drop tmpend

*Keep one observation per plant
bys idplant year_mcvl: egen mode = mode(CNAE09), maxmode
drop if CNAE09!=mode
drop mode
bys idplant year_mcvl: keep if _n==1


forvalues y=2008(-1)2005 {
 append using ../mcvl_stata/MCVL`y'_laboral.dta, keep(year_mcvl idperson spellstart_date spellend_date reason_endspell idplant idfirm idplantmain regime size creation_date CNAE93 legal1firm legal2firm type1plant type2plant provinceplant municipalityplant ptime)

*Drop spells with missing start or end date
drop if spellstart_date==. | spellend_date==.

*Drop spells with negative length
drop if spellend_date<spellstart_date

*Drop spells that refer to admin adjustments; not real employment spells
drop if reason_endspell==60 | reason_endspell==81

*Drop non-employment spells
drop if (type1plant > 749 & type1plant < 760) 
drop if type1plant==400 
drop if type2plant==4100 

*Keep general regime: CCCs can be considered as plants - identify all normal employees in a province
keep if regime==111

*Proxy for extraction date
*Recode date end on-going spells from 31decyear+1 to 31decyear
replace spellend_date=mdy(12,31,year_mcvl) if spellend_date==mdy(12,31,year_mcvl+1) & reason_endspell==0 & year_mcvl==`y'
egen tmpend   = max(spellend_date + 1) if regime == 111 & year_mcvl==`y'
replace spellend_date=mdy(12,31,year_mcvl+1) if spellend_date==mdy(12,31,year_mcvl) & reason_endspell==0 & year_mcvl==`y'

replace extdate   = tmpend   if year_mcvl==`y'

drop tmp*
 
*Keep one observation per plant
bys idplant year_mcvl: egen mode = mode(CNAE93), maxmode
drop if CNAE93!=mode
drop mode
bys idplant year_mcvl: keep if _n==1
}
format extdate %td

keep year_mcvl idplant idfirm idplantmain legal1firm legal2firm regime provinceplant municipalityplant creation_date type1plant CNAE93 CNAE09 type2plant extdate size

save ../mcvl_stata/fpanel_orig.dta, replace

use ../mcvl_stata/fpanel_orig.dta, clear
replace idfirm = idplant if idfirm==""
*Balance the panel
egen id=group(idplant)
xtset id year_mcvl
tsfill, full

gen create=1 if idplant==""

*Exploit panel dimension to recover id's after tsfill
foreach v in idplant idfirm {
	gsort id -year_mcvl
	bys id: replace `v'=`v'[_n-1] if `v'==""

	sort id year_mcvl
	bys id: replace `v'=`v'[_n-1] if `v'==""
}
drop id

*Recover and correct inconsistencies characteristics
recode legal1firm 0=.
recode legal2firm 0=.

recode type2plant 5080=. // 5080 is not a valid value
recode type2plant 0=.
recode CNAE93 0=.
recode CNAE09 0=.

foreach v in legal1firm legal2firm regime provinceplant municipalityplant creation_date type1plant CNAE93 CNAE09 type2plant {
	gen tmp = -year_mcvl
	bys idplant (tmp): replace `v'=`v'[_n-1] if `v'==.
	drop tmp
	bys idplant (year_mcvl): replace `v'=`v'[_n-1] if `v'==.
	bys idplant: egen mode=mode(`v'), maxmode
	replace `v'=mode
	drop mode
}
recode legal1firm .=0
recode legal2firm .=0
recode CNAE93 .=0
recode CNAE09 .=0
recode type2plant .=0

* Variables refer to extraction year
bys year_mcvl (extdate): replace extdate = extdate[1] if extdate==.
rename year_mcvl year_orig
g year_mcvl = yofd(extdate)


*Add year=2005
sort idplant year_mcvl
bys idplant (year_mcvl): gen order = _n
by idplant (year_mcvl): gen first = _n == 1
expand 2 if first

drop order first

bys idplant (year_mcvl): replace year_mcvl = 2005 if _n == 1

*Add size for 2005
merge 1:1 year_mcvl idplant using ../mcvl_stata/fsize05.dta, keep(1 3) keepusing(size05 extdate05)

replace extdate = extdate05 if year_mcvl==2005
bys year_mcvl (extdate): replace extdate = extdate[1] if extdate==.
replace size = size05 if year_mcvl==2005 
drop size05 extdate05 _merge

*Interpolate missing size values
recode size 0=.
bys idplant: ipolate size year_mcvl, gen(isize)
replace isize=round(isize)
recode size .=0
recode isize .=0

rename size size_orig
rename isize size
label var size "Size"

*Recover size if year>creation & size==0 & size[_n+1]!=0
gen tmp = -year_mcvl
bys idplant (tmp): replace size = size[_n-1] if size == 0 & size[_n-1]!=0 & year_mcvl > yofd(creation_date)
replace size = 0 if size==.
drop tmp

*Count gaps in the balanced panel
bys idplant (year_mcvl): gen flag = 1 if size_orig[_n-1]>0 & size_orig==0 & size_orig[_n+1]>0 & _n != 1 & _n != _N
bys idplant: gegen gaps= total(flag)

compress

save ../mcvl_stata/fpanel.dta, replace

exit, clear

