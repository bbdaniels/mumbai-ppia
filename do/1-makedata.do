// Create full appended dataset

  iecodebook append ///
    "${git}/data/wave-0.dta" ///
    "${git}/data/wave-1.dta" ///
    "${git}/data/wave-2.dta" ///
    using  "${git}/data/append-metadata.xlsx" ///
    , clear surveys(Round1 Round2 Round3) gen(round)

  merge m:1 cp_4 using "${git}/data/master-facilities.dta" , keep(3) nogen
  merge m:1 cp_7 using "${git}/data/master-providers.dta" , keep(1 3) nogen
  
// Create new variables and make data corrections
  
  // Correct prices in yes/no field
  replace re_1 = 1 if re_1 > 1 & !missing(re_1)

  // Flag providers and create clinic FE groups for non-specific providers
  gen pxh = cp_7 != ""
    lab var pxh "PPIA Provider"
    replace cp_7 = cp_4 if cp_7 == ""

  // Create new variables for medication indicators
  lab def med_l 1 "Anti-TB Medication" 3 "Other Antibiotic" , modify
  anycat med_k_ med_l_ , shortlabel
  gen med_any = med > 0
    lab var med_any "Any Medication"
    
  // More friendly variable labels
  lab var dr_4 "Referral"
  
  // More friendly value labels
  lab def case 1 "SP Case 1" 2 "SP Case 2" 3 "SP Case 3" 4 "SP Case 4" , modify
  lab def wave 0 "Round 1" 1 "Round 2" 2 "Round 3"
    lab val wave wave
    
  // More friendly IDs
  egen fid = group(cp_4)
    lab var fid "Facility ID"
  egen pid = group(cp_7)
    lab var pid "Provider ID"
    
    order pid fid, first
    
  // Save
  save "${git}/constructed/full-data.dta" , replace
    iecodebook export using "${git}/constructed/full-data.xlsx" , replace
      
// End of dofile
