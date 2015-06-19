clear all
set more off
eststo clear
capture log close _all
capture version 13

/* Stata code for Table 3.3.2*/

/* Download data */
* shell curl -o nswre74.dta  http://economics.mit.edu/files/3828
* shell curl -o cps1re74.dta http://economics.mit.edu/files/3824
* shell curl -o cps3re74.dta http://economics.mit.edu/files/3825

/* Columns 2 and 1 */
use "nswre74.dta", clear
tabstat age ed black hisp married nodeg, by(treat) format(%9.2f)
tabstat re74 re75, by(treat) format(%9.0f) stats(mean count)

/* Column 3 */
use "cps1re74.dta", clear
tabstat age ed black hisp married nodeg if treat == 0, format(%9.2f)
tabstat re74 re75 if treat == 0, format(%9.0f) stats(mean count)

/* Column 5 */
probit treat age age2 ed black hisp married nodeg re74 re75
predict p_score, pr
keep if p_score > 0.1 & p_score < 0.9

tabstat age ed black hisp married nodeg if treat == 0, format(%9.2f)
tabstat re74 re75 if treat == 0, format(%9.0f) stats(mean count)

/* Column 4 */
use "cps3re74.dta", clear
tabstat age ed black hisp married nodeg if treat == 0, format(%9.2f)
tabstat re74 re75 if treat == 0, format(%9.0f) stats(mean count)

/* Column 6 */
probit treat age age2 ed black hisp married nodeg re74 re75
predict p_score, pr
keep if p_score > 0.1 & p_score < 0.9

tabstat age ed black hisp married nodeg if treat == 0, format(%9.2f)
tabstat re74 re75 if treat == 0, format(%9.0f) stats(mean count)

/* End of script */
exit
