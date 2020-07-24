	
	// Global Convenience
	
	use "${directory}/constructed/global_convenience.dta"
	
	local quality "correct dr_1 dr_4 re_1 re_3 re_4 med_any med_l_any_1 med_l_any_2 med_l_any_3 med_k_any_9"
	
	forest reg ///
	(`quality'), ///
	t(engaged) controls(i.case i.qutub_sample i.wave)  b bh /// 
	a(qutub_id_provider) cl(qutub_id_provider) ///
			graphopts($graph_opts ///
			xtit("{&larr} Non-engaged facilities  PPIA engaged facilities{&rarr}", size(small)) ///
			xlab( -.20 "-20%" -0.1 "10%" 0 "0%" 0.1 "10%" 0.2 "20%" , labsize(small)) ///
			ylab(,labsize(small)))
			
		graph export "$directory/outputs/global_convenience.png", width(1000) replace 
		
	valuelabels `quality', name(t4) columns(9) //Create matrix

	mat t4 = r(t4)
	
	matrix colnames t4 = "Non-PPIA Facilities" "PPIA Facilities" "Non-PPIA Facilities" "PPIA Facilities" "Non-PPIA Facilities" "PPIA Facilities" /// 
	"Reg Coefficient" "Std Error" "P-Value" 
	
  // Put statistics in matrix
  local row = 0
  foreach i in `quality' {
    local row = `row' + 1

    quietly reg `i' engaged i.case i.wave i.qutub_sample , /// 
	a(qutub_id_provider) cl(qutub_id_provider)
    mat t4[`row', 7] = _b[engaged] //Effect
    mat t4[`row', 8] = _se[engaged] //Standard Error
    mat t4[`row', 9] = 2*ttail(e(df_r), abs(_b[engaged]/_se[engaged])) //P-value
	
	quietly tabstat `i', by(type) save //Mean values of the 4 groups
	local j = 1
	forv j = 1/6 {
		mat t4[`row',`j'] = r(Stat`j')
	}
  }	
  
  local nRows `= rowsof(t4)'

  forvalues i = 1/`nRows'{ //Round off values
    forvalues j = 1/9 {
      matrix t4[`i', `j'] = round(t4[`i',`j'], 0.001)
    }
  }

  putexcel set "${directory}/outputs/table4.xlsx", replace //Save results in excel

  putexcel D7=matrix(t4), names
  
  putexcel E6:F6 = "Round 1" ///
  , merge hcenter font(calibri,13) bold underline
  
  putexcel G6:H6 = "Round 2" ///
  , merge hcenter font(calibri,13) bold underline
  
  putexcel I6:J6 = "Round 3" ///
  , merge hcenter font(calibri,13) bold underline
	
	
	
	
