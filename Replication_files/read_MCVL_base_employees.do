* STATA 14
* READ_MCVL_base_employees.DO (READ ORIGINAL MCVL IN ASCII)
* Jose Garcia-Louzao
* Feb 2016

clear all
capture log close
capture program drop _all
set more 1
set seed 13

/*
program define check
     list in 1/10, abbrev(4)
     sum
     describe
end
*/
******* datos bases cotizacion (cuenta ajena)
*********************************************

*** read files

program define readcotizajena
   if `1'==2012 | `1'==2011 | `1'==2010 | `1'==2009 | `1'==2008 | `1'==2007 | `1'==2006 | `1'==2005 {
   forvalues i=1(1)12   {   
      infix str15 idperson 1-15 str13 idplant 17-29 str8 fechaaltareal 31-38 str8 fechaaltaefecto 40-47 str8 fechabajareal 49-56 str8 fechabajaefecto 58-65 grupo 67-68 ano 70-73 basecotizjan 75-82 basecotizfeb 84-91 basecotizmarc 93-100 basecotizapr 102-109 basecotizmay 111-118 basecotizjun 120-127 basecotizjul 129-136 basecotizaug 138-145 basecotizsep 147-154 basecotizoct 156-163 basecotiznov 165-172 basecotizdec 174-181 basecotiztot 183-190 contrato 192-194 using ../mcvl_orig/MCVL`1'`2'`i'`3'.`4', clear
      gen year=`1'
      gen file=`i'
      label variable year  "year when person was sampled/observed"
      label variable file "file of the observation"

      label variable idperson "person ID"
      label variable idplant "plant ID"
	  
	  *check

      foreach v in alta baja  {
      foreach m in efecto  {
         codebook fecha`v'`m'
         replace fecha`v'`m'="" if fecha`v'`m'=="000000"
      }
      }
      gen spellstart_date = date(fechaaltareal, "YMD")
      gen spellend_date   = date(fechabajareal, "YMD")
 
      foreach v in start end {
    
        format spell`v'_date %td
        label variable spell`v'_date "`m'date spell `v'"
        
        foreach t in year month day {
           gen tmpspell`v'_`t' = `t'(spell`v'_date)
           tab tmpspell`v'_`t', missing
        
      }
      
}
   tab ano, missing
   ren ano year_w
   label variable year_w "year (of wage)"

   tab grupo, missing
   ren grupo skill
   label values skill skilllb
   label variable skill "skill (group contribution S.Sec.)"
   tab skill, missing

   tab contrato, missing
   ren contrato contract
   label values contract contractlb   
   label variable contract "contract type"
   tab contract, missing 

   foreach m in jan feb mar apr may jun jul aug sep oct nov dec tot {
      sum basecotiz`m'
      recode basecotiz`m' 0=.
      gen w`m'=basecotiz`m'/100
	  recode w`m' .=0
      label variable w`m' "wage `m' (euro)"
      sum w`m', detail
   }
 
   keep     year file idperson idplant skill contract spellstart_date spellend_date  year_w  w*
   order    year file idperson idplant skill contract spellstart_date spellend_date  year_w  w*
   compress year file                  skill contract spellstart_date spellend_date  year_w  w*
   
   describe
   sum
   save ../mcvl_stata/tmpMCVL`1'_w`i'.dta, replace

}
}

if `1'==2018 | `1'==2017 | `1'==2016 | `1'==2015 | `1'==2014 | `1'==2013 {
forvalues i=1(1)12   {  
      infix str15 idperson 1-15 str13 idplant 17-29 ano 31-34 basecotizjan 36-43  basecotizfeb 45-52  basecotizmarc 54-61 basecotizapr 63-70  basecotizmay 72-79 basecotizjun 81-88 basecotizjul 90-97 basecotizaug 99-106 basecotizsep 108-115 basecotizoct 117-124 basecotiznov 126-133 basecotizdec 135-142  basecotiztot 144-151  using ../mcvl_orig/MCVL`1'`2'`i'`3'.`4', clear
   
      gen year=`1'
      gen file=`i'
      label variable year  "year when person was sampled/observed"
      label variable file "file of the observation"
	  label variable idperson "person ID"
      label variable idplant "plant ID"
	  
	  *check
   tab ano, missing
   ren ano year_w
   label variable year_w "year (of wage)"
	  
	  
	  foreach m in jan feb mar apr may jun jul aug sep oct nov dec tot {
      sum basecotiz`m'
      recode basecotiz`m' 0=.
      gen w`m'=basecotiz`m'/100
	  recode w`m' .=0
      label variable w`m' "wage `m' (euro)"
      sum w`m', detail
   }
   
   keep     year file idperson idplant year_w  w*
   order    year file idperson idplant year_w  w*
   compress year file                  year_w  w*
       describe
   sum
   save ../mcvl_stata/tmpMCVL`1'_w`i'.dta, replace
	  	  
   }
   }
   end 
 
readcotizajena 2018 COTIZA "_CDF" txt

/*
readcotizajena 2017 COTIZA "_CDF" txt
readcotizajena 2016 COTIZA "_CDF" txt
readcotizajena 2015 COTIZA "_CDF" txt
readcotizajena 2014 COTIZA "_CDF" txt
readcotizajena 2013 COTIZA   "_CDF" txt

readcotizajena 2012 COTIZA   "_CDF" txt
readcotizajena 2011 COTIZA   "_CDF" txt
readcotizajena 2010 _COTIZA   "_CDF" txt
readcotizajena 2009 _COTIZA   ""     txt
readcotizajena 2008 _COTIANON ""     trs
readcotizajena 2007 _COTIANON ""     trs
readcotizajena 2006 _COTIANON ""     trs
readcotizajena 2005 _COTIANON ""     trs

*readcotizajena 2004 _COTIANON ""     txt 
*/

/*
*Append contribution files 
forvalues y=2012(-1)2005  {
use year idperson idplant year_w  w* spellstart_date spellend_date using ../mcvl_stata/tmpMCVL`y'_w1.dta, clear
forvalues i=2(1)12  {  
     append using ../mcvl_stata/tmpMCVL`y'_w`i'.dta, keep(year idperson idplant year_w  w* spellstart_date spellend_date)
	 
	 }
	 duplicates drop
bys idperson idplant year_w: gen Nobs_w=_N
     sum
	 save ../mcvl_stata/MCVL`y'_wages.dta, replace

}
*/

forvalues y=2018(-1)2018   {
use year idperson idplant year_w w*  using ../mcvl_stata/tmpMCVL`y'_w1.dta, clear
forvalues i=2(1)12  {  
     append using ../mcvl_stata/tmpMCVL`y'_w`i'.dta, keep(year idperson idplant year_w  w*)
	 
	 }
	  duplicates drop
	  bys idperson idplant year_w: gen Nobs_w=_N
sum
	bys idperson idplant year_w: keep if _n == 1
	 save ../mcvl_stata/MCVL`y'_wages.dta, replace

}

forvalues y=2018(-1)2018  {
forvalues i=1(1)12 {
   erase ../mcvl_stata/tmpMCVL`y'_w`i'.dta
 } 
}

 *******************************************************************************
/*
	*Homogenize 2005-2012 to 2013-onwards structure
forvalues y=2012(-1)2005  {
use ../mcvl_stata/MCVL`y'_wages.dta, clear

	*Annual earnings will be computed adding up monthly earnings. wtot will be discarded
		*monthly earning are already the sum of different contributions during the same year for each idperson-idplant (see documentation for further details)
collapse (first) Nobs year (max) wjan wfeb wmar wapr wmay wjun wjul waug wsep woct wnov wdec (sum) wtot, by(idperson idplant year_w)
sum

	 save ../mcvl_stata/MCVL`y'_wages.dta, replace
} 
*/

log close
exit, clear
