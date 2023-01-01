cap log close
log using  $datadir/logs/preanalysis.log, replace
//scratch analysis on facility-level dataset

use $adir/facwithvars.dta, clear 


ivreghdfe logrestot (rnhrppd dchrppd = competitors* nbr*), a(county year)
ivreghdfe lognres_mcare (rnhrppd dchrppd = competitors* nbr*), a(county year)


cap log close