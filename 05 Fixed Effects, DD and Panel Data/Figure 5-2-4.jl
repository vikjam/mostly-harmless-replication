# Load packages
using DataFrames
using DataRead

# Download the data and unzip it
download('http://economics.mit.edu/~dautor/outsourcingatwill_table7.zip', 'outsourcingatwill_table7.zip')
run(`unzip outsourcingatwill_table7.zip`)

# Import data
autor = pd.read_stata('table7/autor-jole-2003.dta')

# End of script
