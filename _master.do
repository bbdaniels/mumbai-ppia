 
 
 /// Define globals-------------------------------------------
 
	global rawdata "/Users/RuchikaBhatia/Box/Ruchika Mumbai Hospital/sp"
	global directory "/Users/RuchikaBhatia/GitHub/mumbai-ppia"
	global rawdata_gx "/Users/RuchikaBhatia/Box/Ruchika Mumbai Hospital/xpert-lab/Genexpert/Genexpert_dta"
	
	global title justification(left) color(black) span pos(11)

	global graph_opts ///
  	title(, justification(left) color(black) span pos(11)) ///
  	graphregion(color(white) lc(white) lw(med)) bgcolor(white) ///
  	ylab(,angle(0) nogrid) ytit(,placement(left) justification(left))  ///
  	yscale(noline) legend(region(lc(none) fc(none)))
	
	global graph_opts2 ///
	graphregion(color(white) lc(white) lw(med)) bgcolor(white) ///
  	ylab(,angle(0) nogrid) ytit(,placement(left) justification(left)) ///
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
	
	net install rdrobust, from(https://sites.google.com/site/rdpackages/rdrobust/stata) replace
	
	
	// Load datafiles into Git location ----------------------------------------------------

  // Hashdata command to import data from remote repository
  qui run "${directory}/ado/iecodebook.ado"

  iecodebook export "${rawdata}/sp-wave-0.dta" ///
     using "${directory}/data/sp-wave-0.dta" ///
     , replace copy hash text reset 

  iecodebook export "${rawdata}/sp-wave-1.dta" ///
     using "${directory}/data/sp-wave-1.dta" ///
     , replace copy hash text reset 
	 
	  iecodebook export "${rawdata}/sp-wave-2.dta" ///
     using "${directory}/data/sp-wave-2.dta" ///
     , replace copy hash text reset 
	 
	
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
	
	
// Run do files  --------------------------------------------------------------------------

	run "$directory/code/construct.do"
	run "$directory/code/table1.do"
	run "$directory/code/table2.do"
	run "$directory/code/table3.do"
	run "$directory/code/table4.do"
	run "$directory/code/table5.do"
	run "$directory/code/table6.do"
	run "$directory/code/tableA1.do"
	run "$directory/code/tableA2.do"
	run "$directory/code/tableA3.do"
	run "$directory/code/tableA4.do"
	run "$directory/code/tableA5.do"
	run "$directory/code/tableA6.do"
	run "$directory/code/lab_tests.do"
	
//------------------------------------------------------------------------------
	
	
	
	
	
