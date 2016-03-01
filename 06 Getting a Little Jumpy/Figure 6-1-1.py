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
fig = plt.figure()

ax1 = fig.add_subplot(311)
ax1.scatter(x, y_linear, edgecolors = 'none')
ax1.plot(x[0.5 >= x], fit_y_linear_0)
ax1.plot(x[x > 0.5], fit_y_linear_1)
ax1.axvline(0.5)
ax1.set_title(r'A. Linear $E[Y_{0i} | X_i]$')

ax2 = fig.add_subplot(312)
ax2.scatter(x, y_nonlin, edgecolors = 'none')
ax2.plot(x[0.5 >= x], fit_y_nonlin_0)
ax2.plot(x[x > 0.5], fit_y_nonlin_1)
ax2.axvline(0.5)
ax2.set_title(r'B. Nonlinear $E[Y_{0i} | X_i]$')

ax3 = fig.add_subplot(313)
ax3.scatter(x, y_mistake, edgecolors = 'none')
ax3.plot(x[0.5 >= x], fit_y_mistake_0)
ax3.plot(x[x > 0.5], fit_y_mistake_1)
ax3.plot(x, 1 / (1 + np.exp(-25 * (x - 0.5))), '--')
ax3.axvline(0.5)
ax3.set_title('C. Nonlinearity mistaken for discontinuity')

plt.tight_layout()
plt.savefig('Figure 6-1-1-Python.png', dpi = 300)

# End of script
