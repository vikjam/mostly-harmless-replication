#!/usr/bin/env python
"""
Tested on Python 3.4
"""

import numpy as np
import statsmodels.api as sm

# Set seed
numpy.random.seed(1025)

# Set parameters of the simulation
N   = 30
r   = 0.9
N_1 = int(r * 30)
sigma = 0.5

# Generate simulation data
d = np.empty(N); d[0:N_1] = 1; d[N_1 + 1:N] = 0

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

# End of script
