#!/usr/bin/env python
"""
Tested on Python 3.4
"""

import urllib
import zipfile
import urllib.request
import pandas as pd
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

# Calculate means and count by educ attainment
groupbyeduc = pums.groupby('educ')
educ_means  = groupbyeduc['lwklywge'].mean()
educ_count  = groupbyeduc['lwklywge'].count()

# Set up the model
y = pums.lwklywge
X = pums.educ
X = sm.add_constant(X)


# End of script
