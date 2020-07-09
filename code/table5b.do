
	use "$directory/constructed/apple_part2.dta", clear
	
	forest reg ///
  (dr_4 dr_1 re_1 re_3 re_4 re_5 ) ///
  (med_l_any_1 med_k_any_6 med_k_any_9 med_l_any_2) , ///
  t(d_treat) control(i.case i.wave d_type*) ///
  vce(cluster qutub_id) bh b ///
	graphopts($graph_opts ///
	xtitle("Pooled Treatment Effect of leaving PPIA network", size(small)) ///
	xlab( -0.75 "-75%" -.5 "-50%" -0.25"25%" 0 "0%" 0.25"25%" .5"50%" 0.75"75%", labsize(medsmall)) ylab(,labsize(medsmall))) 

	graph export "${directory}/outputs/apple_part2.png", replace 
	
	local quality "correct dr_1 dr_4 re_1 re_3 re_4 med_any med_l_any_1 med_l_any_2 med_l_any_3 med_k_any_9"

	valuelabels `quality', name(t6) columns(13) //Create matrix

	mat t6 = r(t6)
	
	matrix colnames t6 = "Non-PPIA Apple hubs" "PPIA Apple hubs in R2" "PPIA Apple hubs in R2 & 3"  "PPIA hubs in R2" "Always PPIA hubs" ///
	"Non-PPIA Apple hubs" "PPIA Apple hubs in R2" "PPIA Apple hubs in R2 & 3"  "PPIA hubs in R2" "Always PPIA hubs" ///
						 "Effect" "Std Error" "P-Value" 
	
	
  egen group = group(wave type), label
  
  // Put statistics in matrix
  local row = 0
  foreach i in `quality' {
    local row = `row' + 1

    quietly reg `i' d_treat i.case i.wave d_type* , ///
  vce(cluster qutub_id)

    mat t6[`row', 11] = _b[d_treat] //Effect
    mat t6[`row', 12] = _se[d_treat] //Standard Error
    mat t6[`row', 13] = 2*ttail(e(df_r), abs(_b[d_treat]/_se[d_treat])) //P-value
  
	quietly tabstat `i', by(group) save //Mean values of the 3 groups

	local column = 1
	
    forv column = 1/10 {
		mat t6[`row',`column'] = r(Stat`column')
		local column = `column' + 1
	}
  }
  
  local nRows `= rowsof(t6)'

  forvalues i = 1/`nRows'{ //Round off values
    forvalues j = 1/13 {
      matrix t6[`i', `j'] = round(t6[`i',`j'], 0.001)
    }
  }

  putexcel set "${directory}/outputs/table5B.xlsx", replace //Save results in excel

  putexcel D7=matrix(t6), names

  putexcel E6:I6 = "Round 2" ///
    , merge hcenter font(calibri,13) bold underline

  putexcel J6:N6 = "Round 3" ///
    , merge hcenter font(calibri,13) bold underline
   	
