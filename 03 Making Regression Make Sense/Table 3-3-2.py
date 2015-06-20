#!/usr/bin/env python
"""
Tested on Python 3.4
"""

import urllib.request
import pandas as pd
import statsmodels.api as sm
import matplotlib.pyplot as plt

# Download data
urllib.request.urlretrieve('http://economics.mit.edu/files/3828', 'nswre74.dta')
urllib.request.urlretrieve('http://economics.mit.edu/files/3824', 'cps1re74.dta')
urllib.request.urlretrieve('http://economics.mit.edu/files/3825', 'cps3re74.dta')

# Read the Stata files into Python
nswre74  = pd.read_stata("nswre74.dta")
cps1re74 = pd.read_stata("cps1re74.dta")
cps3re74 = pd.read_stata("cps3re74.dta")

# End of script
