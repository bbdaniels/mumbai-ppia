// Regression discontinuity analysis
use "${git}/constructed/full-data.dta" ///
  if case < 7 &  wave == 2 , clear

tab case, gen(case)

rdplot re_4 ppsa_cutoff if ppsa_rd == 1, c(81) p(1) ci(95) 
rdplot re_4 ppsa_cutoff , c(81) p(1) ci(95) 

scatter ppia_facility_2 ppsa_cutoff , xline(81) 


rdrobust re_4 ppsa_cutoff if ppsa_rd == 1, c(81) covs(case?)
rdrobust re_4 ppsa_cutoff , c(81) covs(case?) 
