
	// Part 1: Append all datasets --------------------------------------------------------------------------------
	
	use "$rawdata_gx/sheet1.dta", clear // Append all sheets 
	forv i = 2/21 {
		append using "$rawdata_gx/sheet`i'.dta" 
	}
	drop if pageno == "."
	save "$directory/constructed/genexpert.dta", replace
	
	// Part 2: Clean appended dataset --------------------------------------------------------------------------------
	use "$directory/constructed/genexpert.dta", clear
	
	//Merge voucherno and vocherno column
	replace voucherno = vocherno if voucherno == "" & vocherno != ""

	//Code RIF Resistance Results 
	replace rifres = upper(rifres)
	
	gen rifres1 = 0 if strpos(rifres, "NOT") //Negative
	
	foreach i in CANCEL INSLTAENT { //Cancelled
		replace rifres1 = 2 if strpos(rifres, "`i'")
	}
	replace rifres1 = 2 if rifres == "REUD CANCEEW"
	
	replace rifres1 = 3 if strpos(rifres, "ERROR") //ERROR
	
	replace rifres1 = 0 if strpos(rifres, "NO DET") 
	replace rifres1 = 0 if strpos(rifres, "NT DET") 
	replace rifres1 = 0 if strpos(rifres, "NOE DET")
	replace rifres1 = 0 if strpos(rifres, "NTDET")
	replace rifres1 = 0 if strpos(rifres, "NTBET")
	
	replace rifres1 = 4 if rifres == "REPEAT" //REPEAT
	
	replace rifres1 = 5 if rifres == "SAMPLE LAB" | rifres == "REDDISH SAMPLE" | rifres == "11" //Don't know 
	
	replace rifres1 = 1 if rifres != "" & (inlist(rifres1,0,2,3,4,5) == 0)
	replace rifres1 = . if rifres == " " | rifres == "  "

	//Code MTB Results
	replace mtb = upper(mtb)
	gen mtb1 = 0 if strpos(mtb, "NOT")

	foreach v in H. M. L. (H) (M) (L) (VL) VL. HIGH MEDIUM LOW MED {
		replace mtb1 = 1 if strpos(mtb, "`v'")
	}
	
	replace mtb1 = 2 if strpos(mtb, "CANCEL") 
	
	foreach v in BILLING DOUBLE NTBET SWAB REDDISH {
		replace mtb1 = 5 if strpos(mtb, "`v'")
	}
	
	replace mtb = strtrim(mtb)
	replace mtb1 = 0 if mtb == "NT DET"
	replace mtb1 = 0 if mtb == "NO"
	replace mtb1 = 0 if mtb == "N"
	replace mtb1 = 0 if mtb == "NO DET"
	replace mtb1 = 0 if mtb == "NO DETECTED"
	replace mtb1 = 0 if mtb == "NEGTAVI"
	replace mtb1 = 0 if mtb == "NIT"
	replace mtb1 = 0 if mtb == "MO"
	
	replace mtb1 = 4 if mtb == "REPEAT"
	
	replace mtb1 = 6 if strpos(mtb, "REJECTED")
	
	replace mtb1 = 1 if mtb != "" & (inlist(mtb1,0,2,3,4,5,6) == 0)
	
	//Define value label for MTB and RIF test results 
	label def test 0 "Not detected" 1 "Detected" 2 "Cancelled" 3 "Error" 4"Repeat" 5 "Ambigious" 6"Rejected"
	label val mtb1 test
	label variable mtb1 "MTB"
	rename mtb mtb_raw
	rename mtb1 mtb 
	label variable mtb_raw "MTB (RAW)"
	
	label val rifres1 test
	label variable rifres1 "RIF"
	rename rifres rifres_raw
	rename rifres1 rifres
	label variable rifres_raw "RIF (RAW)"
	
	// Code use of voucher 
	replace vocherno = strtrim(voucherno)
	replace voucherno = upper(voucherno)
	destring vocherno, gen(voucherno1) ignore("/") force 
	gen voucher_PPIA = vocherno != ""
	replace voucher_PPIA = 0 if voucherno == "-" | voucherno == "0" | voucherno == "_"
	replace voucher_PPIA = 2 if strpos(voucherno, "CANCEL")
	replace voucher_PPIA = 3 if voucher_PPIA == 1 & voucherno1 == .
	replace voucher_PPIA = 0 if voucher_PPIA == 3 & voucherno == "."

	// Define value label for voucher_PPIA
	label define voucher 0 "No" 1 "Yes" 2"Cancelled" 3"Others"
	label val voucher_PPIA voucher
	label variable voucher_PPIA "PPIA VOUCHER USE"
	rename voucher_PPIA voucher_ppia
	
	//Code use of SPUTUM as specimen
	replace specimen = strtrim(specimen)
	replace specimen = upper(specimen)
	
	gen sputum = .
	replace sputum = 1 if strpos(specimen, "SPT")
	replace sputum = 1 if strpos(specimen, "SPUTUM")
	replace sputum = 1 if strpos(specimen, "SAMPY")

	foreach i in SPATUM SPPT SPU SPUTUR STUTUM SUPUTUM{
		replace sputum = 1 if specimen == "`i'"
	}
	
	replace sputum = 2 if specimen == "PL FLD SPT"
	replace sputum = 2 if specimen == "ACF SPT"
	
	
	foreach i in ENDOSPT SP SPL STP STU {
		replace sputum = 2 if specimen == "`i'"
	}
	
	replace sputum = 0 if (specimen != "" & (inlist(sputum, 1, 2) == 0))
	
	//Define value label for sputum
	label define sputum 0 "Others" 1 "Sputum" 2 "Ambiguous"
	label values sputum sputum
	label variable sputum "SPUTUM AS SPECIMEN"
	
	// Rename labno
	rename labno lab_id
	label variable lab_id "LAB ID"
	
	//Clean date raw
	forv i = 15/17{
		replace date = subinstr(date , "/`i'", "/20`i'", .)		
	}
	replace date = subinstr(date, "-205", "-2015", .)
	
	replace sheet = trim(sheet)
	destring sheet, replace 
	
	replace date = "11/12/2016" if (date == "12/11/2016" & sheet == 4)
	replace date = "10/12/2016" if (date == "12/10/2016" & sheet == 4)
	
	foreach i in 02 03 04 05 06 07 08 09 10 12 {
		replace date = "`i'-11-2016'" if (date == "11-`i'-2016" & sheet == 18)
	}
	
	replace date = "03-02-2015'" if (date == "03-02-2014" & sheet == 19)
	
	foreach i in 02 03 12 05 06 07 08 09 10 {
		replace date = "`i'-01-2015" if (date == "`i'-01-2014" & sheet == 19)
	}
	
	foreach i in 02 03 {
		replace date = "`i'/01/2017" if (date == "`i'/01/2016" & sheet == 2)
	}
	
	foreach i in 05 08 11 12 10 04 07{
			replace date = "`i'/01/2016" if (date == "01/`i'/2016" & sheet == 3)
	}
	
	replace date = "01/01/2016" if (date == "01/01/2017" & sheet == 3)
	
	forv i = 10/12 {
		replace date = "`i'/03/2017" if (date == "03/`i'/2017" & sheet == 8)
	}
	
	replace date = "07/06/2016" if (date == "07/06/2017" & sheet == 12)
	
	replace date = "18/10/2015" if (date == "18/10/2017" & sheet == 17)
	replace date = "18/10/2015" if (date == "18/10/2016" & sheet == 17)
	replace date = "25/09/2015" if (date == "25/09/2016" & sheet == 17)
	
	replace date = "08-03-2015" if (date == "03-08-2015" & sheet == 16)
	replace date = "08-04-2015" if (date == "04-08-2015" & sheet == 16)
	replace date = "09-04-2015" if (date == "04-09-2015" & sheet == 16)
	
	gen d = date(date, "DMY") // Convert to date format 
	format d %td 
	drop if date == ""
	
	//Keep only relevant columns 
	drop date patientsname drname v13 vocherno voucherno1 patientsid patientid v14 v15 v16 v17 v18 pageno srno sheet 
	rename d date

	label variable date "DATE"
	order date 
	
	// Drop observations with unclear/cancelled results
	drop if inlist(mtb,2,4,5,6)
	drop if inlist(rifres,2,3,4,5)
	drop if inlist(sputum, 2)
	drop if inlist(voucher_ppia,2,3)
	
	save "$directory/constructed/mumbai_gx.dta", replace  // Save clean daily gx data 
	
	// Part 3: Create dataset to get total tests done on each date and each observation as a unique date -----------------------------------------------------------------------------------------
	use "$directory/constructed/mumbai_gx.dta", clear
	drop mtb_raw rifres_raw

	foreach var in mtb rifres {
		bys date : egen `var'_total = count(`var') // Total tests done
		
		gen has_`var' = `var' == 1
		replace has_`var' = . if `var' != 1 
		bys date: egen `var'_positive = count(has_`var') // Total +ve test results
		drop has_`var'
		
		gen no_`var' = `var' == 0
		replace no_`var' = . if `var' != 0
		bys date: egen `var'_negative = count(no_`var') // Total -ve test results 
		drop no_`var'

	}
	
	replace sputum = . if sputum != 1
	bys date : egen sputum_total = count(sputum) // Total specimens as sputum
	label variable sputum_total "TOTAL SPECIMENS AS SPUTUM"
	
	//Define labels for total, +ve and -ve mtb and rifres test results
	label variable mtb_total "TOTAL MTB TESTS"
	label variable mtb_positive "TB DETECTED"
	label variable mtb_negative "TB NOT DETECTED"
	
	label variable rifres_total "TOTAL RIF TESTS"
	label variable rifres_positive "RIF RESISTANT"
	label variable rifres_negative "RIF SENSITIVE"
	
	// Total vouchers used 
	replace voucher_ppia = . if voucher_ppia != 1
	bys date: egen voucher_total = count(voucher_ppia)
	label variable voucher_total "TOTAL VOUCHERS USED"
	
	//Keep one observation of each date 
	bys date: gen tag = _n == 1
	drop if tag != 1

	//Keep relevant vars 
	keep date *_total *_positive *_negative sputum_total
	
	save "$directory/constructed/mumbai_gx_total.dta", replace 
	
	// Part 4: Create relevant graphs --------------------------------------------------------------------------------
	use "$directory/constructed/mumbai_gx_total.dta", clear	
	
	//Graph of total mtb tests and vouchers used for each date 
	tw  (bar mtb_total date) (bar voucher_total date) , xlab(,format(%tdMon_YY)) xtit("") $graph_opts
		graph export "$directory/outputs/gx_fig1.png", width(1000) replace
	
	//Get month of each date 
	gen dm=mofd(date)
	format dm %tm
	
	//Monthly total of all vars
	bys dm : egen MTB = total(mtb_total)
	bys dm : egen Voucher_used = total(voucher_total)
	bys dm : egen Sputum = total(sputum_total)
	bys dm : egen RIF_TEST = total(rifres_total)
	bys dm : egen RIF_RESISTANT = total(rifres_positive)
	
	//Keep one observation from each month 
	bys dm : gen a = _n == 1
	keep if a == 1
	
	//Graph of total mtb tests done and vouchers used in each month 
	tw  (bar MTB dm) (bar Voucher_used dm), xlab(,format(%tm)) ytit("Monthly Total") xtit("") $graph_opts
	graph export "$directory/outputs/gx_fig2.png", width(1000) replace
	
	//Graph of total mtb tests done and sputum used as specimen in each month 
	tw  (bar MTB dm) (bar Sputum dm), xlab(,format(%tm)) ytit("Monthly Total") xtit("") $graph_opts
	graph export "$directory/outputs/gx_fig3.png", width(1000) replace 
	
	//Graph of total RIF resistant TB out of total RIF tests done
	tw  (bar RIF_TEST dm) (bar RIF_RESISTANT dm), xlab(,format(%tm)) ytit("Monthly Total") xtit("") $graph_opts
	graph export "$directory/outputs/gx_fig4.png", width(1000) replace
	
	
	
	
