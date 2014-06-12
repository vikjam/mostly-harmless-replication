#!/usr/bin/env python
import urllib
import zipfile
import pandas as pd
import statsmodels.api as sm

# Download data and unzip the data
# urllib.urlretrieve('http://economics.mit.edu/files/397', 'asciiqob.zip')
with zipfile.ZipFile('asciiqob.zip', "r") as z:
    z.extractall()

# Read the data into a pandas dataframe
pums = pd.read_csv('asciiqob.txt', 
	               index_col        = 0,
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
educ_coefs = results.params[1]

# End of script
