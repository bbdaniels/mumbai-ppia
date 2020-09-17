// VERSION 1.0
// Benjamin Daniels
// bbdaniels@gmail.com

// ---------------------------------------------------------------------------------------------
// Main command
cap prog drop specc
prog def specc
  version 13.1

  // Syntax setup
  syntax [anything] [using/]  ///
    [if] ///
    , ///
    [*]

  // Default specc directory
  if "`using'" == "" local using "specc"

  // Parse subcommand
  gettoken subcommand anything : anything

  // Allow abbreviations
  if "`subcommand'" == "init" local subcommand = "initialize"
  if "`subcommand'" == "drop" local subcommand = "remove"

  // Make sure some subcommand is specified
  if !inlist("`subcommand'","initialize","remove","new","report","set","run") {
    di as err "{bf:specc} requires [initialize], [remove], [report], [new], [set], [run] to be specified. Type {bf:help specc} for details."
    error 197
  }

  specc_`subcommand' `anything' using "`using'" `if', `options'

end
// ---------------------------------------------------------------------------------------------

// ---------------------------------------------------------------------------------------------
// Initialization subcommand
cap prog drop specc_initialize
prog def specc_initialize

  // Syntax setup
  syntax using/ , ///
    [*]

  // Create empty dataset for specc storage
  mkdir `"`using'"' , public
  preserve
    clear
    save `"`using'/specc.dta"' , emptyok
  restore

  // Set up model class and main method
  specc new model main Main Specification ///
    using "`using'" ///
    , skipcheck

end
// ---------------------------------------------------------------------------------------------

// ---------------------------------------------------------------------------------------------
// NEW METHOD subcommand
cap prog drop specc_new
prog def specc_new

  // Syntax setup
  syntax anything using/ , ///
    [Code(string asis)] ///
    [replace] [skipcheck] [*]

  // Get info
  gettoken class anything : anything
  gettoken method anything : anything

  // Make sure no conflicts
  if "`skipcheck'" == "" {
    preserve
      use `"`using'/specc.dta"' , clear
      qui count if class == "`class'" & method == "`method'"
      if (`r(N)' > 0) & ("`replace'" == "") {
        di as err "The `method' method already exists in the `class' class."
        error 110
      }
    restore
  }

  // Append new method dataset for specc storage
  preserve
  qui {
  clear
    set obs 1
    gen class = "`class'"
    gen method = "`method'"
    gen dofile = "/`class'/`method'.do"
    gen timestamp = "`c(current_date)' `c(current_time)'"
    gen description = "`anything'"

    append using `"`using'/specc.dta"'
      save `"`using'/specc.dta"' , replace
  }

  // Set up method dofile
  cap mkdir `"`using'/`class'/"' , public
    if "`replace'" != "" erase `"`using'/`class'/`method'.do"'
    cap file close main
    file open main using `"`using'/`class'/`method'.do"' , write
    file write main "// `anything'" _n _n
    file write main `code' _n _n
    if class == "model" {
      file write main "local b =" _n
      file write main "local ll =" _n
      file write main "local ul =" _n
      file write main "local p =" _n
      file write main "cap mat drop _specc_results" _n
      file write main "mat _specc_results = [\`b',\`ll',\`ul',\`p']" _n
      file write main `"mat colnames _specc_results = "b" "ll" "ul" "p" "' _n _n
    }
    file write main "// End of `anything'" _n
    file close main

end
// ---------------------------------------------------------------------------------------------

// ---------------------------------------------------------------------------------------------
// Removal subcommand
cap prog drop specc_remove
prog def specc_remove

  // Syntax setup
  syntax anything using/ , ///
    [*]

  gettoken class anything : anything
  gettoken method anything : anything

  // Remove marked method
  preserve
    use `"`using'/specc.dta"' `if', clear
    qui drop if class == "`class'" & method == "`method'"
    qui save `"`using'/specc.dta"' , replace
  restore
  !rm "`using'/`class'/`method'.do"

end
// ---------------------------------------------------------------------------------------------

// ---------------------------------------------------------------------------------------------
// SET subcommand
cap prog drop specc_set
prog def specc_set

  // Syntax setup
  syntax anything using/ , ///
    reset [*]

  // Create empty dofile for specc storage
  cap rm `"`using'/specc.do"'

  cap file close main
  file open main using `"`using'/specc.do"' , write
  file write main "/* SPECC Runfile will iterate over:" _n
  file write main "`anything'" _n
  file write main "*/" _n _n

  foreach class in `anything' {
    file write main "\``class''" _n _n
  }

  file write main "// End of SPECC Runfile" _n
  file close main

  // Read out execution order
  file open main using `"`using'/specc.do"' , read
    file read main line
    forv i = 1/2 {
      display "`line'"
      if `i' == 1 file read main line
    }
  file close main

end
// ---------------------------------------------------------------------------------------------

// ---------------------------------------------------------------------------------------------
// Report subcommand
cap prog drop specc_report
prog def specc_report

  // Syntax setup
  syntax [anything] using/ [if], ///
    [sort] [*]

  // Load and display report
  if "`anything'" == "" {
    preserve
      use `"`using'/specc.dta"' `if', clear
      if "`sort'" != "" sort class method
      li
    restore

    cap confirm file `"`using'/specc.do"'
    if _rc == 0 {
      di "SPECC Runfile detected at {browse `using'/specc.do}."
      cap file close main
      file open main using `"`using'/specc.do"' , read
      file read main line
      forv i = 1/2 {
      	display "`line'"
      	if `i' == 1 file read main line
      }
    }

    local params = "`line'"
    local n_params: word count `params'

    forv i = 1/`n_params' {
      local c`i' : word `i' of `params'

      preserve
        use `"`using'/specc.dta"' `if', clear
        qui levelsof method if class == "`c`i''" , local(m`i')
        qui levelsof description if class == "`c`i''" , local(d`i')
      restore

      di `" `c`i'' :: `d`i''   "'
    }
  }

  // Display contents if requested
  if "`anything'" != "" {
    gettoken class anything : anything
    gettoken method anything : anything
    cap file close main
    file open main using `"`using'/`class'/`method'.do"' , read
    file read main line
    while r(eof)==0 {
    	display "`line'"
    	file read main line
    }
    file close main
  }

end
// ---------------------------------------------------------------------------------------------

// ---------------------------------------------------------------------------------------------
// Run subcommand
cap prog drop specc_run
prog def specc_run

  // Syntax setup
  syntax using/ , ///
    [sort] [save] [*]

tempfile theData
  save `theData'

  // Read out execution order
  cap file close main
  file open main using `"`using'/specc.do"' , read
    di "SPECC Runfile detected at {browse `using'/specc.do}."
    cap file close main
    file open main using `"`using'/specc.do"' , read
    file read main line
    forv i = 1/2 {
      display "`line'"
      if `i' == 1 file read main line
    }
  file close main
  local params = "`line'"

  // Create iteration loop
  local n_params: word count `params'
  tempname current max

    mat `current' = J(1,`n_params',1)
      mat colnames `current' = `params'
    mat `max' = J(1,`n_params',1)

    forv i = 1/`n_params' {
      local c`i' : word `i' of `params'

      preserve
        use `"`using'/specc.dta"' `if', clear
        qui levelsof method if class == "`c`i''" , local(m`i')
          local max_`c`i'' : word count `m`i''
          mat `max'[1,`i'] = `max_`c`i'''
        qui levelsof description if class == "`c`i''" , local(d`i')

      restore

      // Get longest label length
      local count : word count `d`i''
      local length`i' = 0
      forv label = 1/`count' {
        local thisLabel : word `label' of `d`i''
        local thisLength = length("`thisLabel'")
        local length`i' = max(`length`i'',`thisLength')
      }

      di `" `c`i'' :: `d`i''   "'
    }

  // Loop over combinations

    // Calculate total combinations
    local total = 1
    forv i = 1/`n_params' {
      local next = `max'[1,`i']
      local total = `total'*`next'
    }

    // Set up to loop over all differences
    tempname diffmat

    local diff = 1
    local counter = 0
    cap mat drop _all_results
    while `diff' != 0 {
      local ++counter
      di " "
      di "(`counter'/`total') Running:"

      // Get the dofile list
      forv i = 1/`n_params' {
        local theIndex = `current'[1,`i']
        local theClass = "`c`i''"
        local theMethod : word `theIndex' of `m`i''
        preserve
          use `"`using'/specc.dta"' ///
            if class == "`theClass'" & method == "`theMethod'" , clear
          local theDesc = description[1]
          local lab`i' = `"`lab`i'' `theIndex' "`theDesc'" "'
        restore
        di " `theDesc' (`using'/`theClass'/`theMethod'.do)"
        run `"`using'/`theClass'/`theMethod'.do"'
        if "`theClass'" == "model" {
          mat _all_results = nullmat(_all_results) ///
            \ `current' , _specc_results
        }
      }

      // Quit if this was the max iteration
      mat `diffmat' = (`current' - `max')*(`current' - `max')'
      local diff = `diffmat'[1,1] // Diff becomes zero when matrices are equal

      // Increment first unmaxed param
      local increment = 1
      forv i = 1/`n_params' {
        local theCurrent = `current'[1,`i']
        local theMax = `max'[1,`i']
        if (`theCurrent' < `theMax') & (`increment' == 1) {
          mat `current'[1,`i'] = `theCurrent' + 1
          local increment = 0
        }
        else if (`theCurrent' == `theMax') & (`increment' == 1) {
          mat `current'[1,`i'] = 1
        }
      }
    } // End looping over combinations

  // Build graph
    qui clear
    qui svmat _all_results , n(col)
    sort b
    if "`sort'" != "" sort `line'
    if "`save'" != "" save `"`using'/results.dta"' , replace
    gen n = _n

    local tw_opts ///
    	graphregion(color(white) lc(white) lwidth(none)) bgcolor(white) ///
    	ylab(,angle(0) nogrid) legend(off) plotregion(margin(medium))

    forv i = 1/`n_params' {

      local offset = 8 -0.6*(`length`i'') // Much hacking :-(

      preserve

        qui xtset `c`i'' n
        qui tsfill , full

        qui tw ///
          (scatter `c`i'' n if b != ., msize(medlarge) m(X) mc(black)) ///
          (scatter `c`i'' n if b == ., msize(*.1) m(.) mc(gray)) ///
        , yscale(noline) xscale(noline) xlab(none,notick)  ///
          ylab(`lab`i'' , labsize(tiny) notick) ytit(" ") ///
          nodraw saving(`"`using'/`c`i''.gph"' , replace) `tw_opts' ///
          ytitle(, margin(0 `offset'  0 0 )) ///
          xtitle(" ", margin(0 `offset'  0 0 )) ///
          title("`c`i''", justification(left) color(black) span pos(11) size(small)) ///
          plotregion(lcolor(black))

      restore


      local graphs `"`graphs' "`using'/`c`i''.gph""'
    }

    qui tw ///
      (rspike ul ll n , lc(gs12)) ///
      (scatter b n if p >= 0.05, mlc(black) mc(white) msize(medium)) ///
      (scatter b n if p < 0.05 , mc(black) lc(none) msize(small)) ///
    , xtit(" ") xlab(none,notick) xscale(noline) yscale(noline r(0)) ylab(#6 , grid) ///
      yline(0) fysize(66)  ytit("Coefficient") `tw_opts' ///
      nodraw saving(`"`using'/results.gph"' , replace) ///
      plotregion(lcolor(black))

    graph combine ///
      `"`using'/results.gph"' `graphs' ///
    , c(1) xcom imargin(t=0 b=0) ysize(6) `options' ///
      graphregion(color(white) lc(white))

    !rm "`using'/results.gph" `graphs'



use `theData' , clear // Restore original data
end
// ---------------------------------------------------------------------------------------------

// End of adofile
