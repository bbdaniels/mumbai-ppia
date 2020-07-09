
	use "$directory/constructed/reg_discontinuity_learning.dta", clear
	 
	 //RD plot 
	rdplot re_4 ppsa_cutoff, c(81) covs(case2 case3 case4) graph_options($graph_opts legend(off) xtitle("PPSA Eligibility Score") ytitle("GeneXpert"))
	
	graph export "$directory/outputs/fig3_rd.png", width(1000) replace

	local quality "correct dr_1 dr_4 re_1 re_3 re_4 med_any med_l_any_1 med_l_any_2 med_l_any_3 med_k_any_9"
	valuelabels `quality', name(t3) columns(5) //Create matrix
	mat t3 = r(t3)
	
	matrix colnames t3 = "Non-PPSA hubs" "PPSA hubs" "RD estimate" "Std Error" "p value" 
	
	local row = 0
	foreach i in `quality' {
		local row = `row' + 1
		rdrobust `i' ppsa_cutoff , c(81) covs(case2 case3 case4)
	
		mat t3[`row', 3] = e(tau_cl) //Effect
		mat t3[`row', 4] = e(se_tau_cl) //Standard Error
		mat t3[`row', 5] =  e(pv_cl) 
		
		tabstat `i', by(ppia_facility_2) save
		mat t3[`row', 1] = r(Stat1)
		mat t3[`row', 2] = r(Stat2)
}

	local nRows `= rowsof(t3)'

  forvalues i = 1/`nRows'{ //Round off values
    forvalues j = 1/5 {
      matrix t3[`i', `j'] = round(t3[`i',`j'], 0.001)
    }
  }

  putexcel set "${directory}/outputs/table3.xlsx", replace //Save results in excel

  putexcel D7=matrix(t3), names

