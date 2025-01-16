* Stata 14
* MCVL: Data preparation:  Continuous history of other labor relationships
* Jose Garcia-Louzao


clear all
capture log close
capture program drop _all
set more 1
set seed 13

global y1 = 2018


use ../dta/empspells.dta, clear

keep if regime>111

drop D*

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
drop if nobs>1 
drop nobs
bys idperson spellstart_date spellend_date: keep if _n == 1

*Drop spells fully embedded in longer spells
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
collapse (firstnm) idplant_start = idplant skill_start = skill ptime_start = ptime contract_start = contract (lastnm) idplant idplantmain contract skill ptime reason_endspell spellstart_old merged regime handicap legal1firm legal2firm type1plant type2plant selfemp_status provinceplant CNAE93 CNAE09 creation_date size, by(idperson spellstart_date spellend_pmax idfirm)
rename spellend_pmax spellend_date
format spell* %td

assert spellstart_old >= spellstart_date

*Recover and correct inconsistencies characteristics
recode legal1firm 0=.
recode legal2firm 0=.

recode type2plant 5080=. // 5080 is not a valid value
recode type2plant 0=.
recode CNAE93 0=.
recode CNAE09 0=.

foreach v in legal1firm legal2firm regime provinceplant creation_date type1plant CNAE93 CNAE09 type2plant {
	bys idplant: egen mode=mode(`v'), maxmode
	replace `v'=mode
	drop mode
}
recode legal1firm .=0
recode legal2firm .=0
recode CNAE93 .=0
recode CNAE09 .=0
recode type2plant .=0

quietly {
*Create 2-digit sector of activity variable based on CNAE09  (76 categories)
gen sector2d=int(CNAE09/10)
*If CNAE09==0, use CNAE93 classification and its correspondence with CNAE09 to recover sector
replace sector2d=1  if CNAE09==0 & CNAE93 < 151
replace sector2d=10 if CNAE09==0 & CNAE93 >= 151 & CNAE93 < 159
replace sector2d=11 if CNAE09==0 & CNAE93==159
replace sector2d=12 if CNAE09==0 & CNAE93==160
replace sector2d=13 if CNAE09==0 & CNAE93 >= 171 & CNAE93 <= 176
replace sector2d=14 if CNAE09==0 & CNAE93 >= 177 & CNAE93 <= 182
replace sector2d=15 if CNAE09==0 & (CNAE93 == 183 | CNAE93 >= 191 & CNAE93<=193)
replace sector2d=16 if CNAE09==0 & CNAE93 >= 201 & CNAE93 <= 205
replace sector2d=17 if CNAE09==0 & CNAE93 >= 211 & CNAE93 <= 212
replace sector2d=18 if CNAE09==0 & CNAE93 >= 222 & CNAE93 <= 223
replace sector2d=19 if CNAE09==0 & CNAE93 >= 231 & CNAE93 <= 232  
replace sector2d=20 if CNAE09==0 & CNAE93 >= 241 & CNAE93 <= 247
replace sector2d=21 if CNAE09==0 & CNAE93 >= 233 & CNAE93 <= 240
replace sector2d=22 if CNAE09==0 & CNAE93 >= 251 & CNAE93 <= 252 
replace sector2d=23 if CNAE09==0 & CNAE93 >= 261 & CNAE93 <= 268
replace sector2d=24 if CNAE09==0 & CNAE93 >= 271 & CNAE93 <= 275
replace sector2d=25 if CNAE09==0 & CNAE93 >= 281 & CNAE93 <= 287 
replace sector2d=26 if CNAE09==0 & (CNAE93==300 | CNAE93 >= 311 & CNAE93 <= 313 | CNAE93>=321 & CNAE93<=323)
replace sector2d=27 if CNAE09==0 & CNAE93 >= 314 & CNAE93 <= 316 
replace sector2d=28 if CNAE09==0 & CNAE93 >= 291 & CNAE93 <= 297
replace sector2d=29 if CNAE09==0 & CNAE93 >= 341 & CNAE93 <= 343
replace sector2d=30 if CNAE09==0 & CNAE93 >= 351 & CNAE93 <= 355
replace sector2d=31 if CNAE09==0 & CNAE93==361
replace sector2d=32 if CNAE09==0 & (CNAE93>=331 &  CNAE93<=332) | CNAE93==334 | (CNAE93 >= 362 &  CNAE93 <= 366)
replace sector2d=33 if CNAE09==0 & (CNAE93==333 & CNAE93==335 |  CNAE93>=315 &  CNAE93<=316  | CNAE93==725)
replace sector2d=35 if CNAE09==0 & CNAE93 >= 401 &  CNAE93 <= 403
replace sector2d=36 if CNAE09==0 & CNAE93 == 410 
replace sector2d=37 if CNAE09==0 & CNAE93 == 900
replace sector2d=38 if CNAE09==0 & CNAE93 >= 371 &  CNAE93 <= 372 
replace sector2d=41 if CNAE09==0 & CNAE93==452
replace sector2d=42 if CNAE09==0 & CNAE93==451
replace sector2d=43 if CNAE09==0 & CNAE93>=453 &  CNAE93<=455
replace sector2d=45 if CNAE09==0 & CNAE93>=501 &  CNAE93<=504
replace sector2d=46 if CNAE09==0 & CNAE93 >= 511 &  CNAE93 <=517 
replace sector2d=47 if CNAE09==0 & (CNAE93==505 | (CNAE93 >=521 &  CNAE93<= 526))
replace sector2d=49 if CNAE09==0 & CNAE93 >= 601 &  CNAE93 <= 603
replace sector2d=50 if CNAE09==0 & CNAE93 >= 611 & CNAE93 <= 612
replace sector2d=51 if CNAE09==0 & CNAE93 >= 621 & CNAE93 <= 623
replace sector2d=52 if CNAE09==0 & CNAE93 >= 631 & CNAE93 <= 634
replace sector2d=53 if CNAE09==0 & CNAE93==641
replace sector2d=55 if CNAE09==0 & CNAE93 >= 551 & CNAE93 <= 552
replace sector2d=56 if CNAE09==0 & CNAE93 >= 553 & CNAE93 <= 555
replace sector2d=58 if CNAE09==0 & (CNAE93==221 | CNAE93 >= 722 & CNAE93 <= 724)
replace sector2d=59 if CNAE09==0 & CNAE93 >= 921 & CNAE93 <= 922
replace sector2d=60 if CNAE09==0 & CNAE93==724
replace sector2d=61 if CNAE09==0 & CNAE93==642
replace sector2d=62 if CNAE09==0 & (CNAE93==721 | CNAE93==726) 
replace sector2d=63 if CNAE09==0 &  CNAE93==748 | CNAE93==924
replace sector2d=64 if CNAE09==0 & CNAE93 >= 651 & CNAE93 <= 652
replace sector2d=65 if CNAE09==0 & CNAE93==660
replace sector2d=66 if CNAE09==0 & CNAE93 >= 671 & CNAE93<= 672
replace sector2d=68 if CNAE09==0 & CNAE93 >= 701 & CNAE93 <= 703
replace sector2d=69 if CNAE09==0 & CNAE93 ==741 
replace sector2d=71 if CNAE09==0 & CNAE93 >=742 & CNAE93<=743
replace sector2d=72 if CNAE09==0 & CNAE93 >= 731 & CNAE93 <= 732
replace sector2d=73 if CNAE09==0 & CNAE93 ==744
replace sector2d=74 if CNAE09==0 & CNAE93 >= 746 & CNAE93 <= 748
replace sector2d=75 if CNAE09==0 & CNAE93 ==852
replace sector2d=77 if CNAE09==0 & CNAE93 >= 711 & CNAE93 <= 714
replace sector2d=78 if CNAE09==0 & CNAE93 ==745
replace sector2d=79 if CNAE09==0 & (CNAE93 ==633  | CNAE93 == 746)
replace sector2d=81 if CNAE09==0 & CNAE93 ==747
replace sector2d=82 if CNAE09==0 & CNAE93 ==748
replace sector2d=84 if CNAE09==0 & CNAE93 ==753
replace sector2d=85 if CNAE09==0 & CNAE93 >= 801 & CNAE93 <= 804
replace sector2d=86 if CNAE09==0 & CNAE93 ==851
replace sector2d=87 if CNAE09==0 & CNAE93 ==853
replace sector2d=90 if CNAE09==0 & CNAE93 ==923
replace sector2d=91 if CNAE09==0 & CNAE93 ==925
replace sector2d=92 if CNAE09==0 & CNAE93 ==927
replace sector2d=93 if CNAE09==0 & CNAE93 ==926
replace sector2d=94 if CNAE09==0 & CNAE93 >= 911 & CNAE93 <= 913
replace sector2d=95 if CNAE09==0 & CNAE93 ==527 
replace sector2d=96 if CNAE09==0 & (CNAE93==930 | CNAE93 ==950)
replace sector2d=97 if CNAE09==0 & CNAE93==950
replace sector2d=99 if CNAE09==0 & CNAE93==990

*Create 1-digit sector 
gen sector1d=.
replace sector1d=1 if sector2d<10
replace sector1d=2 if sector2d>=10 & sector2d<=39
*replace sector1d=2 if sector2d>=35 & sector2d<=39
replace sector1d=3 if sector2d>=41 & sector2d<=43
replace sector1d=4 if sector2d>=45 & sector2d<=47
replace sector1d=5 if sector2d>=49 & sector2d<=53
replace sector1d=6 if sector2d>=55 & sector2d<=56
replace sector1d=7 if sector2d>=58 & sector2d<=63
replace sector1d=8 if sector2d>=64 & sector2d<=68
replace sector1d=9 if sector2d>=69 & sector2d<=75
replace sector1d=10 if (sector2d>=77 & sector2d<=82) | (sector2d>=95 & sector2d<=97)
replace sector1d=11 if sector2d>=85 & sector2d<=88
replace sector1d=12 if sector2d>=90 & sector2d<=94
replace sector1d=13 if sector2d==84
replace sector1d=14 if sector2d==99

label define sector1dlb  1 "Primary sector" 2 "Manufacturing" /*2 "Utilities"*/ 3 "Construction"  4 "Trade" 5 "Transportation and storage" 6 "Accommodation and food services" ///
						 7 "Information and communication"  8 "Financial, insurance and real estate activities"  9 "Professional, scientific and technical activities" ///
						 10 "Administrative, support and other services" 11 "Education, human health and social work" 12 "Entertainment" 13 "Social Security" 14 "Int. organizations", modify
label values sector1d sector1dlb
}
drop CNAE*

*Drop Ceuta and Melilla; missing creation or creation after plant is in business
drop if provinceplant>50

*Changing tax ID
gegen group = group(idfirm)
bys idplant: gegen sd=sd(group)
drop if sd!=0
drop group sd

gen coop_we=1 if legal2firm==6 & (type2plant==5161 | type2plant==9999)
gen coop_worker_we=1 if coop_we==1 & type1plant!=930
gen coop_partner_we=1 if coop_we==1 & type1plant==930

gen ls_we=1 if (legal2firm==1 | legal2firm==2) & type2plant==5180
gen ls_worker_we=1 if ls_we==1 & type1plant!=951
gen ls_partner_we=1 if ls_we==1 & type1plant==951

gen kfirm_we=1 if (legal2firm==1 | legal2firm==2 | legal2firm==10 | legal2firm==17) & type2plant==9999 & type1plant!=930
gen soleprop_we=1 if legal2firm==88 & type2plant==9999

gen socialeco=1 if kfirm_we==1 
replace socialeco=2 if coop_we==1
replace socialeco=3 if ls_we==1
replace socialeco=4 if soleprop_we==1
replace socialeco=5 if socialeco==.
label define socialecolb 1 "Capitalist firm" 2 "Cooperative"  3 "Labor society" 4 "Sole proprietor" 5 "Other Form", modify
label values socialeco socialecolb
*drop if socialeco==.

gen coop = socialeco==2

gen partner = type1plant==930 | type1plant==951

compress

save ../dta/contotherspells.dta, replace






