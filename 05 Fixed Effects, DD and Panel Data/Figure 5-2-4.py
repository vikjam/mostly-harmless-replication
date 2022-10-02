#!/usr/bin/env python
"""
Tested on Python 3.8.5
"""
import urllib.request
import zipfile
import pandas as pd
import numpy as np
from linearmodels.panel import PanelOLS
import seaborn as sns
import matplotlib.pyplot as plt

# Download data and unzip the data
urllib.request.urlretrieve('https://www.dropbox.com/s/m6o0704ohzwep4s/outsourcingatwill_table7.zip?dl=1', 'outsourcingatwill_table7.zip')
with zipfile.ZipFile('outsourcingatwill_table7.zip', 'r') as z:
  z.extractall()

# Import data
autor = pd.read_stata("table7/autor-jole-2003.dta")

# Log total employment: from BLS employment & earnings
autor["lnemp"] = np.log(autor["annemp"])

# Non-business-service sector employment from CBP
autor["nonemp"] = autor["stateemp"] - autor["svcemp"]
autor["lnnon"] = np.log(autor["nonemp"])
autor["svcfrac"] = autor["svcemp"] / autor["nonemp"]

# Total business services employment from CBP
autor["bizemp"] = autor["svcemp"] + autor["peremp"]
autor["lnbiz"] = np.log(autor["bizemp"])

# Restrict sample
autor = autor[autor["year"] >= 79]
autor = autor[autor["year"] <= 95]
autor = autor[autor["state"] != 98]

# State dummies, year dummies, and state*time trends
autor["t"] = autor["year"] - 78
autor["t2"] = autor["t"] ** 2

# Generate more aggregate demographics
autor["clp"] = autor["clg"] + autor["gtc"]
autor["a1624"] = autor["m1619"] + autor["m2024"] + autor["f1619"] + autor["f2024"]
autor["a2554"] = autor["m2554"] + autor["f2554"]
autor["a55up"] = autor["m5564"] + autor["m65up"] + autor["f5564"] + autor["f65up"]
autor["fem"] = (
    autor["f1619"] + autor["f2024"] + autor["f2554"] + autor["f5564"] + autor["f65up"]
)
autor["white"] = autor["rs_wm"] + autor["rs_wf"]
autor["black"] = autor["rs_bm"] + autor["rs_bf"]
autor["other"] = autor["rs_om"] + autor["rs_of"]
autor["married"] = autor["marfem"] + autor["marmale"]

# Create categorical for state
autor["state_c"] = pd.Categorical(autor["state"])

# Set index for use with linearmodels
autor = autor.set_index(["state", "year"], drop=False)

# Diff-in-diff regression
did = PanelOLS.from_formula(
    (
        "lnths ~"
        "1 +"
        "lnemp +"
        "admico_2 + admico_1 + admico0 + admico1 + admico2 + admico3 + mico4 +"
        "admppa_2 + admppa_1 + admppa0 + admppa1 + admppa2 + admppa3 + mppa4 +"
        "admgfa_2 + admgfa_1 + admgfa0 + admgfa1 + admgfa2 + admgfa3 + mgfa4 +"
        "state_c:t +"
        "EntityEffects + TimeEffects"
    ),
    data=autor,
    drop_absorbed=True
).fit(cov_type='clustered', cluster_entity=True)

# Store results in a DataFrame for a plot
results_did = pd.DataFrame(
    {"coef": did.params * 100, "ci": 1.96 * did.std_errors * 100}
)

# Keep only the relevant coefficients
results_did = results_did.filter(regex="admico|mico", axis=0).reset_index()

# Define labels for coefficients
results_did_labels = [
    "2 yr prior",
    "1 yr prior",
    "Yr of adopt",
    "1 yr after",
    "2 yr after",
    "3 yr after",
    "4+ yr after",
]

# Make plot
fig, ax = plt.subplots()

ax.errorbar(x="index", y="coef", yerr="ci", marker=".", data=results_did)
ax.axhline(y=0)
ax.set_xticklabels(results_did_labels)
ax.set_xlabel(
    ("Time passage relative to year of adoption of " "implied contract exception")
)
ax.set_ylabel("Log points")

plt.tight_layout()
plt.show()
plt.savefig("Figure 5-2-4-Python.png", format="png")

# End of script
