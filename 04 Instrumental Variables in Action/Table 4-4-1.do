clear all
set more off

/* Stata code for Table 4.4.1*/
* shell curl -o jtpa.raw http://economics.mit.edu/files/614

/* Import data */
infile ym   zm   dm   sex  xm6  xm7  xm8  xm9  xm10 ///
       xm17 xm18 xm12 xm13 xm14 xm15 xm16 xm19 using jtpa.raw, clear

reg sex xm6


/* End of file */
exit
