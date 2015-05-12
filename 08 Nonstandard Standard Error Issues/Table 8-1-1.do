clear all
set more off
eststo clear
capture log close _all
capture version 13

/* Set random seed for replication */
set seed 42

/* Number of simulations */
local reps = 25000

/* Define program for use with -simulate- command */
capture program drop clusterbias
program define clusterbias, rclass
    syntax, [sigma(real 1)]

    /* Set parameters of the simulation */
    local N   = 30
    local r   = 0.9
    local N_1 = `r' * 30

    clear
    set obs `N'
    gen D           = (`N_1' < _n)
    gen epsilon     = rnormal(0, `sigma') if D == 0
    replace epsilon = rnormal(0, 1)       if D == 1
    gen Y           = 0 * D + epsilon

    /* Conventional */
    regress Y D
    matrix B           = e(b)
    local b1           = B[1, 1]
    matrix C           = e(V)
    local conventional = sqrt(C[1, 1])

    /* HC0 and HC1 */
    regress Y D, vce(robust)
    matrix C  = e(V)
    local hc0 = sqrt(((`N' - 2) / `N') * C[1, 1]) // Stata doesn't have hc0
    local hc1 = sqrt(C[1, 1])

    /* HC2 */
    regress Y D, vce(hc2)
    matrix C  = e(V)
    local hc2 = sqrt(C[1, 1])

    /* HC3 */
    regress Y D, vce(hc3)
    matrix C  = e(V)
    local hc3 = sqrt(C[1, 1])

    /* Return results from program */
    return scalar b1           = `b1'
    return scalar conventional = `conventional'
    return scalar hc0          = `hc0'
    return scalar hc1          = `hc1'
    return scalar hc2          = `hc2'
    return scalar hc3          = `hc3'
end

/* Run simulations */

/*----------------------*/
/* Panel A: sigma = 0.5 */
/*----------------------*/
simulate b1           = r(b1)           ///
         conventional = r(conventional) ///
         hc0          = r(hc0)          ///
         hc1          = r(hc1)          ///
         hc2          = r(hc2)          ///
         hc3          = r(hc3), reps(`reps'): clusterbias, sigma(0.50)

gen max_conv_hc0 = max(conventional, hc0)
gen max_conv_hc1 = max(conventional, hc1)
gen max_conv_hc2 = max(conventional, hc2)
gen max_conv_hc3 = max(conventional, hc3)

/* Mean and standard deviations of simulation results */
tabstat *, stat(mean sd) column(stat) format(%9.3f) 

/* Rejection rates */
foreach stderr of varlist conventional hc* max_*_hc* {
    gen z_`stderr'_reject = (2 * normal(-abs(b1 / `stderr')) <= 0.05)
    gen t_`stderr'_reject = (2 * ttail(30 - 2, abs(b1 / `stderr')) <= 0.05)
}
/* Normal */
tabstat z_*_reject, stat(mean) column(stat) format(%9.3f)
/* t-distribution */ 
tabstat t_*_reject, stat(mean) column(stat) format(%9.3f) 

/*-----------------------*/
/* Panel B: sigma = 0.85 */
/*-----------------------*/
simulate b1           = r(b1)           ///
         conventional = r(conventional) ///
         hc0          = r(hc0)          ///
         hc1          = r(hc1)          ///
         hc2          = r(hc2)          ///
         hc3          = r(hc3), reps(`reps'): clusterbias, sigma(0.85)

gen max_conv_hc0 = max(conventional, hc0)
gen max_conv_hc1 = max(conventional, hc1)
gen max_conv_hc2 = max(conventional, hc2)
gen max_conv_hc3 = max(conventional, hc3)

/* Mean and standard deviations of simulation results */
tabstat *, stat(mean sd) column(stat)

/* Rejection rates */
foreach stderr of varlist conventional hc* max_*_hc* {
    gen z_`stderr'_reject = (2 * normal(-abs(b1 / `stderr')) <= 0.05)
    gen t_`stderr'_reject = (2 * ttail(30 - 2, abs(b1 / `stderr')) <= 0.05)
}
/* Normal */
tabstat z_*_reject, stat(mean) column(stat) format(%9.3f)
/* t-distribution */ 
tabstat t_*_reject, stat(mean) column(stat) format(%9.3f) 

/*--------------------*/
/* Panel C: sigma = 1 */
/*--------------------*/
simulate b1           = r(b1)           ///
         conventional = r(conventional) ///
         hc0          = r(hc0)          ///
         hc1          = r(hc1)          ///
         hc2          = r(hc2)          ///
         hc3          = r(hc3), reps(`reps'): clusterbias

gen max_conv_hc0 = max(conventional, hc0)
gen max_conv_hc1 = max(conventional, hc1)
gen max_conv_hc2 = max(conventional, hc2)
gen max_conv_hc3 = max(conventional, hc3)

/* Mean and standard deviations of simulation results */
tabstat *, stat(mean sd) column(stat)

/* Rejection rates */
foreach stderr of varlist conventional hc* max_*_hc* {
    gen z_`stderr'_reject = (2 * normal(-abs(b1 / `stderr')) <= 0.05)
    gen t_`stderr'_reject = (2 * ttail(30 - 2, abs(b1 / `stderr')) <= 0.05)
}
/* Normal */
tabstat z_*_reject, stat(mean) column(stat) format(%9.3f)
/* t-distribution */ 
tabstat t_*_reject, stat(mean) column(stat) format(%9.3f) 

/* End of file */
exit
