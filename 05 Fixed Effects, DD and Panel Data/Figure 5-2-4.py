#!/usr/bin/env python
"""
Tested on Python 3.4
"""
import urllib.request
import zipfile
import pandas as pd
import numpy as np

# Download data and unzip the data
urllib.request.urlretrieve('http://economics.mit.edu/~dautor/outsourcingatwill_table7.zip', 'outsourcingatwill_table7.zip')
with zipfile.ZipFile('outsourcingatwill_table7.zip', 'r') as z:
  z.extractall()

# Import data
autor = pd.read_stata('table7/autor-jole-2003.dta')

# End of script
