// Regression discontinuity analysis
use "${git}/constructed/full-data.dta" ///
  if case < 7 &  wave == 2 , clear

  // RD estimates ranges
  cap mat drop results
    foreach type in "h(16 15)" "h(80 80)" "bwselect(msetwo)" "bwselect(certwo)"  {
      cap mat drop row
      foreach order in 0 1 2 3 {
        qui xi: rdrobust re_4 ppsa_cutoff  ///
          , p(`order') c(81) `type' all covs(i.sample*i.case) vce(cluster fid)
        
        local N = `e(N_h_l)' + `e(N_h_r)'
        mat row = nullmat(row) , [`N'  \ `e(tau_cl)' \ `e(se_tau_cl)' \ `e(tau_bc)' \ `e(se_tau_rb)' ]
      }
      mat results = nullmat(results) \ row
    }
    cap mat drop results_STARS
    
    local row `""Conventional \beta" "Conventional SE" "Robust \tau" "Robust SE""'
    
    outwrite results ///
      using "${git}/outputs/t-discontinuity.tex"  ///
    , replace nobold nostars h(5 10 15) ///
      col("Mean" "Linear" "Quadratic" "Cubic") ///
      par(3 8 13 18 5 10 15 20) ///
      row("Experimental Bandwidth \\ Number of Observations"  `row' ///
          "Full Sample \\ Number of Observations" `row' ///
          "MSE-Optimal Bandwidths \\ Number of Observations" `row' ///
          "CER-Optimal Bandwidths \\ Number of Observations" `row')

// End of dofile
