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

# Download data and unzip the data
# urllib.request.urlretrieve('http://economics.mit.edu/files/397', 'asciiqob.zip')
# with zipfile.ZipFile('asciiqob.zip', "r") as z:
#    z.extractall()

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
    values = birth_means['educ'].values
    ax.plot(values)
    ax.title('A. Average education by quarter of birth (first stage)')
    ax.set_ylabel(ylabel)
    ax.set_xlabel("Quarter of birth")

fig, ax = plt.subplots()
plot_qob(birth_means['educ'], ax, 'A. Average education by quarter of birth (first stage)', 'Years of education')

# Panel A
plt.subplot(2, 1, 1)
plt.title("A. Average education by quarter of birth (first stage)")
plt.set_ylabel("Years of education")
birth_means.plot(y = 'educ', marker = 'o')

# Panel B
plt.subplot(2, 1, 2)
plt.title("B. Average weekly wage by quarter of birth (reduced form)")
plt.set_ylabel("Log weekly earnings")
birth_means.plot(y = 'lwklywge', marker = 'o')

# Format overall figure and export to PDF
plt.legend().set_visible(False)
plt.tight_layout() # http://matplotlib.org/users/tight_layout_guide.html
plt.savefig('Figure 4-1-1-Python.pdf', format = 'pdf')
plt.close('all')

# End of file
