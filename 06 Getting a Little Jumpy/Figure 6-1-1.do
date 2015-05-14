clear all
set more off

/* Set random seed for replication */
set seed 1149

/* Number of random variables */
local nobs = 100

set obs `nobs'

gen x         = runiform()
gen y_linear  = x + (x > 0.5) * 0.25 + rnormal(0, 0.1)
gen y_nonlin  = 0.5 * sin(6 * (x - 0.5)) + 0.5 + (x > 0.5) * 0.25 + rnormal(0, 0.1)
gen y_mistake = 1 / (1 + exp(-25 * (x - 0.5))) + rnormal(0, 0.1)

graph twoway (lfit y_linear x if x < 0.5, lcolor(black))                        ///
             (lfit y_linear x if x > 0.5, lcolor(black))                        ///
             (scatter y_linear x, msize(vsmall) msymbol(circle) mcolor(black)), ///
                title("A. Linear E[Y{sub:0i}|X{sub:i}]")                        ///
                ytitle("Outcome")                                               ///
                xtitle("x")                                                     ///
                xline(0.5, lpattern(dash))                                      ///
                scheme(s1mono)                                                  ///
                legend(off)                                                     ///
                saving(y_linear, replace)

graph twoway (qfit y_nonlin x if x < 0.5, lcolor(black))                        ///
             (qfit y_nonlin x if x > 0.5, lcolor(black))                        ///
             (scatter y_nonlin x, msize(vsmall) msymbol(circle) mcolor(black)), ///
                title("B. Nonlinear E[Y{sub:0i}|X{sub:i}]")                     ///
                ytitle("Outcome")                                               ///
                xtitle("x")                                                     ///
                xline(0.5, lpattern(dash))                                      ///
                scheme(s1mono)                                                  ///
                legend(off)                                                     ///
                saving(y_nonlin, replace)

graph twoway (lfit y_mistake x if x < 0.5, lcolor(black))                        ///
             (lfit y_mistake x if x > 0.5, lcolor(black))                        ///
             (function y = 1 / (1 + exp(-25 * (x - 0.5))), lpattern(dash))       ///
             (scatter y_mistake x, msize(vsmall) msymbol(circle) mcolor(black)), ///
                title("C. Nonlinearity mistaken for discontinuity")              ///
                ytitle("Outcome")                                                ///
                xtitle("x")                                                      ///
                xline(0.5, lpattern(dash))                                       ///
                scheme(s1mono)                                                   ///
                legend(off)                                                      ///
                saving(y_mistake, replace)

graph combine y_linear.gph y_nonlin.gph y_mistake.gph, ///
    col(1)                                             ///
    xsize(4) ysize(6)                                  ///
    graphregion(margin(zero))                          ///
    scheme(s1mono)
graph export "Figure 6-1-1-Stata.png", replace

/* End of file */
exit
