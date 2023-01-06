

import delim "$adir/elasticities1_1_3_1.csv", clear
rename id facyr
rename elast el_le_mcare
merge 1:1 facyr using $idir/fac.dta
drop _merge

**
use $idir/fac.dta, clear
count if missing(labor_expense)
tab year if missing(labor_expense)
tab year if missing(nres_mcare)
tab year if missing(avg_dailycensus)

use  $adir/factract${testtag}.dta, clear //testing
drop avg_dailycensus
save $adir/factract.dta, replace
**


save $adir/elasticities, replace

import delim "$adir/elasticities2_1_3_1.csv", clear
rename id facyr
rename elast el_le_nonmcaid
merge facyr using $adir/elasticities
drop _merge

