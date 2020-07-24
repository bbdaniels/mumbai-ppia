
	
 //Case interactions for known providers in Apple hubs and PPIA hubs across rounds
 
	use "$directory/constructed/learning.dta", clear 
	
	egen group = group(qutub_sample wave)
	
	tabcount case group, v1(1/4) v2(1/6) zero matrix(a1) //Save tabcount in matrix
	
	// Save sum of columns 
	mata : st_matrix("coltot1", colsum(st_matrix("a1")))
	mat b1 = a1\coltot1 
	
	putexcel set "${directory}/outputs/appendix.xlsx", sheet(3) modify
	
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
	
	putexcel D5:F5 = "Apple Hubs", bold hcenter merge
	putexcel G5:I5 = "PPIA Hubs", bold hcenter merge 
	
	putexcel E3:G3 = "For known PPIA providers", bold hcenter merge 
