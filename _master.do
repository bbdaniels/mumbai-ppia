	
	global directory "/Users/RuchikaBhatia/GitHub/mumbai-ppia"
	
	global title justification(left) color(black) span pos(11)

	global graph_opts ///
  	title(, justification(left) color(black) span pos(11)) ///
  	graphregion(color(white) lc(white) lw(med)) bgcolor(white) ///
  	ylab(,angle(0) nogrid) ytit(,placement(left) justification(left))  ///
  	yscale(noline) legend(region(lc(none) fc(none)))
	
	global graph_opts2 ///
	graphregion(color(white) lc(white) lw(med)) bgcolor(white) ///
  	ylab(,angle(0) nogrid) ytit(,placement(left) justification(left))  ///
  	yscale(noline) legend(region(lc(none) fc(none)))
	
	global pct `" 0 "0%" .25 "25%" .5 "50%" .75 "75%" 1 "100%" "'
	
	// Install packages ------------------------------------------------------------------------------
sysdir set PLUS "${directory}/ado/"

  net install "http://www.stata.com/users/kcrow/tab2xl", replace
  net install "http://www.stata.com/users/vwiggins/grc1leg", replace
  ssc install tabcount , replace
  ssc install ietoolkit , replace
  ssc install betterbar , replace
  ssc install randtreat , replace
  ssc install xsvmat, replace 
  ssc install iefieldkit, replace

  net from "https://github.com/bbdaniels/stata/raw/master/"
    net install forest , replace
	
	// Programs ------------------------------------------------------------------------------
	
	// Program 1- Create a matrix with rownames
	capture program drop valuelabels
	program define valuelabels, rclass
	
	syntax varlist, name(str) columns(int) 
	local tRows = 0
    foreach i in `varlist' {
      local thisLabel: variable label `i'
      local rowNames = `" `rowNames' "`thisLabel'"  "'
      local tRows=`tRows'+1
    }
	mat t = J(`tRows', `columns',0)
    matrix rownames t = `rowNames'
	return mat `name' = t
	end
	
	// Program 2: Graph for means of outcomes and GeneExpert for qutub sample types

	capture program drop graphmeans
	program define graphmeans
	
	syntax , sample(int) 
	use "$directory/constructed/analysis-panel.dta", clear
	drop if wave == 2
	
	betterbar ///
	checklist_essential_pct correct dr_4 dr_1 re_1 ///
	re_3 re_4 re_5 med_l_any_1 med_k_any_6 med_k_any_9 med_l_any_2  ///
	if qutub_sample == `sample' , ///
	over(wave) xlab($pct) xscale(noline) ///
	barcolor(eltblue eltgreen) $graph_opts
	
	graph export "$directory/outputs/means_sample`sample'.eps", replace
	
	betterbar ///
	re_4 ///
	if qutub_sample == `sample' , ///
	over(wave) by(case) xlab($pct) xscale(noline) ///
	barcolor(eltblue eltgreen) $graph_opts
	
	graph export "$directory/outputs/GeneExpert_sample`sample'.eps", replace
	
	end	 
	
		
	// Cleanup: Wave 0 --------------------------------------------------------------------------
	
	use "${directory}/data/sp-wave-0.dta" , clear

	tostring form dr_5b_no re_1_a med_h_1 med_j_2 cp_13 med_f_2 med_f_3 re_*_c re_2_c re_11_a re_12_*_* cp_12 cp_12_3 re_4_a, force replace

	rename med_any_ med_any
	
	save "${directory}/constructed/sp-wave-0.dta" , replace

// Cleanup: Wave 1 --------------------------------------------------------------------------
	use "${directory}/data/sp-wave-1.dta" , clear

	tostring form re_1_a dr_3a dr_5a_no dr_5b_no med_h_1 med_j_2 re_12_2 re_12_3 re_12_4 re_12_*_* sp3_h_24_2 , force replace
	replace re_1 = 1 if re_1 > 1

	rename g* g_*
	
	replace dr_4 = 0 if dr_4 == 3

	save "${directory}/constructed/sp-wave-1.dta" , replace
	
	
// Cleanup: Wave 2

	use "$directory/data/sp-wave-2.dta" , clear
	
	tostring form re_1_a dr_3a dr_5a_no dr_5b_no med_h_1 med_j_2 re_12_2 re_12_3 re_12_4 re_12_*_* sp3_h_24_2 , force replace
	replace re_1 = 1 if re_1 > 1

	rename g* g_*
	
	save "${directory}/constructed/sp-wave-2.dta" , replace


// Append --------------------------------------------------------------------------------------
	use "${directory}/constructed/sp-wave-0.dta"

	qui append using ///
	"${directory}/constructed/sp-wave-1.dta" ///
	"${directory}/constructed/sp-wave-2.dta" ///
	, gen(wave) force
	label def wave 0 "Round 1" 1 "Round 2" 2 "Round 3"
	label val wave wave

	drop *given

// Cleaning --------------------------------------------------------------------------

	drop sample
	drop if qutub_sample > 6 

	lab var correct "Correct"
	lab var dr_4 "Referral"

	label define case 7 "SP7", add
	label values case case
	
	drop if case == 7
	
//Save  --------------------------------------------------------------------------

save "${directory}/constructed/analysis-panel.dta" , replace


	
// Run do files  --------------------------------------------------------------------------

	run "$directory/code/construct.do"
	run "$directory/code/Graphs.do"
	run "$directory/code/table1.do"
	run "$directory/code/table2.do"
	run "$directory/code/table3.do"
	
	
	
	
	
