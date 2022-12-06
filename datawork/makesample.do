cap log close 
log using $datadir/logs/makesample.log, replace

//in this do file, we make datasets for both testing and full-sample
//tracts
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

**************************************************
//facilities
use $rdir/analysis.dta, clear

rename (accpt_id latitude longitude) (facid lat lon)

loc xvars dchrppd rnhrppd
loc qvars avg_dailycensus restot paymcare paymcaid
drop if inlist(., restot) //very few have missing restot so just dropping
keep facid year state county cz lat lon ///
	occpct totbeds `xvars' `qvars'
	
compress
save $idir/fac.dta, replace
use  $idir/fac.dta, clear //testing

//keep one observation of coordinates for each facility 
//take most recent coordinates for geonear
keep facid year lat lon
bys facid (year): keep if  _n==_N
save $idir/facloc.dta, replace
use $idir/facloc.dta, clear //testing

***************************************

//merge tracts within distance threshold 

levelsof year, loc(yrs)
foreach yy of loc yrs{
	use $idir/facloc.dta, clear
	geonear facid lat lon using $idir/tract_`yy'.dta, n(tractid lat lon) long within(30)
	rename km_to_tract dist
	save "${idir}/geonear_`yy'.dta", replace
}


clear
gen aux=1
save $idir/sample_novars, replace
use $idir/facloc.dta, clear

levelsof year, loc(yrs)
foreach yy of loc yrs{
	use $idir/fac.dta if year==`yy', clear
	merge 1:m facid using "$idir/geonear_`yy'.dta"
	keep if _merge==3 // 2 for facilities that don't appear in that year
	drop _merge
	merge m:1 tractid using ${idir}/tract_`yy'.dta 
	keep if _merge==3 // 2 if tracts don't have nearby facilities
	drop _merge

	append using $idir/sample_novars
	save $idir/sample_novars, replace
}
drop aux
save $idir/sample_novars, replace
keep if state=="FL" & year==2017
save $idir/sample_novars_FL, replace


/* NOTES:
distance is in km. 
analysis.dta has nhlat/nhlong also. some missings there. 
*/
cap log close
