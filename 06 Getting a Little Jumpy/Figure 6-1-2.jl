# Load packages
using DataFrames
using Gadfly
using Compose
using GLM

# Download the data and unzip it
# download("http://economics.mit.edu/faculty/angrist/data1/mhe/lee", "Lee2008.zip")
# run(`unzip Lee2008.zip`)

# Read the data
lee = readtable("Lee2008/individ_final.csv")

# Subset by non-missing in the outcome and running variable for panel (a)
panel_a = lee[!isna(lee[:, Symbol("difshare")]) & !isna(lee[:, Symbol("myoutcomenext")]), :]

# Create indicator when crossing the cut-off
panel_a[:d] = (panel_a[:difshare] .>= 0) .* 1.0

# Predict with local polynomial logit of degree 4
panel_a[:difshare2] = panel_a[:difshare].^2
panel_a[:difshare3] = panel_a[:difshare].^3
panel_a[:difshare4] = panel_a[:difshare].^4

logit = glm(myoutcomenext ~ difshare   + difshare2   + difshare3   + difshare4   + d +
                            d*difshare + d*difshare2 + d*difshare3 + d*difshare4,
            panel_a,
            Binomial(),
            LogitLink())
panel_a[:mmyoutcomenext] = predict(logit)

# Create local average by 0.005 interval of the running variable
panel_a[:i005] = cut(panel_a[:difshare], collect(-1:0.005:1))
mean_panel_a   = aggregate(panel_a, :i005, [mean])

# Restrict within bandwidth of +/- 0.251
restriction_a = (mean_panel_a[:difshare_mean] .> -0.251) & (mean_panel_a[:difshare_mean] .< 0.251)
mean_panel_a  = mean_panel_a[restriction_a, :]

# Plot panel (a)
plot_a = plot(layer(x = mean_panel_a[:difshare_mean],
                  y = mean_panel_a[:myoutcomenext_mean],
                  Geom.point),
              layer(x = mean_panel_a[mean_panel_a[:difshare_mean] .< 0, :difshare_mean],
                    y = mean_panel_a[mean_panel_a[:difshare_mean] .< 0, :mmyoutcomenext_mean],
                    Geom.line),
              layer(x = mean_panel_a[mean_panel_a[:difshare_mean] .>= 0, :difshare_mean],
                    y = mean_panel_a[mean_panel_a[:difshare_mean] .>= 0, :mmyoutcomenext_mean],
                    Geom.line),
              layer(xintercept = [0],
                    Geom.vline,
                    Theme(line_style = Gadfly.get_stroke_vector(:dot))),
              Guide.xlabel("Democratic Vote Share Margin of Victory, Election t"),
              Guide.ylabel("Probability of Victory, Election t+1"),
              Guide.title("a"))

# Create local average by 0.005 interval of the running variable
panel_b        = lee[!isna(lee[:, Symbol("difshare")]) & !isna(lee[:, Symbol("mofficeexp")]), :]
panel_b[:i005] = cut(panel_b[:difshare], collect(-1:0.005:1))
mean_panel_b   = aggregate(panel_b, :i005, [mean])

# Restrict within bandwidth of +/- 0.251
restriction_b = (mean_panel_b[:difshare_mean] .> -0.251) & (mean_panel_b[:difshare_mean] .< 0.251)
mean_panel_b  = mean_panel_b[restriction_b, :]

# Plot panel (b)
plot_b = plot(layer(x = mean_panel_b[:difshare_mean],
                  y = mean_panel_b[:mofficeexp_mean],
                  Geom.point),
              layer(x = mean_panel_b[mean_panel_b[:difshare_mean] .< 0, :difshare_mean],
                    y = mean_panel_b[mean_panel_b[:difshare_mean] .< 0, :mpofficeexp_mean],
                    Geom.line),
              layer(x = mean_panel_b[mean_panel_b[:difshare_mean] .>= 0, :difshare_mean],
                    y = mean_panel_b[mean_panel_b[:difshare_mean] .>= 0, :mpofficeexp_mean],
                    Geom.line),
              layer(xintercept = [0],
                    Geom.vline,
                    Theme(line_style = Gadfly.get_stroke_vector(:dot))),             
              Guide.xlabel("Democratic Vote Share Margin of Victory, Election t"),
              Guide.ylabel("No. of Past Victories as of Election t"),
              Guide.title("b"))

# Combine plots
draw(PNG("Figure 6-1-2-Julia.png", 6inch, 8inch), vstack(plot_a, plot_b))

# End of script
