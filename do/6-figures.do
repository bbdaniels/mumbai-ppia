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
use "${git}/constructed/full-data.dta" ///
  if case < 7 &  wave == 2 , clear
   
  gen cutoff = ppsa_cutoff > 81
    lab var cutoff "Round 3 Eligibility Loss"
    
  xi: rdbwselect re_4 ppsa_cutoff , c(81) bwselect(msetwo)  covs(i.sample*i.case)
   
  rdplot re_4 ppsa_cutoff ///
    , c(81) p(0) ci(95) h(`e(h_msetwo_l)' `e(h_msetwo_r)') ///
      graph_options(title("GeneXpert Mean in Selected Bandwidth") ///
        ylab(\${pct}) xtit("RD Running Variable")) 
    
    graph save "${git}/outputs/f-discontinuity-1.gph" , replace
    
  xi: rdbwselect re_4 ppsa_cutoff , c(81) bwselect(msetwo)  covs(i.sample*i.case)
  
  rdplot re_4 ppsa_cutoff ///
    , c(81) p(1) ci(95) h(`e(h_msetwo_l)' `e(h_msetwo_r)') ///
      graph_options(title("GeneXpert Mean and Slope in Selected Bandwidth") ///
        ylab(\${pct}) xtit("RD Running Variable")) 
    
    graph save "${git}/outputs/f-discontinuity-2.gph" , replace

  egen ftag = tag(fid)
  xi: rdbwselect re_4 ppsa_cutoff , c(81) bwselect(msetwo)  covs(i.sample*i.case)
  tw ///
    (scatter ppia_facility_2 ppsa_cutoff if ftag, mc(black) jitter(5)) ///
    (lpolyci re_4 ppsa_cutoff if cutoff == 0 , lp(solid) lc(black) lw(thick) alwidth(none) ) ///
    (lpolyci re_4 ppsa_cutoff if cutoff == 1 , lp(solid) lc(black) lw(thick) alwidth(none) ) ///
    (lfit re_4 ppsa_cutoff if cutoff == 0 , lp(dash) lc(black) lw(thin) alwidth(none) ) ///
    (lfit re_4 ppsa_cutoff if cutoff == 1 , lp(dash) lc(black) lw(thin) alwidth(none) ) ///
    (lfit ppia_facility_2 ppsa_cutoff if cutoff == 0 , lp(dash) lc(red) ) ///
    (lfit ppia_facility_2 ppsa_cutoff if cutoff == 1 , lp(dash) lc(red) ) ///
    , xline(81 , lc(red)) xline(`=81-`e(h_msetwo_l)'' `=81+`e(h_msetwo_r)'' , lc(black)) ylab(0 "No" 1 "Yes")  ///
      title("Round 3 Enrollment and GeneXpert use by Rank") xtit("RD Running Variable, Cutoff, and Bandwidth") ///
      legend(on ring(0) c(1) pos(7) order(8 "Enrollment" 3 "GeneXpert"))
      
    graph save "${git}/outputs/f-discontinuity-3.gph" , replace

  gen a = ppsa_cutoff - 81  
  forest reg ///
    (dr_1 dr_4 re_1 re_3 re_4) ///
    (med_any med_l_any_1 med_l_any_2 med_l_any_3 med_k_any_9) ///
  , t(cutoff) c(a i.cutoff#c.a i.sample##i.case) ///
    cl(fid) b bh graph(title("Full-Sample Linear RD Estimates for Outcomes",span))
    
    graph save "${git}/outputs/f-discontinuity-4.gph" , replace
  
  graph combine ///
    "${git}/outputs/f-discontinuity-3.gph" ///
    "${git}/outputs/f-discontinuity-2.gph" ///
    "${git}/outputs/f-discontinuity-4.gph" ///
    "${git}/outputs/f-discontinuity-1.gph" ///
    , altshrink
  
  graph export "${git}/outputs/f-discontinuity.eps" , replace
  
// End of dofile
