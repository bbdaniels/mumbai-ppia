
	// Case interactions for facilities in PPSA RD sample
	
	use "$directory/constructed/reg_discontinuity.dta", clear 
	
	keep if ppsa_rd == 1
	
	egen group = group(engaged)
	
	// Save results in matrix 
	tabcount case group, v1(1/4) v2(1/2) zero matrix(a1)
	
	// Get column total 
	mata : st_matrix("coltot1", colsum(st_matrix("a1")))
	mat b1 = a1\coltot1 
	
	putexcel set "${directory}/outputs/appendix.xlsx", sheet(6) modify
	
	putexcel D7 = matrix(b1)
	
	putexcel C7 = "SP Case 1"
	putexcel C8 = "SP Case 2"
	putexcel C9 = "SP Case 3"
	putexcel C10 = "SP Case 4"
	putexcel C11 = "Total", bold
	
	putexcel D6 = "Non-PPIA Hubs", bold hcenter 
	putexcel E6 = "PPIA Hubs", bold hcenter 

	putexcel D4:E4 = "PPSA RD Sample", bold hcenter merge 

	
	
	
	

	

	
