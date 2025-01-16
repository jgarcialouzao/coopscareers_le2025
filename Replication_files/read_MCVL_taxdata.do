* STATA 12
* READ_MCVL_FISCAL_JGL.DO (READ ORIGINAL MCVL IN ASCII)
* Jose Garcia-Louzao
* Sep 2016

clear all
capture log close
capture program drop _all
set more 1


log using logs\read_MCVL_taxdata.log, replace


program define check
     list in 1/10, abbrev(4)
     sum
     describe
end

program define readfiscal
if   `1'==2006 | `1'==2007 | `1'==2008 | `1'==2009 | `1'==2010 | `1'==2011 | `1'==2012 | `1'==2013 | `1'==2014 {
    infix str15 idperson 1-15 str15 juridica 17 str15 idfirm 19-33 str2 province 35-36 str1 typerem 38 str2 type2rem 40-41 perc_integra 43-54 using ..\mcvl_orig\MCVL`1'`2'.`3', clear //retencion 48-59 perc_espec 60-71 ingresos_ef 72-83 ingresos_rep 84-95 ceuta 96 str4 nacimiento 97-100 family 101 disability 102 contract2 103 prolongacion 104 movilidad 105 reducciones 106-117 deducibles 118-129 compensatoria 130-141 alimentos 142-153 children_under3 154 children2_under3 155 children_other 156-157 children2_other 158-159 children_handicap 160-161 children2_handicap 162-163 children_handicap2 164-165 children2_handicap2 166-167 children_handicap_severe 168-169 children2_handicap_severe 170-171 children_tot 172-173 elder_under75 174 elder2_under75 175 elder_over75 176 elder2_over75 177 elder_handicap 178 elder2_handicap 179 elder_handicap2 180 elder2_handicap2 181 elder_handicap_severe 182 elder2_handicap_severe 183 elder_tot 184 

	*infix str15 idperson 1-15 str15 idfirm 16-30 str2 province 31-32 str1 typerem 33 str2 type2rem 34-35 perc_integra 36-47 //retencion 48-59 perc_espec 60-71 ingresos_ef 72-83 ingresos_rep 84-95 ceuta 96 str4 nacimiento 97-100 family 101 disability 102 contract2 103 prolongacion 104 movilidad 105 reducciones 106-117 deducibles 118-129 compensatoria 130-141 alimentos 142-153 children_under3 154 children2_under3 155 children_other 156-157 children2_other 158-159 children_handicap 160-161 children2_handicap 162-163 children_handicap2 164-165 children2_handicap2 166-167 children_handicap_severe 168-169 children2_handicap_severe 170-171 children_tot 172-173 elder_under75 174 elder2_under75 175 elder_over75 176 elder2_over75 177 elder_handicap 178 elder2_handicap 179 elder_handicap2 180 elder2_handicap2 181 elder_handicap_severe 182 elder2_handicap_severe 183 elder_tot 184 using ..\mcvl_orig\MCVL`1'_`2'.`3', clear
}
if `1'==2015 {
    infix str15 idperson 1-15 str15 juridica 17 str15 idfirm 19-33 str2 province 35-36 str1 typerem 38 str2 type2rem 40-41 perc_integra 43-54 using ..\mcvl_orig\MCVL`1'`2'.`3', clear //retencion 48-59 perc_espec 60-71 ingresos_ef 72-83 ingresos_rep 84-95 ceuta 96 str4 nacimiento 97-100 family 101 disability 102 contract2 103 prolongacion 104 movilidad 105 reducciones 106-117 deducibles 118-129 compensatoria 130-141 alimentos 142-153 children_under3 154 children2_under3 155 children_other 156-157 children2_other 158-159 children_handicap 160-161 children2_handicap 162-163 children_handicap2 164-165 children2_handicap2 166-167 children_handicap_severe 168-169 children2_handicap_severe 170-171 children_tot 172-173 elder_under75 174 elder2_under75 175 elder_over75 176 elder2_over75 177 elder_handicap 178 elder2_handicap 179 elder_handicap2 180 elder2_handicap2 181 elder_handicap_severe 182 elder2_handicap_severe 183 elder_tot 184 using ..\mcvl_orig\MCVL`1'_`2'.`3', clear

}
if  `1'==2016 | `1'==2017 | `1'==2018 {
    infix str15 idperson 1-15 str15 juridica 17 str15 idfirm 19-33 str2 province 35-36 str1 typerem 38 str2 type2rem 40-41 perc_integra 43-54 perc_integraIL 56-67 using ..\mcvl_orig\MCVL`1'`2'.`3', clear //retencion 48-59 perc_espec 60-71 ingresos_ef 72-83 ingresos_rep 84-95 ceuta 96 str4 nacimiento 97-100 family 101 disability 102 contract2 103 prolongacion 104 movilidad 105 reducciones 106-117 deducibles 118-129 compensatoria 130-141 alimentos 142-153 children_under3 154 children2_under3 155 children_other 156-157 children2_other 158-159 children_handicap 160-161 children2_handicap 162-163 children_handicap2 164-165 children2_handicap2 166-167 children_handicap_severe 168-169 children2_handicap_severe 170-171 children_tot 172-173 elder_under75 174 elder2_under75 175 elder_over75 176 elder2_over75 177 elder_handicap 178 elder2_handicap 179 elder_handicap2 180 elder2_handicap2 181 elder_handicap_severe 182 elder2_handicap_severe 183 elder_tot 184 using ..\mcvl_orig\MCVL`1'_`2'.`3', clear


}
gen year_mcvl=`1'
   label variable year_mcvl  "year when person was sampled/observed"
   check

   *person ID
   label variable idperson "person ID"
   codebook idperson
   duplicates report
   duplicates drop
   bys idperson: gen Nobs=_N
   tab Nobs
   
   *legal setting of the employer
   if year_mcvl!=2004 {
   #delimit ;
   replace juridica="1" if juridica=="A"; replace juridica="2" if juridica=="B"; replace juridica="3" if juridica=="C"; replace juridica="4" if juridica=="D"; replace juridica="5" if juridica=="E"; replace juridica="6" if juridica=="F"; replace juridica="7" if juridica=="G"; replace juridica="8" if juridica=="H"; replace juridica="9" if juridica=="J"; replace juridica="10" if juridica=="N"; replace juridica="11" if juridica=="P"; replace juridica="12" if juridica=="Q"; replace juridica="13" if juridica=="R"; replace juridica="14" if juridica=="S"; replace juridica="15" if juridica=="U"; replace juridica="16" if juridica=="V"; replace juridica="17" if juridica=="W";
   #delimit cr
   
   gen legal2firm=real(juridica) 
   label variable legal2firm "legal setting of firm"
   do labels/labellegal2
   label values legal2firm legal2lb
   tab legal2firm, missing
   }
   *firm ID - This variable should be the one to link affiliation and tax files
   codebook idfirm
   label variable idfirm "firm juridical ID"
   
   *province residence
   label variable province "province of residence"
   
   *type of perception/remuneration
   codebook typerem
   label variable typerem "type of remuneration (labor earnings, pensions, ...)"
   tab typerem, missing
   
   *sub-type of perception - detailed information regarding some types of remunaration
   label variable type2rem "(sub)type of remuneration (labor earnings, pensions, ...)"
   tab type2rem, missing
   
   *annual monetary payments 
   sum perc_integra, d
   ren perc_integra monetary_pay
   replace monetary_pay=monetary_pay/100
   label variable monetary_pay "annual monetary payments"
   sum monetary_pay, d
   
      /*
   *account withholding taxes - related to annual monetary payments 
   sum retencion, d
   ren retencion wh_tax
   replace wh_tax=wh_tax/100
   label variable wh_tax "annual amount of withholding taxes (IRPF)"
   sum wh_tax, d
   
   *annual payments in kind (value)
   sum perc_espec, d
   ren perc_espec inkind_pay
   replace inkind_pay=inkind_pay/100
   label variable inkind_pay "annual payments in kind"
   sum inkind_pay, d
   
   *effective acc. deposits related to in kind payments
   sum ingresos_ef, d
   ren ingresos_ef effacc_deposit
   replace effacc_deposit=effacc_deposit/100
   label variable effacc_deposit "effective acc. deposits related to in kind payments"
   sum effacc_deposit, d
   
   *transferred (?) account deposit related to in kind payments
   sum ingresos_rep, d
   ren ingresos_rep tranacc_deposit
   replace tranacc_deposit=tranacc_deposit/100
   label variable tranacc_deposit "transferred acc. deposit related to in kind payments"
   sum tranacc_deposit, d
   

   *Ceuta/Melilla - Dummy variable to identify whether income was generated in Ceuta/Melilla or not
   tab ceuta, missing
   label variable ceuta "income generated in Ceuta/Meilla==1"
   
   *year of birth
   codebook nacimiento
   replace nacimiento="" if nacimiento=="0000"
   gen tmp=date(nacimiento, ""YMD"")
   gen yearbirth=yofd(tmp)
   drop tmp
   label variable yearbirth "year of birth"
   tab yearbirth, missing
   
   *family
   tab family, missing
   label variable family "family situation (marital status, children,...)"

   *disability discrete
   tab disability, missing
   label variable disability "degree of disability"
   
   *contract type
   tab contract2, missing
   label variable contract2 "type of contract or labor relation"
   
   *reductions due to extension of labor relation 
   tab prolongacion, missing
   ren prolongacion ext_relation
   label variable ext_relation "reduction due to extension of labor relation (=1)"
   
   *reduction due to geo mobility
   tab movilidad, missing
   ren movilidad mobility
   label variable mobility "reduction due to geo mobility (=1)"
   
   *reductions - money value
   sum reducciones, d
   ren reducciones reductions
   replace reductions=reductions/100
   label variable reductions "monetary value of reductions"
   sum reductions, d
   
   *tax-deductible expenses
   sum deducibles, d
   ren deducibles deductible_exp
   replace deductible_exp=deductible_exp/100
   label variable deductible_exp "tax-deductible expenses"
   sum deductible_exp, d
   
   *compensatory payments
   sum compensatoria, d
   ren compensatoria comp_payment
   replace comp_payment=comp_payment/100
   label variable comp_payment "compensatory payment to former spouse"
   sum comp_payment, d
   
   *food payments to children
   sum alimentos, d
   ren alimentos food_payment
   replace food_payment=food_payment/100
   label variable food_payment "food payment to children due to divorce"
   sum food_payment, d
   
   *children under 3 years
   tab children_under3, missing
   label variable children_under3 "number of children under 3 years"
   
   *children under 3 years "por entero" - they were used to compute the type of tax-withholding
   tab children2_under3, missing
   label variable children2_under3 "number of children under 3 considered for tax-withholding"
   
   *other children
   tab children_other, missing
   label variable children_other "number of children (not included in under 3 years)"
   
   *other children used to compute type of tax-withholding
   tab children2_other, missing
   label variable children2_other "number of children considered for tax-withholding (not included in under 3 years)"
   
   *disabled children - handicap between 33 and 65%
   tab children_handicap, missing
   label variable children_handicap "number of disabled children (handicap between 33 and 65%)"
   
   *disabled children - handicap between 33 and 65% - used to compute type of tax-withholding
   tab children2_handicap, missing
   label variable children2_handicap "number of disabled children (handicap between 33 and 65%) for tax-withholding"
   
   *disabled children - handicap between 33 and 65% & limited mobility
   tab children_handicap2, missing
   label variable children_handicap2 "number of disabled children (handicap between 33 and 65% & limited mobility)"
   
   *disabled children - handicap between 33 and 65% & limited mobility - used to compute type of tax-withholding
   tab children2_handicap2, missing
   label variable children2_handicap2 "number of disabled children (handicap between 33 and 65% & limited mobility) for tax-withholding"
   
   *disabled children - handicap +65%
   tab children_handicap_severe, missing
   label variable children_handicap_severe "number of disabled children (handicap +65%)"
   
   *disabled children - handicap between 33 and 65% - used to compute type of tax-withholding
   tab children2_handicap_severe, missing
   label variable children2_handicap_severe "number of disabled children (handicap +65%) for tax-withholding"
   
   *total number of children  = children_under3 + children_other
   tab children_tot, missing
   *assert children_tot==children_under3+children_other
   label variable children_tot "total number of children"
   
   *elderly under 75 years
   tab elder_under75, missing
   label variable elder_under75 "number of elderly under 75 years"
   
   *elderly under 75 years - considered for tax-withholding
   tab elder2_under75, missing
   label variable elder2_under75 "number of elderly under 75 years - considered for tax-withholding" 
   
   *elderly over 75 years
   tab elder_over75, missing 
   label variable elder_over75 "number of elderly over 75 years"
   
   *elderly over 75 years - considered for tax-withholding 
   tab elder2_over75, missing 
   label variable elder2_over75 "number of elderly over 75 years - considered for tax-withholding"
      
   *disabled elderly - handicap between 33 and65%
   tab elder_handicap, missing 
   label variable elder_handicap "number of disabled elderly (handicap 33-65%)"
   
   *disabled elderly - handicap between 33 and65% - considered for tax-withholding
   tab elder2_handicap, missing 
   label variable elder2_handicap "number of disabled elderly (handicap 33-65%) considered for tax-withholding"
   
   *disabled elderly - handicap between 33 and65% & limited mobility
   tab elder_handicap2, missing 
   label variable elder_handicap2 "number of disabled elderly (handicap 33-65% & limited mobility)"
   
   *disabled elderly - handicap between 33 and65% & limited mobility - considered for tax-withholding
   tab elder2_handicap2, missing 
   label variable elder2_handicap2 "number of disabled elderly (handicap 33-65% & limited mobility) considered for tax-withholding"
   
   *disabled elderly - handicap +65%
   tab elder_handicap_severe, missing 
   label variable elder_handicap_severe "number of disabled elderly (handicap +65%)"
   
   *disabled elderly - handicap +65% - considered for tax-withholding
   tab elder2_handicap_severe, missing 
   label variable elder2_handicap_severe "number of disabled elderly (handicap +65%) considered for tax-withholding"
   
   *total number of elderly 
   tab elder_tot, missing
   *assert elder_tot==elder_under75+elder_over75
   label variable elder_tot "total number of elderly"
 */


*keep    idperson idfirm  year_mcvl            province yearbirth family disability typerem type2rem monetary_pay inkind_pay wh_tax effacc_deposit tranacc_deposit //ceuta contract2 ext_relation mobility reductions deductible_exp comp_payment food_payment children_under3 children2_under3 children_other children2_other children_handicap children2_handicap children_handicap2 children2_handicap2 children_handicap_severe children2_handicap_severe children_tot elder_under75 elder2_under75 elder_over75 elder2_over75 elder_handicap elder2_handicap elder_handicap2 elder2_handicap2 elder_handicap_severe elder2_handicap_severe elder_tot 
*order   idperson idfirm  year_mcvl            province yearbirth family disability typerem type2rem monetary_pay inkind_pay wh_tax effacc_deposit tranacc_deposit //ceuta contract2 ext_relation mobility reductions deductible_exp comp_payment food_payment children_under3 children2_under3 children_other children2_other children_handicap children2_handicap children_handicap2 children2_handicap2 children_handicap_severe children2_handicap_severe children_tot elder_under75 elder2_under75 elder_over75 elder2_over75 elder_handicap elder2_handicap elder_handicap2 elder2_handicap2 elder_handicap_severe elder2_handicap_severe elder_tot
compress	

 
 
   describe
   sum 
   save ../mcvl_stata/MCVL`1'_taxdata.dta, replace
end

/* 1: year
   2: original file name
   3: original file extension */
readfiscal 2018 "FISCAL_CDF" txt 
readfiscal 2017 "FISCAL_CDF" txt 
readfiscal 2016 "FISCAL_CDF" txt
readfiscal 2015 "FISCAL_CDF" txt
readfiscal 2014 "FISCAL_CDF" txt
readfiscal 2013 "FISCAL_CDF" txt
readfiscal 2012 "FISCAL_CDF" txt   
readfiscal 2011 "FISCAL_CDF" txt
readfiscal 2010 "_FISCAL_CDF" txt
readfiscal 2009 "_FISCAL_CDF" txt
readfiscal 2008 "_DATOS_FISCALES" trs
readfiscal 2007 "_DATOS_FISCALES" trs
readfiscal 2006 "_DATOS_FISCALES" trs

*Append year files
use ../mcvl_stata/MCVL2006_taxdata.dta, clear
forvalues y=2007(1)2018 {
append using ../mcvl_stata/MCVL`y'_taxdata.dta
}
bys idperson idfirm year_mcvl: gen nobs = _N
save ../mcvl_stata/MCVL_taxdata.dta, replace


log close
exit, clear
   
   
  
   
   
