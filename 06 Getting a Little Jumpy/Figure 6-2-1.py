#!/usr/bin/env python
"""
Create Figure 6.2.1 in MHE
Tested on Python 3.4
numpy: math and stat functions, array
matplotlib: plot figures
"""
import numpy as np
import matplotlib.pyplot as plt
import pandas as pd

# Download data
urllib.request.urlretrieve('http://economics.mit.edu/files/1359', 'final4.dta')
urllib.request.urlretrieve('http://economics.mit.edu/files/1358', 'final5.dta')

# Read the data into a pandas dataframe
grade4 = pd.read_csv('final4.csv', encoding = 'iso8859_8')
grade5 = pd.read_csv('final5.csv', encoding = 'iso8859_8')

# Find means class size by grade size
grade4means = grade4.groupby('c_size')['classize'].mean()
grade5means = grade5.groupby('c_size')['classize'].mean()

# Create grid and function for Maimonides Rule
def maimonides_rule(x):
    return x / (np.floor((x - 1)/40) + 1)

x = np.arange(0, 220, 1)

# Plot figures
fig = plt.figure()

ax1 = fig.add_subplot(211)
ax1.plot(grade4means)
ax1.plot(x, maimonides_rule(x), '--')
ax1.set_xticks(range(0, 221, 20))
ax1.set_xlabel("Enrollment count")
ax1.set_ylabel("Class size")
ax1.set_title('B. Fourth grade')

ax2 = fig.add_subplot(212)
ax2.plot(grade5means)
ax2.plot(x, maimonides_rule(x), '--')
ax2.set_xticks(range(0, 221, 20))
ax2.set_xlabel("Enrollment count")
ax2.set_ylabel("Class size")
ax2.set_title('A. Fifth grade')

plt.tight_layout()
plt.savefig('Figure 6-2-1-Python.png', dpi = 300)

# End of script
