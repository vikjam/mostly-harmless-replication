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
urllib.request.urlretrieve('http://economics.mit.edu/files/384', 'angcherfer06.zip')
with zipfile.ZipFile('angcherfer06.zip', 'r') as z:
   z.extractall()

# Function to run the quantile regressions
def quant_mincer(q, data):
  r      = smf.quantreg('logwk ~ educ + black + exper + exper2 + wt - 1', data)
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
    df['wt']  = np.sqrt(df['perwt'])
    wdf       = df[['logwk', 'educ', 'black', 'exper', 'exper2']]. \
                multiply(df['wt'], axis = 'index')
    wdf['wt'] = df['wt']
    # Summary statistics
    results['Obs']  += [df['logwk'].count(), None]
    results['Mean'] += [np.mean(df['logwk']), None]
    results['Std']  += [np.std(df['logwk']), None]
    # Quantile regressions
    for tau in taus:
        results[tau] += quant_mincer(tau, wdf)
    # Run OLS with weights to get OLS parameters and MSE
    wls_model  = smf.ols('logwk ~ educ + black + exper + exper2 + wt - 1', wdf)
    wls_result = wls_model.fit()
    results['OLS']  += [wls_result.params['educ'], wls_result.bse['educ']]
    results['RMSE'] += [np.sqrt(wls_result.mse_resid), None]

# Export table (round the results and place them in a DataFrame to tabulate)
def format_results(the_list, the_format):
  return([the_format.format(x) if x else x for x in the_list])

table = pd.DataFrame(columns = ['Year', 'Obs', 'Mean', 'Std',
                                '0.1', '0.25', '0.5', '0.75', '0.9',
                                'OLS', 'RMSE'])

table['Year'] = ['1980', None, '1990', None, '2000', None]
table['Obs']  = format_results(results['Obs'], '{:,}')
table['Mean'] = format_results(results['Mean'], '{:.2f}')
table['Std']  = format_results(results['Std'], '{:.3f}')
table['0.1']  = format_results(results[0.1], '{:.3f}')
table['0.25'] = format_results(results[0.25], '{:.3f}')
table['0.5']  = format_results(results[0.5], '{:.3f}')
table['0.75'] = format_results(results[0.75], '{:.3f}')
table['0.9']  = format_results(results[0.9], '{:.3f}')
table['OLS']  = format_results(results['OLS'], '{:.3f}')
table['RMSE'] = format_results(results['RMSE'], '{:.2f}')

print(tabulate(table, headers = 'keys'))

# End of script
