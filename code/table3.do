	
	//Learning in PPIA providers from R1 to R2 and from R2 to R3
	
	use "$directory/constructed/learning.dta", clear 
	
	local quality "correct dr_1 dr_4 re_1 re_3 re_4 med_any med_l_any_1 med_l_any_2 med_l_any_3 med_k_any_9"
	
	forest reg ///
	(`quality') if wave < 2, ///
	t(treat) controls(i.case)  b bh a(qutub_id) cl(qutub_id) ///
			graphopts(title(, justification(left) color(black) pos(11)) ///
  	graphregion(color(white) lc(white) lw(med)) bgcolor(white) ///
  	ylab(,angle(0) nogrid) ytit(,placement(left) justification(left))  ///
  	yscale(noline) legend(region(lc(none) fc(none))) ///
			xtit("{&larr} Round 1   Round 2 {&rarr}", size(small)) ///
			xlab(-.30 "-30%" -.20 "-20%" -0.1 "10%" 0 "0%" 0.1 "10%" 0.2 "20%" .3 "30%"   , labsize(small)) ///
			ylab(,labsize(small)))
			
		graph export "$directory/outputs/learning_R2.png", width(1000) replace 
		
	forest reg  ///
	(`quality') if wave != 0 , ///
	t(treat_2) controls(i.case)  b bh a(qutub_id) cl(qutub_id) ///
			graphopts(title(, justification(left) color(black) pos(11)) ///
  	graphregion(color(white) lc(white) lw(med)) bgcolor(white) ///
  	ylab(,angle(0) nogrid) ytit(,placement(left) justification(left))  ///
  	yscale(noline) legend(region(lc(none) fc(none))) ///
			xtit("{&larr} Round 2   Round 3{&rarr}", size(small)) ///
			xlab(-.30 "-30%" -.20 "-20%" -0.1 "10%" 0 "0%" 0.1 "10%" 0.2 "20%" .3 "30%"   , labsize(small)) ///
			ylab(,labsize(small)))
			
		graph export "$directory/outputs/learning_R3.png", width(1000) replace 
		
	
	valuelabels `quality', name(t3) columns(9) //Create matrix

	mat t3 = r(t3)
	
	matrix colnames t3 = "Round 1" ///
	"Round 2" "Round 3" "Reg Coefficient" "Std Error" "P-Value" ///
	"Reg Coefficient" "Std Error" "P-Value"
	
  // Put statistics in matrix
  local row = 0
  foreach i in `quality' {
    local row = `row' + 1

    quietly reg `i' treat i.case if wave != 2, a(qutub_id) cl(qutub_id)
    mat t3[`row', 4] = _b[treat] //Effect
    mat t3[`row', 5] = _se[treat] //Standard Error
    mat t3[`row', 6] = 2*ttail(e(df_r), abs(_b[treat]/_se[treat])) //P-value
	
	quietly reg `i' treat_2 i.case if wave != 0, a(qutub_id) cl(qutub_id)
	mat t3[`row', 7] = _b[treat_2] //Effect
    mat t3[`row', 8] = _se[treat_2] //Standard Error
    mat t3[`row', 9] = 2*ttail(e(df_r), abs(_b[treat_2]/_se[treat_2])) //P-value
	
	quietly tabstat `i', by(wave) save //Mean values of the groups
	mat t3[`row',1] = r(Stat1)
	mat t3[`row',2] = r(Stat2)
	mat t3[`row',3] = r(Stat3)	
		
  }
  
  local nRows `= rowsof(t3)'

  forvalues i = 1/`nRows'{ //Round off values
    forvalues j = 1/9 {
      matrix t3[`i', `j'] = round(t3[`i',`j'], 0.001)
    }
  }

  putexcel set "${directory}/outputs/table3.xlsx", replace //Save results in excel

  putexcel D7=matrix(t3), names
  
  putexcel H6:J6 = "Change from R1 to R2" ///
  , merge hcenter font(calibri,13) bold underline
  
  putexcel K6:M6 = "Change from R2 to R3" ///
  , merge hcenter font(calibri,13) bold underline
	
	
	// -------------------------------------------------------------------------


				
		
