clear all
set more off
eststo clear
capture log close _all
capture version 13

/* Stata code for Table 3.3.2*/
/* !! Can't find right data !! */

/* Download data */
* shell curl -o asciiqob.zip http://economics.mit.edu/files/397
* unzipfile asciiqob.zip, replace

/* Import data */
infile lwklywge educ yob qob pob using asciiqob.txt, clear

/* Panel A */
/* Old-fashioned standard errors */
regress lwklywge educ
/* Robust standard errors */
regress lwklywge educ, robust

/* Collapse data for Panel B (counting only if in sample) */
gen count = 1 if e(sample)
collapse (sum) count (mean) lwklywge, by(educ)

/* Old-fashioned standard errors */
regress lwklywge educ [aweight = count]
/* Robust standard errors */
regress lwklywge educ [aweight = count], robust

/* End of file */
exit
