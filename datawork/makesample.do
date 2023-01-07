cap log close 
log using $datadir/logs/makesample.log, replace

// generate facility-level variables, merge with tracts

**************************************************
//facilities
use $rdir/analysis_wnotforprofit.dta, clear

rename (accpt_id latitude longitude) (facid lat lon)

loc xvars dchrppd rnhrppd lpnhrppd cnahrppd labor_expense
keep facid year state county lat lon `xvars' restot paymcare paymcaid

***
*generate facility-level variables

*** county
egen statecounty = group(state county)

*** facility-year identifier
egen facyr = group(facid year)

// *** fix occpct
// gen occpct = 100 * restot / totbeds

*** medicare residents
gen nres_mcare = (paymcare / 100) * restot

*** (non-)medicaid residents
gen nres_mcaid = (paymcaid / 100) * restot
gen nres_nonmcaid = restot - nres_mcaid
drop nres_mcaid paymcaid paymcare


loc yvars restot nres_mcare nres_nonmcaid

//winsorize staffing more aggressively
foreach vv of varlist `xvars'{
	winsor2 `vv', cuts(0 97) replace
}


//generate logs of staffing and quantity variables
foreach vv of varlist `yvars' `xvars'{
	gen log`vv' = log(`vv')
	replace log`vv' = log(0.05) if `vv'<0.05
}

// //generate lagged staffing
// foreach vv of varlist `xvars'{
// 	bys facid (year): gen `vv'_lag = `vv'[_n-1]
// 	bys facid (year): gen log`vv'_lag = log`vv'[_n-1]
// }


// gsort facid -year
// bys facid : replace county = county[_n-1] if missing(county)



compress
save $idir/fac.dta, replace //facility-year level
//
// use  $idir/fac.dta, clear //testing


clear
gen aux=1
save $idir/sample_novars.dta, replace
use $idir/facloc.dta, clear //created in findnbrs.do. just the coords

levelsof year, loc(yrs)
foreach yy of loc yrs{
	di "`yy'"
	use $idir/fac.dta if year==`yy', clear
	merge 1:m facid using "$idir/geonear_`yy'.dta" //created in findnbrs.do
	keep if _merge==3 // 2 for facilities that don't appear in that year
	drop _merge
	merge m:1 tractid using ${idir}/tract_`yy'.dta 
	keep if _merge==3 // 2 if tracts don't have nearby facilities
	drop _merge

	append using $idir/sample_novars
	save $idir/sample_novars, replace
}
drop aux

//log distance
gen logd = log(dist)
replace logd = log(0.5) if dist<0.5

compress
save $idir/sample_novars, replace

keep if state=="FL" 
save $idir/sample_novars_FL, replace

keep if state=="FL" & year==2017
save $idir/sample_novars_FL17, replace


/* NOTES:
distance is in km. 
analysis.dta has nhlat/nhlong also. some missings there. 
*/
cap log close
