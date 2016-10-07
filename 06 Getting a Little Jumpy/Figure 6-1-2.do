clear all
set more off

/* Download data */
* shell curl -o Lee2008.zip http://economics.mit.edu/faculty/angrist/data1/mhe/lee
* unzipfile Lee2008.zip, replace

/* Plot Panel (a) */
* Load the data
use "Lee2008/group_final.dta", clear
graph twoway (scatter mdemwinnext difdemshare, ms(O) mc(gs0) msize(small))    ///
             (line mpdemwinnext difdemshare, sort lcolor(gs0))                /// 
                if difdemshare > -0.251 & difdemshare < 0.251 & use == 1,     /// 
                xline(0, lcolor(gs0)) title("Figure 5a", color(gs0))          ///
                xtitle("Democratic Vote Share Margin of Victory, Election t") /// 
                ytitle("Probability of Victory, Election t+1")                ///
                yscale(r(0 1)) ylabel(0(.1)1)                                 ///
                xscale(r(-0.25 0.25)) xlabel(-0.25(.05)0.25)                  ///
                legend(label(1 "Local Average") label(2 "Logit Fit"))         ///
                scheme(s1mono)

/* Plot Panel (b) */
* Load the data
use "Lee2008/individ_final.dta", clear
graph twoway (scatter mofficeexp difshare, ms(O) mc(gs0) msize(small))        ///
             (line mpofficeexp difshare, sort lcolor(gs0))                    /// 
                if difshare > -0.251 & difshare < 0.251 & use == 1,           ///
                xline(0, lcolor(gs0)) title("b", color(gs0))                  ///
                xtitle("Democratic Vote Share Margin of Victory, Election t") ///
                ytitle("No. of Past Victories as of Election t")              ///
                yscale(r(0 5)) ylabel(0(.5)5)                                 ///
                xscale(r(-0.25 0.25)) xlabel(-0.25(.05)0.25)                  ///
                legend(label(1 "Local Average") label(2 "Polynomial Fit"))    ///
                scheme(s1mono)

/* End of file */
exit
