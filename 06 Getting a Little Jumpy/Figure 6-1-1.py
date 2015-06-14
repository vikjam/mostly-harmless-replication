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
y_linear  = x + (x > 0.5) * 0.25 + np.random.normal(0, 0.1, nobs)
y_nonlin  = 0.5 * np.sin(6 * (x - 0.5)) + 0.5 + (x > 0.5) + np.random.normal(0, 0.1, nobs)
y_mistake = 1 / (1 + np.exp(-25 * (x - 0.5))) + np.random.normal(0, 0.1, nobs)

# Get fitted lines
b1, b0 = np.polyfit(x, y_linear, 1)

# Plot figures
plt.figure()
plt.scatter(x, y_linear, edgecolors = 'none')
plt.plot(x, b0 + b1 * x)
plt.axvline(0.5)
plt.savefig('Figure 6-1-1-Python.pdf')

# End of script
