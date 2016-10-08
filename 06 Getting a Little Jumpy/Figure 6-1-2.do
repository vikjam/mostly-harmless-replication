clear all
set more off

* Download data and unzip the data
shell curl -o Lee2008.zip http://economics.mit.edu/faculty/angrist/data1/mhe/lee
unzipfile Lee2008.zip, replace

* Load the data
use "Lee2008/individ_final.dta", clear

* Create 0.005 intervals of democratic share of votes
egen i005   = cut(difshare), at(-1(0.005)1.005)

* Take the mean within each interval
egen m_next = mean(myoutcomenext), by(i005)

* Predict with polynomial logit of degree 4
foreach poly of numlist 1(1)4 {
    gen poly_`poly' = difshare^`poly'
}

gen d = (difshare >= 0)
logit myoutcomenext c.poly_*##d
predict next_pr, pr
egen mp_next  = mean(next_pr), by(i005)

* Create the variables for office of experience (taken as given from Lee, 2008)
egen mp_vic   = mean(mpofficeexp), by(i005)
egen m_vic    = mean(mofficeexp), by(i005)

* Tag each interval once for the plot
egen tag_i005 = tag(i005)

* Plot panel (a)
graph twoway (scatter m_next  i005, msize(small))                              ///
             (line    mp_next i005 if i005 >= 0, sort)                         ///
             (line    mp_next i005 if i005 <  0, sort)                         /// 
                if i005 > -0.251 & i005 < 0.251 & tag_i005 == 1,               /// 
                xline(0, lpattern(dash))                                       ///
                title("a")                                                     ///
                xtitle("Democratic Vote Share Margin of Victory, Election t")  /// 
                ytitle("Probability of Victory, Election t+1")                 ///
                yscale(r(0 1))        ylabel(0(.1)1)                           ///
                xscale(r(-0.25 0.25)) xlabel(-0.25(.05)0.25)                   ///
                legend(order(1 2) cols(1)                                      ///
                       ring(0) bplacement(nwest)                               ///
                       label(1 "Local Average") label(2 "Logit Fit"))          ///
                scheme(s1mono)                                                 ///
                saving(panel_a.gph, replace)

* Plot panel (b)
graph twoway (scatter m_vic  i005, msize(small))                               ///
             (line    mp_vic i005 if i005 >= 0, sort)                          ///
             (line    mp_vic i005 if i005 <  0, sort)                          /// 
                if i005 > -0.251 & i005 < 0.251 & tag_i005 == 1,               /// 
                xline(0, lpattern(dash))                                       ///
                title("b")                                                     ///
                xtitle("Democratic Vote Share Margin of Victory, Election t")  /// 
                ytitle("No. of Past Victories as of Election t")               ///
                yscale(r(0 5))        ylabel(0(.5)5)                           ///
                xscale(r(-0.25 0.25)) xlabel(-0.25(.05)0.25)                   ///
                legend(order(1 2) cols(1)                                      ///
                       ring(0) bplacement(nwest)                               ///
                       label(1 "Local Average") label(2 "Logit Fit"))          ///
                scheme(s1mono)                                                 ///
                saving(panel_b.gph, replace)

* Combine plots
graph combine panel_a.gph panel_b.gph, ///
    col(1)                             ///
    xsize(4) ysize(6)                  ///
    graphregion(margin(zero))          ///
    scheme(s1mono)

* Export figures
graph export "Figure 6-1-2-Stata.png", replace

/* End of file */
exit
