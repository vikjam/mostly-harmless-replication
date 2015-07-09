clear all
set more off
eststo clear
capture version 13
/* Required programs      */
/* - estout: output table */

/* Stata code for Table 3.3.2*/

/* Download data */
shell curl -o nswre74.dta  http://economics.mit.edu/files/3828
shell curl -o cps1re74.dta http://economics.mit.edu/files/3824
shell curl -o cps3re74.dta http://economics.mit.edu/files/3825

/* End of script */
