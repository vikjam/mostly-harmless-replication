clear all
set more off
eststo clear
/* Required programs      */
/* - estout: output table */

/* Stata code for Table 3.3.2*/

* Store URL to MHE Data Archive in local
local base_url = "https://economics.mit.edu/sites/default/files/inline-files"

/* Store variable list in local */
local summary_var "age ed black hisp nodeg married re74 re75"
local pscore_var "age age2 ed black hisp married nodeg re74 re75"

/* Columns 1 and 2 */
use "`base_url'/nswre74.dta", clear
eststo column_1, title("NSW Treat"): estpost summarize `summary_var' if treat == 1
eststo column_2, title("NSW Control"): estpost summarize `summary_var' if treat == 0

/* Column 3 */
use "`base_url'/cps1re74.dta", clear
eststo column_3, title("Full CPS-1"): estpost summarize `summary_var' if treat == 0

/* Column 5 */
probit treat `pscore_var'
predict p_score, pr
keep if p_score > 0.1 & p_score < 0.9

eststo column_5, title("P-score CPS-1"): estpost summarize `summary_var' if treat == 0

/* Column 4 */
use "`base_url'/cps3re74.dta", clear
eststo column_4, title("Full CPS-3"): estpost summarize `summary_var' if treat == 0

/* Column 6 */
probit treat `pscore_var'
predict p_score, pr
keep if p_score > 0.1 & p_score < 0.9

eststo column_6, title("P-score CPS-3"): estpost summarize `summary_var' if treat == 0

/* Label variables */
label var age "Age"
label var ed "Years of Schooling"
label var black "Black"
label var hisp "Hispanic"
label var nodeg "Dropout"
label var married "Married"
label var re74 "1974 earnings"
label var re75 "1975 earnings"

/* Output Table */
esttab column_1 column_2 column_3 column_4 column_5 column_6, ///
    label mtitle                                              ///
    cells(mean(label(Mean) fmt(2 2 2 2 2 2 0 0)))

/* End of script */
exit
