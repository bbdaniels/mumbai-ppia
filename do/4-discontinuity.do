// Regression discontinuity analysis
use "${git}/constructed/full-data.dta" ///
  if case < 7 &  wave == 2 , clear
  
  gen cutoff = ppsa_cutoff > 81
    lab var cutoff "Round 3 Eligibility Loss"

  // Robust estimates
  xi: rdrobust re_4 ppsa_cutoff  , p(0) c(81)  bwselect(msetwo) all covs(i.sample*i.case)
  xi: rdrobust re_4 ppsa_cutoff  , p(1) h(80 15) c(81)  bwselect(msetwo) all covs(i.sample*i.case)
  xi: rdrobust re_4 ppsa_cutoff  , p(1) c(81)  bwselect(msetwo) all covs(i.sample*i.case) vce(cluster fid)
    est sto local 
  
  xi: rdrobust re_4 rd  ,  p(3)  h(80 15) all vce(cluster fid) covs(i.sample i.case) 
    

    rdrobust re_4 ppsa_cutoff if ppsa_rd == 1, c(81) covs(type? pxh) vce(cluster fid) 
      est sto local
      -
    rdrobust re_4 ppsa_cutoff , c(81) covs(type?) vce(cluster fid) 
      est sto global
      
  // Linear RD
  use "${git}/constructed/full-data.dta" ///
    if case < 7 &  wave == 2 , clear
    
    gen Robust = ppsa_cutoff > 81
      lab var Robust "Loss of PPIA Eligibility"
      
    gen a = ppsa_cutoff - 81
    xi: rdbwselect re_4 ppsa_cutoff , c(81) bwselect(msetwo)  covs(i.sample*i.case)

    reg re_4 Robust a i.Robust#c.a i.sample##i.case  ///
      if ppsa_cutoff > (81-`e(h_msetwo_l)') & ppsa_cutoff < (81+`e(h_msetwo_r)') ///
     , cl(fid)
      est sto linear
      
  // Diff-diff estimates
  use "${git}/constructed/full-data.dta" ///
    if case < 7 &  wave >= 1 , clear
    
    gen cutoff = ppsa_cutoff > 81
      lab var cutoff "Round 3 Eligibility Loss"
    
    bys fid: egen min = min(wave)
      keep if min == 1
    gen RD_Estimate = cutoff * (wave==2)
      gen untreated = cutoff
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
    gen cutoff = ""
      lab var cutoff "Round 3 Eligibility Loss"
  
  outwrite local localreg global globalreg globalreg2 ///
    using "${git}/outputs/t-discontinuity.tex" ///
  , replace stats(N) format(%9.3f) nobold nolab statform(%9.0f %9.4f) ///
    drop(untreated i.wave#i.case i.sample i.sample#i.case)  ///
    colnames("Local Robust" "Local Linear" "Global Robust" "Global Linear" "Global Diff-Diff") ///
    add( ///
      ("Samples" "All ex. 2b" "All ex. 2b" "All ex. 2b" "All ex. 2b" "1a 2a 3") ///
      ("Rounds" "3" "3" "3" "3" "2 3") ///
      ("Provider FE" "No" "No" "No" "No" "Yes" ) ///
      ("Clustering" "Facility" "Facility" "Facility" "Facility" "Facility") ///
      ("Case Control" "Yes" "Yes" "Yes" "Yes" "Yes") ///
      ("Sample-Case Control" "No" "Yes" "No" "Yes" "Yes") ///
    )

// End of dofile
