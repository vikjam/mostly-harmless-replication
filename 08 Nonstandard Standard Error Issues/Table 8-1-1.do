clear all
set more off
eststo clear
capture log close _all
capture version 13

/* Set random seed for replication */
set seed 42

/* Define program for use with -simulate- command */
capture program drop clusterbias
program define clusterbias, rclass
    version 13.1

    local N       = 30
    local r       = 0.5
    local N_1     = 10
    local N_0     = `N' - `N_1'
    local h_i     = `N_1' / `N'
    local mu_0    = 0
    local mu_1    = 0
    local sigma_0 = 0.5
    local sigma_1 = 1
    local beta_1  = 0

    clear
    set obs `N'
    gen D           = (_n <= `N_1')
    gen epsilon     = rnormal(`mu_0', `sigma_0') if D == 0
    replace epsilon = rnormal(`mu_1', `sigma_1') if D == 1
    gen Y           = `beta_1' * D + epsilon

    /* Conventional */
    regress Y D
    matrix B           = e(b)
    local b1           = B[1, 1]
    matrix C           = e(V)
    local conventional = sqrt(C[1, 1])
    predict ehat, residuals

    /* HC1 */
    regress Y D, vce(robust)
    matrix C  = e(V)
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
    return scalar hc1          = `hc1'
    return scalar hc2          = `hc2'
    return scalar hc3          = `hc3'

end

/* Run simulation */
simulate b1           = r(b1)           ///
         conventional = r(conventional) ///
         hc1          = r(hc1)          ///
         hc2          = r(hc2)          ///
         hc3          = r(hc3), reps(100): clusterbias

gen max_conv_hc1 = max(conventional, hc1)
gen max_conv_hc2 = max(conventional, hc2)
gen max_conv_hc3 = max(conventional, hc3)

/* End of file */
exit
