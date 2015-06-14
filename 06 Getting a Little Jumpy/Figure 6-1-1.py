#!/usr/bin/env python
"""
Create Figure 4-6-1 in MHE
Tested on Python 3.4
numpy: math and stat functions, array
matplotlib: plot figures
"""

import numpy as np
import matplotlib.pyplot as plt

# Set seed
np.random.seed(10633)

# Set number of simulations
nobs = 100

# Generate series
x         = np.random.uniform(0, 1, nobs)
x         = np.sort(x)
y_linear  = x + (x > 0.5) * 0.25 + np.random.normal(0, 0.1, nobs)
y_nonlin  = 0.5 * np.sin(6 * (x - 0.5)) + 0.5 + (x > 0.5) * 0.25 + np.random.normal(0, 0.1, nobs)
y_mistake = 1 / (1 + np.exp(-25 * (x - 0.5))) + np.random.normal(0, 0.1, nobs)

# Fit lines using user-created function
def rdfit(x, y, cutoff, degree):
    coef_0 = np.polyfit(x[cutoff >= x], y[cutoff >= x], degree)
    fit_0  = np.polyval(coef_0, x[cutoff >= x])

    coef_1 = np.polyfit(x[x > cutoff], y[x > cutoff], degree)
    fit_1  = np.polyval(coef_1, x[x > cutoff])

    return coef_0, fit_0, coef_1, fit_1

coef_y_linear_0 , fit_y_linear_0 , coef_y_linear_1 , fit_y_linear_1  = rdfit(x, y_linear, 0.5, 1)
coef_y_nonlin_0 , fit_y_nonlin_0 , coef_y_nonlin_1 , fit_y_nonlin_1  = rdfit(x, y_nonlin, 0.5, 2)
coef_y_mistake_0, fit_y_mistake_0, coef_y_mistake_1, fit_y_mistake_1 = rdfit(x, y_mistake, 0.5, 1)

# Plot figures
plt.figure()

plt.subplot(311)
plt.scatter(x, y_linear, edgecolors = 'none')
plt.plot(x[0.5 >= x], fit_y_linear_0)
plt.plot(x[x > 0.5], fit_y_linear_1)
plt.axvline(0.5)

plt.subplot(312)
plt.scatter(x, y_nonlin, edgecolors = 'none')
plt.plot(x[0.5 >= x], fit_y_nonlin_0)
plt.plot(x[x > 0.5], fit_y_nonlin_1)
plt.axvline(0.5)

plt.subplot(313)
plt.scatter(x, y_mistake, edgecolors = 'none')
plt.plot(x[0.5 >= x], fit_y_mistake_0)
plt.plot(x[x > 0.5], fit_y_mistake_1)
plt.plot(x, 1 / (1 + np.exp(-25 * (x - 0.5))), '--')
plt.axvline(0.5)

plt.savefig('Figure 6-1-1-Python.pdf')

# End of script
