clear all
set more off
eststo clear
capture version 13

/* Pull data from the 'Mostly Harmless' website */
/* http://economics.mit.edu/faculty/angrist/data1/mhe/krueger */
shell curl -o webstar.dta http://economics.mit.edu/files/3827/

/* Load downloaded data */
use webstar.dta, clear

/* Create variables in table */
gen white_asian = (inlist(srace, 1, 3)) if !missing(srace)
label var white_asian "White/Asian"

/* Calculate percentiles of test scores */
local testscores "treadssk tmathssk treadss1 tmathss1 treadss2 tmathss2 treadss3 tmathss3"
foreach var of varlist `testscores' {
	xtile pct_`var' = `var', nq(100)
}
egen avg_pct = rowmean(pct_*)
label var avg_pct "Percentile score in kindergarten"

/* End of file */
exit
