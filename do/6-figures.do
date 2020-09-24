// Learning effect - global
use "${git}/constructed/full-data.dta" ///
  if case < 7 , clear

  // Define treatment effect for regressions
  gen treat = pxh == 1 & wave > 0
    lab var treat "PPIA After Round 1"

  // Generate figure
  forest areg ///
    (dr_1 dr_4 re_1 re_3 re_4) ///
    (med_any med_l_any_1 med_l_any_2 med_l_any_3 med_k_any_9) ///
  , t(treat) c(pxh i.wave i.sample##i.case) ///
    a(fid) cl(pid) b bh
    
    graph export "${git}/outputs/f-learning-global.eps" , replace
    
// Convenience effect - global 
use "${git}/constructed/full-data.dta" ///
  if case < 7 , clear

  // Define treatment effect for regressions
  gen ppia = 0
    lab var ppia "PPIA Facility"
  forvalues i = 0/2 {
    replace ppia = 1 if wave == `i' & ppia_facility_`i' == 1
  }

  // Generate figure
  forest areg ///
    (dr_1 dr_4 re_1 re_3 re_4) ///
    (med_any med_l_any_1 med_l_any_2 med_l_any_3 med_k_any_9) ///
  , t(ppia) c(i.wave i.sample##i.case) ///
    a(pid) cl(fid) b bh
    
    graph export "${git}/outputs/f-convenience-global.eps" , replace

// End of dofile
