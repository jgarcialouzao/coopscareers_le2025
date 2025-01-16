program define censoredtobit_CHK, byable(recall)
                    
marksample use
		
			cnreg logdailywages oneobs meanw_noT meantop_noT ftime sector1d_* regionpla_* month_* year_* if `use', censored(cens)

			predict xb,  xb        
			gen se=_b[/sigma]      
			replace mu=xb          if `use'
			replace sigma=se       if `use'
			drop xb se
						                    
            end
