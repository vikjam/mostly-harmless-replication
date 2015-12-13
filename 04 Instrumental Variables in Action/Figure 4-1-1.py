#!/usr/bin/env python
"""
Create Figure 4-6-1 in MHE
Tested on Python 3.4
"""

import zipfile
import urllib.request
import pandas as pd
import statsmodels.api as sm
import matplotlib.pyplot as plt

# Download data and unzip the data
urllib.request.urlretrieve('http://economics.mit.edu/files/397', 'asciiqob.zip')
with zipfile.ZipFile('asciiqob.zip', "r") as z:
   z.extractall()

# Read the data into a pandas dataframe
pums         = pd.read_csv('asciiqob.txt',
                           header           = None,
                           delim_whitespace = True)
pums.columns = ['lwklywge', 'educ', 'yob', 'qob', 'pob']

# Calculate means by educ and lwklywge
groupbybirth = pums.groupby(['yob', 'qob'])
birth_means  = groupbybirth['lwklywge', 'educ'].mean()

# Plot figures
plt.figure()
plt.subplot(2, 1, 1)
birth_means.plot(y = 'educ', marker = 'o')
plt.legend().set_visible(False)
plt.subplot(2, 1, 2)
birth_means.plot(y = 'lwklywge', marker = 'o')
plt.savefig('Figure 4-1-1-Python.pdf', format = 'pdf')
plt.close('all')

# End of file
