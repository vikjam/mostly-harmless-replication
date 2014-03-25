clear all
set more off
eststo clear
capture version 13

/* Pull data from the 'Mostly Harmless' website */
/* http://economics.mit.edu/faculty/angrist/data1/mhe/krueger */
shell /usr/local/bin/wget -O webstar.dta http://economics.mit.edu/files/3827/

/* Load downloaded data */
use webstar.dta, clear


/* End of file */
exit
