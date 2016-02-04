clear all
set more off
eststo clear
capture version 14

/* Stata code for Table 5.2.3 */
shell curl -o industry.zip http://sticerd.lse.ac.uk/eopp/_new/data/indian_data/industry.zip
unzipfile industry.zip, replace

shell curl -o socioeconomics.zip http://sticerd.lse.ac.uk/eopp/_new/data/indian_data/socioeconomics.zip
unzipfile socioeconomics.zip, replace

/* Drop missing data */
drop if missing(state) | missing(year)

/* Declare data as panel data */
xtset state year

/* Column 1 */
regress earning L.strict  

/* End of script */
