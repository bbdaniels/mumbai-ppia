// Global
use "${git}/constructed/full-data.dta" ///
  if case < 7 , clear

gen ppia = 0
  lab var ppia "PPIA Facility"
forvalues i = 0/2 {
  replace ppia = 1 if wave == `i' & ppia_facility_`i' == 1
}
      
areg re_4 ppia ///
  i.wave i.sample##i.case ///
  , a(pid) cl(fid)
  
  est sto g1

  // Alt versions
    // No sample-case interaction
    areg re_4 ppia i.wave ///
      i.case ///
      , a(pid) cl(fid)
      
      est sto g2

    // Case-wave interaction
    areg re_4 ppia i.wave ///
      i.wave##i.case i.sample##i.case ///
      , a(pid) cl(fid)
      
      est sto g3

    // Facility clustering
    areg re_4 ppia i.wave ///
      i.sample##i.case ///
      , a(pid) cl(pid)
      
      est sto g4

    // No FE
    reg re_4 ppia i.wave ///
      i.sample##i.case ///
      , cl(fid)
      
      est sto g5
      
  outwrite g1 g2 g3 g4 g5 ///
    using "${git}/outputs/t-convenience-global.xlsx" ///
  , replace drop(i.wave#i.case i.sample i.sample#i.case) format(%9.3f) stats(N r2)
  
// Diff-diff
use "${git}/constructed/full-data.dta" ///
  if case < 7 , clear
  
gen treat_base = ppia_facility_0 == 0 & ppia_facility_1 == 1 
  lab var treat_base "PPIA Joiner (Control)"
gen treat = ppia_facility_0 == 0 & ppia_facility_1 == 1 & wave == 1
  lab var treat "PPIA Joiner (Joined)"

areg re_4 treat treat_base i.wave ///
  i.sample##i.case ///
  if wave < 2  ///
  , a(pid) cl(fid)
  
  est sto g1

  forest areg ///
    (dr_1 dr_4 re_1 re_3 re_4) ///
    (med_any med_l_any_1 med_l_any_2 med_l_any_3 med_k_any_9) ///
  if wave < 2  ///
  , t(treat) c(treat_base wave i.wave i.sample##i.case) ///
    a(pid) cl(fid)
    
    graph export "${git}/outputs/f-convenience-r12.eps" , replace

  // Alt versions
    // No sample-case interaction
    areg re_4 treat treat_base i.wave ///
      i.case ///
      if wave < 2  ///
      , a(pid) cl(fid)
      
      est sto g2

    // Case-wave interaction
    areg re_4 treat treat_base i.wave ///
      i.wave##i.case i.sample##i.case ///
      if wave < 2  ///
      , a(pid) cl(fid)
      
      est sto g3

    // Facility clustering
    areg re_4 treat treat_base i.wave ///
      i.sample##i.case ///
      if wave < 2  ///
      , a(pid) cl(pid)
      
      est sto g4

    // No FE
    reg re_4 treat treat_base i.wave ///
      i.sample##i.case ///
      if wave < 2  ///
      , cl(fid)
      
      est sto g5
      
       outwrite g1 g2 g3 g4 g5 ///
         using "${git}/outputs/t-convenience-r12.xlsx" ///
       , replace drop(i.wave#i.case i.sample i.sample#i.case) format(%9.3f) stats(N r2)
       
// Global, separate waves
use "${git}/constructed/full-data.dta" ///
  if case < 7 , clear
  
gen treat1 = (wave == 1 & ppia_facility_1 == 1)
  lab var treat1 "PPIA In Round 2"
gen treat2 = (wave == 2 & ppia_facility_2 == 1)
  lab var treat2 "PPIA In Round 3"
  
areg re_4 treat1 treat2 ppia_facility_? ///
  i.wave i.sample##i.case ///
  , a(pid) cl(fid)
  
  est sto g1

  // Alt versions
    // No sample-case interaction
    areg re_4 treat1 treat2 ppia_facility_? i.wave ///
      i.case ///
      , a(pid) cl(fid)
      
      est sto g2

    // Case-wave interaction
    areg re_4 treat1 treat2 ppia_facility_? i.wave ///
      i.wave##i.case i.sample##i.case ///
      , a(pid) cl(fid)
      
      est sto g3

    // Facility clustering
    areg re_4 treat1 treat2 ppia_facility_? i.wave ///
      i.sample##i.case ///
      , a(pid) cl(pid)
      
      est sto g4

    // No FE
    reg re_4 treat1 treat2 ppia_facility_? i.wave ///
      i.sample##i.case ///
      , cl(cp_7)
      
      est sto g5
      
  outwrite g1 g2 g3 g4 g5 ///
    using "${git}/outputs/t-convenience-global2.xlsx" ///
  , replace drop(i.wave#i.case i.sample i.sample#i.case) format(%9.3f) stats(N r2)
 
