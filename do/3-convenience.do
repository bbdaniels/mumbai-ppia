use "${git}/constructed/full-data.dta" ///
  if case < 7 , clear

gen ppia = 0
  lab var ppia "PPIA Facility"
forvalues i = 0/2 {
  replace ppia = 1 if wave == `i' & ppia_facility_`i' == 1
}

gen treat = ppia == 1 & wave > 0
  lab var treat "PPIA After Round 1"
      
// Global
areg re_4 treat ppia ///
  i.wave i.sample##i.case ///
  , a(pid) cl(fid)
  
  est sto g1

  forest areg ///
    (dr_1 dr_4 re_1 re_3 re_4) ///
    (med_any med_l_any_1 med_l_any_2 med_l_any_3 med_k_any_9) ///
  , t(treat) c(ppia i.wave i.sample##i.case) ///
    a(pid) cl(fid) b bh
    
    graph export "${git}/outputs/f-convenience-global.eps" , replace

  // Alt versions
    // No sample-case interaction
    areg re_4 treat ppia i.wave ///
      i.case ///
      , a(pid) cl(fid)
      
      est sto g2

    // Case-wave interaction
    areg re_4 treat ppia i.wave ///
      i.wave##i.case i.sample##i.case ///
      , a(pid) cl(fid)
      
      est sto g3

    // Facility clustering
    areg re_4 treat ppia i.wave ///
      i.sample##i.case ///
      , a(pid) cl(pid)
      
      est sto g4

    // No FE
    reg re_4 treat ppia i.wave ///
      i.sample##i.case ///
      , cl(fid)
      
      est sto g5
      
  outwrite g1 g2 g3 g4 g5 ///
    using "${git}/outputs/t-convenience-global.xlsx" ///
  , replace drop(i.wave#i.case i.sample i.sample#i.case) format(%9.3f) stats(N r2)
  
// Diff-diff
areg re_4 treat ppia i.wave ///
  i.sample##i.case ///
  if wave < 2  ///
  , a(pid) cl(fid)
  
  est sto g1

  forest areg ///
    (dr_1 dr_4 re_1 re_3 re_4) ///
    (med_any med_l_any_1 med_l_any_2 med_l_any_3 med_k_any_9) ///
  if wave < 2  ///
  , t(treat) c(ppia wave i.wave i.sample##i.case) ///
    a(pid) cl(fid)
    
    graph export "${git}/outputs/f-convenience-r12.eps" , replace

  // Alt versions
    // No sample-case interaction
    areg re_4 treat ppia i.wave ///
      i.case ///
      if wave < 2  ///
      , a(pid) cl(fid)
      
      est sto g2

    // Case-wave interaction
    areg re_4 treat ppia i.wave ///
      i.wave##i.case i.sample##i.case ///
      if wave < 2  ///
      , a(pid) cl(fid)
      
      est sto g3

    // Facility clustering
    areg re_4 treat ppia i.wave ///
      i.sample##i.case ///
      if wave < 2  ///
      , a(pid) cl(pid)
      
      est sto g4

    // No FE
    reg re_4 treat ppia i.wave ///
      i.sample##i.case ///
      if wave < 2  ///
      , cl(fid)
      
      est sto g5
      
       outwrite g1 g2 g3 g4 g5 ///
         using "${git}/outputs/t-convenience-r12.xlsx" ///
       , replace drop(i.wave#i.case i.sample i.sample#i.case) format(%9.3f) stats(N r2)
       
// Global, separate waves
replace treat = 0 if wave == 2
  lab var treat "PPIA In Round 1"
gen treat2 = ppia == 1 & wave > 1
  lab var treat2 "PPIA In Round 2"
  
areg re_4 treat treat2 ppia ///
  i.wave i.sample##i.case ///
  , a(pid) cl(fid)
  
  est sto g1

  // Alt versions
    // No sample-case interaction
    areg re_4 treat treat2 ppia i.wave ///
      i.case ///
      , a(pid) cl(fid)
      
      est sto g2

    // Case-wave interaction
    areg re_4 treat treat2 ppia i.wave ///
      i.wave##i.case i.sample##i.case ///
      , a(pid) cl(fid)
      
      est sto g3

    // Facility clustering
    areg re_4 treat treat2 ppia i.wave ///
      i.sample##i.case ///
      , a(pid) cl(pid)
      
      est sto g4

    // No FE
    reg re_4 treat treat2 ppia i.wave ///
      i.sample##i.case ///
      , cl(cp_7)
      
      est sto g5
      
  outwrite g1 g2 g3 g4 g5 ///
    using "${git}/outputs/t-convenience-global2.xlsx" ///
  , replace drop(i.wave#i.case i.sample i.sample#i.case) format(%9.3f) stats(N r2)
 
