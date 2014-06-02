clear all
set more off
eststo clear
capture log close _all
capture version 13

/* Stata code for Table 3.3.2*/

log using "Table 3-3-2-Stata.txt", name(table030302) text replace

* /* Download data */
* shell /usr/local/bin/wget -O cps1re74.dta http://economics.mit.edu/files/3824
* shell /usr/local/bin/wget -O cps3re74.dta http://economics.mit.edu/files/3825
* shell /usr/local/bin/wget -O nswre74.dta http://economics.mit.edu/files/3828

/* Columns 2 and 1 */
use "nswre74.dta", clear
tabstat age ed black hisp married nodeg, by(treat) format(%9.2f)
tabstat re74 re75, by(treat) format(%9.0f)

/* Column 3 */
use "cps1re74.dta", clear
tabstat age ed black hisp married nodeg if treat == 0, format(%9.2f)
tabstat re74 re75 if treat == 0, format(%9.0f)

/* Column 4 */
use "cps3re74.dta", clear
tabstat age ed black hisp married nodeg if treat == 0, format(%9.2f)
tabstat re74 re75 if treat == 0, format(%9.0f)

log close table030302
/* End of script */
exit
