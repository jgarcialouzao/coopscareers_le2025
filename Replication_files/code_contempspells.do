* Stata 14
* MCVL: Data preparation: Laboral data - Employment spells - Continuous history of wage-employment spells
* Jose Garcia-Louzao


clear all
capture log close
capture program drop _all
set more 1
set seed 13

global y1 = 2018


log using logs\contjobspells.log, replace	

use ../dta/empspells.dta, clear

*Drop self-employment spells and other regimes that do not correspond to wage-employment relations
drop if (regime>=521 & regime<=540)
drop if regime>111

*Keep relevant variables, remaining will be merge later
keep year_mcvl idperson idfirm idplantmain idplant spellstart_date spellend_date skill contract ptime reason_endspell regime handicap

* Create continuous history of spells 

** Same organization spells
* Spells with same starting and ending dates, labor relationship exactly equal but in different establishments with different ptime coeffs; add up spells
bys idperson spellstart_date spellend_date idfirm regime contract skill reason_endspell: gen nobs = _N
bys idperson spellstart_date spellend_date idfirm regime contract skill reason_endspell: gegen tptime = sum(ptime)
bys idperson spellstart_date spellend_date idfirm regime contract skill reason_endspell: gegen max = max(ptime)
drop if nobs>1 & ptime!=max
replace tptime = . if (tptime>=100 | tptime == 0) & nobs>1
replace ptime = tptime if nobs>1
drop nobs tptime max
bys idperson spellstart_date spellend_date idfirm regime contract skill reason_endspell ptime: gen nobs = _N
drop if nobs > 1 & idplant != idplantmain
drop nobs

* Spells with same starting and ending dates, regime skill and reason for termination but splitted in different contracts, keep one with most common contract
bys idperson spellstart_date spellend_date idfirm regime skill reason_endspell: gen nobs = _N
bys idperson spellstart_date spellend_date idfirm regime skill reason_endspell: gegen mode = mode(contract), minmode
replace contract = mode if nobs > 1
drop mode nobs
bys idperson spellstart_date spellend_date idfirm regime skill reason_endspell contract: gen nobs = _N
drop if nobs > 1 & idplant != idplantmain
drop nobs

* Spells with same starting and ending dates in same organization, keep the one in the main plant
bys idperson spellstart_date spellend_date idfirm: gen nobs = _N
drop if nobs > 1 & idplant != idplantmain
drop nobs

* Spells with same starting and ending dates but different organizations (part-time jobs), keep the one working most hours
bys idperson spellstart_date spellend_date: gen nobs = _N
bys idperson spellstart_date spellend_date: gegen max = max(ptime)
drop if nobs>1 & ptime!=max
drop max nobs

* Spells with same starting and ending dates but different organizations (part-time jobs), keep the one with highest skill (implict higher earnings)
bys idperson spellstart_date spellend_date: gen nobs = _N
bys idperson spellstart_date spellend_date: gegen min = min(skill)
drop if nobs>1 & skill!=min
drop min nobs

* Remaining same starting and ending dates, reduce inconsistencies by dropping spells containing variables with no valid characteristics and then keep only one
bys idperson spellstart_date spellend_date: gen nobs = _N
drop if nobs>1 & skill>10
drop if nobs>1 & idfirm==""
drop if nobs>1 & (reason_endspell==63 | reason_endspell==67 | reason_endspell==72 | reason_endspell==74 | reason_endspell==78 | reason_endspell==84 | reason_endspell==87 | reason_endspell==90 | reason_endspell==97 | reason_endspell==98)   |  ///
				(contract>99 & contract<300 & reason_endspell==93) | (contract>99 & contract<300 & reason_endspell==94) | (reason_endspell==0 & spellend_date!=mdy(12,31,${y1}))
drop if nobs>1 & regime!=111
drop nobs
bys idperson spellstart_date spellend_date: keep if _n == 1



*Drop spells fully embedded in longer spells
*Very short-term spells - median duration is 2 days, 1 out of 4 spells has a duration of 1 day
sort idperson spellstart_date spellend_date idplant
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

save ../dta/contempspells_temp.dta, replace

use ../dta/contempspells_temp.dta, clear

*Spells with the same starting date but different ending date, keep the longest
bys idperson spellstart_date: gegen maxdate = max(spellend_date)
drop if maxdate != spellend_date
drop maxdate

*Partially overlapped spells: delay starting date for spells that started before a previous spell had finished 
bys idperson (spellstart_date spellend_date idplant): replace spellstart_date = spellend_date[_n-1] + 1 if spellend_date>=spellend_date[_n-1] & spellend_date[_n-1]>=spellstart_date

*Drop spells with negative length as a result of adjusting dates
drop if spellend_date<spellstart_date

*Verify there is no overlapping spells on a daily basis with continuous dates
sort idperson 
gen tmp=0
bys idperson (spellstart_date spellend_date idplant ): replace tmp=1 if _n!=1 & spellstart_date<spellend_date[_n-1] 
bys idperson (spellstart_date spellend_date idplant ): replace tmp=1 if spellstart_date[_n+1]<spellend_date 
assert tmp==0
drop tmp

* Identify consecutive spells with same organization (i.e. firm) --at most 15 days between spells, merge them
* Assumption, even if there is a plant change within same location, this is not considered as the end of the employment relationship
replace idfirm = idplantmain if idfirm==""
gen spellstart_old = spellstart_date
bys idperson (spellstart_date spellend_date idfirm idplant): replace spellstart_date=spellstart_date[_n-1] if (spellend_date[_n-1]<=spellstart_date & spellstart_date<=spellend_date[_n-1] + 15) & idfirm==idfirm[_n-1]
			  
bys idperson spellstart_date: gegen spellend_pmax = max(spellend_date)
format spell* %td

assert spellstart_old >= spellstart_date

*Label merged spells
bys idperson spellstart_date spellend_pmax idfirm: gen merged = _N
label var merged "#spells merged within firm (1 means none)"

*Merged consecutive spells
collapse (firstnm) idplant_start = idplant skill_start = skill ptime_start = ptime contract_start = contract (lastnm) idplant idplantmain contract skill ptime reason_endspell spellstart_old merged regime handicap D*, by(idperson spellstart_date spellend_pmax idfirm)
rename spellend_pmax spellend_date
format spell* %td

assert spellstart_old >= spellstart_date

compress

save ../dta/contempspells.dta, replace




log close

