#!/usr/bin/env python
"""
Create Figure 4-6-1 in MHE
Tested on Python 3.4
"""

import pandas as pd
import numpy as np
import statsmodels.api as sm
import matplotlib.pyplot as plt
import random
import math

# Number of simulations
nsims = 10

# Set seed
random.seed(461)

# Set parameters
Sigma   = [[1.0, 0.8],
           [0.8, 1.0]]
mu      = [0, 0]
errors  = np.random.multivariate_normal(mu, Sigma, 1000)
eta     = errors[:, 0]
xi      = errors[:, 1]

# Create Z, x, y
Z  = np.random.multivariate_normal([0] * 20, np.identity(20), 1000)
x  = 0.1 * Z[: , 0] + xi
y  = x + eta
x  = sm.add_constant(x)
Z  = sm.add_constant(x)

ols  = sm.OLS(y, x).fit().params[1]
tsls = np.linalg.inv(np.transpose(Z).dot(x)).dot(np.transpose(Z).dot(y))[1]

# End of script
