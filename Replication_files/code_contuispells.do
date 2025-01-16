* Stata 14
* MCVL: Data preparation: Laboral data - Employment spells - Continuous history of insured unemployment spells
* Jose Garcia-Louzao


clear all
capture log close
capture program drop _all
set more 1
set seed 13

global y1 = 2018


use ../dta/uispells.dta, clear


* Create continuous history of spells 
*Drop spells fully embedded in longer spells
*Very short-term spells - median duration is 2 days, 1 out of 4 spells has a duration of 1 day
sort idperson spellstart_date spellend_date provinceplant
gen drop_1=0
replace drop_1=1 if spellstart_date[_n-1]<spellstart_date & spellend_date<spellend_date[_n-1] & idperson==idperson[_n-1]
bys idperson: gen nobs=_N
gegen max = max(nobs)
gen max_j = max - 1
local max_obs "max"
local max_obs_j "max_j"
local i = 2
local j = 1
while `i' < `max_obs' {
  while `j' < `max_obs_j' {
	gen drop_`i'=drop_`j'
    replace drop_`i'=1  if spellstart_date[_n-`i']<spellstart_date & spellend_date<spellend_date[_n-`i'] & idperson==idperson[_n-`i']
	drop drop_`j'
    local j = `j' + 1
    local i = `i' + 1

  }
}
rename drop_* drop_1
gen tmp= spellend_date - spellstart_date + 1
sum tmp if drop_1==1, d
drop if drop_1==1
drop drop_* max* tmp
drop nobs

*Spells with the same starting date but different ending date, keep the longest
bys idperson spellstart_date: gegen maxdate = max(spellend_date)
drop if maxdate != spellend_date
drop maxdate

*Partially overlapped spells: delay starting date for spells that started before a previous spell had finished 
bys idperson (spellstart_date spellend_date provinceplant): replace spellstart_date = spellend_date[_n-1] + 1 if spellend_date>=spellend_date[_n-1] & spellend_date[_n-1]>=spellstart_date

*Drop spells with negative length as a result of adjusting dates
drop if spellend_date<spellstart_date

*Verify there is no overlapping spells on a daily basis with continuous dates
sort idperson 
gen tmp=0
bys idperson (spellstart_date spellend_date provinceplant): replace tmp=1 if _n!=1 & spellstart_date<spellend_date[_n-1] 
bys idperson (spellstart_date spellend_date provinceplant): replace tmp=1 if spellstart_date[_n+1]<spellend_date 
assert tmp==0
drop tmp

* Identify consecutive spells in the same province --at most 15 days between spells, merge them
* Assumption, even if there is a plant change within same location, this is not considered as the end of the employment relationship
gen spellstart_old = spellstart_date
bys idperson (spellstart_date spellend_date provinceplant): replace spellstart_date=spellstart_date[_n-1] if (spellend_date[_n-1]<=spellstart_date & spellstart_date<=spellend_date[_n-1] + 15) & (provinceplant==provinceplant[_n-1])
			  
bys idperson spellstart_date: gegen spellend_pmax = max(spellend_date)
format spell* %td

assert spellstart_old >= spellstart_date

*Label merged spells
bys idperson spellstart_date spellend_pmax provinceplant: gen merged = _N
label var merged "#spells merged within firm (1 means none)"

*Merged consecutive spells, keep id of first plant for matching tv characteristics
collapse (firstnm) type2plant spellstart_old, by(idperson spellstart_date spellend_pmax provinceplant)
rename spellend_pmax spellend_date
format spell* %td

assert spellstart_old >= spellstart_date

gen ui = 1

compress

keep idperson idplant spellstart_date spellend_date ui 

save ../dta/contuispells.dta, replace

compress




