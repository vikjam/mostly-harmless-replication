clear all
set more off
capture log close _all
capture version 13

log using "Figure 4-6-1-Stata.txt", name(figure040601) text replace

local nsims = 10000
set seed 42
set matsize `nsims'

matrix COEF = J(`nsims', 3, .)

matrix C = (1, 0.8 \ 0.8, 1)

forvalues sim = 1/`nsims' {

    display _n "Simulation `sim'"
    quietly drawnorm eta xi, n(1000) corr(C) clear

    forvalues i = 1/20 {
        quietly gen z`i' = rnormal()
    }

    quietly gen x = 0.1*z1 + xi
    quietly gen y = x + eta

    quietly: regress y x
    matrix OLS = e(b)

    quietly: ivregress 2sls y (x = z*)
    matrix TSLS = e(b)

    quietly: ivregress liml y (x = z*)
    matrix LIML = e(b)

    matrix COEF[`sim', 1] = OLS[1, 1]
    matrix COEF[`sim', 2] = TSLS[1, 1]
    matrix COEF[`sim', 3] = LIML[1, 1]

}

clear
svmat COEF, names(coef)
rename coef1 coefols
rename coef2 coeftsls
rename coef3 coefliml

cumul coefols, gen(cols)
cumul coeftsl, gen(ctsls)
cumul coefliml, gen(climl)
stack cols coefols ctsls coeftsls climl coefliml, into(c coef) wide clear
label var coef "beta"
label var cols "OLS"
label var ctsls "2SLS"
label var climl "LIML"

graph set window fontface "Palatino"
line cols ctsls climl coef if inrange(coef, 0, 2.5),                       ///
    sort                                                                   ///
    lpattern(solid dash longdash_dot)                                      ///
    lwidth(medthick medthick medthick)                                     ///
    lcolor("228 26 28" "55 126 184" "77 175 74")                           ///
    scheme(s1color)                                                        ///
    legend(rows(1))                                                        ///
    xline(1, lcolor("189 189 189") lpattern(shortdash) lwidth(medthick))   ///
    yline(0.5, lcolor("189 189 189") lpattern(shortdash) lwidth(medthick)) ///
    xtitle("estimated {&beta}")                                            ///
    ytitle("empirical F")
graph export "iv_mc.eps", replace

log close figure040601
/* End of script */
