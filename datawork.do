gl datadir = "/export/storage_adgandhi/MiscLi/factract"
gl rdir = "$datadir/raw"
gl idir = "$datadir/intermediate"
gl adir = "$datadir/analysis"

///// testing
loc testmode = 0
if "`testmode'"=="1"{
	loc testtag "_FL"
}

gl auxstate = "FL" //pick one state to test 

//tracts
use $rdir/TractLocVars.dta, clear
keep if year==2017
drop if pop65plus_int==0
bys geoid (gisjoin): keep if _n==_N

rename (geoid tract_latitude tract_longitude) (tractid lat lon)
keep tractid state lat lon pop65plus_int poptot_int 

save $idir/tract.dta, replace
keep if state=="$auxstate"
save $idir/tract_$auxstate.dta, replace

// use $idir/tract_$auxstate.dta, clear //testing

//facilities
use $rdir/analysis.dta, clear
keep if year==2017
rename (accpt_id latitude longitude) (facid lat lon)

loc xvars dchrppd rnhrppd
loc qvars avg_dailycensus restot paymcare 
keep facid state county cz lat lon ///
	occpct totbeds `xvars' `qvars'
	
gisid facid
save $idir/fac.dta, replace
keep if state=="$auxstate"
save $idir/fac_$auxstate.dta, replace

// use $idir/fac_$auxstate.dta, clear //testing


use $idir/fac`testtag'.dta, clear //testing
geonear facid lat lon using $idir/tract`testtag'.dta, n(tractid lat lon) long within(10) rep(10)
rename km_to_tractid dist

gsort tractid facid
gduplicates tag tractid, g(nfacs) //number of facilities near the tract
drop if nfacs == 0

merge m:1 facid using $idir/fac`testtag'.dta
keep if _merge==3
drop _merge
merge m:1 tractid using $idir/tract`testtag'.dta
keep if _merge==3
drop _merge



compress
save $adir/dists`testtag'.dta, replace
use $adir/dists`testtag'.dta, clear
export delim $adir/factract`testtag', replace



/* NOTES:
distance is in km. 
only using 2017.
analysis.dta has nhlat/nhlong also. some missings there. 
*/
