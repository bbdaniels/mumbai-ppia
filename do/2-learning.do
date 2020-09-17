use "${git}/constructed/full-data.dta" ///
  if case < 7 , clear

// Define treatment effect for regressions
  gen treat = pxh == 1 & wave > 0
    lab var treat "PPIA After Round 1"
      
// Global
areg re_4 treat pxh ///
  i.wave i.sample##i.case ///
  , a(cp_4) cl(cp_7)
  
  est sto g1

  forest areg ///
    (dr_1 dr_4 re_1 re_3 re_4) ///
    (med_any med_l_any_1 med_l_any_2 med_l_any_3 med_k_any_9) ///
  , t(treat) c(pxh i.wave i.sample##i.case) ///
    a(cp_4) cl(cp_7) b bh
    
    graph export "${git}/outputs/t-learning-global.eps" , replace

  // Alt versions
    // No sample-case interaction
    areg re_4 treat pxh i.wave ///
      i.case ///
      , a(cp_4) cl(cp_7)
      
      est sto g2

    // Case-wave interaction
    areg re_4 treat pxh i.wave ///
      i.wave##i.case i.sample##i.case ///
      , a(cp_4) cl(cp_7)
      
      est sto g3

    // Facility clustering
    areg re_4 treat pxh i.wave ///
      i.sample##i.case ///
      , a(cp_4) cl(cp_4)
      
      est sto g4

    // No FE
    reg re_4 treat pxh i.wave ///
      i.sample##i.case ///
      , cl(cp_7)
      
      est sto g5
      
  outwrite g1 g2 g3 g4 g5 ///
    using "${git}/outputs/f-learning-global.xlsx" ///
  , replace drop(i.wave#i.case i.sample i.sample#i.case) format(%9.3f)
  
// Diff-diff
areg re_4 treat pxh i.wave ///
  i.sample##i.case ///
  if wave < 2  ///
  , a(cp_4) cl(cp_7)
  
  est sto g1

  forest areg ///
    (dr_1 dr_4 re_1 re_3 re_4) ///
    (med_any med_l_any_1 med_l_any_2 med_l_any_3 med_k_any_9) ///
  if wave < 2  ///
  , t(treat) c(pxh wave i.wave i.sample##i.case) ///
    a(cp_4) cl(cp_7)
    
    graph export "${git}/outputs/f-learning-r12.eps" , replace

  // Alt versions
    // No sample-case interaction
    areg re_4 treat pxh i.wave ///
      i.case ///
      if wave < 2  ///
      , a(cp_4) cl(cp_7)
      
      est sto g2

    // Case-wave interaction
    areg re_4 treat pxh i.wave ///
      i.wave##i.case i.sample##i.case ///
      if wave < 2  ///
      , a(cp_4) cl(cp_7)
      
      est sto g3

    // Facility clustering
    areg re_4 treat pxh i.wave ///
      i.sample##i.case ///
      if wave < 2  ///
      , a(cp_4) cl(cp_4)
      
      est sto g4

    // No FE
    reg re_4 treat pxh i.wave ///
      i.sample##i.case ///
      if wave < 2  ///
      , cl(cp_7)
      
      est sto g5
      
       outwrite g1 g2 g3 g4 g5 ///
         using "${git}/outputs/t-learning-r12.xlsx" ///
       , replace drop(i.wave#i.case i.sample i.sample#i.case) format(%9.3f)
       
// Global, separate waves
replace treat = 0 if wave == 2
  lab var treat "PPIA In Round 1"
gen treat2 = pxh == 1 & wave > 1
  lab var treat2 "PPIA In Round 2"
  
areg re_4 treat treat2 pxh ///
  i.wave i.sample##i.case ///
  , a(cp_4) cl(cp_7)
  
  est sto g1

  // Alt versions
    // No sample-case interaction
    areg re_4 treat treat2 pxh i.wave ///
      i.case ///
      , a(cp_4) cl(cp_7)
      
      est sto g2

    // Case-wave interaction
    areg re_4 treat treat2 pxh i.wave ///
      i.wave##i.case i.sample##i.case ///
      , a(cp_4) cl(cp_7)
      
      est sto g3

    // Facility clustering
    areg re_4 treat treat2 pxh i.wave ///
      i.sample##i.case ///
      , a(cp_4) cl(cp_4)
      
      est sto g4

    // No FE
    reg re_4 treat treat2 pxh i.wave ///
      i.sample##i.case ///
      , cl(cp_7)
      
      est sto g5
      
  outwrite g1 g2 g3 g4 g5 ///
    using "${git}/outputs/f-learning-global2.xlsx" ///
  , replace drop(i.wave#i.case i.sample i.sample#i.case) format(%9.3f)
  
