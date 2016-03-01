# Load packages
using DataFrames
using Gadfly
using Distributions
using CurveFit
using Colors

# Set seed
srand(08421)

# Set number of simulations
nsims = 100

# Set distributions for random draws
uniform = Uniform(0, 1)
normal  = Normal(0, 0.1) 

# Generate series
x         = rand(uniform, nsims)
y_linear  = x .+ (x .> 0.5) .* 0.25 .+ rand(normal, nsims)
y_nonlin  = 0.5 .* sin(6 .* (x .- 0.5)) .+ 0.5 .+ (x .> 0.5) .* 0.25 .+ rand(normal, nsims)
y_mistake = 1 ./ (1 .+ exp(-25 .* (x .- 0.5))) .+ rand(normal, nsims)

# Fit lines using user-created function
function rdfit(x, y, cutoff, degree)
    coef_0 = curve_fit(Poly, x[cutoff .>= x], y[cutoff .>= x], degree)
    fit_0  = fit(x[cutoff .>= x])

    coef_1 = curve_fit(Poly, x[x .> cutoff], y[x .> cutoff], degree)
    fit_1  = fit(x[x .> cutoff])

    nx_0 = length(x[x .> cutoff])

    df_0 = DataFrame(x_0 = x[cutoff .>= x], fit_0 = fit_0)
    df_1 = DataFrame(x_1 = x[x .> cutoff],  fit_1 = fit_1)
    na_0 = DataFrame(repeat([NA], outer = [100 - nx_0, 2]))
    na_1 = DataFrame(repeat([NA], outer = [nx_0, 2]))
    names!(na_0, [:x_0, :fit_0])
    names!(na_1, [:x_1, :fit_1])
    append!(df_0, na_0)
    append!(na_0, df_0)

    df = DataFrame(x_0   = append!(x[cutoff .>= x], repmat([NA], 100 - nx_0, 1)[:]),
                   fit_0 = append!(fit_0, repmat([NA], 100 - nx_0, 1)[:]),
                   x_1   = append!(repmat([NA], nx_0, 1)[:], x[x .> cutoff]),
                   fit_0 = append!(repmat([NA], nx_0, 1)[:], fit_1),
                   x     = x,
                   y     = y)
    return df
end

data_linear  = rdfit(x, y_linear, 0.5, 1)
data_nonlin  = rdfit(x, y_nonlin, 0.5, 2)
data_mistake = rdfit(x, y_mistake, 0.5, 2)

plot(data_linear_0, layer(x = "x_0", y = "fit_0", Geom.line, Theme(default_color = parse(Colorant, "green"))))

# End of script
