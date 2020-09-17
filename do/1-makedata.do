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
  anycat med_k_ med_l_
  gen med_any = med > 0
    lab var med_any "Any Medication"
    
  // More friendly IDs
  gen fid = cp_4
    lab var fid "Facility ID"
  gen pid = cp_7
    lab var pid "Provider ID"
    
    order pid fid, first
    
  // Save
  save "${git}/constructed/full-data.dta" , replace
    iecodebook export using "${git}/constructed/full-data.xlsx" , replace
      
// End of dofile
