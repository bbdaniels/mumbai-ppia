 
	// Convenience effect for specific known PPIA providers when a facility joins PPIA in R2 relative to ones whose PPIA status remains the same in R1 & R2
	
	use "$directory/constructed/ppia_convenience.dta", clear 
	
	local quality "correct dr_1 dr_4 re_1 re_3 re_4 med_any med_l_any_1 med_l_any_2 med_l_any_3 med_k_any_9"
	
	forest reg ///
	(`quality'), ///
	t(engaged) controls(i.case i.type i.wave)  b bh /// 
	a(qutub_id_provider) cl(qutub_id_provider) ///
			graphopts ( $graph_opts ///
			xtit("{&larr}PPIA status remained the same in R1 & R2     Joined PPIA in R2{&rarr}", size(small)) ///
			xlab(-0.5 "-50%" -0.4 "-40%" -0.3 "-30%" -.20 "-20%" -0.1 "10%" 0 "0%" 0.1 "10%" 0.2 "20%" 0.3 "30%" 0.4"40%" 0.5"50%" , labsize(small)) ///
			ylab(,labsize(small)))
	
	valuelabels `quality', name(t5) columns(9) //Create matrix

	mat t5 = r(t5)
	
	matrix colnames t5 = "Remained out of PPIA" "Joined PPIA in R2" /// 
	"Remained in PPIA" "Remained out of PPIA" "Joined PPIA in R2" /// 
	"Remained in PPIA" "Reg Coefficient" "Std Error" "P-Value" 
	
  // Put statistics in matrix
  local row = 0
  foreach i in `quality' {
    local row = `row' + 1

    quietly reg `i' engaged i.case i.wave i.type , /// 
	a(qutub_id_provider) cl(qutub_id_provider)
    mat t5[`row', 7] = _b[engaged] //Effect
    mat t5[`row', 8] = _se[engaged] //Standard Error
    mat t5[`row', 9] = 2*ttail(e(df_r), abs(_b[engaged]/_se[engaged])) //P-value
	
	quietly tabstat `i', by(group) save //Mean values of the 4 groups
	local j = 1
	forv j = 1/6 {
		mat t5[`row',`j'] = r(Stat`j')
	}
  }	
  
  local nRows `= rowsof(t5)'

  forvalues i = 1/`nRows'{ //Round off values
    forvalues j = 1/9 {
      matrix t5[`i', `j'] = round(t5[`i',`j'], 0.001)
    }
  }

  putexcel set "${directory}/outputs/table5.xlsx", replace //Save results in excel

  putexcel D7=matrix(t5), names
  
  putexcel E6:G6 = "Round 1" ///
  , merge hcenter font(calibri,13) bold underline
  
  putexcel H6:J6 = "Round 2" ///
  , merge hcenter font(calibri,13) bold underline
  
 
	
