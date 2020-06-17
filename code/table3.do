
	use "$directory/constructed/Reg_discontinuity_learning.dta", clear
	
	local quality "correct dr_1 dr_4 re_1 re_3 re_4 med_any med_l_any_1 med_l_any_2 med_l_any_3 med_k_any_9"

	valuelabels `quality', name(t3) columns(7) //Create matrix

	mat t3 = r(t3)
	
	matrix colnames t3 = "PPIA" "Left PPIA" "PPIA" "Left PPIA" ///
						 "Effect" "Std Error" "P-Value" 
	
	
	//4 groups according to wave and trial_assignment
  egen group = group(wave d_treat), label
  
  // Put statistics in matrix
  local row = 0
  foreach i in `quality' {
    local row = `row' + 1

    quietly reg `i' d_treatXpost d_treat d_post i.case, vce(cluster qutub_id) 

    mat t3[`row', 5] = _b[d_treatXpost] //Effect
    mat t3[`row', 6] = _se[d_treatXpost] //Standard Error
    mat t3[`row', 7] = 2*ttail(e(df_r), abs(_b[d_treatXpost]/_se[d_treatXpost])) //P-value
  
	quietly tabstat `i', by(group) save //Mean values of the 4 groups

    mat t3[`row',1] = r(Stat1)
    mat t3[`row',2] = r(Stat2)
    mat t3[`row',3] = r(Stat3)
    mat t3[`row',4] = r(Stat4)
  
  }
  
  local nRows `= rowsof(t3)'

  forvalues i = 1/`nRows'{ //Round off values
    forvalues j = 1/7 {
      matrix t3[`i', `j'] = round(t3[`i',`j'], 0.001)
    }
  }

  putexcel set "${directory}/outputs/table3.xlsx", replace //Save results in excel

  putexcel D7=matrix(t3), names

  putexcel E6:F6 = "Wave-1" ///
    , merge hcenter font(calibri,13) bold underline

  putexcel G6:H6 = "Wave-2" ///
    , merge hcenter font(calibri,13) bold underline
  
  forest reg ///
  (`quality') ///
    , t(d_treatXpost) controls(d_treat d_post i.case) ///
    vce(cluster qutub_id) bh sort(global) ///
	graphopts($graph_opts ///
	xtitle("Learning Effect", size(medsmall)) ///
	xlab( -.3 "-30%" -.2 "-20%" -.1 "-10%" 0 "0%" .1"10%" 0.2 "20%" 0.3"30%", labsize(medsmall)) ylab(,labsize(medsmall))) 
	
	graph export "${directory}/outputs/fig3_DiD.eps", replace
