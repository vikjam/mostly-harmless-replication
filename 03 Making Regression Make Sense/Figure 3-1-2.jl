# Load packages
using DataFrames
using Gzip

# Download the data
download("http://economics.mit.edu/files/397", "asciiqob.zip")

# Import data
pums = readtable("asciiqob.txt",
                 header    = false,
                 separator = ' ')

names!(pums, [:lwklywge, :educ, :yob, :qob, :pob])

# End of script
