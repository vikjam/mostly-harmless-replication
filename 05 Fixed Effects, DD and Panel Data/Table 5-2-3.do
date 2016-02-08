clear all
set more off
eststo clear
capture version 14

/* Stata code for Table 5.2.3 */

/* Download the data and unzip it */

* /* Industry */
* shell curl -o industry.zip http://sticerd.lse.ac.uk/eopp/_new/data/indian_data/industry.zip
* unzipfile industry.zip, replace

* /* Socioeconomics */
* shell curl -o socioeconomics.zip "http://sticerd.lse.ac.uk/eopp/_new/data/indian_data/socioeconomics.zip"
* unzipfile socioeconomics.zip, replace

* /* Poverty and inequality */
* shell curl -o Poverty_Inequality.zip "http://sticerd.lse.ac.uk/eopp/_new/data/indian_data/Poverty_Inequality.zip"
* unzipfile Poverty_Inequality.zip, replace

* /* Public finance */
* shell curl -o Public_Finance.zip "http://sticerd.lse.ac.uk/eopp/_new/data/indian_data/Public_Finance.zip"
* unzipfile Public_Finance.zip, replace

* /* Politics */
* shell curl -o Politics.zip "http://sticerd.lse.ac.uk/eopp/_new/data/indian_data/Politics.zip"
* unzipfile Politics.zip, replace

/*----------------------*/
/* Import industry data */
/*----------------------*/
use industry.dta

/* Drop missing data */
drop if missing(state) | missing(year)

/* Save as temp file to merge to Socioeconomics.dta */
tempfile industry
save `industry'

/*------------------------*/
/* Poverty and inequality */
/*------------------------*/

/* Import poverty and inequality */
use poverty_and_inequality.dta

/* Drop missing data */
drop if missing(state) | missing(year)

/* Save as temp file to merge to Socioeconomics.dta */
tempfile poverty_and_inequality
save `poverty_and_inequality'

/*----------------*/
/* Socioeconomics */
/*----------------*/

/* Import socioeconomics */
use Socioeconomic.dta, clear

/* Drop missing data */
drop if missing(state) | missing(year)

/* Save as temp file to merge to Socioeconomics.dta */
tempfile socioeconomic
save `socioeconomic'

/* Drop missing data */
drop if missing(state) | missing(year)

/*----------------*/
/* Public finance */
/*----------------*/

/* Import socioeconomics */
use public_finance.dta, clear

/* Drop missing data */
drop if missing(state) | missing(year)

/* Save as temp file to merge to Socioeconomics.dta */
tempfile public_finance
save `public_finance'

/*----------*/
/* Politics */
/*----------*/

/* Import politics */
use politics.dta, clear

/* Merge by state-year */
merge 1:1 state year using "`industry'", gen(_mindustry)
merge 1:1 state year using "`poverty_and_inequality'", gen(_mpi)
merge 1:1 state year using "`socioeconomic'", gen(_socioeconomic)
merge 1:1 state year using "`public_finance'", gen(_public_finance)

/* Set as time series */
xtset state year

/* Restrict to 1958 to 1992 */
keep if inrange(year, 1958, 1992)

/* Generate relevant variables */
gen log_employm   = log(employm * 1000)
gen lnstrict      = L.nstrict               // Labor regulation (lagged)
gen log_pop       = log(pop1 + pop2)        // Log population
gen log_devexppc  = log(devexp)    // Log development expenditure per capita
gen log_regmanpc  = log(nsdpmanr) - log_pop // Log registered manufacturing output per capita
gen log_uregmanpc = log(nsdpuman) - log_pop // Log unregistered manufacturing output per capita
gen log_ffcappc   = log(ffcap / employm)    // Log registered manufacturing fixed capital per capita
gen log_fvaladdpe = log(fvaladd) - log_pop
gen log_instcap   = log(instcap)            // Log installed electricity capacity per capita
gen mdlloc_wkr    = mdlloc / (workers) // Workdays lost to lockouts per worker
gen mdldis_wkr    = mdldis / (workers) // Workdays lost to strikes per worker
gen janata        = lkdp + jp + jd
gen hard_left     = cpi + cpm
gen regional      = oth
gen congress      = inc + incu + ics

tabstat nstrict mdldis_wkr mdlloc_wkr log_regmanpc log_uregmanpc ///
        log_employm log_ffcappc log_fvaladdpe h2 h1 log_devexppc ///
        log_instcap log_pop congress hard_left janata regional,  ///
            c(s) s(mean sd N)

/* Column 1 */
eststo col1: regress log_regmanpc lnstrict i.year i.state, cluster(state)
estadd local state_trends "NO"

/* Column 2 */
eststo col2: regress log_regmanpc lnstrict log_devexppc log_instcap log_pop i.year i.state, cluster(state)
estadd local state_trends "NO"

/* Column 3 */
eststo col3: regress log_regmanpc lnstrict log_devexppc log_instcap log_pop congress hard_left janata regional i.year i.state, cluster(state)
estadd local state_trends "NO"

/* Column 4 */
eststo col4: regress log_regmanpc lnstrict log_devexppc log_instcap log_pop congress hard_left janata regional i.year i.state i.state#c.year, cluster(state)
estadd local state_trends "YES"

esttab, se                                                                                 ///
        nomtitles                                                                          ///
        noobs                                                                              ///
        ar2                                                                                ///
        scalars("state_trends State-speciÖc trends")                                       ///
        keep(lnstrict log_devexppc log_instcap log_pop congress hard_left janata regional)
eststo clear

/* End of script */
