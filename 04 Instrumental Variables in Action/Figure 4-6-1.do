clear all
set more off
capture log close _all
capture version 13.1 // Note this script has only been tested in Stata 13.1

/* Stata code for Figure 4.6.1 */

/* Log output*/
log using "Figure 4-6-1-Stata.txt", name(figure040601) text replace

/* Set random seed for replication */
set seed 42

/* Define program for use with -simulate- command */
capture program drop weakinstr
program define weakinstr, rclass
    version 13.1

    /* Draw from random normal with correlation of 0.8 and variance of 1 */
    matrix C = (1, 0.8 \ 0.8, 1)
    quietly drawnorm eta xi, n(1000) corr(C) clear

    /* Create a random instruments */
    forvalues i = 1/20 {
        quietly gen z`i' = rnormal()
    }

    /* Endogenous x only based on z1 while z2-z20 irrelevant */
    quietly gen x = 0.1*z1 + xi
    quietly gen y = x + eta

    /* OLS */
    quietly: regress y x
    matrix OLS = e(b)

    /* 2SLS */
    quietly: ivregress 2sls y (x = z*)
    matrix TSLS = e(b)

    /* LIML */
    quietly: ivregress liml y (x = z*)
    matrix LIML = e(b)

    /* Return results from program */
    return scalar ols  = OLS[1, 1]
    return scalar tsls = TSLS[1, 1]
    return scalar liml = LIML[1, 1]

end

/* Run simulation */
simulate coefols = r(ols) coeftsls = r(tsls) coefliml = r(liml), reps(10000): weakinstr

/* Create empirical CDFs */
cumul coefols, gen(cols)
cumul coeftsls, gen(ctsls)
cumul coefliml, gen(climl)
stack cols coefols ctsls coeftsls climl coefliml, into(c coef) wide clear
label var coef "beta"
label var cols "OLS"
label var ctsls "2SLS"
label var climl "LIML"

/* Graph results */
graph set window fontface "Palatino"
line cols ctsls climl coef if inrange(coef, 0, 2.5),                        ///
     sort                                                                   ///
     lpattern(solid dash longdash_dot)                                      ///
     lwidth(medthick medthick medthick)                                     ///
     lcolor("228 26 28" "55 126 184" "77 175 74")                           ///
     scheme(s1color)                                                        ///
     legend(rows(1) region(lwidth(none)))                                   ///
     xline(1, lcolor("189 189 189") lpattern(shortdash) lwidth(medthick))   ///
     yline(0.5, lcolor("189 189 189") lpattern(shortdash) lwidth(medthick)) ///
     xtitle("estimated {&beta}")                                            ///
     ytitle("F{subscript:n}")
graph export "Figure 4-6-1-Stata.eps", replace

log close figure040601
/* End of script */
