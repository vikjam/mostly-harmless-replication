clear all
set more off
/* Stata code for Figure 5.2.4 */

/* Download data */
shell curl -o final4.dta http://economics.mit.edu/files/1359
shell curl -o final5.dta http://economics.mit.edu/files/1358

/* Import data */
use "final5.dta", clear

replace avgverb= avgverb-100 if avgverb>100
replace avgmath= avgmath-100 if avgmath>100

gen func1 = c_size  / (floor((c_size - 1) / 40) + 1)
gen func2 = cohsize / (floor(cohsize      / 40) + 1)

replace avgverb  = . if verbsize == 0
replace passverb = . if verbsize == 0

replace avgmath  = . if mathsize == 0
replace passmath = . if mathsize == 0

/* Sample restrictions */
keep if 1 < classize & classize < 45 & c_size > 5
keep if c_leom == 1 & c_pik < 3

sum avgverb
sum avgmath

mmoulton avgverb classize, cluvar(schlcode)
mmoulton avgverb classize tipuach, cluvar(schlcode)
mmoulton avgverb classize tipuach c_size, clu(schlcode)
mmoulton avgmath classize, cluvar(schlcode)
mmoulton avgmath classize tipuach, cluvar(schlcode)
mmoulton avgmath classize tipuach c_size, clu(schlcode)

/* End of script */
exit
