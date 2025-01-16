* STATA 16
* MCVL - Descriptive Statistics - 15years pooled
* Jose Garcia-Louzao


clear all
capture log close
capture program drop _all
set more 1
set seed 13
set max_memory 200g
set segmentsize 3g
set cformat %5.4f


use ../dta/workers_yearly.dta, clear

*DESCRIPTIVE STATISTICS

*longrun variables
foreach v in WEdays SEdays OEdays UIdays WEincome_CHK SEincome OEincome UIincome {
bys idperson: egen longrun_`v'= total(`v')
label var longrun_`v' "`v'"
}

drop if status==4
bys idperson idplant: gen flag = _n==1
bys idperson: egen longrun_employers = total(flag)
drop flag
bys idperson idplant: gen flag = _n==1 & coop==1
bys idperson: egen longrun_coops = total(flag)
label var longrun_employers "No. employers"
label var longrun_coops "No. cooperatives"
drop flag

gen coop_entry = first_socialeco==2

gen flag = first_socialeco==socialeco 
bys idperson: egen tmp = mean(flag)
gen always = tmp==1
label var always "Always same firm type"

label var firstjob_earnings  "Total earnings in first job"
label var firstjob_days      "Total days worked in first job"

bys idperson (year): keep if _n == 1
keep first* coop_entry educ pygrad Efirst  datebirth provincebirth female longrun* always urate_t0

gen time2firstjob = yofd(dofm(Efirst)) - pygrad - 1
label var time2firstjob "Time graduation and first job (years)"

*High-school
qui gen highschool = educ==2
label var highschool "High-school"

*College
qui gen college = educ==3
label var college "College"

gen ftime = first_ptime>95
label var ftime "Full-time job"

gen ms = first_skill>3 & first_skill<8
label var ms "Mid-skill occ."
gen hs = first_skill>=1 & first_skill<=3
label var hs "High-skill occ."

qui g oec = first_contract==1|first_contract==3|first_contract==65|first_contract==100|first_contract==139|first_contract==189|first_contract==200|first_contract==239|first_contract==289| ///
first_contract==8|first_contract==9|first_contract==11|first_contract==12|first_contract==13|first_contract==20|first_contract==23|first_contract==28|first_contract==29|first_contract==30|first_contract==31|first_contract==32|first_contract==33|first_contract==35|first_contract==38|first_contract==40|first_contract==41|first_contract==42|first_contract==43|first_contract==44|first_contract==45|first_contract==46|first_contract==47|first_contract==48|first_contract==49|first_contract==50|first_contract==51|first_contract==52|first_contract==59|first_contract==60|first_contract==61|first_contract==62|first_contract==63|first_contract==69|first_contract==70|first_contract==71|first_contract==80|first_contract==81|first_contract==86|first_contract==88|first_contract==89|first_contract==90|first_contract==91|first_contract==98|first_contract==101|first_contract==102|first_contract==109|first_contract==130|first_contract==131|first_contract==141|first_contract==150|first_contract==151|first_contract==152|first_contract==153|first_contract==154|first_contract==155|first_contract==156|first_contract==157|first_contract==186|first_contract==209|first_contract==230|first_contract==231|first_contract==241|first_contract==250|first_contract==251|first_contract==252|first_contract==253|first_contract==254|first_contract==255|first_contract==256|first_contract==257
label var oec "Open-ended first_contract"

replace oec = . if yofd(dofm(Efirst))<1997

*Sectors
qui gen manuf = first_sector1d==2
label var manuf  "Manufacturing"
qui gen construction = first_sector1d==3
label var construction "Construction"

*Located in 4 largest metropolitan areas (Madrid, Barcelona, Sevilla, Valencia)
gen bigcity= 1 if first_provinceplant==8 | first_provinceplant==28 | first_provinceplant==41 | first_provinceplant==46
recode bigcity .=0
label var bigcity "Big city"

*Young firmage
replace first_creation_date = dofm(Efirst)  if first_creation_date>dofm(Efirst) & first_creation_date!=.
gen page = yofd(dofm(Efirst)) - yofd(first_creation_date)
label var page "Firm age"

qui gen age =  yofd(dofm(Efirst)) - yofd(datebirth)
label var age "Age"

*Labor market entry when firm created
gen entry_newfirm = yofd(dofm(Efirst)) <= yofd(first_creation_date)
label var entry_newfirm "First job in a new firm"

*First job being partner
label var first_partner "Entry as cooperative partner" 
replace first_partner = 0 if first_socialeco!=2

*First experience province of birth
gen sameprov = provincebirth == first_provinceplant
label var sameprov "First job in province of birth"

foreach n in 0 1 {

estpost summarize female age highschool college sameprov time2firstjob urate first6_earnings first6_days first6_employers firstjob_earnings firstjob_days entry_newfirm first_partner ms hs ftime page manuf construction bigcity  longrun_WEincome longrun_SEincome longrun_OEincome longrun_UIincome longrun_WEdays longrun_SEdays longrun_OEdays longrun_UIdays longrun_employers longrun_coops always if coop_entry==`n' 
est store desc_coop_entry`n'_all

}
esttab desc_coop_entry0_all desc_coop_entry1_all using ../tables/descriptives_longrun15.tex, replace cells("mean(fmt(%13.2fc))") label


