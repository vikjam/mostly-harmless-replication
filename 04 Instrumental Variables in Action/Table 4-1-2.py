#!/usr/bin/env python
"""
Create Table 4-1-2 in MHE
Tested on Python 3.4
"""

import zipfile
import urllib.request
import pandas as pd
import scipy.stats
import statsmodels.api as sm

# Download data and unzip the data
urllib.request.urlretrieve('http://economics.mit.edu/files/397', 'asciiqob.zip')
with zipfile.ZipFile('asciiqob.zip', "r") as z:
   z.extractall()

# Read the data into a pandas dataframe
pums         = pd.read_csv('asciiqob.txt',
                           header           = None,
                           delim_whitespace = True)
pums.columns = ['lwklywge', 'educ', 'yob', 'qob', 'pob']

# Create binary variable
pums['z'] = ((pums.educ == 3) | (pums.educ == 4)) * 1

# Compare means (and differences)
ttest_lwklywge = scipy.stats.ttest_ind(pums.lwklywge[pums.z == 1], pums.lwklywge[pums.z == 0])
ttest_educ     = scipy.stats.ttest_ind(pums.educ[pums.z == 1], pums.educ[pums.z == 0])

# Compute Wald estimate (need to use arrays to use SUR in statsmodels)
wald_estimate = (np.mean(pums.lwklywge[pums.z == 1]) - np.mean(pums.lwklywge[pums.z == 0])) / \
                (np.mean(pums.educ[pums.z == 1])     - np.mean(pums.educ[pums.z == 0]))

# OLS estimate
ols = sm.OLS(y, X).fit()

# End of script
