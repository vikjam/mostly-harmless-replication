# Load packages
using DataFrames
using DataRead

# Download the data
download('http://economics.mit.edu/files/3828', 'nswre74.dta')
download('http://economics.mit.edu/files/3824', 'cps1re74.dta')
download('http://economics.mit.edu/files/3825', 'cps3re74.dta')

# # Read the Stata files into Julia
# nswre74  = read_dta("nswre74.dta")
# cps1re74 = read_dta("cps1re74.dta")
# cps3re74 = read_dta("cps3re74.dta")

# Read the CSV files into Julia
nswre74  = readtable("nswre74.csv")
cps1re74 = readtable("cps1re74.csv")
cps3re74 = readtable("cps3re74.csv")

summary_vars = [:age, :ed, :black], :hisp, :nodeg, :married, :re74, :re75]
nswre74_stat = aggregate(nswre74, summary_vars, [mean])

# End of script
