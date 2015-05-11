clear all
set more off
eststo clear
capture log close _all
capture version 13

/* Set random seed for replication */
set seed 42

/* Define program for use with -simulate- command */
capture program drop clusterbias
program define weakinstr, rclass
    version 13.1

    clear
    set obs 30
    gen e_a = rnormal(-0.001, 0.586) 
    gen e_b = rnormal( 0.004, 0.600)
    gen e_c = rnormal(-0.003, 0.611)

end

/* Run simulation */
simulate, reps(25000): clusterbias

/* End of file */
exit
