// use $idir/fac.dta, clear
//
//
// binscatter2 nres_mcare labor_expense, line(none)
// binscatter2 nres_mcare lepb, line(none)
//
//
// gen auxle = rnhrppd + cnahrppd + lpnhrppd
// gen auxfac = auxle / labor_expense
// sum auxfac

***********
//
//
// sum labor_expense, d
// gen high_labexp = labor_expense > 100
//
//
// twoway ///
// hist occpct if high_labexp, color(maroon%50) width(1) || ///
// hist occpct if !high_labexp, color(navy%50) width(1)
//
//
// sum occpct, d
//
// cap drop lepb
//
// gen nres_nonmcaid = restot - nres_mcaid
//
// binscatter2 nres_mcare lepb, line(none)
// binscatter2 nres_nonmcaid lepb, line(none)
//
//
// binscatter2 nres_mcare labor_expense if !high_labexp, line(none)
// binscatter2 nres_mcare labor_expense if high_labexp, line(none)
// binscatter2 restot labor_expense, line(none)
// binscatter2 occpct labor_expense, line(none)
//
// binscatter2 avg_dailycensus labor_expense_lag, line(none)
//
//
// binscatter2 nres_nonmcaid labor_expense_lag, line(none)
//
// binscatter2 nres_mcare loglabor_expense_lag, line(none)


//explore high-expenditure facilities




cap log close
log using  $datadir/logs/eda.log, replace
//scratch data exploration

use $adir/facwithvars.dta, clear 

loc yvars restot nres_mcare
loc xvars dchrppd cnahrppd lpnhrppd rnhrppd

foreach yvar of varlist `yvars'{
	gen log`yvar' = log(`yvar')
}

//binscatter log(quantity) against log(staffing)
foreach xvar of varlist `xvars'{
	foreach yvar of varlist `yvars'{
		binscatter2 log`yvar' log`xvar', line(none)
		graph export "$datadir/temp/bsc_`yvar'_`xvar'.png", replace
	}
}

ivreghdfe logrestot (rnhrppd dchrppd = competitors* nbr*), a(county year)
ivreghdfe lognres_mcare (rnhrppd dchrppd = competitors* nbr*), a(county year)


cap log close









