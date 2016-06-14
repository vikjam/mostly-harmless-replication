#!/usr/bin/env python
"""
Tested on Python 3.4
"""
import urllib
import zipfile
import urllib.request
import pandas as pd
import numpy as np
import statsmodels.api as sm
import statsmodels.formula.api as smf
import matplotlib.pyplot as plt
from statsmodels.regression.quantile_regression import QuantReg
from collections import defaultdict 
from tabulate import tabulate

# Download data and unzip file
# urllib.request.urlretrieve('http://economics.mit.edu/files/384', 'angcherfer06.zip')
# with zipfile.ZipFile('angcherfer06.zip', 'r') as z:
#    z.extractall()

# Function to run the quantile regressions
def quant_mincer(q, data):
  r      = smf.quantreg('logwk ~ educ + black + exper + exper2', data)
  result = r.fit(q = q)
  coef   = result.params['educ']
  se     = result.bse['educ']
  return [coef, se]

# Create dictionary to store the results
results = defaultdict(list)

# Loop over years and quantiles
years = ['80', '90', '00']
taus  = [0.1, 0.25, 0.5, 0.75, 0.9]

for year in years:
    # Load data
    dta_path = 'Data/census%s.dta' % year
    df       = pd.read_stata(dta_path)
    # Weight the data by perwt
    wdf      = df[['logwk', 'educ', 'black', 'exper', 'exper2']]. \
               multiply(1 / df['perwt'], axis = 'index')
    # Summary statistics
    results['Obs']  += [df['logwk'].count(), None]
    results['Mean'] += [np.mean(df['logwk']), None]
    results['Std']  += [np.std(df['logwk']), None]
    # Quantile regressions
    for tau in taus:
        results[tau] += quant_mincer(tau, wdf)
    # Run OLS with weights to get OLS parameters and MSE
    wls_model  = smf.ols('logwk ~ educ + black + exper + exper2', wdf)
    wls_result = wls_model.fit()
    results['OLS']  += [wls_result.params['educ'], wls_result.bse['educ']]
    results['RMSE'] += [np.sqrt(wls_result.mse_resid), None]

# Export table
print(tabulate(results, headers = 'keys'))
table = np.column_stack((results['Obs'], results['Mean'], results['Std'],
                         results['0.1'], results['0.25'], results['0.5'],
                         results['0.75'], results['0.9'],
                         results['OLS'], results['RMSE']))
print(tabulate(table))

# End of script
