#!/usr/bin/env python
"""
Create Figure 4-6-1 in MHE
Tested on Python 3.4
"""

import pandas as pd
import numpy as np
import statsmodels.api as sm
from statsmodels.sandbox.regression import gmm
import matplotlib.pyplot as plt
import random
import math
from scipy.linalg import eigh

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
# tsls = np.linalg.inv(np.transpose(Z).dot(x)).dot(np.transpose(Z).dot(y))[1]
tsls = gmm.IV2SLS(y, x, Z).fit().params[1]

def LIML(exogenous, endogenous, instruments):
    y = exogenous
    x = endogenous
    Z = instruments
    I = np.eye(y.shape[0])
    Mz = I - Z.dot(np.linalg.inv(np.transpose(Z).dot(Z))).dot(np.transpose(Z))
    Mx = I - x.dot(np.linalg.inv(np.transpose(x).dot(x))).dot(np.transpose(x))
    A = np.transpose(np.hstack((y, x[:,1]))).dot(Mz).dot(np.hstack((y, x[:,1])))
    k = 1 
    beta = np.linalg.inv(np.transpose(Z).dot(I - k * M).dot(Z)).dot(np.transpose(Z).dot(I - k * M)).dot(y)
    return 

# End of script
