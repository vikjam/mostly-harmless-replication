#!/usr/bin/env python
"""
Create Figure 4-6-1 in MHE
Tested on Python 3.4
"""

import zipfile
import urllib.request
import pandas as pd
import statsmodels.api as sm
import matplotlib.pyplot as plt
from matplotlib.ticker import FormatStrFormatter

# Download data and unzip the data
urllib.request.urlretrieve('http://economics.mit.edu/files/397', 'asciiqob.zip')
with zipfile.ZipFile('asciiqob.zip', "r") as z:
   z.extractall()

# Read the data into a pandas dataframe
pums         = pd.read_csv('asciiqob.txt',
                           header           = None,
                           delim_whitespace = True)
pums.columns = ['lwklywge', 'educ', 'yob', 'qob', 'pob']

# Calculate means by educ and lwklywge
groupbybirth = pums.groupby(['yob', 'qob'])
birth_means  = groupbybirth['lwklywge', 'educ'].mean()

# Create function to plot figures
def plot_qob(yvar, ax, title, ylabel):
    values = yvar.values
    ax.plot(values, color = 'k')

    for i, y in enumerate(yvar):
        qob = yvar.index.get_level_values('qob')[i]
        ax.annotate(qob,
                    (i, y),
                    xytext = (-5, 5),
                    textcoords = 'offset points')
        if qob == 1:
            ax.scatter(i, y, marker = 's', facecolors = 'none', edgecolors = 'k')
        else:
            ax.scatter(i, y, marker = 's', color = 'k')

    ax.set_xticks(range(0, len(yvar), 4))
    ax.set_xticklabels(yvar.index.get_level_values('yob')[1::4])
    ax.set_title(title)
    ax.set_ylabel(ylabel)
    ax.yaxis.set_major_formatter(FormatStrFormatter('%.2f'))
    ax.set_xlabel("Year of birth")
    ax.margins(0.1)

fig, (ax1, ax2) = plt.subplots(2, sharex = True)

plot_qob(yvar   = birth_means['educ'],
         ax     = ax1,
         title  = 'A. Average education by quarter of birth (first stage)',
         ylabel = 'Years of education')

plot_qob(yvar   = birth_means['lwklywge'],
         ax     = ax2,
         title  = 'B. Average weekly wage by quarter of birth (reduced form)',
         ylabel = 'Log weekly earnings')

fig.tight_layout()
fig.savefig('Figure 4-1-1-Python.pdf', format = 'pdf')

# End of file
