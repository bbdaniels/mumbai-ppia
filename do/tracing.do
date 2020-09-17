// Tracing analysis

use "${git}/constructed/full-data.dta" if sample == 1, clear
keep pid fid round sample pxh
  duplicates drop


reshape wide pxh, i(pid fid) j(round)
sort sample fid pid

egen p1 = group(sample fid)
bys fid: gen p2 = _n

gen place = real(string(p1)+"."+string(p2))
reshape long pxh, i(pid fid) j(round)

bys fid: gen n = _N
sort place

tw ///
  (line place round if !pxh , lw(thin) lc(black) mc(black) connect(ascending)) ///
  (line place round if pxh , lw(thin) lc(red) mc(black) connect(ascending)) ///
  , by(sample, compact r(1))
