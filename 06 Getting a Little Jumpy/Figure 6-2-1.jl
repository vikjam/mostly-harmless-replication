# Load packages
using DataFrames
using Gadfly

# Download the data
download("http://economics.mit.edu/files/1359", "final4.dta")
download("http://economics.mit.edu/files/1358", "final5.dta")

# Load the data
grade4 = readtable("final4.csv");
grade5 = readtable("final5.csv");

# Find means class size by grade size
grade4      = grade4[[:c_size, :classize]];
grade4means = aggregate(grade4, :c_size, [mean])

grade5      = grade5[[:c_size, :classize]];
grade5means = aggregate(grade5, :c_size, [mean])

# Create function for Maimonides Rule
function maimonides_rule(x)
    x / (floor((x - 1)/40) + 1)
end

ticks = collect(0:20:220)
p_grade4 = plot(layer(x = grade4means[:c_size], y = grade4means[:classize_mean], Geom.line),
                layer(maimonides_rule, 1, 220, Theme(line_style = Gadfly.get_stroke_vector(:dot))),
                Guide.xticks(ticks = ticks),
                Guide.xlabel("Enrollment count"),
                Guide.ylabel("Class size"),
                Guide.title("B. Fourth grade"))

p_grade5 = plot(layer(x = grade5means[:c_size], y = grade5means[:classize_mean], Geom.line),
                layer(maimonides_rule, 1, 220, Theme(line_style = Gadfly.get_stroke_vector(:dot))),
                Guide.xticks(ticks = ticks),
                Guide.xlabel("Enrollment count"),
                Guide.ylabel("Class size"),
                Guide.title("A. Fifth grade"))

draw(PNG("Figure 6-2-1-Julia.png", 6inch, 8inch), vstack(p_grade5, p_grade4))

# End of script
