gl vars state county year tractid mktpop facid restot nres_mcare ///
	nres_nonmcaid *labor_expense* competitors* nbr* dist_nbrfac

gl ivvars competitors_in20 competitors_in5 nbr_dchrppd nbr_rnhrppd nbr_lpnhrppd nbr_cnahrppd dist_nbrfac
***
// use $vars using $adir/factract.dta, clear 
//
// gcollapse (sum) mktpop (firstnm) nres_mcare restot labor_expense, by(facid year)
// binscatter2 mktpop labor_expense, line(none)
// binscatter2 nres_mcare mktpop, line(none)
// binscatter2 mktpop restot, line(none)

***
// use $vars using $adir/factract.dta, clear 
//
// gcollapse (mean) labor_expense nres_mcare (firstnm) mktpop , by(tractid year)
//
// binscatter2 mktpop labor_expense , line(none)
// binscatter2 mktpop nres_mcare , line(none)


***
use $vars using $adir/factract.dta, clear 
gduplicates tag tractid year, gen(nfacs)
gcollapse (firstnm) loglabor_expense nres_mcare (mean) mean_ncomp = nfacs (sum) sum_mktpop = mktpop (mean) mean_mktpop = mktpop (count) ntracts=loglabor_expense  , by(facid year)
binscatter2 nres_mcare sum_mktpop, line(none)
binscatter2 nres_mcare mean_mktpop, line(none)
binscatter2 nres_mcare mean_ncomp, line(none)
binscatter2 mean_ncomp nres_mcare, line(none)

binscatter2 nres_mcare ntracts, line(none)
binscatter2 nres_mcare ntracts if ntracts < 200, line(none)
save $idir/fac_mkt_stats, replace
***
use $vars using $adir/factract.dta, clear 
gduplicates tag facid year, gen(ntracts)

binscatter2 ntracts loglabor_expense, line(none)
binscatter2 ntracts nres_mcare, line(none)


use $vars using $adir/factract.dta, clear 

// use `vars' using $adir/factract_FL17.dta, clear 
// binscatter2 mktpop loglabor_expense, line(none)
gl qvar nres_mcare


egen ctymkt = group(state county year)
drop if missing(ctymkt)
if "$qvar"!="restot" {
	replace mktpop = mktpop / 3
}
// within each year, keep one population for each tract, then sum within county
bys tractid year: gen aux_trpop = mktpop if _n==1
replace aux_trpop = 0 if missing(aux_trpop)
bys ctymkt: egen ctypop = total(aux_trpop)
drop aux_trpop mktpop tract*

gduplicates drop ctymkt facid, force 

//drop if <=2 facilities in county
gduplicates tag ctymkt , g(dups)
drop if inlist(dups, 0, 1)
drop dups

gen share = $qvar / ctypop
bys ctymkt : egen inside_share = total(share)
gen outside_share = 1 - inside_share
gen deltas = log(share) - log(outside_share)


reg deltas loglabor_expense
reg deltas loglabor_expense_lag
ivreg2 deltas (loglabor_expense_lag=$ivvars)
ivreg2 deltas (loglabor_expense=$ivvars)
ivreg2 deltas i.year (loglabor_expense=$ivvars)
ivreghdfe deltas (loglabor_expense=$ivvars ), absorb(year)
ivreghdfe deltas (loglabor_expense=$ivvars ), absorb(ctymkt)
ivreghdfe deltas (loglabor_expense=$ivvars ), absorb(ctymkt year)


//demean within county markets
bys ctymkt : egen meanlabor_expense = mean(labor_expense)
gen demeanlabor_expense = labor_expense - meanlabor_expense
bys ctymkt : egen meannres_mcare = mean(nres_mcare)
gen demeannres_mcare = nres_mcare - meannres_mcare
binscatter2 demeannres_mcare demeanlabor_expense, line(none)


save $idir/county_markets.dta, replace
use $idir/county_markets.dta, clear

binscatter2 deltas loglabor_expense, line(none)
binscatter2 share loglabor_expense, line(none)
binscatter2 nres_mcare loglabor_expense, line(none)

gcollapse (mean) labor_expense loglabor_expense restot nres_mcare share (firstnm) ctypop inside_share (count) nfacs = ctypop, by(ctymkt)
binscatter2 nfacs ctypop, line(none)

binscatter2 loglabor_expense ctypop, line(none)
binscatter2 nres_mcare ctypop, line(none)
binscatter2 inside_share ctypop, line(none)
gen logshare = log(share)
binscatter2 share ctypop, line(none)
binscatter2 logshare ctypop, line(none)

