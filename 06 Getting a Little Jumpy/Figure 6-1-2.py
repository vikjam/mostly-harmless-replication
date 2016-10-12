#!/usr/bin/env python
"""
Create Figure 6.1.2 in MHE
Tested on Python 3.4
pandas: import .dta and manipulate data
altair: plot figures
"""
import urllib
import zipfile
import urllib.request
import pandas
import matplotlib.pyplot as plt
import seaborn as sns
import numpy
from patsy import dmatrices
from sklearn.linear_model import LogisticRegression

# Download data and unzip the data
urllib.request.urlretrieve('http://economics.mit.edu/faculty/angrist/data1/mhe/lee', 'Lee2008.zip')
with zipfile.ZipFile('Lee2008.zip', 'r') as z:
   z.extractall()

# Load the data
lee = pandas.read_stata('Lee2008/individ_final.dta')

# Subset by non-missing in the outcome and running variable for panel (a)
panel_a = lee[['myoutcomenext', 'difshare']].dropna(axis = 0)

# Create indicator when crossing the cut-off
panel_a['d'] = (panel_a['difshare'] >= 0) * 1.0

# Create matrices for logistic regression
y, X  = dmatrices('myoutcomenext ~ d*(difshare + numpy.power(difshare, 2) + numpy.power(difshare, 3) + numpy.power(difshare, 4))', panel_a)

# Flatten y into a 1-D array for the sklearn LogisticRegression
y = numpy.ravel(y)

# Run the logistic regression
logit = LogisticRegression().fit(X, y)

# Produce predicted probabilities
panel_a['predict'] = logit.predict_proba(X)[:, 1]

# Create 0.005 intervals of the running variable
breaks          = numpy.arange(-1.0, 1.005, 0.005)
panel_a['i005'] = pandas.cut(panel_a['difshare'], breaks)

# Calculate means by interval
mean_panel_a  = panel_a.groupby('i005').mean().dropna(axis = 0)
restriction_a = (mean_panel_a['difshare'] > -0.251) & (mean_panel_a['difshare'] < 0.251)
mean_panel_a  = mean_panel_a[restriction_a]

# Calculate means for panel (b)
panel_b         = lee[['difshare', 'mofficeexp', 'mpofficeexp']].dropna(axis = 0)
panel_b['i005'] = pandas.cut(panel_b['difshare'], breaks)
mean_panel_b    = panel_b.groupby('i005').mean().dropna(axis = 0)
restriction_b   = (mean_panel_b['difshare'] > -0.251) & (mean_panel_b['difshare'] < 0.251)
mean_panel_b    = mean_panel_b[restriction_b]

# Plot figures
fig = plt.figure(figsize = (7, 7))

# Panel (a)
ax_a = fig.add_subplot(211)
ax_a.scatter(mean_panel_a['difshare'],
	         mean_panel_a['myoutcomenext'],
	         edgecolors = 'none', color = 'black')
ax_a.plot(mean_panel_a['difshare'][mean_panel_a['difshare'] >= 0],
	      mean_panel_a['predict'][mean_panel_a['difshare'] >= 0],
	      color = 'black')
ax_a.plot(mean_panel_a['difshare'][mean_panel_a['difshare'] < 0],
	      mean_panel_a['predict'][mean_panel_a['difshare'] < 0],
	      color = 'black')
ax_a.axvline(0, linestyle = '--', color = 'black')
ax_a.set_title('a')

# Panel (b)
ax_b = fig.add_subplot(212)
ax_b.scatter(mean_panel_b['difshare'],
	         mean_panel_b['mofficeexp'],
	         edgecolors = 'none', color = 'black')
ax_b.plot(mean_panel_b['difshare'][mean_panel_b['difshare'] >= 0],
	      mean_panel_b['mpofficeexp'][mean_panel_b['difshare'] >= 0],
	      color = 'black')
ax_b.plot(mean_panel_b['difshare'][mean_panel_b['difshare'] < 0],
	      mean_panel_b['mpofficeexp'][mean_panel_b['difshare'] < 0],
	      color = 'black')
ax_b.axvline(0, linestyle = '--', color = 'black')
ax_b.set_title('b')

plt.tight_layout()
plt.savefig('Figure 6-1-2-Python.png', dpi = 300)

# End of script
