
	
	
	use "$directory/constructed/reg_discontinuity.dta", clear 
	
	//RD plot for PPSA sample (local fit)
	rdplot re_4 ppsa_cutoff if ppsa_rd == 1, c(81) covs(case2 case3 case4) p(3) ci(95) graph_options($graph_opts legend(off) xtitle("PPSA Eligibility Score") ytitle("GeneXpert"))
	
	graph export "$directory/outputs/rdplot_local.png", width(1000) replace
	
	//RD plot for full sample (global fit)
	rdplot re_4 ppsa_cutoff , c(81) covs(case2 case3 case4) p(3) ci(95) graph_options($graph_opts legend(off) xtitle("PPSA Eligibility Score") ytitle("GeneXpert"))
	
	graph export "$directory/outputs/rdplot_global.png", width(1000) replace
	

	local quality "correct dr_1 dr_4 re_1 re_3 re_4 med_any med_l_any_1 med_l_any_2 med_l_any_3 med_k_any_9"

	valuelabels `quality', name(t5) columns(5) //Create matrix

	mat t5 = r(t5)
	
	matrix colnames t5 = "Non-PPIA Hubs" "PPIA Hubs" ///
	 "Reg Coefficient" "Std Error" "P-Value" 
	
  // Put statistics in matrix
	local row = 0
	foreach i in `quality' {
    local row = `row' + 1

    quietly reg `i' engaged ppsa_cutoff i.case if ppsa_rd == 1, cl(qutub_id)
    mat t5[`row', 3] = _b[engaged] //Effect
    mat t5[`row', 4] = _se[engaged] //Standard Error
    mat t5[`row', 5] = 2*ttail(e(df_r), abs(_b[engaged]/_se[engaged])) 
	//P-value

	quietly tabstat `i', by(engaged) save //Mean values of the groups
	mat t5[`row',1] = r(Stat1)
	mat t5[`row',2] = r(Stat2)

  }
  
  local nRows `= rowsof(t5)'

  forvalues i = 1/`nRows'{ //Round off values
    forvalues j = 1/5 {
      matrix t5[`i', `j'] = round(t5[`i',`j'], 0.001)
    }
  }

  putexcel set "${directory}/outputs/table5.xlsx", sheet(1) modify //Save results in excel

  putexcel D7=matrix(t5), names
  
  // Global RD 
  
  valuelabels `quality', name(t6) columns(5) //Create matrix

	mat t6 = r(t6)
	
	matrix colnames t6 = "Non-PPIA Hubs" "PPIA Hubs" ///
	 "Reg Coefficient" "Std Error" "P-Value" 
	
  // Put statistics in matrix
	local row = 0
	foreach i in `quality' {
    local row = `row' + 1

    quietly reg `i' engaged ppsa_cutoff i.case , cl(qutub_id)
    mat t6[`row', 3] = _b[engaged] //Effect
    mat t6[`row', 4] = _se[engaged] //Standard Error
    mat t6[`row', 5] = 2*ttail(e(df_r), abs(_b[engaged]/_se[engaged])) 
	//P-value

	quietly tabstat `i', by(engaged) save //Mean values of the groups
	mat t6[`row',1] = r(Stat1)
	mat t6[`row',2] = r(Stat2)

  }
  
  local nRows `= rowsof(t6)'

  forvalues i = 1/`nRows'{ //Round off values
    forvalues j = 1/5 {
      matrix t6[`i', `j'] = round(t6[`i',`j'], 0.001)
    }
  }

  putexcel set "${directory}/outputs/table5.xlsx", sheet(2) modify //Save results in excel

  putexcel D7=matrix(t6), names
  
  

  
