cap log close 
log using $datadir/logs/readtracts.log, replace

***************** tracts
use $rdir/TractLocVars.dta, clear

rename (geoid tract_latitude tract_longitude) (tractid lat lon)

//remove duplicate entries for gisjoin
bys tractid year (gisjoin): keep if _n==_N

keep tractid year state lat lon pop65plus_int poptot_int 
drop if pop65plus_int==0


//coordinates are at the tract-year level
//save each year in separate file
levelsof year, loc(yrs)
foreach yy of loc yrs{
	savesome if year==`yy' using $idir/tract_`yy', replace
}

save $idir/tract.dta, replace
// use $idir/tract.dta, clear //testing

cap log close