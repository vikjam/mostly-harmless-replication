clear all
set more off
eststo clear
capture version 13

/* Stata code for Table 5.2.1*/
shell curl -o njmin.zip http://economics.mit.edu/files/3845
unzipfile njmin.zip, replace

/* Import data */
infile SHEET CHAIN CO_OWNED STATE SOUTHJ CENTRALJ NORTHJ PA1 PA2      ///
       SHORE NCALLS EMPFT EMPPT NMGRS WAGE_ST INCTIME FIRSTINC BONUS  ///
       PCTAFF MEALS OPEN HRSOPEN PSODA PFRY PENTREE NREGS NREGS11     ///
       TYPE2 STATUS2 DATE2 NCALLS2 EMPFT2 EMPPT2 NMGRS2 WAGE_ST2      ///
       INCTIME2 FIRSTIN2 SPECIAL2 MEALS2 OPEN2R HRSOPEN2 PSODA2 PFRY2 ///
       PENTREE2 NREGS2 NREGS112 using "public.dat", clear

/* Label the state variables and values */
label var STATE "State"
label define state_labels 0 "PA" 1 "NJ"
label values STATE state_labels

/* Calculate FTE employement */
gen FTE  = EMPFT  + 0.5 * EMPPT  + NMGRS
label var FTE  "FTE employment before"
gen FTE2 = EMPFT2 + 0.5 * EMPPT2 + NMGRS2
label var FTE2 "FTE employment after"

/* Calculate means */
tabstat FTE FTE2, by(STATE) stat(mean semean)

/* End of script */
