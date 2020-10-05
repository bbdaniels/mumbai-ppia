// Regression discontinuity analysis
use "${git}/constructed/full-data.dta" ///
  if case < 7 &  wave == 2 , clear
  
  gen cutoff = ppsa_cutoff > 81
    lab var cutoff "Round 3 Eligibility Loss"
    
    gen Robust = ppsa_cutoff > 81

  // RD estimates ranges
  cap mat drop results
    foreach type in "bwselect(msetwo)" "h(10 10)" "h(15 15)" "h(45 45)" "h(80 80)" {
      cap mat drop row
      foreach order in 0 1 2 3 {
        qui xi: rdrobust re_4 ppsa_cutoff  ///
          , p(`order') c(81) `type' all covs(i.sample*i.case) 
        
        local N = `e(N_h_l)' + `e(N_h_r)'
        mat row = nullmat(row) , [`N'  \ `e(tau_cl)' \ `e(se_tau_cl)' \ `e(tau_bc)' \ `e(se_tau_rb)' ]
      }
      mat results = nullmat(results) \ row
    }
    cap mat drop results_STARS
    
    local row `""Conventional \beta" "Conventional SE" "Robust \tau" "Robust SE""'
    
    outwrite results ///
      using "${git}/outputs/t-discontinuity-types.tex"  ///
    , replace nobold nostars h(5 10 15 20) ///
      col("Mean" "Linear" "Quadratic" "Cubic") ///
      par(3 8 13 18 23 5 10 15 20 25) ///
      row("Selected Bandwidth N" `row' "Bandwidth 10 N"  ///
       `row' "Bandwidth 15 N"  `row' "Bandwidth 45 N " `row' "Full Sample N" `row' )

// End of dofile
