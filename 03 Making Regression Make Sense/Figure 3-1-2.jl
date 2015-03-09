# Load packages
using DataFrames
using GZip
using Gadfly
using GLM

# Download the data
download("http://economics.mit.edu/files/397", "asciiqob.zip")

# Import data
pums = readtable("asciiqob.txt",
                 header    = false,
                 separator = ' ')
names!(pums, [:lwklywge, :educ, :yob, :qob, :pob])

# Run OLS and save predicted values
OLS = glm(lwklywge ~ educ, pums, Normal(), IdentityLink())
pums[:predicted] = predict(OLS)

# Aggregate into means for figure
means = aggregate(pums, :educ, [mean])

# Plot figure and export figure using Gadfly
figure = plot(means,
              layer(x = "educ", y = "predicted_mean", Geom.line, Theme(default_color = color("green"))),
              layer(x = "educ", y = "lwklywge_mean", Geom.line, Geom.point),
              Guide.xlabel("Years of completed education"),
              Guide.ylabel("Log weekly earnings, \$2003"))

draw(SVG("Figure 3-1-2-Julia.png", 5inch, 5inch), figure)

# End of script
