clear all
set more off
/* Stata code for Figure 4-1-1 */

/* Download data */
shell curl -o asciiqob.zip http://economics.mit.edu/files/397
unzipfile asciiqob.zip, replace

/* Import data */
infile lwklywge educ yob qob pob using asciiqob.txt, clear

/* Use Stata date formats */
gen yqob = yq(1900 + yob, qob)
format yqob %tq

/* Collapse by quarter of birth */
collapse (mean) educ (mean) lwklywge (mean) qob, by(yqob)

/* Plot data */
graph twoway (line educ yqob, lcolor(black))                                        ///
             (scatter educ yqob if qob == 1,                                        ///
                mlabel(qob) msize(small) msymbol(S) mcolor(black))                  ///
             (scatter educ yqob if qob != 1,                                        ///
                mlabel(qob) msize(small) msymbol(Sh) mcolor(black)),                ///
                    xlabel(, format(%tqY))                                          ///
                    title("A. Average education by quarter of birth (first stage)") ///
                    ytitle("Years of education")                                    ///
                    xtitle("Year of birth")                                         ///
                    legend(off)                                                     ///
                    name(educ)                                                      ///
                    scheme(s1mono)

graph twoway (line lwklywge yqob, lcolor(black))                                       ///
             (scatter lwklywge yqob if qob == 1,                                       ///
                mlabel(qob) msize(small) msymbol(S) mcolor(black))                     ///
             (scatter lwklywge yqob if qob != 1,                                       ///
                mlabel(qob) msize(small) msymbol(Sh) mcolor(black)),                   ///
                    xlabel(, format(%tqY))                                             ///
                    title("B. Average weekly wage by quarter of birth (reduced form)") ///
                    ytitle("Log weekly earnings")                                      ///
                    xtitle("Year of birth")                                            ///
                    legend(off)                                                        ///
                    name(lwklywge)                                                     ///
                    scheme(s1mono)

/* Compare graphs */
graph combine educ lwklywge,  ///
    col(1)                    ///
    xsize(4) ysize(6)         ///
    graphregion(margin(zero)) ///
    scheme(s1mono)

graph export "Figure 4-1-1-Stata.pdf", replace

/* End of file */
