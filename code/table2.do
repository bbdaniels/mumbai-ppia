

	use "$directory/constructed/did_convenience.dta", clear

	
	local quality "correct dr_1 dr_4 re_1 re_3 re_4 med_any med_l_any_1 med_l_any_2 med_l_any_3 med_k_any_9"
	

	valuelabels `quality', name(t2) columns(9) //Create matrix

	mat t2 = r(t2)
	
	matrix colnames t2 = "NNL Control" "NNL Treated" "PPIA" ///
					     "NNL Control" "NNL Treated" "PPIA" ///
						 "Effect" "Std Error" "P-Value" 
	
	

  egen group = group(wave type), label
  
  // Put statistics in matrix
  local row = 0
  foreach i in `quality' {
    local row = `row' + 1

    quietly areg `i' d_type2_wave wave d_type2 d_type3 d_type3_wave i.case, ///
	a(qutub_id_provider) vce(cluster qutub_id) 

    mat t2[`row', 7] = _b[d_type2_wave] //Effect
    mat t2[`row', 8] = _se[d_type2_wave] //Standard Error
    mat t2[`row', 9] = 2*ttail(e(df_r), abs(_b[d_type2_wave]/_se[d_type2_wave])) //P-value
  
	quietly tabstat `i', by(group) save //Mean values of the 3 groups

    mat t2[`row',1] = r(Stat1)
    mat t2[`row',2] = r(Stat2)
    mat t2[`row',3] = r(Stat3)
    mat t2[`row',4] = r(Stat4)
	mat t2[`row',5] = r(Stat5)
	mat t2[`row',6] = r(Stat6)
  
  }
  
  local nRows `= rowsof(t2)'

  forvalues i = 1/`nRows'{ //Round off values
    forvalues j = 1/9 {
      matrix t2[`i', `j'] = round(t2[`i',`j'], 0.001)
    }
  }

  putexcel set "${directory}/outputs/table2.xlsx", replace //Save results in excel

  putexcel D7=matrix(t2), names

  putexcel E6:G6 = "Wave-0" ///
    , merge hcenter font(calibri,13) bold underline

  putexcel H6:J6 = "Wave-1" ///
    , merge hcenter font(calibri,13) bold underline
  
	forest areg ///
  (dr_4 dr_1 re_1 re_3 re_4 re_5 ) ///
  (med_l_any_1 med_k_any_6 med_k_any_9 med_l_any_2) , ///
  t(d_type2_wave) control(wave d_type2 d_type3 d_type3_wave i.case) ///
  a(qutub_id_provider) vce(cluster qutub_id) bh b ///
	graphopts($graph_opts ///
	xtitle("Convenience Effect", size(medsmall)) ///
	xlab( -0.75 "-75%" -.5 "-50%" -0.25"25%" 0 "0%" 0.25"25%" .5"50%" 0.75"75%", labsize(medsmall)) ylab(,labsize(medsmall))) 
	
	
	graph export "$directory/outputs/fig2_did.png", width(1000) replace
	
	
	
	
