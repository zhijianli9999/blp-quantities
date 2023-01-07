cap log close 
log using $datadir/logs/genvars.log, replace

//creates market-level variables and IVs

use $idir/sample_novars${testtag}.dta, clear

***
//scale factor - fraction of elderly population considered to be in market
//for now, set as 0.03
// or 0.06 if tract has high residents:population ratio - avoid estimation issues


bys facid year: egen pop65_j = total(pop65plus_int) //population>65 in tracts near j
gen ratio_occpop = restot / pop65_j
sum ratio_occpop, d
gen aux_highnhratio = ratio_occpop > `r(p95)'
gen fracpop_inmkt = 0.03
bys tractid year: egen aux_boosttractpop = max(aux_highnhratio)
replace fracpop_inmkt = 0.06 if aux_boosttractpop == 1
drop aux_* ratio_occpop
gen mktpop = fracpop_inmkt * pop65plus_int

drop pop*_int pop65_j fracpop_inmkt
*****
// IV: neighbors' staffing

loc xvars labor_expense dchrppd rnhrppd cnahrppd lpnhrppd
bys tractid year: egen mkt_nj = count(facid)

foreach v of varlist `xvars'{
	bys tractid year: egen mktnbr_`v' = total(`v')
	replace mktnbr_`v' = mktnbr_`v' - `v'
	replace mktnbr_`v' = mktnbr_`v' / (mkt_nj - 1)
	bys facid year: egen nbr_`v' = mean(mktnbr_`v')
}
drop mktnbr_* mkt_nj
compress
tempfile tmp1
save `tmp1'


// IV: distance to nearest competitor 
geonear facid lat lon using `tmp1', n(facid lat lon) ignoreself nearcount(1)
drop nid
rename km_to_nid dist_nbrfac


// IV: number of competitors within distance band
gen facid2 = facid
tempfile tmp2
save `tmp2'

foreach dd of numlist 5 20{
	geonear facid lat lon using `tmp2', n(facid2 lat lon) long ignoreself within(`dd')
	gcollapse (count) competitors_in`dd'=km_to_facid2, by(facid)
	label var competitors_in`dd' "Number of competitors within `dd'km"
	replace competitors_in`dd' = competitors_in`dd' - 1
	merge 1:m facid using `tmp2'
	drop _merge
	save `tmp2', replace
}
drop facid2

gsort tractid year facid
egen tractyear = group(tractid year) 

merge 1:1 facid tractid year using `tmp1' 
drop _merge

drop lat lon 

compress
save $adir/factract${testtag}.dta, replace
// use  $adir/factract${testtag}.dta, clear //testing

export delim $adir/factract${testtag}, replace

//save facility-level dataset (with IVs) 
collapse (firstnm) restot nres_mcare nres_nonmcaid labor_expense loglabor_expense competitors_in* dist_nbrfac nbr* state county statecounty,  by(facid year)
save $adir/fac${testtag}.dta, replace
export delim $adir/fac${testtag}.csv, replace 
// use $adir/fac${testtag}.dta, clear
cap log close
