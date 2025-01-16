
*** Stata 18
**  Program sequence to replicate results of "Employee-Owned Firms and the Careers of Young Workers"
*   Jose Garcia-Louzao & Gabriel Burdin


clear all
capture log close
capture program drop _all
macro drop _all
set more 1
set seed 13
set cformat %5.4f
set max_memory 32g
set scheme s2color

** Set main directory
global path /*"{Replication_files}"*/ "C:\Users\jgarcialouzao\Dropbox\Projects_ES\ScarringCoop\Stata" // main directory here but recall one needs to have the sub-folders within the diretory, i.e., do_files, dta_files, cohorts_2018, tables, figures
cd ${path}

/*
capture mkdir ./ado
adopath ++ "${path}\ado"
sysdir set PERSONAL "${path}\ado"
sysdir set PLUS "${path}\ado"
*/
** Additional programs required 
/*
** to download [to be in ado folder]
ssc install ftools, replace

ssc install reghdfe, replace
ssc install group2hdfe, replace
ssc install ivreghdfe, replace 
ssc install ivreg2, replace
ssc install ranktest, replace
ssc install estout, replace
ssc install outreg2, replace
ssc install splitvallabels, replace
ssc install heatplot, replace
ssc install binscatter, replace
ssc install grstyle, replace
ssc install palettes, replace
ssc install colrspace, replace
ssc install gtools, replace
gtools, upgrade
ssc install regsensitivity, replace
ssc install ivdesc, replace 
ssc install ivolsdec, replace

** homemade [to be in Do folder ]
sectorhom.do 
provtoreg.do 
censoredtobit_CHK.ado
*/
** Data extraction routines
do ${path}\Do\1_read_MCVL.do

** Create panels for workers, firms, wages, etc 
do ${path}\Do\2_code_panels.do 

** Data preparation to create panel of young workers 
do ${path}\Do\3_data_prep.do 


** Regression results 
do ${path}\Do\Reg_Baseline.do 				        // benchmark wage results
do ${path}\Do\Reg_Mobility.do      				   // mobility
do ${path}\Do\Reg_WageMobility_CoopIncidence.do   // wage gap and mobility by incidence of coop time
do ${path}\Do\Reg_Returns2Exp.do                 // returns to experience [including figure for catch-up rate]
do ${path}\Do\Reg_Promotions2Exp.do             // returns to experience


** Appendix 
do ${path}\Do\Desc_FirstJob.do
do ${path}\Do\Desc_PooledSample.do
do ${path}\Do\Reg_Baseline_Heterogeneity.do      // wage effects by sub-groups 
do ${path}\Do\Reg_JobLadder.do                  // persistence of cooperative employer 
do ${path}\Do\Reg_Mobility_Unemployment.do     // incidence of unemployment over the career



** Online Appendix
//additional figures and tables
do ${path}\Do\B1.FigureEntrants.do
do ${path}\Do\B2.Graphs_Duration_first_job.do
do ${path}\Do\B3.WorkerFE.do
do ${path}\Do\B4.Distribution_CoopEntry_Observables.do
do ${path}\Do\B5.Reg_ExitRate_1stJob.do
// Robustness test
do ${path}\Do\Reg_Baseline_Robust_WorkerOwned.do
do ${path}\Do\Reg_Baseline_Robust_FirstJobDef.do
do ${path}\Do\Reg_Baseline_Robust_LMRelationships.do
do ${path}\Do\Reg_Baseline_Robust_Censoring.do
do ${path}\Do\Reg_Baseline_Robust_FirmSizeEntry.do
