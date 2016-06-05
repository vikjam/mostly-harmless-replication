clear all
set more off

/* Stata code for Table 7.1.1 */

/* Download data */
shell curl -o angcherfer06.zip http://economics.mit.edu/files/384
unzipfile angcherfer06.zip, replace

foreach year of numlist 80 90 00 {
	/* Load data */
	use "Data/census`year'.dta"

	/* Summary statistics */
	summ logwk [pweight = perwt]

	/* Education variables */
	gen highschool = 1 if (educ == 12)
	gen college    = 1 if (educ == 16)

	/* Run quantile regressions */
	foreach tau of numlist 10 25 50 75 90 {
		qreg logwk educ black exper exper2 [pweight = perwt], q(`tau')
	}

	/* Run OLS */
	regress logwk educ black exper exper2 [pweight = perwt]
}

/* End of file */
