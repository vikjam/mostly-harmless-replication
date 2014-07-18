#!/usr/bin/env python

import urllib
import zipfile
import pandas as pd
import statsmodels.api as sm
import matplotlib.pyplot as plt

# Download data and unzip the data
# urllib.urlretrieve('http://economics.mit.edu/files/397', 'asciiqob.zip')
with zipfile.ZipFile('asciiqob.zip', "r") as z:
    z.extractall()

# Read the data into a pandas dataframe
pums = pd.read_csv('asciiqob.txt',
	               index_col        = 0,
	               header           = None,
	               delim_whitespace = True,
                   usecols          = [0, 1, 2])
pums.columns = ['lwklywge', 'educ']

# Set up the model
y = pums.lwklywge
X = pums.educ
X = sm.add_constant(X)

# Save coefficient on education
model      = sm.OLS(y, X)
results    = model.fit()
educ_coefs = results.params[1]

# Get means by 'educ'
means = pums.groupby('educ').mean()[1:21]
## For some reason there are additional 'educ' levels that shouldn't exist.
print(means)
# Create plot
plt.figure()
means.plot()
plt.legend().set_visible(False)
plt.savefig('Figure 3-1-2-Python.pdf')

# End of script
