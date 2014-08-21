clear all
set more off
eststo clear
capture log close _all
capture version 13

/* Stata code for Table 4.4.1*/
log using "Table 4-4-1-Stata.txt", name(table040401) text replace

log close table040401

/* End of file */
exit
