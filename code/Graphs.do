
	//Year over year for all the hubs (apple,nnl,ppia)
	
  use "$directory/constructed/analysis-panel.dta", clear
  
  drop if wave == 2
  
  local quality "checklist_essential_pct correct dr_4 dr_1 re_1 re_3 re_4 re_5 med_l_any_1 med_k_any_6 med_k_any_9 med_l_any_2"
 						
	betterbar ///
	`quality' , ///
	over(wave) xlab($pct) xscale(noline) barcolor(eltblue eltgreen) $graph_opts
	
	graph export "$directory/outputs/means_allhubs.eps", replace
	
	//Year over year for GeneExpert by case scenario
	
	betterbar ///
	re_4 , ///
	by(case) over(wave) barcolor(eltblue eltgreen) ///
	xlab($pct) xscale(noline) $graph_opts
	
	graph export "$directory/outputs/GeneExpert_allhubs.eps", replace
	
//------------------------------------------------------------------------------	
	// Year over year Apple Hubs 	
	graphmeans , sample(1)
	
	// Year over year PPIA walkins 
	graphmeans , sample(2)
	
	//Year over year NNL
	graphmeans, sample(3)
	
//------------------------------------------------------------------------------	
	// Year over year Apple hubs that joined and did not join PPIA in Round-2
	use "${directory}/constructed/apple-analysis-panel.dta", clear
	  						
	betterbar ///
	`quality' if applehub_always == 1 , ///
	over(wave) xlab($pct) xscale(noline) ///
	barcolor(eltblue eltgreen) $graph_opts2 ///
	title("Always Apple Hub", size(medium) justification(center) span)
	
	graph save "$directory/outputs/applehub_always.gph", replace
	
	betterbar ///
	`quality' if applehub_always == 0 , ///
	over(wave) xlab($pct) xscale(noline) ///
	barcolor(eltblue eltgreen) $graph_opts2 ///
	title("Apple Hub joins PPIA in round-2", justification(center) span size(medium))
	
	graph save "$directory/outputs/applehub_joinsPPIA.gph", replace
	
	graph combine ///
	"$directory/outputs/applehub_always.gph" ///
	"$directory/outputs/applehub_joinsPPIA.gph" , ///
	xcommon altshrink
	
	graph export "$directory/outputs/applehub.eps", replace 
	
//------------------------------------------------------------------------------
	
	// Line graph 1 :PPIA and Non-PPIA providers at Apple hubs that joined and didn't join PPIA in Round-2
	 use "$directory/constructed/applegroups-analysis-panel.dta", clear
	
	egen group_wave = group(group wave), label 
	
	mat fig=J(1,10,0)
	
	//colnames according to the group and round 
	matrix colnames fig = "1_0" "1_1" "2_0" "2_1" "3_0" "3_1" "4_0" "4_1" "n_0" "n_1"
	
	mat fig[1,9] = 1 // round-1
	mat fig[1,10] = 2  //round-2
	
	set scheme s2color
	
	tabstat re_4, by(group_wave) save //Save mean values in matrix
		
	local column = 1 
		
	forvalues column = 1/7 {
		if `column'<4 {
		mat fig[1, `column'] = r(Stat`column') 
		}
		else if `column' > 4{
		mat fig[1, `column'+1] = r(Stat`column')
		}
		local column = `column' +1
	}
	
	mat fig[1,4] = . // one group has no value for round-2
		
	svmat float fig , names(matcol) //Create variables from matrix
			
	keep fig* //Reshape to long format 
	gen id = _n
	reshape long fig1_ fig2_ fig3_ fig4_ fign_, i(id) j(wave)
			
	label define lblindicator 1 "Round 1" 2 "Round 2"
	label values fign_ lblindicator
			
	//Line graph for all the 4 groups
			
	scatter fig1_ fign_, c(l) || scatter fig2_ fign_, c(l) || ///
	scatter fig3_ fign_, c(l) || scatter fig4_ fign_, c(l) ///
	ytitle("") xtitle("GeneExpert") /// 
	legend(order(1 "Non-PPIA providers at Non-PPIA Apple hubs" ///
			2 "PPIA providers at Non-PPIA Apple hubs" ///
			3 "Non-PPIA providers at Apple hubs that joined PPIA" ///
			4 "PPIA providers at Apple hubs that joined PPIA") ///
			region(lcolor(white))) ///
			xlabel(1 2, valuelabel) ylabel(,angle(0)) legend(size(vsmall)) ///
			graphregion(color(white) lwidth(large)) ///
			ylab(0.05 "5%" 0.1 "10%" 0.15 "15%"  0.2 "20%" 0.25 "25%", notick nogrid)
		
			
	graph export "${directory}/outputs/linegraph1.eps", replace
		
//------------------------------------------------------------------------------

	//Line graph 2: GeneExpert for Random and PPIA providers at Non-PPIA and PPIA hubs
	
	use "$directory/constructed/linegraph2.dta", clear
	
	 mat fig = J(1,10,0) 
	 mat colnames fig = "1_0" "1_1" "2_0" "2_1" "3_0" "3_1" "4_0" "4_1" "n_0" "n_1"
	 
	 local i = 1
	 local column = 1 
	 
	 forv i = 1/4 {
		tabstat re_4, by(group`i'_0) save 
		mat fig[1, `column'] = r(Stat2) //Saving means of all groups in the matrix 
		tabstat re_4, by(group`i'_1) save 
		mat fig[1,`column'+1] = r(Stat2)
		local column = `column' +2
	 }
	 
	mat fig[1,9] = 1
	mat fig[1,10] = 2 
	
	svmat float fig , names(matcol) //Create variables from matrix
			
	keep fig* //Reshape to long format 
	gen id = _n
	reshape long fig1_ fig2_ fig3_ fig4_ fign_, i(id) j(wave)
			
	label define lblindicator 1 "Round-1" 2 "Round-2"
	label values fign_ lblindicator
			
	//Line graph for all the 4 groups
	scatter fig1_ fign_, c(l) || scatter fig2_ fign_, c(l) || ///
	scatter fig3_ fign_, c(l) || scatter fig4_ fign_, c(l) ///
	ytitle("") xtitle("GeneExpert") /// 
	legend(order(1 "Random provider at Non-PPIA hub" ///
				 2 "Random provider at PPIA hub" ///
				 3 "PPIA provider at Non-PPIA hub" ///
				 4 "PPIA provider at PPIA hub") ///
			region(lcolor(white))) ///
			xlabel(1 2, valuelabel) ylabel(,angle(0)) legend(size(small)) ///
			graphregion(color(white) lwidth(large)) ///
			ylab( 0.1 "10%" 0.2 "20%" 0.3 "30%" 0.4 "40%" 0.5 "50%", notick nogrid)
		
			
	graph export "${directory}/outputs/linegraph2.eps", replace	

	//------------------------------------------------------------------------------
	// Line Graphs for GeneExpert use for each TB case by Random and PPIA providers
	// at PPIA and Non-PPIA hubs 
	
	 use "$directory/constructed/linegraph2.dta", clear
	
	local case = 1
	forv case = 1/4 {
	
	preserve
		keep if case == `case'
		 mat fig = J(1,10,0) 
		 mat colnames fig = "1_0" "1_1" "2_0" "2_1" "3_0" "3_1" "4_0" "4_1" "n_0" "n_1"
		 
		 local i = 1
		 local column = 1 
		 
		 forv i = 1/4 {
			tabstat re_4, by(group`i'_0) save 
			mat fig[1, `column'] = r(Stat2) //Saving means of all groups in the matrix 
			tabstat re_4, by(group`i'_1) save 
			mat fig[1,`column'+1] = r(Stat2)
			local column = `column' +2
		 }
		 
		mat fig[1,9] = 1
		mat fig[1,10] = 2 
		
		svmat float fig , names(matcol) //Create variables from matrix
				
		keep fig* //Reshape to long format 
		gen id = _n
		reshape long fig1_ fig2_ fig3_ fig4_ fign_, i(id) j(wave)
				
		label define lblindicator 1 "Round-1" 2 "Round-2"
		label values fign_ lblindicator
				
		//Line graph for all the 4 groups
		scatter fig1_ fign_, c(l) || scatter fig2_ fign_, c(l) || ///
		scatter fig3_ fign_, c(l) || scatter fig4_ fign_, c(l) ///
		ytitle("") xtitle("GeneExpert-TB Case`case'") /// 
		legend(order(1 "Random provider at Non-PPIA hub" ///
					 2 "Random provider at PPIA hub" ///
					 3 "PPIA provider at Non-PPIA hub" ///
					 4 "PPIA provider at PPIA hub") ///
				region(lcolor(white))) ///
				xlabel(1 2, valuelabel) ylabel(,angle(0)) legend(size(small)) ///
				graphregion(color(white) lwidth(large)) ///
				ylab( 0.1 "10%" 0.2 "20%" 0.3 "30%" 0.4 "40%" 0.5 "50%" 0.6 "60%" ///
					  0.7 "70%", notick nogrid)
			
				
		graph save "${directory}/outputs/linegraph3_case`case'.gph", replace	
	restore
	} 
	
	grc1leg ///
	"${directory}/outputs/linegraph3_case1.gph" ///
	"${directory}/outputs/linegraph3_case2.gph" ///
	"${directory}/outputs/linegraph3_case3.gph" ///
	"${directory}/outputs/linegraph3_case4.gph", ///
	legendfrom("${directory}/outputs/linegraph3_case1.gph") ///
	rows(2) altshrink ycommon graphregion(color(white))
	
	graph export "${directory}/outputs/linegraph3.eps", replace

	//------------------------------------------------------------------------------
	
