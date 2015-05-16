#!/usr/bin/env python
"""
Tested on Python 3.4
numpy: generate random data, manipulate arrays
statsmodels.api: estimate OLS and robust errors
tabulate: pretty print to markdown
scipy.stats: calculate distributions
"""

import numpy as np
import statsmodels.api as sm
from tabulate import tabulate
import scipy.stats

# Set seed
np.random.seed(1025)

# Set number of simulations
nsims = 25000

# Create function to create data for each run
def generateHC(sigma):
    # Set parameters of the simulation
    N   = 30
    r   = 0.9
    N_1 = int(r * 30)

    # Generate simulation data
    d = np.ones(N); d[0:N_1] = 0;

    epsilon         = np.empty(N)
    epsilon[d == 1] = np.random.normal(0, 1, N - N_1)
    epsilon[d == 0] = np.random.normal(0, sigma, N_1)

    # Run regression
    y       = 0 * d + epsilon
    X       = sm.add_constant(d)
    model   = sm.OLS(y, X)
    results = model.fit()
    b1      = results.params[1]

    # Calculate standard errors
    conventional = results.bse[1]
    hc0          = results.get_robustcov_results(cov_type = 'HC0').bse[1]
    hc1          = results.get_robustcov_results(cov_type = 'HC1').bse[1]
    hc2          = results.get_robustcov_results(cov_type = 'HC2').bse[1]
    hc3          = results.get_robustcov_results(cov_type = 'HC3').bse[1]
    return([b1, conventional, hc0, hc1, hc2, hc3])

# Create function to report simulations
def simulateHC(nsims, sigma):
    # Initialize array to save results
    simulation_results = np.empty(shape = [nsims, 6])

    # Run simulation
    for i in range(0, nsims):
        simulation_results[i, :] = generateHC(0.5)

    # Take maximum of conventional versus HC's, and combine with simulation results
    compare_errors     = np.maximum(simulation_results[:, 1].transpose(),
                                    simulation_results[:, 2:6].transpose()).transpose()
    simulation_results = np.concatenate((simulation_results, compare_errors), axis = 1)
    
    # Calculate rejection rates (note backslash = explicit line continuation)
    test_stats       = np.tile(simulation_results[:, 0], (9, 1)).transpose() / \
                       simulation_results[:, 1:10]
    summary_reject_z = np.mean(2 * scipy.stats.norm.cdf(-abs(test_stats)) <= 0.05,
                               axis = 0).transpose()
    summary_reject_t = np.mean(2 * scipy.stats.t.cdf(-abs(test_stats), df = 30 - 2) <= 0.05,
                               axis = 0).transpose()
    summary_reject_z = np.concatenate([[np.nan], summary_reject_z]).transpose()
    summary_reject_t = np.concatenate([[np.nan], summary_reject_t]).transpose()

    # Calculate mean and standard errors
    summary_mean  = np.mean(simulation_results, axis = 0).transpose()
    summary_std   = np.std(simulation_results, axis = 0).transpose()

    # Create labels
    summary_labs  = np.array(["Beta_1", "Conventional","HC0", "HC1", "HC2", "HC3",
                              "max(Conventional, HC0)", "max(Conventional, HC1)",
                              "max(Conventional, HC2)", "max(Conventional, HC3)"])

    # Combine all the results and labels
    summary_stats = np.column_stack((summary_labs,
                                     summary_mean,
                                     summary_std,
                                     summary_reject_z,
                                     summary_reject_t))

    # Create header for table
    header        = ["Mean", "Std", "z rate", "t rate"]
    return(tabulate(summary_stats, header, tablefmt = "pipe"))

print("Panel A")
print(simulateHC(nsims, 0.5))

print("Panel B")
print(simulateHC(nsims, 0.85))

print("Panel C")
print(simulateHC(nsims, 1))
# End of script
