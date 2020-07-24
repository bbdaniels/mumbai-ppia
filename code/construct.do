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

// Dataset for baseline balance ------------------------------------------------------------------------------

	use "${directory}/constructed/analysis-panel.dta" , clear
	keep if wave == 0 
	replace ppia_provider_0 = 0 if ppia_provider_0 == .
	save "$directory/constructed/baseline.dta", replace 

// Dataset for global learning -------------------------------------------------------------------------------
	use "${directory}/constructed/analysis-panel.dta" , clear
	gen pxh = qutub_id != qutub_id_provider // PPIA providers 
	
	//Dummy variables for wave and PPIA provider in current round 
	forv i = 1/2{
		gen wave_`i' = wave == `i' 
		gen pxh_w`i' = pxh * wave_`i' 
	}
	
	label var wave_1 "Wave 1"
	label var wave_2 "Wave 2"
	label var pxh_w1 "PPIA provider in wave 1"
	label var pxh_w2 "PPIA provider in wave 2"
	
	egen type = group(wave pxh), label 
	
	save "$directory/constructed/global_learning", replace 
	
// Dataset for learning in PPIA providers -------------------------------------------------------------------------------
	
	use "${directory}/constructed/analysis-panel.dta" , clear
	
	keep if qutub_sample < 3 // Keep only PPIA and Apple Hubs 
	
	gen pxh = qutub_id != qutub_id_provider // Known PPIA providers
	keep if pxh == 1 
	label var pxh "Known PPIA Provider"
	
	gen treat = ppia_provider_0 == 1 & wave == 1 
	label var treat "PPIA provider in wave 1"
	gen treat_2 = ppia_provider_0 == 1 & wave == 2
	label var treat "PPIA provider in wave 2 "
	
	save "$directory/constructed/learning.dta", replace 
	
// Dataset for global convenience effect  -------------------------------------------------------------------------------

	use "${directory}/constructed/analysis-panel.dta" , clear
	gen pxh = qutub_id != qutub_id_provider // Known PPIA providers
	keep if pxh == 1 
	label var pxh "Known PPIA Provider"
	
	gen engaged = 0 // Facility PPIA status in current round
	forv i = 0/2 {
		replace engaged = 1 if ppia_facility_`i' == 1 & wave == `i'
	}
	label var engaged "Facility PPIA status in current round"
	
	egen type = group(wave engaged), label 

	save "${directory}/constructed/global_convenience.dta", replace 
	
// Dataset for convenience effect for specific PPIA providers from R1 to R2 -------------------------------------------------------------------------------

	use "${directory}/constructed/analysis-panel.dta" , clear
	
	gen pxh = qutub_id != qutub_id_provider // Known PPIA providers
	keep if pxh == 1 
	label var pxh "Known PPIA Provider"
	
	keep if wave < 2
	
	gen engaged = 0
	forv i = 0/1 {
		replace engaged = 1 if ppia_facility_`i' == 1 & wave == `i'
	}
	label var engaged "Facility PPIA status in current round"
	
	egen type = group(ppia_facility_0 ppia_facility_1), label 
	egen group = group(wave type), label 
	
	save "$directory/constructed/ppia_convenience.dta", replace 
	
	
// Dataset for ppsa hubs in round 3 - regression discontinuity -------------------------------------------------------------------------------

	use "${directory}/constructed/analysis-panel.dta" , clear
	
	gen engaged = 0 // Facility PPIA status in current round
	forv i = 0/2 {
		replace engaged = 1 if ppia_facility_`i' == 1 & wave == `i'
	}
	
	keep if wave == 2
	
	gen case2 = case == 2 //Dummy variables for cases 
	gen case3 = case ==3 
	gen case4 = case==4
	
	save "$directory/constructed/reg_discontinuity.dta", replace 

// -----------------------------------------------------------------------------
	
	
