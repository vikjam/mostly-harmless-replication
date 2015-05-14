clear all
set more off

/* Set random seed for replication */
set seed 42

/* Number of random variables */
local nobs = 100

set obs `nobs'

gen x         = runiform()
gen y_linear  = x   + (x > 0.5) * 0.25 + rnormal(0, 0.1)
gen y_nonlin  = x^4 + (x > 0.5) * 0.25 + rnormal(0, 0.1)
gen y_mistake = 8 * (x - 0.5)^3        + rnormal(0, 0.1)

graph twoway (lfit y_linear x if x < 0.5, lcolor(black))          ///
             (lfit y_linear x if x > 0.5, lcolor(black))          ///
             (scatter y_linear x, msymbol(circle) mcolor(black)), ///
                title("A. Linear E[Y{sub:0i}|X{sub:i}]")          ///
                ytitle("Outcome")                                 ///
                xtitle("x")                                       ///
                xline(0.5, lpattern(dash))                        ///
                scheme(s1mono)                                    ///
                legend(off)

graph twoway (qfit y_nonlin x if x < 0.5, lcolor(black))          ///
             (qfit y_nonlin x if x > 0.5, lcolor(black))          ///
             (scatter y_nonlin x, msymbol(circle) mcolor(black)), ///
                title("B. Nonlinear E[Y{sub:0i}|X{sub:i}]")       ///
                ytitle("Outcome")                                 ///
                xtitle("x")                                       ///
                xline(0.5, lpattern(dash))                        ///
                scheme(s1mono)                                    ///
                legend(off)

graph twoway (lfit y_mistake x if x < 0.5, lcolor(black))           ///
             (lfit y_mistake x if x > 0.5, lcolor(black))           ///
             (function y = 8 * (x - 0.5)^3, lpattern(dash))         ///
             (scatter y_mistake x, msymbol(circle) mcolor(black)),  ///
                title("A. Nonlinearity mistaken for discontinuity") ///
                ytitle("Outcome")                                   ///
                xtitle("x")                                         ///
                xline(0.5, lpattern(dash))                          ///
                scheme(s1mono)                                      ///
                legend(off)

/* End of file */
exit
