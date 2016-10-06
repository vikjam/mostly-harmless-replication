clear all
set more off
eststo clear
capture version 14

/* Stata code for Figure 5.2.4 */

/* Download the data and unzip it */
shell curl -o outsourcingatwill_table7.zip "http://economics.mit.edu/~dautor/outsourcingatwill_table7.zip"
unzipfile outsourcingatwill_table7.zip

/*-------------*/
/* Import data */
/*-------------*/
use "table7/autor-jole-2003.dta", clear

/* Log total employment: from BLS employment & earnings */
gen lnemp = log(annemp)

/* Non-business-service sector employment from CBP */
gen nonemp  = stateemp - svcemp
gen lnnon   = log(nonemp)
gen svcfrac = svcemp / nonemp

/* Total business services employment from CBP */
gen bizemp = svcemp + peremp
gen lnbiz  = log(bizemp)

/* Time trends */
gen t  = year - 78 // Linear time trend
gen t2 = t^2       // Quadratic time trend

/* Restrict sample */
keep if inrange(year, 79, 95) & state != 98

/* Generate more aggregate demographics */
gen clp     = clg + gtc
gen a1624   = m1619 + m2024 + f1619 + f2024
gen a2554   = m2554 + f2554
gen a55up   = m5564 + m65up + f5564 + f65up
gen fem     = f1619 + f2024 + f2554 + f5564 + f65up
gen white   = rs_wm + rs_wf
gen black   = rs_bm + rs_bf
gen other   = rs_om + rs_of
gen married = marfem + marmale

/* Modify union variable */
replace unmem = . if inlist(year, 79, 81) // Don't interpolate 1979, 1981
replace unmem = unmem * 100               // Rescale into percentage

/* Diff-in-diff regression */
reg lnths lnemp admico_2 admico_1 admico0 admico1 admico2 admico3 mico4 admppa_2 admppa_1   ///
    admppa0 admppa1 admppa2 admppa3 mppa4 admgfa_2 admgfa_1 admgfa0 admgfa1 admgfa2 admgfa3 ///
    mgfa4 i.year i.state i.state#c.t, cluster(state)

coefplot, keep(admico_2 admico_1 admico0 admico1 admico2 admico3 mico4)                     ///
          coeflabels(admico_2 = "2 yr prior"                                                ///
                     admico_1 = "1 yr prior"                                                ///
                     admico0  = "Yr of adopt"                                               ///
                     admico1  = "1 yr after"                                                ///
                     admico2  = "2 yr after"                                                ///
                     admico3  = "3 yr after"                                                ///
                     mico4    = "4+ yr after")                                              ///
          vertical                                                                          ///
          yline(0)                                                                          ///
          ytitle("Log points")                                                              ///
          xtitle("Time passage relative to year of adoption of implied contract exception") ///
          addplot(line @b @at)                                                              ///
          ciopts(recast(rcap))                                                              ///
          rescale(100)                                                                      ///
          scheme(s1mono)
graph export "Figures/Figure 5-2-4.png", replace

/* End of script */
