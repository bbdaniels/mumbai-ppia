// Regression discontinuity analysis
use "${git}/constructed/full-data.dta" ///
  if case < 7 &  wave == 2 , clear

  tab case, gen(case) // Need dummy variables for -rdrobust-
  
  gen cutoff = ppsa_cutoff > 81
    lab var cutoff "Round 3 Eligibility Loss"

  // Robust estimates
  
    rdrobust re_4 ppsa_cutoff if ppsa_rd == 1, c(81) covs(case?) vce(cluster fid) 
      est sto local
      
    rdrobust re_4 ppsa_cutoff , c(81) covs(case?) vce(cluster fid) 
      est sto global
      
  // Linear RD estimates
  
    gen RD_Estimate = -ppia_facility_2
      lab var RD_Estimate "Loss of PPIA Eligibility"
    
    reg re_4 RD_Estimate ppsa_cutoff i.sample##i.case , cl(fid)
      est sto globalreg

    reg re_4 RD_Estimate ppsa_cutoff i.sample##i.case if ppsa_rd == 1 , cl(fid)
      est sto localreg
      
  // Diff-diff estimates
  use "${git}/constructed/full-data.dta" ///
    if case < 7 &  wave >= 1 , clear
    
    bys fid: egen min = min(wave)
      keep if min == 1
    gen RD_Estimate = -ppia_facility_2 * (wave==2)
      gen untreated = -ppia_facility_2
        lab var untreated "Control"
  
    areg re_4 RD_Estimate untreated ppsa_cutoff i.wave i.sample##i.case if ppia_facility_1 == 1, cl(fid) a(pid)
      est sto globalreg2
      
  // Print table
  use "${git}/constructed/full-data.dta" ///
    if case < 7 &  wave >= 1 , clear
    
    gen untreated = ""
      lab var untreated "Control"
    gen RD_Estimate = ""
      lab var RD_Estimate "Loss of Eligibility"
      lab var ppsa_cutoff "Running Variable"
  
  outwrite local localreg global globalreg globalreg2 ///
    using "${git}/outputs/t-discontinuity.tex" ///
  , replace stats(N) format(%9.3f) nobold nolab statform(%9.0f %9.4f) ///
    drop(untreated i.wave#i.case i.sample i.sample#i.case)  ///
    colnames("Local Robust" "Local Linear" "Global Robust" "Global Linear" "Global Diff-Diff") ///
    add( ///
      ("Samples" "All ex. 2b" "All ex. 2b" "All ex. 2b" "All ex. 2b" "All ex. 2b") ///
      ("Rounds" "3" "3" "3" "3" "2 3") ///
      ("Provider FE" "No" "No" "No" "No" "Yes" ) ///
      ("Clustering" "Facility" "Facility" "Facility" "Facility" "Facility") ///
      ("Case Control" "Yes" "Yes" "Yes" "Yes" "Yes") ///
      ("Sample-Case Control" "No" "No" "Yes" "Yes" "Yes") ///
    )

// End of dofile
