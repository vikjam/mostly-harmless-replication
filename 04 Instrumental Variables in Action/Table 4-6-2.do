clear all
set more off
eststo clear
capture log close _all
capture version 13

/* Stata code for Table 4.6.2     */
/* Required additional packages   */
/* ivreg2: running IV regressions */
/* estout: for exporting tables   */

log using "Table 4-6-2-Stata.txt", name(table040602) text replace

/* Download data */
shell curl -o asciiqob.zip http://economics.mit.edu/files/397
unzipfile asciiqob.zip, replace

/* Import data */
infile lwklywge educ yob qob pob using asciiqob.txt, clear

/*Creat variables */
gen num_qob = yq(1900 + yob, qob)      // Quarter of birth
gen survey_qtr = yq(1980, 3)           // Survey quarter
gen age = survey_qtr - num_qob         // Age in quarter
gen agesq = age^2                      // Age^2
xi i.yob i.pob i.qob*i.yob i.qob*i.pob // Create all the dummies

/* Create locals for controls */
local col1_controls   "_Iyob_31 - _Iyob_39"
local col1_excl_instr "_Iqob_2 - _Iqob_4"

local col2_controls   "_Iyob_31 - _Iyob_39 age agesq"
local col2_excl_instr "_Iqob_2 - _Iqob_3" // colinear age qob: drop _Iqob_4

local col3_controls   "_Iyob_31 - _Iyob_39"
local col3_excl_instr "_Iqob_2 - _Iqob_4 _IqobXyob_2_31 - _IqobXyob_4_39"

local col4_controls   "_Iyob_31 - _Iyob_39 age agesq"
local col4_excl_instr "_Iqob_2 - _Iqob_3 _IqobXyob_2_31 - _IqobXyob_4_38" // colinear age qob: drop _Iqob_4, _IqobXyob_4_39

local col5_controls   "_Iyob_31 - _Iyob_39 _Ipob_2 - _Ipob_56"
local col5_excl_instr "_Iqob_2 - _Iqob_4 _IqobXyob_2_31 - _IqobXyob_4_39 _IqobXpob_2_2 - _IqobXpob_4_56"

local col6_controls   "_Iyob_31 - _Iyob_39 _Ipob_2 - _Ipob_56 age agesq"
local col6_excl_instr "_Iqob_2 - _Iqob_3 _IqobXyob_2_31 - _IqobXyob_4_38 _IqobXpob_2_2 - _IqobXpob_4_56" // colinear age qob: drop _Iqob_4, _IqobXyob_4_39

foreach model in "2sls" "liml" {
    if "`model'" == "2sls" {
        local ivreg2_mod ""
    }
    else {
        local ivreg2_mod "`model'"
    }
    foreach col in "col1" "col2" "col3" "col4" "col5" "col6" {
        display "Time for `col', `model'"
        display "Running ivreg2 lwklywge ``col'_controls' (educ = ``col'_excl_instr'), `ivreg2_mod'"
        eststo `col'_`model': ivreg2 lwklywge ``col'_controls' (educ = ``col'_excl_instr'), `ivreg2_mod'
        local num_instr = wordcount("`e(exexog)'")
        estadd local num_instr `num_instr'
        local fstat = round(`e(widstat)', 0.01)
        estadd local fstat `fstat'
    }
}

/* OLS for comparison */
eststo col1_ols: regress lwklywge educ i.yob
eststo col2_ols: regress lwklywge educ i.yob age agesq
eststo col5_ols: regress lwklywge educ i.yob i.pob
eststo col6_ols: regress lwklywge educ i.yob i.pob age agesq

/* Export results */
esttab, keep(educ)               ///
        b(3) se(3)               ///
        nostar se noobs mtitles  ///
        scalars(fstat num_instr) ///
        plain replace
eststo clear

log close table040602
/* End of file */
