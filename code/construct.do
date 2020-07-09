// Cleanup: Wave 0 --------------------------------------------------------------------------
	
	use "${directory}/data/sp-wave-0.dta" , clear

	tostring form dr_5b_no re_1_a med_h_1 med_j_2 cp_13 med_f_2 med_f_3 re_*_c re_2_c re_11_a re_12_*_* cp_12 cp_12_3 re_4_a, force replace

	rename med_any_ med_any
	
	save "${directory}/constructed/sp-wave-0.dta" , replace

// Cleanup: Wave 1 --------------------------------------------------------------------------
	use "${directory}/data/sp-wave-1.dta" , clear

	tostring form re_1_a dr_3a dr_5a_no dr_5b_no med_h_1 med_j_2 re_12_2 re_12_3 re_12_4 re_12_*_* sp3_h_24_2 , force replace
	replace re_1 = 1 if re_1 > 1

	rename g* g_*
	
	replace dr_4 = 0 if dr_4 == 3
	
	gen pxh = qutub_id_provider != qutub_id
	replace ppia_provider_0 = 1 if pxh
	replace ppia_provider_1 = 1 if pxh  
	drop pxh 
	
	
	save "${directory}/constructed/sp-wave-1.dta" , replace
	
	
// Cleanup: Wave2 --------------------------------------------------------------------------

	use "$directory/data/sp-wave-2.dta" , clear
	
	tostring form re_1_a dr_3a dr_5a_no dr_5b_no med_h_1 med_j_2 re_12_2 re_12_3 re_12_4 re_12_*_* sp3_h_24_2 , force replace
	replace re_1 = 1 if re_1 > 1

	rename g* g_*
	
	gen pxh = qutub_id != qutub_id_provider
	replace ppia_provider_0 = 1 if pxh
	replace ppia_provider_1 = 1 if pxh  
	drop pxh 
	
	save "${directory}/constructed/sp-wave-2.dta" , replace


// Append --------------------------------------------------------------------------------------
	use "${directory}/constructed/sp-wave-0.dta"

	qui append using ///
	"${directory}/constructed/sp-wave-1.dta" ///
	"${directory}/constructed/sp-wave-2.dta" ///
	, gen(wave) force
	label def wave 0 "Round 1" 1 "Round 2" 2 "Round 3"
	label val wave wave

	drop *given

// Cleanup : Appended dataset --------------------------------------------------------------------------

	drop sample
	drop if qutub_sample > 6 

	lab var correct "Correct"
	lab var dr_4 "Referral"

	label define case 7 "SP7", add
	label values case case
	
	drop if case == 7
	
save "${directory}/constructed/analysis-panel.dta" , replace

	

	//Create Dataset for Learning Effects Diff in Diff --------------------------------------------------------------------------
	
	use "${directory}/constructed/analysis-panel.dta", clear
	
	drop if wave == 2
	
	keep if qutub_sample == 2 // keep only PPIA sample 
	
	gen d_treat = ppia_provider_0 == 1 // Dummy for PPIA provider
	lab var d_treat "PPIA provider"
    lab val d_treat yesno

	// Dummy for whether treatment received in the round
	gen d_treatXpost =  d_treat * wave 
    lab var d_treatXpost "PPIA status in round 2"
    lab val d_treatXpost yesno
	
	save "$directory/constructed/did_learning.dta", replace 
	
//----------------------------------------------------------------------------

	// Create Dataset for Convenience Effect Diff in Diff
	
	use "${directory}/constructed/analysis-panel.dta", clear
	  drop if wave == 2 
	  
	  drop if qutub_sample == 1 //drop apple hubs 
	 
	  keep if qutub_id != qutub_id_provider //keep only PPIA providers
	  
	  //keep PPIA providers present in NNL hubs in either of the rounds
	  forv w = 0/1 {
		forv s = 2/3 {
			gen type`s' = qutub_sample == `s' if wave == `w'
			bys qutub_id_provider : egen type`s'_`w' = max(type`s')
			replace type`s'_`w' = 0 if type`s'_`w' == .
			drop type`s'
			}
	  }
	  
	keep if ((type2_0 == 1 & (type3_0 == 1 | type3_1 == 1)) | ///
			(type3_0 == 1 & (type3_0 == 1 | type3_1 == 1)))
	
	//group facilities according to ppia status in the 2 rounds
	egen type = group(ppia_facility_0 ppia_facility_1), label 
	
	forv i = 2/3{
		gen d_type`i' = type == `i' //Dummy for facility type
		//Dummy for interaction of facility type and wave 
		gen d_type`i'_wave = type == `i' & wave == 1 
	}
	
	save "$directory/constructed/did_convenience.dta", replace 
	

//----------------------------------------------------------------------------
	
	// Create Dataset for Learning Effect Reg. Discontinuity
	
	use "${directory}/constructed/analysis-panel.dta", clear
	
	keep if wave == 2
	
	keep if ppsa_rd == 1 // Keep only PPSA Sample 
	
	gen case2 = case == 2 //Dummy for cases 
	gen case3 = case ==3 
	gen case4 = case==4
	
	
	save "$directory/constructed/reg_discontinuity_learning.dta", replace

//----------------------------------------------------------------------------

	//Dataset for PPIA leaving NNL facilities in round 3
	
	use "${directory}/constructed/analysis-panel.dta", clear
	
	drop if wave == 0
	  
	  keep if qutub_sample == 2 | qutub_sample == 3  //drop apple hubs 
	  
	  keep if qutub_id != qutub_id_provider // only PPIA providers
	  
	  //keep PPIA providers present in NNL hubs in either round 2 or 3 
	  
	  forv w = 1/2 {
		forv s = 2/3 {
			gen type`s' = qutub_sample == `s' if wave == `w'
			bys qutub_id_provider : egen type`s'_`w' = max(type`s')
			replace type`s'_`w' = 0 if type`s'_`w' == .
			drop type`s'
			}
	  }
	  
	  keep if ((type2_1 == 1 & (type3_1 == 1 | type3_2 == 1)) ///
			  | (type2_2 == 1 & (type3_1 == 1 | type3_2 == 1)))
			 
	egen type = group(qutub_sample ppia_facility_1 ppia_facility_2), label
	
	forv i = 1/5 {
		gen d_type`i' = type == `i' //Dummy for facility type
		//Dummy for interaction of facility type and wave 
		gen d_type`i'_wave = type == `i' & wave == 2
	}
	
	drop d_type5 d_type5_wave // drop comparison group : NNL hubs that remained in PPIA in round 3
	
	save "$directory/constructed/did_convenience2.dta", replace 
	
//----------------------------------------------------------------------------
 
 // Dataset for pooled treatment effect on PPIA joining apple hubs 
 
	use "${directory}/constructed/analysis-panel.dta", clear
	
	keep if qutub_sample == 1 | qutub_sample == 2 //drop NNL hubs
	drop if wave == 2 // drop round 3
	
	egen type = group(qutub_sample ppia_facility_0 ppia_facility_1), label
	
	gen d_treat = (ppia_facility_0 == 1 & wave == 0)| (ppia_facility_1 == 1 & wave == 1) // hub considered treated in a round if its a part of PPIA network in that round 
	
	gen d_type2 = type == 2 
	gen d_type3 = type == 3
	
	save "$directory/constructed/apple_part1.dta", replace 
	
//----------------------------------------------------------------------------
	
	// Dataset for pooled treatment effect on PPIA leaving apple hubs and PPIA hubs
	
	use "${directory}/constructed/analysis-panel.dta", clear
	drop if wave == 0 // keep round 2 and 3
	keep if qutub_sample == 1 | qutub_sample == 2 // drop NNL hubs
	
	egen type = group(qutub_sample ppia_facility_1 ppia_facility_2), label
	
	gen d_treat = (ppia_facility_1 == 0 & wave == 1)| (ppia_facility_2 == 0 & wave == 2) // hub considered treated if its not a part of PPIA network in that round 
	 
	 forv i = 2/5{
		gen d_type`i' = type == `i'
	 }
	 
	 save "$directory/constructed/apple_part2.dta", replace 
	 
	 //----------------------------------------------------------------------------
	 
	 //Dataset for diff in diff b/w PPIA hubs and Non-PPIA apple hubs from round 1 to 2
	 
	use "${directory}/constructed/analysis-panel.dta", clear
	drop if wave == 2 // drop round 3
	keep if qutub_sample == 1| qutub_sample == 2 // drop NNL hubs 
	
	egen type = group(ppia_facility_0 ppia_facility_1), label
	drop if type == 2 // drop PPIA joining apple hubs
	
	gen d_type3 = type == 3
	gen d_type3_wave = d_type3 * wave
	
	save "$directory/constructed/apple_part3.dta", replace 
	
//----------------------------------------------------------------------------
	 
	 //Dataset for diff in diff b/w PPIA hubs that leave the network in round 3 and pure apple hubs 

	use "${directory}/constructed/analysis-panel.dta", clear
	drop if wave == 0 // drop round 1 
	keep if qutub_sample == 1| qutub_sample == 2 // drop NNL hubs
	egen type = group(qutub_sample ppia_facility_1 ppia_facility_2), label
	
	keep if type == 1 | type == 4 // keep only pure apple hubs and PPIA hubs that leave network in round 3
	
	gen d_treat = type == 4 & wave == 2
	
	save "$directory/constructed/apple_part4.dta", replace 
	
	
	
