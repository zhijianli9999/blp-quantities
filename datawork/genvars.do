
use $idir/sample_novars${testtag}.dta, clear


***
//scale factor - fraction of elderly population considered to be in market
//for now, set as 0.1...
// or 0.2 if tract has high residents:population ratio - avoid estimation issues


bys facid: egen pop65_j = total(pop65plus_int) //population>65 in tracts near j
gen ratio_occpop = restot / pop65_j
sum ratio_occpop, d
gen aux_highnhratio = ratio_occpop > `r(p95)'
gen fracpop_inmkt = 0.1
bys tractid: egen aux_boosttractpop = max(aux_highnhratio)
replace fracpop_inmkt = 0.2 if aux_boosttractpop == 1
drop aux_* ratio_occpop
gen mktpop = fracpop_inmkt * pop65plus_int

*** medicare residents
gen nres_mcare = paymcare / 100 * restot
drop paymcare

gsort tractid

save $adir/factract${testtag}.dta, replace
use $adir/factract${testtag}.dta, clear
export delim $adir/factract${testtag}, replace
