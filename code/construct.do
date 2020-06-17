
	// Dataset for graph of apple hubs

	 use "${directory}/constructed/analysis-panel.dta", clear
	 
	 drop if wave == 2
	 
	 gen applehub_always = qutub_apple == 1 & ppia_facility_1 == 0
	 replace applehub_always = . if qutub_apple == 0
	 
	 sort qutub_id wave
	 
	 by qutub_id : replace applehub_always = applehub_always[1]
	 
	 save "${directory}/constructed/apple-analysis-panel.dta", replace
	 
//------------------------------------------------------------------------------	 
	//Dataset for line graph of apple hubs
	
	use "$directory/constructed/apple-analysis-panel.dta", clear
	
	drop if wave == 2
	
	 drop if applehub_always == . // Keeping only Apple Hubs
	 
	 gen group = 1 if (applehub_always == 1 & (ppia_provider_0 != 1 ///
	| ppia_provider_1 != 1 )) // Non-PPIA providers at Apple hubs that didn't join PPIA in round-2 
	
	replace group = 2 if (applehub_always == 1 & (ppia_provider_0 == 1 ///
	| ppia_provider_1 == 1 )) // PPIA providers at Apple Hubs that didn't join PPIA in round-2
	
	replace group = 3 if (applehub_always == 0 & (ppia_provider_0 != 1 ///
	| ppia_provider_1 != 1 )) // Non-PPIA providers at Apple Hubs that joined PPIA in round-2
	
	replace group = 4 if (applehub_always == 0 & (ppia_provider_0 == 1 ///
	| ppia_provider_1 == 1 )) // PPIA providers at Apple Hubs that joined PPIA in round-2
	
	save "$directory/constructed/applegroups-analysis-panel.dta", replace 
	
//------------------------------------------------------------------------------	
	//Dataset for line graphs of random and PPIA providers at Non-PPIA and PPIA hubs
	
	**** Not sure of Random provider at PPIA hub in Round-2 and in general all numbers of Round-2
	
	 use "$directory/constructed/analysis-panel.dta", clear
	 
	 drop if wave == 2
	 
	 //Groups for Round 1
	 gen group1_0 = wave == 0 & qutub_sample_1 == 1 //Random provider at Non-PPIA hub
	 gen group2_0 = wave == 0 & qutub_sample_2 == 1 //Random provider at PPIA hub
	 //PPIA provider at Non-PPIA hub
	 gen group3_0 = wave == 0 & ppia_provider_0 == 1 & ppia_facility_0 == 0 
	 //PPIA provider at PPIA hub
	 gen group4_0 = wave == 0 & ppia_provider_0 == 1 & ppia_facility_0 == 1
	 
	 //Groups for Round 2
	 //Random provider at Non-PPIA hub
	 gen group1_1 = ppia_facility_1 == 0 & qutub_sample == 1 & wave == 1 
	 //Random provider at PPIA hub
	 gen targeted2 = 1 if qutub_sample_3 == 0 & ppia_provider_0 == 1 // provider targeted in round-2 if he was PPIA in a random walk in in wave-1
	 sort qutub_id_provider wave 
	 bys qutub_id_provider : gen targeted = 1 if qutub_sample_3[1] == 1 //provider targeted in round-2 if he was targeted in round-1
	 bys qutub_id_provider : replace targeted = 1 if targeted2 == 1 //total targeted providers
	 gen group2_1 = wave == 1 & ppia_facility_1 == 1 & targeted == .
	 
	 //PPIA provider at Non-PPIA hub
	 gen group3_1 = wave == 1 & ppia_provider_1 == 1 & ppia_facility_1 == 0 
	 //PPIA provider at PPIA hub
	 gen group4_1 = wave == 1 & ppia_provider_1 == 1 & ppia_facility_1 == 1 
	 
	 save "$directory/constructed/linegraph2.dta", replace

//----------------------------------------------------------------------------

	//Create Dataset for Learning Effects Diff in Diff
	
	/*PPIA providers receive treatment in both the rounds; how to incorporate that*/
	
	use "${directory}/constructed/analysis-panel.dta", clear
	
	drop if wave == 2
	
	keep if qutub_sample == 2 // keep only PPIA sample 
	drop if qutub_id == "QH2GN0006" //facility not present in wave-1
	
	gen d_treat = ppia_provider_0 == 1 // Dummy for PPIA provider
	lab var d_treat "PPIA Provider"
    lab val d_treat yesno

	gen d_post = wave // Dummy for time period
  	lab var d_post "Time Period"
    lab val d_post yesno

	// Dummy for whether treatment received in the round
	gen d_treatXpost =  d_treat*d_post
    lab var d_treatXpost "Treatment Received"
    lab val d_treatXpost yesno
	
	save "$directory/constructed/DiD_learning.dta", replace 
	
//----------------------------------------------------------------------------

	// Create Dataset for Convenience Effect Diff in Diff
	
	use "${directory}/constructed/analysis-panel.dta", clear
	
	drop if wave == 2
	
	drop if qutub_sample == 1 // include only ppia and nnl sample
	
	//group facilities according to ppia status in the 2 rounds
	egen type = group(ppia_facility_0 ppia_facility_1), label 
	
	//Dummy for whether facility is engaged in PPIA or not
	gen d_treat = type == 3 | type == 2
	lab var d_treat "PPIA Facility"
	lab val d_treat yesno
	
	gen d_post = wave //Dummy for time period
	lab var d_post "Time Period"
	lab val d_post yesno
	
	//Dummy for whether treatment received in the round
	gen d_treatXpost = d_treat * d_post  	
	replace d_treatXpost = 1 if type == 3 // PPIA sample treated in both the rounds
	lab var d_treatXpost "Treatment Received"
	lab val d_treatXpost yesno
	
	save "$directory/constructed/DiD_convenience.dta", replace

//----------------------------------------------------------------------------
	
	// Create Dataset for Learning Effect Reg. Discontinuity
	
	use "${directory}/constructed/analysis-panel.dta", clear
	drop if wave == 0
	
	keep if ppsa_rd == 1 
	
	//Dummy for whether facilities engaged in PPIA
	gen d_treat = ppia_facility_2 == 0
	lab var d_treat "Left PPIA"
	lab val d_treat yesno
	
	gen d_post = wave == 2 //Dummy for time period
	lab var d_post "Time Period"
	lab val d_post yesno
	
	//Dummy for whether treatment received in the round
	gen d_treatXpost = d_treat * d_post
	lab var d_treatXpost "Treatment Received"
	lab val d_treatXpost yesno
	
	save "$directory/constructed/Reg_discontinuity_learning.dta", replace

	
	
	
	
	
	
