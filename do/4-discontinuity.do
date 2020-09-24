// Regression discontinuity analysis
use "${git}/constructed/full-data.dta" ///
  if case < 7 &  wave == 2 , clear

  tab case, gen(case) // Need dummy variables for -rdrobust-
  
   
    gen cutoff = ppsa_cutoff < 81
      lab var cutoff "Round 3 Eligibility"

// RD Analysis Figure
 
  rdplot re_4 ppsa_cutoff if ppsa_rd == 1 ///
    , c(81) p(1) ci(95) ///
      graph_options(title("GeneXpert in Local Sample") ylab(\${pct}) xtit("RD Running Variable")) 
    
    graph save "${git}/outputs/f-discontinuity-1.gph" , replace
    
  rdplot re_4 ppsa_cutoff ///
    , c(81) p(1) ci(95) ///
      graph_options(title("GeneXpert in Global Sample") ylab(\${pct}) xtit("RD Running Variable")) 
    
    graph save "${git}/outputs/f-discontinuity-2.gph" , replace

  scatter ppia_facility_2 ppsa_cutoff ///
    , xline(81) ylab(0 "No" 1 "Yes") mc(black) ///
      title("PPIA Enrollment in Round 3 by Rank")
      
    graph save "${git}/outputs/f-discontinuity-3.gph" , replace

  forest reg ///
    (dr_1 dr_4 re_1 re_3 re_4) ///
    (med_any med_l_any_1 med_l_any_2 med_l_any_3 med_k_any_9) ///
  , t(cutoff) c(ppsa_cutoff i.sample##i.case) ///
    cl(fid) b bh graph(title("Linear RD Estimates for Outcomes",span))
    
    graph save "${git}/outputs/f-discontinuity-4.gph" , replace
  
  graph combine ///
    "${git}/outputs/f-discontinuity-3.gph" ///
    "${git}/outputs/f-discontinuity-2.gph" ///
    "${git}/outputs/f-discontinuity-4.gph" ///
    "${git}/outputs/f-discontinuity-1.gph" ///
    , altshrink
  
  graph export "${git}/outputs/f-discontinuity.eps" , replace

// RD Analysis Table
rdrobust re_4 ppsa_cutoff if ppsa_rd == 1, c(81) covs(case?)
rdrobust re_4 ppsa_cutoff , c(81) covs(case?) 
reg re_4 ppia_facility_2 ppsa_cutoff i.case##i.sample , cl(fid)
reg re_4 ppia_facility_2 ppsa_cutoff i.case if ppsa_rd == 1 , cl(fid)
