# Load packages
using DataFrames
using Gadfly
using GLM
using Dates

# Download the data and unzip it
download("http://economics.mit.edu/files/397", "asciiqob.zip")
run(`unzip -o asciiqob.zip`)

# Import data
pums = readtable("asciiqob.txt",
                 header    = false,
                 separator = ' ')
names!(pums, [:lwklywge, :educ, :yob, :qob, :pob])

# Aggregate into means for figure
means = aggregate(pums, [:yob, :qob], [mean])

# Create dates
n = nrow(means)
means[:date] = NA
for i = 1:n
    means[:date][i] = DateTime(1900 + means[:yob][i], means[:qob][i] * 12, 1)
end

# End of file
