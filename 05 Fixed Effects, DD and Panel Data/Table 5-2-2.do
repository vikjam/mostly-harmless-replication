clear all
set more off
eststo clear
capture version 13

/* Pull data from the 'Mostly Harmless' website */
/* http://economics.mit.edu/faculty/angrist/data1/mhe/card */
shell curl -o njmin.zip http://economics.mit.edu/files/3845
shell unzip -j njmin.zip

/* End of script*/
exit
