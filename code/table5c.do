
	//Diff in diff b/w PPIA hubs and Non-PPIA apple hubs from round 1 to 2
	
	use "$directory/constructed/apple_part3.dta", clear 
	
	forest reg ///
  (dr_4 dr_1 re_1 re_3 re_4 re_5 ) ///
  (med_l_any_1 med_k_any_6 med_k_any_9 med_l_any_2) , ///
  t(d_type3_wave) control(i.wave i.case d_type3) ///
  vce(cluster qutub_id) bh b  ///
	graphopts($graph_opts ///
	xtitle("Diff in growth b/w PPIA hubs and Non-PPIA apple hubs", size(vsmall)) ///
	xlab( -0.75 "-75%" -.5 "-50%" -0.25"25%" 0 "0%" 0.25"25%" .5"50%" 0.75"75%", labsize(medsmall)) ylab(,labsize(medsmall))) 

	graph export "${directory}/outputs/apple_part3.png", replace 
	
	local quality "correct dr_1 dr_4 re_1 re_3 re_4 med_any med_l_any_1 med_l_any_2 med_l_any_3 med_k_any_9"

	valuelabels `quality', name(t7) columns(7) //Create matrix

	mat t7 = r(t7)
	
	matrix colnames t7 = "Non-PPIA Apple hubs" "PPIA hubs" "Non-PPIA Apple hubs" "PPIA hubs" ///
						 "Effect" "Std Error" "P-Value" 
	
  egen group = group(wave type), label
  
  // Put statistics in matrix
  local row = 0
  foreach i in `quality' {
    local row = `row' + 1

    quietly reg `i' d_type3_wave i.case i.wave d_type3, ///
  vce(cluster qutub_id)

    mat t7[`row', 5] = _b[d_type3_wave] //Effect
    mat t7[`row', 6] = _se[d_type3_wave] //Standard Error
    mat t7[`row', 7] = 2*ttail(e(df_r), abs(_b[d_type3_wave]/_se[d_type3_wave])) //P-value
  
	quietly tabstat `i', by(group) save //Mean values of the 3 groups

	local column = 1 
	
	forv column = 1 /4 {
		 mat t7[`row', `column'] = r(Stat`column')	
		 local column = `column' + 1
	}
  
  }
  
  local nRows `= rowsof(t7)'

  forvalues i = 1/`nRows'{ //Round off values
    forvalues j = 1/7 {
      matrix t7[`i', `j'] = round(t7[`i',`j'], 0.001)
    }
  }

  putexcel set "${directory}/outputs/table5C.xlsx", replace //Save results in excel

  putexcel D7=matrix(t7), names

  putexcel E6:F6 = "Round 1" ///
    , merge hcenter font(calibri,13) bold underline

  putexcel G6:H6 = "Round 2" ///
    , merge hcenter font(calibri,13) bold underline
