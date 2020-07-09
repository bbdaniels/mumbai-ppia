
	//Pooled treatment effect on PPIA joining apple hubs 
	
	use "$directory/constructed/apple_part1.dta", clear 
	
	forest reg ///
  (dr_4 dr_1 re_1 re_3 re_4 re_5 ) ///
  (med_l_any_1 med_k_any_6 med_k_any_9 med_l_any_2) , ///
  t(d_treat) control(i.case i.wave d_type2 d_type3) ///
  vce(cluster qutub_id) bh b ///
	graphopts($graph_opts ///
	xtitle("Pooled Treatment Effect of joining PPIA network", size(small)) ///
	xlab( -0.75 "-75%" -.5 "-50%" -0.25"25%" 0 "0%" 0.25"25%" .5"50%" 0.75"75%", labsize(medsmall)) ylab(,labsize(medsmall))) 
	
	graph export "${directory}/outputs/apple_part1.png", replace 
	
	local quality "correct dr_1 dr_4 re_1 re_3 re_4 med_any med_l_any_1 med_l_any_2 med_l_any_3 med_k_any_9"

	valuelabels `quality', name(t5) columns(9) //Create matrix

	mat t5 = r(t5)
	
	matrix colnames t5 = "Non-PPIA Apple hubs" "PPIA Apple hubs" "PPIA hubs"  "Non-PPIA Apple hubs" "PPIA Apple hubs" "PPIA hubs" ///
						 "Effect" "Std Error" "P-Value" 
	
  egen group = group(wave type), label
  
  // Put statistics in matrix
  local row = 0
  foreach i in `quality' {
    local row = `row' + 1

    quietly reg `i' d_treat i.case i.wave d_type2 d_type3, ///
  vce(cluster qutub_id)

    mat t5[`row', 7] = _b[d_treat] //Effect
    mat t5[`row', 8] = _se[d_treat] //Standard Error
    mat t5[`row', 9] = 2*ttail(e(df_r), abs(_b[d_treat]/_se[d_treat])) //P-value
  
	quietly tabstat `i', by(group) save //Mean values of the 3 groups

    mat t5[`row',1] = r(Stat1)
    mat t5[`row',2] = r(Stat2)
    mat t5[`row',3] = r(Stat3)
    mat t5[`row',4] = r(Stat4)
	mat t5[`row',5] = r(Stat5)
	mat t5[`row',6] = r(Stat6)
  
  }
  
  local nRows `= rowsof(t5)'

  forvalues i = 1/`nRows'{ //Round off values
    forvalues j = 1/9 {
      matrix t5[`i', `j'] = round(t5[`i',`j'], 0.001)
    }
  }

  putexcel set "${directory}/outputs/table5A.xlsx", replace //Save results in excel

  putexcel D7=matrix(t5), names

  putexcel E6:G6 = "Round 1" ///
    , merge hcenter font(calibri,13) bold underline

  putexcel H6:J6 = "Round 2" ///
    , merge hcenter font(calibri,13) bold underline
   	
