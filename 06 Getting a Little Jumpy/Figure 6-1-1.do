clear all
set more off
eststo clear
capture log close _all
capture version 13

/* Pull data from the 'Mostly Harmless' website */
shell /usr/local/bin/wget -O Lee2008.zip http://economics.mit.edu/faculty/angrist/data1/mhe/lee
unzipfile Lee2008.zip, replace

/* End of file */
exit
