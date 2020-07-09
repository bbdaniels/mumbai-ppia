

	// DiD for learning effects
	
	use "$directory/constructed/did_learning.dta", clear
	
	local quality "correct dr_1 dr_4 re_1 re_3 re_4 med_any med_l_any_1 med_l_any_2 med_l_any_3 med_k_any_9"

	valuelabels `quality', name(t1) columns(7) //Create matrix

	mat t1 = r(t1)
	
	matrix colnames t1 = "Non-PPIA Providers" "PPIA Providers" "Non-PPIA Providers" "PPIA Providers" ///
						 "Effect" "Std Error" "P-Value" 
	
	
  egen group = group(wave d_treat), label
  
  // Put statistics in matrix
  local row = 0
  foreach i in `quality' {
    local row = `row' + 1

    quietly areg `i' d_treatXpost i.wave d_treat i.case, a(qutub_id) vce(cluster qutub_id_provider) 

    mat t1[`row', 5] = _b[d_treatXpost] //Effect
    mat t1[`row', 6] = _se[d_treatXpost] //Standard Error
    mat t1[`row', 7] = 2*ttail(e(df_r), abs(_b[d_treatXpost]/_se[d_treatXpost])) //P-value
  
	quietly tabstat `i', by(group) save //Mean values of the 4 groups

    mat t1[`row',1] = r(Stat1)
    mat t1[`row',2] = r(Stat2)
    mat t1[`row',3] = r(Stat3)
    mat t1[`row',4] = r(Stat4)
  
  }
  
  local nRows `= rowsof(t1)'

  forvalues i = 1/`nRows'{ //Round off values
    forvalues j = 1/7 {
      matrix t1[`i', `j'] = round(t1[`i',`j'], 0.001)
    }
  }

  putexcel set "${directory}/outputs/table1.xlsx", replace //Save results in excel

  putexcel D7=matrix(t1), names

  putexcel E6:F6 = "Round 1" ///
    , merge hcenter font(calibri,13) bold underline

  putexcel G6:H6 = "Round 2" ///
    , merge hcenter font(calibri,13) bold underline
   

  forest areg ///
 (dr_4 dr_1 re_1 re_3 re_4 re_5 ) ///
  (med_l_any_1 med_k_any_6 med_k_any_9 med_l_any_2) , ///
     t(d_treatXpost) controls(d_treat i.wave i.case)  ///
    a(qutub_id) vce(cluster qutub_id_provider) bh b ///
	graphopts($graph_opts ///
	xtitle("Learning Effect", size(medsmall)) ///
	xlab( -.3 "-30%" -.2 "-20%" -.1 "-10%" 0 "0%" .1"10%" 0.2 "20%" 0.3"30%", labsize(medsmall)) ylab(,labsize(medsmall))) 
	
	graph export "${directory}/outputs/fig1_DiD.png", width(1000)replace
