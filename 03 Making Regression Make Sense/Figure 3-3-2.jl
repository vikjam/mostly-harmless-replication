# Load packages
using DataFrames
using DataRead

# Download the data
download('http://economics.mit.edu/files/3828', 'nswre74.dta')
download('http://economics.mit.edu/files/3824', 'cps1re74.dta')
download('http://economics.mit.edu/files/3825', 'cps3re74.dta')

# Read the Stata files into Python
nswre74  = read_dta("nswre74.dta")
cps1re74 = read_dta("cps1re74.dta")
cps3re74 = read_dta("cps3re74.dta")

# End of script
