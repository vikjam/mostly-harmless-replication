clear all
set more off

/* Stata code for Table 7.1.1 */

/* Download data */
shell curl -o angcherfer06.zip http://economics.mit.edu/files/384
unzipfile angcherfer06.zip, replace

/* Create matrix to store all the results */
matrix R = J(6, 10, .)
matrix rownames R = 80 80se 90 90se 00 00se
matrix colnames R = Obs Mean SD 10 25 50 75 90 Coef MSE

/* Loop through the years to get the results */
foreach year in "80" "90" "00" {
	/* Load data */
	use "Data/census`year'.dta", clear

	/* Summary statistics */
	summ logwk
	matrix R[rownumb(R, "`year'"), colnumb(R, "Obs")]  = r(N)
	matrix R[rownumb(R, "`year'"), colnumb(R, "Mean")] = r(mean)
	matrix R[rownumb(R, "`year'"), colnumb(R, "SD")]   = r(sd)

	/* Define education variables */
	gen highschool = 1 if (educ == 12)
	gen college    = 1 if (educ == 16)

	/* Run quantile regressions */
	foreach tau of numlist 10 25 50 75 90 {
		qreg logwk educ black exper exper2 [pweight = perwt], q(`tau')
		matrix R[rownumb(R, "`year'"), colnumb(R, "`tau'")]   = _b[edu]
		matrix R[rownumb(R, "`year'se"), colnumb(R, "`tau'")] = _se[edu]
	}

	/* Run OLS */
	regress logwk educ black exper exper2 [pweight = perwt]
	matrix R[rownumb(R, "`year'"), colnumb(R, "Coef")]   = _b[edu]
	matrix R[rownumb(R, "`year'se"), colnumb(R, "Coef")] = _se[edu]
	matrix R[rownumb(R, "`year'"), colnumb(R, "MSE")]    = e(rmse)
}

/* List results */
matlist R

/* End of file */
