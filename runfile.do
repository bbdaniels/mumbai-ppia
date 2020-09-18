// Runfile for Mumbai analysis

global git "/users/bbdaniels/github/mumbai-ppia/"
global box "/users/bbdaniels/Box/Qutub/MUMBAI/"

// Install adofiles and other support

  sysdir set PLUS "${git}/ado/"

  ssc install iefieldkit , replace
  ssc install rdrobust, replace
  net install forest, from(https://github.com/bbdaniels/stata/raw/master/)
  net install outwrite, from(https://github.com/bbdaniels/stata/raw/master/)
  net install specc, from(https://github.com/bbdaniels/stata/raw/master/)

// Get data from Box (finalize before publication)

  foreach file in ///
    master-facilities master-providers master-interactions ///
    wave-0 wave-1 wave-2 {
      copy "${box}/data/deidentified/`file'.dta" ///
        "${git}/data/`file'.dta" , replace
  }
  
  // Get metadata
  copy "${box}/data/metadata/deidentified/all.xlsx" ///
    "${git}/data/append-metadata.xlsx" , replace

// Project settings

	global graph_opts title(, justification(left) color(black) span pos(11)) ///
    graphregion(color(white)) ylab(,angle(0) nogrid) xtit(,placement(left) ///
    justification(left)) yscale(noline) xscale(noline) legend(region(lc(none) fc(none)))
	global graph_opts_1 title(, justification(left) color(black) span pos(11)) ///
    graphregion(color(white)) ylab(,angle(0) nogrid) yscale(noline) legend(region(lc(none) fc(none)))
	global comb_opts graphregion(color(white))
	global hist_opts ylab(, angle(0) axis(2)) yscale(noline alt axis(2)) ///
    ytit(, axis(2)) ytit(, axis(1)) yscale(off axis(2)) yscale(alt)
	global note_opts justification(left) color(black) span pos(7)
	global pct `" 0 "0%" .25 "25%" .5 "50%" .75 "75%" 1 "100%" "'

// End of dofile
