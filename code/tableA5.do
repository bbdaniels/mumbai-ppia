
	// Case interactions of known providers in facilities that changed PPIA status in R2 and the ones that didn'that
	
	use "$directory/constructed/ppia_convenience.dta", clear
	
	egen group_2 = group (type wave), label 
	
	// Save case interactions in matrix
	tabcount case group_2, v1(1/4) v2(1/6) zero matrix(a1)
	
	//Get column total 
	mata : st_matrix("coltot1", colsum(st_matrix("a1")))
	mat b1 = a1\coltot1 
	
	putexcel set "${directory}/outputs/appendix.xlsx", sheet(5) modify
	
	putexcel D7 = matrix(b1)
	
	putexcel C7 = "SP Case 1"
	putexcel C8 = "SP Case 2"
	putexcel C9 = "SP Case 3"
	putexcel C10 = "SP Case 4"
	putexcel C11 = "Total", bold
	
	putexcel D6 = "Round 1"
	putexcel E6 = "Round 2"
	
	putexcel F6 = "Round 1"
	putexcel G6 = "Round 2"
	
	putexcel H6 = "Round 1"
	putexcel I6 = "Round 2"
	
	putexcel D5:E5 = "Non-PPIA Hubs always", bold hcenter merge
	putexcel F5:G5 = "Hubs that joined PPIA in R2", bold hcenter merge 
	putexcel H5:I5 = "PPIA Hubs always", bold hcenter merge 
	
	putexcel E3:G3 = "For known PPIA providers", bold hcenter merge 
	
	
	
	
	
	

	
