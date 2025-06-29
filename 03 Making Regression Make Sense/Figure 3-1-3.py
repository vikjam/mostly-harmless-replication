#!/usr/bin/env python
"""
Tested on Python 3.11.5
"""

import urllib
import zipfile
import urllib.request
import pandas as pd
import statsmodels.api as sm
import statsmodels.formula.api as smf

# Read the data into a pandas.DataFrame
angrist_archive_url = (
   'https://economics.mit.edu/sites/'
   'default/files/publications/asciiqob.zip'
)
pums = pd.read_csv(
   angrist_archive_url,
   compression = 'zip',
   header = None,
   sep = '\s+'
)
pums.columns = ['lwklywge', 'educ', 'yob', 'qob', 'pob']

# Panel A
# Set up the model and fit it
mod_a = smf.ols(
   formula = 'lwklywge ~ educ',
   data = pums
)
res_a = mod_a.fit()
# Old-fashioned standard errors
print(res_a.summary(title='Old-fashioned standard errors'))
# Robust standard errors
res_a_robust = res_a.get_robustcov_results(cov_type='HC1')
print(
   res_a_robust.summary(title='Robust standard errors')
)
# Panel B
# Calculate means and count by educ attainment
pums_agg = pums.groupby('educ').agg(
   lwklywge = ('lwklywge', 'mean'),
   count = ('lwklywge', 'count')
).reset_index()
# Set up the model and fit it
mod_b = smf.wls(
   formula = 'lwklywge ~ educ',
   weights = pums_agg['count'],
   data = pums_agg
)
res_b = mod_b.fit()
# Old-fashioned standard errors
print(res_b.summary(title='Old-fashioned standard errors'))
# Robust standard errors
res_b_robust = res_b.get_robustcov_results(cov_type='HC1')
print(
   res_b_robust.summary(title='Robust standard errors')
)

# End of script
