clear all
set more off

/* Download data */
* shell curl -o final4.dta http://economics.mit.edu/files/1359
* shell curl -o final5.dta http://economics.mit.edu/files/1358

/* Import data */
use "final4.dta", clear

keep if 1 < classize & classize < 45 & c_size > 5
keep if c_leom == 1 & c_pik < 3

collapse classize, by(c_size)
gen m = c_size / (floor((c_size - 1)/40) + 1)

graph twoway (line classize c_size, lcolor(black))                                                 ///
             (function y = x / (floor((x - 1)/40) + 1), range(1 220) lpattern(dash) lcolor(black)), ///
                xlabel(20(20)220)                                                                   ///
                title("B. Fourth grade")                                                            ///
                ytitle("Class size")                                                                ///
                xtitle("Enrollment count")                                                          ///
                legend(label(1 "Actual class size") label(2 "Maimonides Rule"))                     ///
                scheme(s1mono)                                                                      ///
                saving(fourthgrade.gph, replace)

use "final5.dta", clear

keep if 1 < classize & classize < 45 & c_size > 5
keep if c_leom == 1 & c_pik < 3

collapse classize, by(c_size)
gen m = c_size / (floor((c_size - 1)/40) + 1)

graph twoway (line classize c_size, lcolor(black))                                                 ///
             (function y = x / (floor((x - 1)/40) + 1), range(1 220) lpattern(dash) lcolor(black)), ///
                xlabel(20(20)220)                                                                   ///
                title("A. Fifth grade")                                                             ///
                ytitle("Class size")                                                                ///
                xtitle("Enrollment count")                                                          ///
                legend(label(1 "Actual class size") label(2 "Maimonides Rule"))                     ///
                scheme(s1mono)                                                                      ///
                saving(fifthgrade.gph, replace)

graph combine fifthgrade.gph fourthgrade.gph,          ///
    col(1)                                             ///
    xsize(4) ysize(6)                                  ///
    graphregion(margin(zero))                          ///
    scheme(s1mono)
graph export "Figure 6-2-1-Stata.png", replace

/* End of file */
exit
