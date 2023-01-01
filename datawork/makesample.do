cap log close 
log using $datadir/logs/makesample.log, replace

// generate facility-level variables, merge with tracts

**************************************************
//facilities
use $rdir/analysis.dta, clear

rename (accpt_id latitude longitude) (facid lat lon)

loc xvars dchrppd rnhrppd lpnhrppd cnahrppd labor_expense
loc qvars avg_dailycensus restot paymcare paymcaid
drop if inlist(., restot) //very few have missing restot so just dropping
keep facid year state county cz lat lon ///
	totbeds `xvars' `qvars'
	

*****
//generate facility-level variables

*** fix occpct
gen occpct = 100 * restot / totbeds

*** medicare residents
gen nres_mcare = (paymcare / 100) * restot

*** (non-)medicaid residents
gen nres_mcaid = (paymcaid / 100) * restot
gen nres_nonmcaid = restot - nres_mcaid


loc yvars restot nres_mcare

//winsorize staffing more aggressively
foreach vv of varlist `xvars'{
// 	histogram `vv', freq yla(, format(%5.0f))
// 	graph export "$datadir/temp/hist_`vv'.png", replace
	winsor2 `vv', cuts(0 97) replace
// 	histogram `vv', freq yla(, format(%5.0f))
// 	graph export "$datadir/temp/hist_win_`vv'.png", replace
}


//labor expense per bed
gen lepb = labor_expense * occpct /100

loc xvars `xvars' lepb

//generate logs of staffing and quantity variables
foreach vv of varlist `yvars' `xvars'{
	gen log`vv' = log(`vv')
	replace log`vv' = log(0.05) if `vv'<0.05
}

//generate lagged staffing
foreach vv of varlist `xvars'{
	bys facid (year): gen `vv'_lag = `vv'[_n-1]
	bys facid (year): gen log`vv'_lag = log`vv'[_n-1]
}

// dummy for high labor_expense
sum labor_expense, d
gen highle100 = labor_expense > 100
gen highlep95 = labor_expense > `r(p95)'


//generate RN fraction
gen rn_frac = rnhrppd / dchrppd 
replace rn_frac = 1 if rn_frac > 1


compress
save $idir/fac.dta, replace
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
compress
save $idir/sample_novars, replace
keep if state=="FL" & year==2017
save $idir/sample_novars_FL17, replace


/* NOTES:
distance is in km. 
analysis.dta has nhlat/nhlong also. some missings there. 
*/
cap log close
