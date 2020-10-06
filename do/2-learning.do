// Global model
use "${git}/constructed/full-data.dta" ///
  if case < 7 , clear

  gen treat = pxh == 1 & wave > 0
    lab var treat "PPIA After Round 1"
      
  areg re_4 treat pxh ///
    i.wave i.sample##i.case##i.pxh ///
    , a(fid) cl(pid) 
    
    est sto global
    
// Sample 1a
use "${git}/constructed/full-data.dta" ///
  if sample == 1 & case < 7 , clear

  gen treat = pxh == 1 & wave > 0
    lab var treat "PPIA After Round 1"
    
  areg re_4 treat pxh i.wave ///
    i.case##i.pxh ///
    , a(fid) cl(pid)
    
    est sto sample1a

// Difference-in-difference
use "${git}/constructed/full-data.dta" ///
  if case < 7 & wave < 2, clear

  gen treat = pxh == 1 & wave > 0
    lab var treat "PPIA After Round 1"
    
  areg re_4 treat pxh i.wave ///
    i.sample##i.case##i.pxh ///
    , a(fid) cl(pid)
    
    est sto did
    
// Sample 1a Did
use "${git}/constructed/full-data.dta" ///
  if sample == 1 & case < 7 & wave < 2, clear

  gen treat = pxh == 1 & wave > 0
    lab var treat "PPIA After Round 1"
    
  areg re_4 treat pxh i.wave ///
    i.case##i.pxh ///
    , a(fid) cl(pid)
    
    est sto did1a

// Restricted to matched facilities
use "${git}/constructed/full-data.dta" ///
  if case < 7 , clear
  
  bys fid : egen max = max(pxh)
  bys fid : egen min = min(pxh)
    keep if max == 1 & min == 0

  gen treat = pxh == 1 & wave > 0
    lab var treat "PPIA After Round 1"
      
  areg re_4 treat pxh ///
    i.wave i.sample##i.case##i.pxh ///
    , a(fid) cl(pid) 
    
    est sto restricted
    
// Separate round effects
use "${git}/constructed/full-data.dta" ///
  if case < 7 , clear

  gen treat = pxh == 1 & wave > 0
    lab var treat "PPIA After Round 1"
  gen treat2 = pxh == 1 & wave == 2
    lab var treat "PPIA In Round 2"
      
  areg re_4 treat treat2 pxh ///
    i.wave i.sample##i.case##i.pxh ///
    , a(fid) cl(pid) 
    
    est sto separate
  
// Print table
use "${git}/constructed/full-data.dta" , clear
  gen treat = ""
  gen treat2 = ""
  lab var treat "PPIA After Round 1"
  lab var treat2 "PPIA In Round 2"
  
  outwrite global sample1a did did1a restricted separate ///
    using "${git}/outputs/t-learning.tex" ///
  , replace keep(treat treat2 *) format(%9.3f) stats(N r2) ///
    drop(i.wave#i.case i.sample i.sample#i.case i.case#i.pxh i.sample#i.pxh i.sample#i.case#i.pxh)  ///
    nobold nolab statform(%9.0f %9.3f) ///
    colnames("Pooled Model" "Sample 1a Pooled" "Diff-Diff Model" "Sample 1a Diff-Diff"  "Restricted Sample" "Separate Effects") ///
    add( ///
      ("Samples" "All" "1a"  "1a 2a 3" "1a" "All ex. 4" "All") ///
      ("Rounds" "All" "All" "1 2" "1 2" "All" "All") ///
      ("Facility FE" "Yes" "Yes" "Yes" "Yes" "Yes" "Yes") ///
      ("Clustering" "Provider" "Provider" "Provider" "Provider" "Provider" "Provider") ///
      ("Sample-Case Control" "Yes" "No" "Yes" "No" "Yes" "Yes") ///
    )

// End of dofile
