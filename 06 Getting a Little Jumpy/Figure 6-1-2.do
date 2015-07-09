clear all
set more off

/* Download data */
shell curl -o Lee2008.zip http://economics.mit.edu/faculty/angrist/data1/mhe/lee
unzipfile Lee2008.zip, replace

/* End of file */
exit
