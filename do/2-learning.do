// Global
use "${git}/constructed/full-data.dta" ///
  if case < 7 , clear

// Define treatment effect for regressions
  gen treat = pxh == 1 & wave > 0
    lab var treat "PPIA After Round 1"
      
areg re_4 treat pxh ///
  i.wave i.sample##i.case ///
  , a(fid) cl(pid) 
  
  est sto g1

  forest areg ///
    (dr_1 dr_4 re_1 re_3 re_4) ///
    (med_any med_l_any_1 med_l_any_2 med_l_any_3 med_k_any_9) ///
  , t(treat) c(pxh i.wave i.sample##i.case) ///
    a(fid) cl(pid) b bh
    
    graph export "${git}/outputs/f-learning-global.eps" , replace

  // Alt versions
    // No sample-case interaction
    areg re_4 treat pxh i.wave ///
      i.case ///
      , a(fid) cl(pid)
      
      est sto g2

    // Case-wave interaction
    areg re_4 treat pxh i.wave ///
      i.wave##i.case i.sample##i.case ///
      , a(fid) cl(pid)
      
      est sto g3

    // Facility clustering
    areg re_4 treat pxh i.wave ///
      i.sample##i.case ///
      , a(fid) cl(fid)
      
      est sto g4

    // No FE
    reg re_4 treat pxh i.wave ///
      i.sample##i.case ///
      , cl(pid)
      
      est sto g5
      
  outwrite g1 g2 g3 g4 g5 ///
    using "${git}/outputs/t-learning-global.xlsx" ///
  , replace drop(i.wave#i.case i.sample i.sample#i.case) format(%9.3f) stats(N r2)
  
// Diff-diff
use "${git}/constructed/full-data.dta" ///
  if case < 7 , clear

  // Define treatment effect for regressions
  gen treat = pxh == 1 & wave > 0
    lab var treat "PPIA After Round 1"
    
areg re_4 treat pxh i.wave ///
  i.sample##i.case ///
  if wave < 2  ///
  , a(fid) cl(pid)
  
  est sto g1

  forest areg ///
    (dr_1 dr_4 re_1 re_3 re_4) ///
    (med_any med_l_any_1 med_l_any_2 med_l_any_3 med_k_any_9) ///
  if wave < 2  ///
  , t(treat) c(pxh wave i.wave i.sample##i.case) ///
    a(fid) cl(pid)
    
    graph export "${git}/outputs/f-learning-r12.eps" , replace

  // Alt versions
    // No sample-case interaction
    areg re_4 treat pxh i.wave ///
      i.case ///
      if wave < 2  ///
      , a(fid) cl(pid)
      
      est sto g2

    // Case-wave interaction
    areg re_4 treat pxh i.wave ///
      i.wave##i.case i.sample##i.case ///
      if wave < 2  ///
      , a(fid) cl(pid)
      
      est sto g3

    // Facility clustering
    areg re_4 treat pxh i.wave ///
      i.sample##i.case ///
      if wave < 2  ///
      , a(fid) cl(fid)
      
      est sto g4

    // No FE
    reg re_4 treat pxh i.wave ///
      i.sample##i.case ///
      if wave < 2  ///
      , cl(pid)
      
      est sto g5
      
       outwrite g1 g2 g3 g4 g5 ///
         using "${git}/outputs/t-learning-r12.xlsx" ///
       , replace drop(i.wave#i.case i.sample i.sample#i.case) format(%9.3f) stats(N r2)
       
// Global, separate waves
use "${git}/constructed/full-data.dta" ///
  if case < 7 , clear
  
gen treat1 = (pxh == 1 & wave == 1)
  lab var treat1 "PPIA In Round 2"
gen treat2 = (pxh == 1 & wave == 2)
  lab var treat2 "PPIA In Round 3"
  
areg re_4 treat1 treat2 pxh ///
  i.wave i.sample##i.case ///
  , a(fid) cl(pid)
  
  est sto g1

  // Alt versions
    // No sample-case interaction
    areg re_4 treat1 treat2 pxh i.wave ///
      i.case ///
      , a(fid) cl(pid)
      
      est sto g2

    // Case-wave interaction
    areg re_4 treat1 treat2 pxh i.wave ///
      i.wave##i.case i.sample##i.case ///
      , a(fid) cl(pid)
      
      est sto g3

    // Facility clustering
    areg re_4 treat1 treat2 pxh i.wave ///
      i.sample##i.case ///
      , a(fid) cl(fid)
      
      est sto g4

    // No FE
    reg re_4 treat1 treat2 pxh i.wave ///
      i.sample##i.case ///
      , cl(pid)
      
      est sto g5
      
  outwrite g1 g2 g3 g4 g5 ///
    using "${git}/outputs/t-learning-global2.xlsx" ///
  , replace drop(i.wave#i.case i.sample i.sample#i.case) format(%9.3f) stats(N r2)
  
