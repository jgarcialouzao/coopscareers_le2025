* STATA 14
* READ_MCVL_base_selfemp.DO (READ ORIGINAL MCVL IN ASCII)
* Jose Garcia-Louzao
* Mar 2016

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
******* datos bases cotizacion (cuenta propia)
*********************************************

*** read files

log using ..\logs\read_MCVL_baseselfemp.log, replace


program define readcotizpropia
   if `1'==2012 | `1'==2011 | `1'==2010 | `1'==2009 | `1'==2008 | `1'==2007 | `1'==2006 | `1'==2005 {
 
      infix str15 idperson 1-15 str13 idplant 17-29 str8 fechaaltareal 31-38 str8 fechaaltaefecto 40-47 str8 fechabajareal 49-56 str8 fechabajaefecto 58-65 ano 67-70 basecotizjan 72-78 basecotizfeb 80-86 basecotizmarc 88-94 basecotizapr 96-102 basecotizmay 104-110 basecotizjun 112-118 basecotizjul 120-126 basecotizaug 128-134 basecotizsep 136-142 basecotizoct 144-150 basecotiznov 152-158 basecotizdec 160-166 basecotiztot 168-174 using ../data_orig/MCVL`1'`2'`3'.`4', clear
      gen year=`1'
    
      label variable year  "year when person was sampled/observed"

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

 

   foreach m in jan feb mar apr may jun jul aug sep oct nov dec tot {
      sum basecotiz`m'
      recode basecotiz`m' 0=.
      gen w`m'=basecotiz`m'/100
	  recode w`m' .=0
      label variable w`m' "wage `m' (euro)"
      sum w`m', detail
   }
 
   keep     year idperson idplant spellstart_date spellend_date  year_w  w*
   order    year idperson idplant spellstart_date spellend_date  year_w  w*
   compress year                  spellstart_date spellend_date  year_w  w*
   
   duplicates report
   duplicates drop
   describe
   sum
   save ../mcvl_stata/MCVL`1'_selfemp_w.dta, replace


}


if `1'==2015 | `1'==2014 | `1'==2013 {

      infix str15 idperson 1-15 str13 idplant 17-29 ano 31-34 basecotizjan 36-43  basecotizfeb 45-52  basecotizmarc 54-61 basecotizapr 63-70  basecotizmay 72-79 basecotizjun 81-88 basecotizjul 90-97 basecotizaug 99-106 basecotizsep 108-115 basecotizoct 117-124 basecotiznov 126-133 basecotizdec 135-142  basecotiztot 144-151  using ../data_orig/MCVL`1'`2'`3'.`4', clear
   
      gen year=`1'
   
      label variable year  "year when person was sampled/observed"
     
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
   
   keep     year idperson idplant year_w  w*
   order    year idperson idplant year_w  w*
   compress year                  year_w  w*
   
   duplicates report
   duplicates drop
       describe
   sum
   save ../mcvl_stata/MCVL`1'_selfemp_w.dta, replace
	  	  
  
   }
   end 

readcotizpropia 2015 COTIZA13  "_CDF" TXT
readcotizpropia 2014 COTIZA13  "_CDF" TXT
readcotizpropia 2013 COTIZA13  "_CDF" TXT
readcotizpropia 2012 COTIZA13  "_CDF" TXT
readcotizpropia 2011 COTIZA13  "_CDF" TXT
readcotizpropia 2010 _COTIZA13  "_CDF" TXT
readcotizpropia 2009 _COTIZA13  "_CDF" TXT
readcotizpropia 2008 _COTIANON13 ""     trs
readcotizpropia 2007 _COTIANON13 ""     trs
readcotizpropia 2006 _COTIANON13 ""     trs
readcotizpropia 2005 _CPROANON   ""     trs
*readcotizpropia 2004 CPROANON   ""     txt


*Keep the last information available in MCVL
use ../mcvl_stata/MCVL2015_selfemp_w.dta, clear
forvalues y=2014(-1)2005 {
merge 1:1 idperson idplant year_w using ../mcvl_stata/MCVL`y'_selfemp_w.dta
drop _merge
}
sort idperson idplant year_w 
save ../mcvl_stata/MCVL_selfempw.dta, replace
log close


