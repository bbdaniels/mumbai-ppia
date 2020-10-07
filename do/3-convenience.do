// Global model
use "${git}/constructed/full-data.dta" ///
  if case < 7 , clear

  gen treat = 0
    lab var treat "PPIA Facility"
  forvalues i = 0/2 {
    replace treat = 1 if wave == `i' & ppia_facility_`i' == 1
  }
      
  areg re_4 treat i.wave ppia_facility_? ///
    i.sample##i.case##i.pxh ///
    , a(pid) cl(fid)
  
  est sto global

// Known providers only
use "${git}/constructed/full-data.dta" ///
  if case < 7  , clear

  gen treat = 0
    lab var treat "PPIA Facility"
  forvalues i = 0/2 {
    replace treat = 1 if wave == `i' & ppia_facility_`i' == 1
  }
  
  gen treat1 = treat == 1 & pxh == 0
      
  areg re_4 treat treat1 i.wave ppia_facility_? ///
    i.sample##i.case ///
    , a(pid) cl(fid)
  
  est sto known
  
// Separate effects; all providers
use "${git}/constructed/full-data.dta" ///
  if case < 7   , clear
  
  gen treat = ///
    ppia_facility_0 == 1 & wave == 0 ///
  | ppia_facility_1 == 1 & wave == 1 
  
  gen treat2 = ppia_facility_2 == 1 & wave == 2
    lab var treat2 "PPIA Round 3"
    
  egen check = group(pid fid)
  areg re_4 treat treat2 i.case i.wave , a(check) robust
  
  est sto all
  
// Known providers only; separate effects
use "${git}/constructed/full-data.dta" ///
  if case < 7  & pxh == 1 , clear
  
  gen treat = ///
    ppia_facility_0 == 1 & wave == 0 ///
  | ppia_facility_1 == 1 & wave == 1 
  
  gen treat2 = ppia_facility_2 == 1 & wave == 2
    lab var treat2 "PPIA Round 3"
  
  egen check = group(pid fid)
  areg re_4 treat treat2 i.case i.wave , a(check) robust
  
  est sto separate
  
// Separate effects; non-PPIA providers
use "${git}/constructed/full-data.dta" ///
  if case < 7  & pxh != 1 , clear
  
  gen treat = ///
    ppia_facility_0 == 1 & wave == 0 ///
  | ppia_facility_1 == 1 & wave == 1 
  
  gen treat2 = ppia_facility_2 == 1 & wave == 2
    lab var treat2 "PPIA Round 3"
  
  egen check = group(pid fid)
  areg re_4 treat treat2 i.case i.wave , a(check) robust
  
  est sto nonppia

// Print table
use "${git}/constructed/full-data.dta" , clear
  gen treat = ""
  gen treat1 = ""
  gen treat2 = ""
  lab var treat  "PPIA Facility"
  lab var treat1 "PPIA Facility for non-PPIA provider"
  lab var treat2 "PPIA Facility Round 3"
  
  outwrite global known all separate nonppia ///
    using "${git}/outputs/t-convenience.tex" ///
  , replace keep(treat treat1 treat2 *) format(%9.3f) stats(N r2) ///
    drop(i.wave#i.case i.sample i.sample#i.case i.case#i.pxh i.sample#i.pxh i.sample#i.case#i.pxh ppia_facility_?)  ///
    nobold nolab statform(%9.0f %9.3f) ///
    colnames("Pooled Model" "PPIA Providers" "Separate Effects" "Separate PPIA" "Separate Other") ///
    add( ///
      ("Samples" "1a 2a 3" "1a 2a 3"  "All" "All" "All") ///
      ("Rounds" "All" "All" "All" "All" "All") ///
      ("Fixed Effects" "Provider" "Provider" "Provider-Facility" "Provider-Facility" "Provider-Facility" ) ///
      ("Clustering" "Facility" "Facility" "Robust" "Robust" "Robust" ) ///
      ("Sample-Case Control" "Yes" "Yes" "No" "No" "No") ///
    )
    
// End of dofile
