#!/usr/bin/env python
"""
Tested on Python 3.4
numpy: generate random data, manipulate arrays
statsmodels.api: estimate OLS and robust errors
tabulate: pretty print to markdown
"""

import numpy as np
import statsmodels.api as sm
from tabulate import tabulate

# Set seed
np.random.seed(1025)

# Set number of simulations
nsims = 25

# Create function to create data for each run
def generateHC(sigma):
    # Set parameters of the simulation
    N   = 30
    r   = 0.9
    N_1 = int(r * 30)

    # Generate simulation data
    d = np.zeros(N); d[0:N_1] = 1;

    epsilon         = np.empty(N)
    epsilon[d == 1] = np.random.normal(0, 1, N_1)
    epsilon[d == 0] = np.random.normal(0, sigma, N - N_1)

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

    compare_errors     = np.maximum(simulation_results[:, 1].transpose(), simulation_results[:, 2:6].transpose()).transpose()
    simulation_results = np.column_stack((simulation_results, compare_errors))

    summary_mean  = np.mean(simulation_results, axis = 0).transpose()
    summary_std   = np.std(simulation_results, axis = 0).transpose()
    summary_stats = np.column_stack((summary_mean, summary_std))
    return(tabulate(summary_stats))

print(simulateHC(25, 0.5))
# End of script
