
use $idir/sample_novars${testtag}.dta, clear


***
//scale factor - fraction of elderly population considered to be in market
//for now, set as 0.1...
// or 0.2 if tract has high residents:population ratio - avoid estimation issues


//facility-based ratio cutoff
bys facid: egen pop65_j = total(pop65plus_int) //population>65 in tracts near j
gen ratio_j = restot / pop65_j
sum ratio_j, d
gen aux_highratio = ratio_j > (`r(p50)' * 8)
gen aux_lowratio = ratio_j < (`r(p50)' / 8)
bys tractid: egen boostmkt_j = max(aux_highratio)
bys tractid: egen paremkt_j = max(aux_lowratio)
drop aux*ratio ratio_j

//tract-based ratio cutoff
bys tractid: egen nhpop_t = total(restot)
gen ratio_t =  nhpop_t / pop65plus_int
sum ratio_t, d
gen aux_highratio = ratio_t > (`r(p50)' * 8)
gen aux_lowratio = ratio_t < (`r(p50)' / 8)
bys tractid: egen boostmkt_t = max(aux_highratio)
bys tractid: egen paremkt_t = max(aux_lowratio)

sum boost* pare*

gen fracpop_inmkt = 0.05
replace fracpop_inmkt = fracpop_inmkt + 0.025 if boostmkt_j==1 | boostmkt_t==1
replace fracpop_inmkt = fracpop_inmkt - 0.025 if paremkt_j==1 | paremkt_t==1

gen mktpop = fracpop_inmkt * pop65plus_int

// roughly tabulate total inside share
preserve 
collapse (first) mktpop fracpop_inmkt, by(tractid)
tabstat mktpop, stat(sum)
sum fracpop_inmkt, d 
restore 
preserve 
collapse (first) restot, by(facid)
tabstat restot, stat(sum)
restore

drop aux_* ratio* boost* pare* fracpop_inmkt pop65_j nhpop_t


*** medicare residents
gen nres_mcare = paymcare / 100 * restot
drop paymcare

gsort tractid


*****
// neighbors' staffing as IV
loc xvars dchrppd rnhrppd
foreach v of varlist `xvars'{
	bys tractid: egen nbr_`v' = total(`v')
	replace nbr_`v' = nbr_`v' - `v'
}



*****


save $adir/factract${testtag}.dta, replace
use $adir/factract${testtag}.dta, clear
export delim $adir/factract${testtag}, replace
