cap log close 
log using $datadir/logs/findnbrs.log, replace

// do the geonear stuff which takes a while to run

//facilities
use $rdir/analysis_wnotforprofit.dta, clear

rename (accpt_id latitude longitude) (facid lat lon)

//keep one observation of coordinates for each facility 
//take most recent coordinates for geonear
keep facid year lat lon
bys facid (year): keep if  _n==_N
save $idir/facloc.dta, replace
// use $idir/facloc.dta, clear //testing

***************************************

//merge tracts within distance threshold 

levelsof year, loc(yrs)
foreach yy of loc yrs{
	use $idir/facloc.dta, clear
	geonear facid lat lon using $idir/tract_`yy'.dta, n(tractid lat lon) long within(30)
	rename km_to_tractid dist
	save "${idir}/geonear_`yy'.dta", replace
}

cap log close
