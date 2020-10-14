// Pooled model
use "${git}/constructed/full-data.dta" ///
  if case < 7 , clear

  gen treat = 0
    lab var treat "PPIA Facility"
  forvalues i = 0/2 {
    replace treat = 1 if wave == `i' & ppia_facility_`i' == 1
  }
      
  areg re_4 treat i.wave  ///
    i.sample##i.case##i.pxh ///
    , a(pid) cl(fid)
  
  est sto pooled

// PPIA Interaction
use "${git}/constructed/full-data.dta" ///
  if case < 7  , clear

  gen treat = 0
    lab var treat "PPIA Facility"
  forvalues i = 0/2 {
    replace treat = 1 if wave == `i' & ppia_facility_`i' == 1
  }
  
  gen treat1 = treat == 1 & pxh == 1
      
  areg re_4 treat treat1 i.wave  ///
    i.sample##i.case##i.pxh ///
    , a(pid) cl(fid)
  
  est sto interaction
  
// Separate effects for all providers
use "${git}/constructed/full-data.dta" ///
  if case < 7   , clear
  
  gen treat = ///
    ppia_facility_0 == 1 & wave == 0 ///
  | ppia_facility_1 == 1 & wave == 1 
  
  gen treat2 = ppia_facility_2 == 1 & wave == 2
    lab var treat2 "PPIA Round 3"
    
  egen check = group(pid fid)
  areg re_4 treat treat2 i.case i.wave i.sample##i.case##i.pxh , a(check) cl(fid)
  
  est sto separate
  
// PPIA Wave Identification
use "${git}/constructed/full-data.dta" ///
  if case < 7  & pxh == 1 , clear
  
  gen treat = ///
    ppia_facility_0 == 1 & wave == 0 ///
  | ppia_facility_1 == 1 & wave == 1 
  
  gen treat2 = ppia_facility_2 == 1 & wave == 2
    lab var treat2 "PPIA Round 3"
  
  egen check = group(pid fid case)
  isid uid, sort
  set seed 667618	// random.org Timestamp: 2020-10-14 20:44:17 UTC
  areg re_4 treat treat2 i.wave, a(check) vce(bootstrap , r(1000) cluster(pid))
  
  est sto wave
  
// PPIA Facility Identification
use "${git}/constructed/full-data.dta" ///
  if case < 7  & pxh == 1 , clear
  
  gen treat = ///
    ppia_facility_0 == 1 & wave == 0 ///
  | ppia_facility_1 == 1 & wave == 1 
  
  gen treat2 = ppia_facility_2 == 1 & wave == 2
    lab var treat2 "PPIA Round 3"
  
  egen check = group(pid wave case)
  isid uid, sort
  set seed 340322	// random.org Timestamp: 2020-10-14 20:44:36 UTC
  areg re_4 treat treat2 , a(check) vce(bootstrap , r(1000) cluster(pid))
  
  est sto facility
  
// Non-PPIA providers
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
  lab var treat1 "PPIA Facility * PPIA provider"
  lab var treat2 "PPIA Facility Round 3"
  
  outwrite pooled interaction separate wave facility nonppia ///
    using "${git}/outputs/t-convenience.tex" ///
  , replace keep(treat treat1 treat2 *) format(%9.3f) stats(N r2) ///
    drop(i.wave#i.case i.sample i.sample#i.case i.case#i.pxh i.sample#i.pxh i.sample#i.case#i.pxh ppia_facility_?)  ///
    nobold nolab statform(%9.0f %9.3f) ///
    colnames("Pooled Model" "PPIA Interaction" "Separate Effects" "Wave Identification" "Facility Identification" "Non-PPIA Providers") ///
    add( ///
      ("Samples" "All" "All" "All" "All ex. 4" "All ex. 4" "All ex. 2b") ///
      ("Rounds" "All" "All" "All" "All" "All") ///
      ("Fixed Effects" "Provider" "Provider" "Provider" "Provider-Facility-Case + Wave" "Provider-Wave-Case" "Provider-Facility" ) ///
      ("Variance Model" "Facility Cluster" "Facility Cluster" "Facility Cluster" "Provider Bootstrap" "Provider Bootstrap" "Robust") ///
      ("Sample-Case Control" "Yes" "Yes" "Yes" "No" "No" "No") ///
    )
    
// End of dofile
