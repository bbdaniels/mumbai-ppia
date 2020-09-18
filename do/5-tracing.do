// Tracing analysis

// PPIA Providers @ Providers in 3 Rounds
use "${git}/constructed/full-data.dta" , clear
  keep if pxh == 1
  keep pid fid round sample ppia_facility_? pxh
  ren ppia_facility_? ppf?
    duplicates drop

  reshape wide pxh, i(pid fid) j(round)
  sort pid sample fid
  
    forv i = 1/4 {
      gen r`i' = `i'
    }
    
    egen p1 = group(pid)
    bys pid: gen p2 = _n
    
    gen place = p1

    forv i = 1/3 {
      replace r`i' = r`i' + (p2-1)/10 if pid != fid
    }
    
    tw ///
      (rspike r1 r2 place if pxh1 == 1 , hor lw(thin) lc(gs12)) ///
      (rspike r3 r2 place if pxh2 == 1 , hor lw(thin) lc(gs12)) ///
      (rspike r3 r4 place if pxh3 == 1 , hor lw(thin) lc(gs12)) ///
      (scatter place r1 if ppf0 == 1 , mc(black)) ///
      (scatter place r2 if ppf1 == 1 , mc(black)) ///
      (scatter place r3 if ppf2 == 1 , mc(black)) ///
      (scatter place r1 if pxh1 == 1, mc(red) msize(*.4)) ///
      (scatter place r2 if pxh2 == 1, mc(red) msize(*.4)) ///
      (scatter place r3 if pxh3 == 1, mc(red) msize(*.4)) ///
      (scatter place r1 if pxh1 == . , mc(gray) msize(*.4)) ///
      (scatter place r2 if pxh2 == . , mc(gray) msize(*.4)) ///
      (scatter place r3 if pxh3 == . , mc(gray) msize(*.4)) ///
    , ysize(7) ylab(none) yscale(noline) ytit("") ///
      xlab(1.5 "Round 1" 2.5 "Round 2" 3.5 "Round 3", notick) xscale(noline alt) ///
      legend(on order(7 "PPIA Provider" 4 "PPIA Location" 10 "Missing") ///
        pos(12) region(lc(none) fc(none)) r(1))
        
      graph export "${git}/outputs/f-tracing-pxh.eps" , replace

// PPIA Facilities & Providers in 3 Rounds
use "${git}/constructed/full-data.dta" , clear
  keep if sample == 1 
  keep pid fid round sample pxh
    duplicates drop

  reshape wide pxh, i(pid fid) j(round)
  sort sample fid pid

    forv i = 1/4 {
      gen r`i' = `i'
    }
    
  egen p1 = group(sample fid)
  bys fid: gen p2 = _n

  gen place = p1

  forv i = 1/3 {
    replace r`i' = r`i' + (p2-1)/10 if pid != fid
  }

  tw ///
    (rspike r1 r2 place if pxh1 == 0 & pxh2 == 0 , hor lw(thin) lc(gs12)) ///
    (rspike r3 r2 place if pxh3 == 0 & pxh2 == 0 , hor lw(thin) lc(gs12)) ///
    (rspike r3 r4 place if pxh3 == 0  , hor lw(thin) lc(gs12)) ///
    (scatter place r1 if pxh1 == 0 , mc(black)) ///
    (scatter place r2 if pxh2 == 0 , mc(black)) ///
    (scatter place r3 if pxh3 == 0 , mc(black)) ///
    (scatter place r1 if pxh1 == 1, mc(red) m(T)) ///
    (scatter place r2 if pxh2 == 1, mc(red) m(T)) ///
    (scatter place r3 if pxh3 == 1, mc(red) m(T)) ///
    (scatter place r1 if pxh1 == . , m(S) mc(gray)) ///
    (scatter place r2 if pxh2 == . , m(S) mc(gray)) ///
    (scatter place r3 if pxh3 == . , m(S) mc(gray)) ///
  , ysize(7) ylab(none) yscale(noline) ytit("") ///
    xlab(1.5 "Round 1" 2.5 "Round 2" 3.5 "Round 3", notick) xscale(noline alt) ///
    legend(on order(4 "Facility Walk-In" 7 "PPIA Provider" 10 "Missing") ///
      pos(12) region(lc(none) fc(none)) r(1))
      
    graph export "${git}/outputs/f-tracing-ppia.eps" , replace
