// Global
use "${git}/constructed/full-data.dta" ///
  if case < 7 , clear

  gen treat = pxh == 1 & wave > 0
    lab var treat "PPIA After Round 1"
      
  areg re_4 treat pxh ///
    i.wave i.sample##i.case ///
    , a(fid) cl(pid) 
    
    est sto global

// Difference-in-difference
use "${git}/constructed/full-data.dta" ///
  if case < 7 & wave < 2, clear

  gen treat = pxh == 1 & wave > 0
    lab var treat "PPIA After Round 1"
    
  areg re_4 treat pxh i.wave ///
    i.sample##i.case ///
    , a(fid) cl(pid)
    
    est sto did
    
// Difference-in-difference - restricted sample
use "${git}/constructed/full-data.dta" ///
  if sample == 1 & case < 7 & wave < 2, clear

  gen treat = pxh == 1 & wave > 0
    lab var treat "PPIA After Round 1"
    
  areg re_4 treat pxh i.wave ///
    i.case ///
    , a(fid) cl(pid)
    
    est sto did1
    
// Global - restricted sample
use "${git}/constructed/full-data.dta" ///
  if sample == 1 & case < 7 , clear

  gen treat = pxh == 1 & wave > 0
    lab var treat "PPIA After Round 1"
    
  areg re_4 treat pxh i.wave ///
    i.case ///
    , a(fid) cl(pid)
    
    est sto did2

// Global restricted
use "${git}/constructed/full-data.dta" ///
  if case < 7 , clear
  
  bys fid : egen max = max(pxh)
  bys fid : egen min = min(pxh)
    keep if max == 1 & min == 0

  gen treat = pxh == 1 & wave > 0
    lab var treat "PPIA After Round 1"
      
  areg re_4 treat pxh ///
    i.wave i.sample##i.case ///
    , a(fid) cl(pid) 
    
    est sto global2
    
// Global multiple effects
use "${git}/constructed/full-data.dta" ///
  if case < 7 , clear

  gen treat = pxh == 1 & wave > 0
    lab var treat "PPIA After Round 1"
  gen treat2 = pxh == 1 & wave == 2
    lab var treat "PPIA In Round 2"
      
  areg re_4 treat treat2 pxh ///
    i.wave i.sample##i.case ///
    , a(fid) cl(pid) 
    
    est sto global3
  
// Print table
use "${git}/constructed/full-data.dta" , clear
  gen treat = ""
  gen treat2 = ""
  lab var treat "PPIA After Round 1"
  lab var treat2 "PPIA In Round 2"
  
  outwrite global did did1 did2 global2 global3 ///
    using "${git}/outputs/t-learning-global.tex" ///
  , replace drop(i.wave#i.case i.sample i.sample#i.case) format(%9.3f) stats(N r2) ///
    nobold nolab statform(%9.0f %9.4f) ///
    colnames("Pooled" "Diff-Diff" "Sample 1a (Diff-Diff)" "Sample 1a (All)" "Restricted" "Separate") ///
    add( ///
      ("Samples" "All" "1a 2a 3" "1a" "1a" "All ex. 4" "All") ///
      ("Rounds" "All" "1 2" "1 2" "All" "All" "All") ///
      ("Facility FE" "Yes" "Yes" "Yes" "Yes" "Yes" "Yes") ///
      ("Clustering" "Provider" "Provider" "Provider" "Provider" "Provider" "Provider") ///
      ("Sample-Case Control" "Yes" "Yes" "No" "No" "Yes" "Yes") ///
    )

// End of dofile
