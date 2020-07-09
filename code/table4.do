
	//Effect on PPIA leaving NNL facilities 
	
	use "$directory/constructed/did_convenience2.dta", clear 
			  
	forest areg ///
  (dr_4 dr_1 re_1 re_3 re_4 re_5 ) ///
  (med_l_any_1 med_k_any_6 med_k_any_9 med_l_any_2) , ///
  t(d_type4_wave) control(i.wave d_type* i.case) ///
  a(qutub_id_provider) vce(cluster qutub_id) bh b ///
	graphopts($graph_opts ///
	xtitle("Leaving Effect", size(medsmall)) ///
	xlab( -0.75 "-75%" -.5 "-50%" -0.25"25%" 0 "0%" 0.25"25%" .5"50%" 0.75"75%", labsize(medsmall)) ylab(,labsize(medsmall))) 
	
	
	graph export "${directory}/outputs/did_convenience_part3.png", replace
	
	
	local quality "correct dr_1 dr_4 re_1 re_3 re_4 med_any med med_l_any_1 med_l_any_2 med_l_any_3 med_k_any_9"

	valuelabels `quality', name(t4) columns(7) //Create matrix

	mat t4 = r(t4)

    matrix colnames t4 = "NNL control" ///
						"NNL treated" ///
						"NNL control " ///
						"NNL treated" ///
						"Reg Estimate" ///
						 "Std Error" "p value" 
						 
	egen group = group(wave type), label 
						 
	local row = 0
  foreach i in `quality' {
    local row = `row' + 1

    quietly areg `i' i.wave d_type* i.case, a(qutub_id_provider) vce(cluster qutub_id)

    mat t4[`row', 5] = _b[d_type4_wave] //Effect
    mat t4[`row', 6] = _se[d_type4_wave] //Standard Error
    mat t4[`row', 7] = 2*ttail(e(df_r), abs(_b[d_type4_wave]/_se[d_type4_wave])) //P-value

	
		quietly tabstat `i', by(group) save
		mat t4[`row', 1] = r(Stat5)
		mat t4[`row', 2] = r(Stat4)
		mat t4[`row', 3] = r(Stat10)
		mat t4[`row', 4] = r(Stat9)
	}

	local nRows `= rowsof(t4)'

  forvalues i = 1/`nRows'{ //Round off values
    forvalues j = 1/7 {
      matrix t4[`i', `j'] = round(t4[`i',`j'], 0.001)
    }
  }

  putexcel set "${directory}/outputs/table4.xlsx", replace //Save results in excel

  putexcel D7=matrix(t4), names

  putexcel E6:F6 = "Round 2" ///
    , merge hcenter font(calibri,13) bold underline

  putexcel G6:H6 = "Round 3" ///
    , merge hcenter font(calibri,13) bold underline
  
	
	putexcel E7 = "NNL hubs that were a part of PPIA network in round 2 and 3"
	putexcel F7 = "NNL hubs that were a part of PPIA network only in round 2"
	putexcel G7 = "NNL hubs that were a part of PPIA network in round 2 and 3"
	putexcel H7 = "NNL hubs that were a part of PPIA network only in round 2"
	putexcel I7 = "Reg. Estimate"
	putexcel J7 = "Std. Error"
	
