 // Table with number of SP visits per sample type in each wave
 
 use "${directory}/constructed/analysis-panel.dta", clear
 
 egen type = group(qutub_sample ppia_facility_0 ppia_facility_1 ppia_facility_2), label 
 
 
 forv sample = 1/3 {
	tab type wave if qutub_sample == `sample', matcell(a`sample')
	//matrix colnames a`sample' = "Wave-0" "Wave-1" "Wave-2"
	 mata : st_matrix("coltot`sample'", colsum(st_matrix("a`sample'")))
	 mat b`sample' = a`sample'\coltot`sample'
 }
 
 putexcel set "${directory}/outputs/tableA1.xlsx", replace 
 
 local row = 4
 forv i = 1/3 {
	putexcel C`row' = matrix(b`i')
	local nRows `= rowsof(b`i')'
	local row = `row' + `nRows' + 2
 }
 
 putexcel B3 = "Apple Hubs", bold 
 putexcel B4 = "Never joined PPIA network"
 putexcel B5 = "Part of PPIA network round 2"
 putexcel B6 = "Part of PPIA network in round 2 and 3"
 putexcel B7 = "Total", bold
 
 putexcel B9 = "PPIA Hubs", bold
 putexcel B10 = "Left PPIA network in round 3"
 putexcel B11 = "Always a part of PPIA network"
 putexcel B12 = "Total", bold
 
 putexcel B14 = "NNL Hubs", bold 
 putexcel B15 = "Never joined PPIA network"
 putexcel B16 = "Part of PPIA network round 2"
 putexcel B17 = "Part of PPIA network in round 2 and 3"
 putexcel B18 = "Total", bold
 
 putexcel B20 = "PPSA A/B Hubs", bold
 putexcel B21 = "PPSA RD Hubs", bold
 putexcel B22 = "PPSA Extensive Hubs", bold 
 
 putexcel C2 = "Round 1", bold
 putexcel D2 = "Round 2", bold
 putexcel E2 = "Round 3", bold
 
 keep if qutub_sample > 3
 
 tab qutub_sample, matcell(a1)
 putexcel E20 = matrix(a1)
 
 

 
 
