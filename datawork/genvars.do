cap log close 
log using $datadir/logs/genvars.log, replace

use $idir/sample_novars${testtag}.dta, clear

***
//scale factor - fraction of elderly population considered to be in market
//for now, set as 0.1...
// or 0.2 if tract has high residents:population ratio - avoid estimation issues


bys facid year: egen pop65_j = total(pop65plus_int) //population>65 in tracts near j
gen ratio_occpop = restot / pop65_j
sum ratio_occpop, d
gen aux_highnhratio = ratio_occpop > `r(p95)'
gen fracpop_inmkt = 0.03
bys tractid year: egen aux_boosttractpop = max(aux_highnhratio)
replace fracpop_inmkt = 0.06 if aux_boosttractpop == 1
drop aux_* ratio_occpop
gen mktpop = fracpop_inmkt * pop65plus_int

*** medicare residents
gen nres_mcare = paymcare / 100 * restot
drop paymcare


*** medicaid residents
gen nres_mcaid = paymcaid / 100 * restot
drop paymcaid

sum mktpop, d

// roughly tabulate total inside share
preserve 
collapse (first) mktpop fracpop_inmkt, by(tractid year)
tabstat mktpop, stat(sum)
sum fracpop_inmkt, d 
restore 
preserve 
collapse (first) restot, by(facid year)
tabstat restot, stat(sum)
restore


*****
// IV: neighbors' staffing
loc xvars dchrppd rnhrppd
bys tractid year: egen mkt_nj = count(facid)

foreach v of varlist `xvars'{
	bys tractid year: egen mktnbr_`v' = total(`v')
	replace mktnbr_`v' = mktnbr_`v' - `v'
	replace mktnbr_`v' = mktnbr_`v' / (mkt_nj - 1)
	bys facid year: egen nbr_`v' = mean(mktnbr_`v)
}

tempfile aux_facs
save `aux_facs'

// IV: distance to nearest competitor 
geonear facid lat lon using `aux_facs', n(facid lat lon) ignoreself nearcount(1)
drop nid
rename km_to_nid dist_nbrfac

// IV: number of competitors within distance band


gsort tractid year facid
egen tractyear = group(tractid year)

save $adir/factract${testtag}.dta, replace


export delim $adir/factract${testtag}, replace

cap log close
