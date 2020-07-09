
 use "${directory}/constructed/analysis-panel.dta", clear
 
 egen type = group(qutub_sample ppia_facility_0 ppia_facility_1 ppia_facility_2), label
 
 egen type2 = group(wave case), label
 
 tabcount type type2, v1(1/3) v2(1/12) zero matrix(a1)
 tabcount type type2, v1(4/5) v2(1/12) zero matrix(a2)
 tabcount type type2, v1(6/8) v2(1/12) zero matrix(a3)

 forv sample = 1/3 {
	
	 mata : st_matrix("coltot`sample'", colsum(st_matrix("a`sample'")))
	 mat b`sample' = a`sample'\coltot`sample'
 }
 
 putexcel set "${directory}/outputs/tableA2.xlsx", replace 
 
 local row = 4
 forv i = 1/3 {
	putexcel C`row' = matrix(b`i')
	local nRows `= rowsof(b`i')'
	local row = `row' + `nRows' + 2
 }
 
 putexcel B3 = "Apple Hubs", bold 
 putexcel B4 = "Never joined PPIA network"
 putexcel B5 = "Part of PPIA network only in round 2"
 putexcel B6 = "Part of PPIA network in round 2 and 3"
 putexcel B7 = "Total", bold
 
 putexcel B9 = "PPIA Hubs", bold
 putexcel B10 = "Left PPIA network in round 3"
 putexcel B11 = "Always a part of PPIA network"
 putexcel B12 = "Total", bold
 
 putexcel B14 = "NNL Hubs", bold 
 putexcel B15 = "Never joined PPIA network"
 putexcel B16 = "Part of PPIA network only in round 2 "
 putexcel B17 = "Part of PPIA network in round 2 and 3"
 putexcel B18 = "Total", bold
 
 putexcel B20 = "PPSA A/B Hubs", bold
 putexcel B21 = "PPSA RD Hubs", bold
 putexcel B22 = "PPSA Extensive Hubs", bold 
 
 putexcel C1:F1 = "Round 1", bold hcenter merge
 putexcel G1:J1 = "Round 2", bold hcenter merge 
 putexcel K1:N1 = "Round 3", bold hcenter merge 
  
 local ncol = 3
 local j = 1
 
 forv j = 1/3{
	local i = 1
	forv i = 1/4 {
		local col: word `ncol' of `c(ALPHA)'
		putexcel `col'2 = "Case `i'"
		local ncol = `ncol' + 1
		local i = `i' + 1
	}
	local j = `j' + 1
 }
 
 keep if qutub_sample > 3
 tab qutub_sample case, matcell(a1)
 putexcel K20 = matrix(a1)
 
