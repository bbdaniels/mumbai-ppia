
	// Baseline balance of PPIA and Non-PPIA providers 
	
	use "${directory}/constructed/baseline.dta" , clear
	
	local quality "correct dr_1 dr_4 re_1 re_3 re_4 med_any med_l_any_1 med_l_any_2 med_l_any_3 med_k_any_9"
	

		forest reg ///
		(`quality' ) ///
		, t(ppia_provider_0) controls(i.case i.qutub_sample) b bh vce(cluster qutub_id) ///
			graphopts(title(, justification(left) color(black) pos(11)) ///
  	graphregion(color(white) lc(white) lw(med)) bgcolor(white) ///
  	ylab(,angle(0) nogrid) ytit(,placement(left) justification(left))  ///
  	yscale(noline) legend(region(lc(none) fc(none))) ///
			xtit("{&larr} Favors Non-PPIA providers   Favors PPIA providers {&rarr}", size(small)) ///
			xlab(-0.3 "-30%" -.2 "-20%" -.1 "-10%"  0 "0%" .1 "10%" .2 "20%" 0.3 "30%"   , labsize(small)) ///
			ylab(,labsize(small)))
			
			graph export "${directory}/outputs/figure1.png", width(1000) replace
			
	valuelabels `quality', name(t1) columns(5) //Create matrix
	mat t1 = r(t1)
	
	matrix colnames t1 = "Non-PPIA providers" "PPIA Providers" "Reg Coefficient" "Std Error" "p value" 
	
	local row = 0
	foreach i in `quality' {
		local row = `row' + 1
		reg `i' ppia_provider_0 i.case i.qutub_sample, cl(qutub_id)
	
		mat t1[`row', 3] = _b[ppia_provider_0] //Effect
		mat t1[`row', 4] = _se[ppia_provider_0] //Standard Error
		mat t1[`row', 5] =  2*ttail(e(df_r), abs(_b[ppia_provider_0]/_se[ppia_provider_0])) 
		
		tabstat `i', by(ppia_provider_0) save
		mat t1[`row', 1] = r(Stat1)
		mat t1[`row', 2] = r(Stat2)
}

	local nRows `= rowsof(t1)'

  forvalues i = 1/`nRows'{ //Round off values
    forvalues j = 1/5 {
      matrix t1[`i', `j'] = round(t1[`i',`j'], 0.001)
    }
  }

  putexcel set "${directory}/outputs/table1.xlsx", replace //Save results in excel

  putexcel D7=matrix(t1), names

// ----------------------------------------------------------------------------
