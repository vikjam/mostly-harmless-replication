#!/usr/bin/env python
import urllib
import zipfile
import pandas as pd
import statsmodels.api as sm
import matplotlib.pyplot as plt

# Download data and unzip the data
urllib.urlretrieve('http://economics.mit.edu/files/397', 'asciiqob.zip')
with zipfile.ZipFile('asciiqob.zip', "r") as z:
   z.extractall()

# Read the data into a pandas dataframe
pums = pd.read_csv('asciiqob.txt',
	               header           = None,
	               delim_whitespace = True)
pums.columns = ['lwklywge', 'educ', 'yob', 'qob', 'pob']

# Set up the model
y = pums.lwklywge
X = pums.educ
X = sm.add_constant(X)

# Save coefficient on education
model      = sm.OLS(y, X)
results    = model.fit()
educ_coef  = results.params[1]
intercept  = results.params[0]

# Calculate means by educ attainment
groupbyeduc = pums.groupby('educ')
educ_means  = groupbyeduc['lwklywge'].mean()

# Plot


# End of script
