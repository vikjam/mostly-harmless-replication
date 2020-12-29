# Load packages
using CSV
using DataFrames
using GLM
using Statistics
using Gadfly
using Cairo

# Download the data and unzip it
download("http://economics.mit.edu/files/397", "asciiqob.zip")
run(`unzip asciiqob.zip`)

# Import data
pums = DataFrame(CSV.File("asciiqob.txt", header = false, delim = " ",  ignorerepeated = true))
rename!(pums, [:lwklywge, :educ, :yob, :qob, :pob])

# Run OLS and save predicted values
OLS = lm(@formula(lwklywge ~ educ), pums)
pums.predicted = predict(OLS)

# Aggregate into means for figure
means = combine(groupby(pums, :educ), [:lwklywge, :predicted] .=> mean)

# Plot figure and export figure using Gadfly
figure = plot(means,
              layer(x = "educ", y = "predicted_mean", Geom.line, Theme(default_color = colorant"green")),
              layer(x = "educ", y = "lwklywge_mean", Geom.line, Geom.point),
              Guide.xlabel("Years of completed education"),
              Guide.ylabel("Log weekly earnings, \$2003"))

draw(PNG("Figure 3-1-2-Julia.png", 7inch, 6inch), figure)

# End of script
