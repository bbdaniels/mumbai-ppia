
	// Case interactions of known providers in PPIA engaged and not engaged facilities 
	
	use "${directory}/constructed/global_convenience.dta", clear 
	
	egen group = group(engaged wave), label 
	
	// Save case interactions in matrix
	tabcount case group, v1(1/4) v2(1/6) zero matrix(a1)
	
	// Get column total
	mata : st_matrix("coltot1", colsum(st_matrix("a1")))
	mat b1 = a1\coltot1 
	
	putexcel set "${directory}/outputs/appendix.xlsx", sheet(4) modify
	
	putexcel D7 = matrix(b1)
	
	putexcel C7 = "SP Case 1"
	putexcel C8 = "SP Case 2"
	putexcel C9 = "SP Case 3"
	putexcel C10 = "SP Case 4"
	putexcel C11 = "Total", bold
	
	putexcel D6 = "Round 1"
	putexcel E6 = "Round 2"
	putexcel F6 = "Round 3"
	
	putexcel G6 = "Round 1"
	putexcel H6 = "Round 2"
	putexcel I6 = "Round 3"
	
	putexcel D5:F5 = "Non-PPIA Hubs", bold hcenter merge
	putexcel G5:I5 = "PPIA Hubs", bold hcenter merge 
	
	putexcel E3:G3 = "For known PPIA providers", bold hcenter merge 
	
	
