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

// RD Analysis Figure
  
  // Full sample and experimental illustration
  use "${git}/constructed/full-data.dta" ///
    if case < 7 &  wave == 2 , clear

  gen cutoff = ppsa_cutoff > 81
  egen ftag = tag(fid)
  gen cutoff_whole = ceil(ppsa_cutoff) - 0.5
    bys cutoff_whole ppia_facility_2 ftag : gen n = _n if cutoff_whole != .
    gen ppia_facility_fake = ppia_facility_2 - .02*(n-1) if ppia_facility_2 == 1 & ftag == 1
    replace ppia_facility_fake = ppia_facility_2 + .02*(n-1) if ppia_facility_2 == 0 & ftag == 1
  tw ///
    (lpolyci re_4 ppsa_cutoff if cutoff == 0 , lp(solid) lc(black) lw(thick) alwidth(none) ) ///
    (lpolyci re_4 ppsa_cutoff if cutoff == 1 , lp(solid) lc(black) lw(thick) alwidth(none) ) ///
    (lfit re_4 ppsa_cutoff if cutoff == 0 , lp(dash) lc(black) lw(thin) alwidth(none) ) ///
    (lfit re_4 ppsa_cutoff if cutoff == 1 , lp(dash) lc(black) lw(thin) alwidth(none) ) ///
    (scatter ppia_facility_fake cutoff_whole if ftag, mc(black) ) ///
      (lfit ppia_facility_2 ppsa_cutoff if cutoff == 0 , lp(dash) lc(red) ) ///
      (lfit ppia_facility_2 ppsa_cutoff if cutoff == 1, lp(dash) lc(red) ) ///
    , xline(81 , lc(red)) xline(65 96 , lc(black)) ylab(0 "Not Enrolled" 1 "Enrolled")  ///
      title("A: Round 3 Enrollment and GeneXpert use by Rank" , justification(left) span pos(11)) ///
      xtit("RD Running Variable") ///
      legend(on ring(1) c(2) pos(6) order(8 "Enrollment" 2 "GeneXpert"))
      
    graph save "${git}/outputs/f-discontinuity-1.gph" , replace

  // Linearized estimates
  use "${git}/constructed/full-data.dta" ///
    if case < 7 &  wave == 2 & ppsa_cutoff > 65 , clear

  gen cutoff = ppsa_cutoff > 81
    lab var cutoff "Loss of Eligibility"
  gen a = ppsa_cutoff - 81  
  forest reg ///
    (dr_1 dr_4 re_1 re_3 re_4) ///
    (med_any med_l_any_1 med_l_any_2 med_l_any_3 med_k_any_9) ///
  , t(cutoff) c(a i.cutoff#c.a i.sample##i.case) ///
    cl(fid) b bh graph(title("B: Linear RD Estimates for Experimental Bandwidth",justification(left) span pos(11)))
    
    graph save "${git}/outputs/f-discontinuity-2.gph" , replace
    
  // RD functional forms
  use "${git}/constructed/full-data.dta" ///
    if case < 7 &  wave == 2 , clear
   
  rdplot re_4 ppsa_cutoff if ppsa_cutoff > 65 ///
  , c(81) p(1) ci(95) h(16 15) ///
    graph_options(title("C: Linear RD in Experimental Bandwidth" , justification(left) span pos(11)) ///
    ylab(\${pct}) xtit("RD Running Variable")) 
   
    graph save "${git}/outputs/f-discontinuity-3.gph" , replace
   
  rdplot re_4 ppsa_cutoff if ppsa_cutoff > 65 ///
  , c(81) p(2) ci(95) h(16 15) ///
    graph_options(title("D: Quadratic RD in Experimental Bandwidth" , justification(left) span pos(11)) ///
    ylab(\${pct}) xtit("RD Running Variable")) 

    graph save "${git}/outputs/f-discontinuity-4.gph" , replace
  
  // Final figure
  graph combine ///
    "${git}/outputs/f-discontinuity-1.gph" ///
    "${git}/outputs/f-discontinuity-2.gph" ///
    "${git}/outputs/f-discontinuity-3.gph" ///
    "${git}/outputs/f-discontinuity-4.gph" ///
    , altshrink
  
  graph export "${git}/outputs/f-discontinuity.eps" , replace
  
// End of dofile
