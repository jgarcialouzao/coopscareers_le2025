

** Sequence of preparation files to set up the panel of young workers 
do ${path}\Do\CensoringCorrection.do

/*
use ../dta/workers_monthly.dta, clear
keep if status==1
keep dailyw dailyw_CHK
gen lnw = ln(dailyw)
gen lnw_CHK = ln(dailyw_CHK)

tw (kdensity lnw, lcolor("255 141 61") mcolor("255 141 61 %34")) (kdensity lnw_CHK, lcolor("31 119 180") mcolor("31 119 180 %34")), legend(order( 1 "Censored" 2 "Imputed"))  xtitle("(log) Real daily wage") xlabel(-3.5(1)7.5) ytitle("Density") ylabel(0(0.3)1.2)
qui graph export "../figures/lnw_distcens.png", as(png) replace 


sum lnw, d 
sum lnw_CHK, d 
*/

do ${path}\Do\DataPrep_Workers_1.do // [censoring correction needs to be ran before start preparation]
do ${path}\Do\DataPrep_Workers_2.do 
do ${path}\Do\DataPrep_Firms.do 


/*
** Additional panels for extra results 
do ${path}\Do\C1.DataPrep_Workers_2_firstjobspell100days.do
do ${path}\Do\C2.DataPrep_Workers_2_firstjob180days12months.do
do ${path}\Do\${path}\Do\C3.DataPrep_Workers_2_time1stjob.do
do ${path}\Do\ C4.DataPrep_Workers_2_privateLLC.do
do ${path}\Do\C5.DataPrep_Workers_2_mainjobincome.do
do ${path}\Do\C6.DataPrep_OldCohorts.do 
