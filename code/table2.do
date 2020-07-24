
	// Global learning effect 
	
	use "$directory/constructed/global_learning",clear 
	
	local quality "correct dr_1 dr_4 re_1 re_3 re_4 med_any med_l_any_1 med_l_any_2 med_l_any_3 med_k_any_9"
	
	forest reg ///
	(`quality'), ///
	t(pxh_w1) controls(i.pxh wave_1 wave_2 pxh_w2 i.case) b bh a(qutub_id) cl(qutub_id) ///
			graphopts( $graph_opts ///
			xtit("{&larr} Favors Non-PPIA providers   Favors PPIA providers {&rarr}", size(small)) ///
			xlab(-.30 "-30%" -.20 "-20%" -0.1 "10%" 0 "0%" 0.1 "10%" 0.2 "20%" .3 "30%"   , labsize(small)) ///
			ylab(,labsize(small)))
			
		graph export "$directory/outputs/global_learning_R2.png", width(1000) replace 
		
		
		forest reg ///
	(`quality'), ///
	t(pxh_w2) controls(i.pxh wave_1 wave_2 pxh_w1 i.case) b bh a(qutub_id) cl(qutub_id) ///
			graphopts($graph_opts ///
			xtit("{&larr} Favors Non-PPIA providers   Favors PPIA providers {&rarr}", size(small)) ///
			xlab(-.30 "-30%" -.20 "-20%" -0.1 "10%" 0 "0%" 0.1 "10%" 0.2 "20%" .3 "30%"   , labsize(small)) ///
			ylab(,labsize(small)))
		
		graph export "$directory/outputs/global_learning_R3.png", width(1000) replace 
		
		
	valuelabels `quality', name(t2) columns(12) //Create matrix

	mat t2 = r(t2)
	
	matrix colnames t2 = "Non-PPIA Providers" "PPIA Providers" ///
	"Non-PPIA Providers" "PPIA Providers" "Non-PPIA Providers" "PPIA Providers" ///
	 "Effect" "Std Error" "P-Value" "Effect" "Std Error" "P-Value" 
	
  // Put statistics in matrix
  local row = 0
  foreach i in `quality' {
    local row = `row' + 1

    quietly reg `i' i.pxh wave_1 wave_2 pxh_w2 i.case pxh_w1, a(qutub_id) cl(qutub_id)
    mat t2[`row', 7] = _b[pxh_w1] //Effect
    mat t2[`row', 8] = _se[pxh_w1] //Standard Error
    mat t2[`row', 9] = 2*ttail(e(df_r), abs(_b[pxh_w1]/_se[pxh_w1])) 
	//P-value
	
	mat t2[`row', 10] = _b[pxh_w2] //Effect
    mat t2[`row', 11] = _se[pxh_w2] //Standard Error
    mat t2[`row', 12] = 2*ttail(e(df_r), abs(_b[pxh_w2]/_se[pxh_w2]))
  
	quietly tabstat `i', by(type) save //Mean values of the groups
	
	local j = 1
	forv j = 1/6 {
		mat t2[`row',`j'] = r(Stat`j')
	}
  }
  
  local nRows `= rowsof(t2)'

  forvalues i = 1/`nRows'{ //Round off values
    forvalues j = 1/12 {
      matrix t2[`i', `j'] = round(t2[`i',`j'], 0.001)
    }
  }

  putexcel set "${directory}/outputs/table2.xlsx", replace //Save results in excel

  putexcel D7=matrix(t2), names

  putexcel E6:F6 = "Round 1" ///
    , merge hcenter font(calibri,13) bold underline

  putexcel G6:H6 = "Round 2" ///
    , merge hcenter font(calibri,13) bold underline
	
	putexcel I6:J6 = "Round 3" ///
    , merge hcenter font(calibri,13) bold underline
	
	putexcel K6:M6 = "Excess Learning Round 2" ///
    , merge hcenter font(calibri,13) bold underline
	
	putexcel N6:P6 = "Excess Learning Round 3" ///
    , merge hcenter font(calibri,13) bold underline
	
	
   // --------------------------------------------------------------------------
