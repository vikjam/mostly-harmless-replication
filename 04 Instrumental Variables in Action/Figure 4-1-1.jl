# Load packages
using DataFrames
using Gadfly
using GLM

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
means[:date] = [Date(1900 + y, m * 3, 1) for (y, m) in zip(means[:yob], means[:qob])]

# Plot
p = plot(means,
		 layer(x = "date", y = "educ_mean", Geom.point, Geom.line))
p = plot(means,
		 layer(x = "date", y = "lwklywge_mean", Geom.point, Geom.line))

# End of file
