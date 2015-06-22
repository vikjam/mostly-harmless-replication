#!/usr/bin/env python
"""
Tested on Python 3.4
"""

import urllib.request
import pandas as pd
import statsmodels.api as sm
import numpy as np
import patsy
from tabulate import tabulate

# Download data
urllib.request.urlretrieve('http://economics.mit.edu/files/3828', 'nswre74.dta')
urllib.request.urlretrieve('http://economics.mit.edu/files/3824', 'cps1re74.dta')
urllib.request.urlretrieve('http://economics.mit.edu/files/3825', 'cps3re74.dta')

# Read the Stata files into Python
nswre74  = pd.read_stata("nswre74.dta")
cps1re74 = pd.read_stata("cps1re74.dta")
cps3re74 = pd.read_stata("cps3re74.dta")

# Store list of variables for summary
summary_vars = ['age', 'ed', 'black', 'hisp', 'nodeg', 'married', 're74', 're75']

# Calculate propensity scores
# Create formula for probit
f = 'treat ~ ' + ' + '.join(['age', 'age2', 'ed', 'black', 'hisp', \
                             'nodeg', 'married', 're74', 're75'])

# Run probit with CPS-1
y, X   = patsy.dmatrices(f, cps1re74, return_type = 'dataframe')
model  = sm.Probit(y, X).fit()
cps1re74['pscore'] = model.predict(X)

# Run probit with CPS-3
y, X   = patsy.dmatrices(f, cps3re74, return_type = 'dataframe')
model  = sm.Probit(y, X).fit()
cps3re74['pscore'] = model.predict(X)

# Create function to summarize data
def summarize(dataset, conditions):
  stats          = dataset[summary_vars][conditions].mean()
  stats['count'] = sum(conditions)
  return stats

# Summarize data
nswre74_treat_stats    = summarize(nswre74, nswre74.treat == 1)
nswre74_control_stats  = summarize(nswre74, nswre74.treat == 0)
cps1re74_control_stats = summarize(cps1re74, cps1re74.treat == 0)
cps3re74_control_stats = summarize(cps3re74, cps3re74.treat == 0)
cps1re74_ptrim_stats   = summarize(cps1re74, (cps1re74.treat == 0)   & \
                                             (cps1re74.pscore > 0.1) & \
                                             (cps1re74.pscore < 0.9))
cps3re74_ptrim_stats   = summarize(cps3re74, (cps3re74.treat == 0)   & \
                                             (cps3re74.pscore > 0.1) & \
                                             (cps3re74.pscore < 0.9))

# Combine summary stats, add header and print to markdown
frames = [nswre74_treat_stats,
          nswre74_control_stats,
          cps1re74_control_stats,
          cps3re74_control_stats,
          cps1re74_ptrim_stats,
          cps3re74_ptrim_stats]

summary_stats = pd.concat(frames, axis = 1)
header        = ["NSW Treat", "NSW Control", \
                 "Full CPS-1", "Full CPS-3", \
                 "P-score CPS-1", "P-score CPS-3"]

print(tabulate(summary_stats, header, tablefmt = "pipe"))

# End of script
