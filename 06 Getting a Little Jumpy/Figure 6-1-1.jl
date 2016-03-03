# Load packages
using DataFrames
using Gadfly
using Cairo
using Fontconfig
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
function rdfit(xvar, yvar, cutoff, degree)
    coef_0 = curve_fit(Poly, xvar[cutoff .>= x], yvar[cutoff .>= x], degree)
    fit_0  = coef_0(xvar[cutoff .>= x])

    coef_1 = curve_fit(Poly, xvar[xvar .> cutoff], yvar[xvar .> cutoff], degree)
    fit_1  = coef_1(xvar[xvar .> cutoff])

    nx_0 = length(xvar[xvar .> cutoff])

    df_0 = DataFrame(x_0 = xvar[cutoff .>= xvar], fit_0 = fit_0)
    df_1 = DataFrame(x_1 = xvar[xvar .> cutoff],  fit_1 = fit_1)
 
    return df_0, df_1
end

data_linear_0, data_linear_1 = rdfit(x, y_linear, 0.5, 1)
data_nonlin_0, data_nonlin_1 = rdfit(x, y_nonlin, 0.5, 2)
data_mistake_0, data_mistake_1 = rdfit(x, y_mistake, 0.5, 1)

p_linear = plot(layer(x = x, y = y_linear, Geom.point),
                layer(x = data_linear_0[:x_0], y = data_linear_0[:fit_0], Geom.line),
                layer(x = data_linear_1[:x_1], y = data_linear_1[:fit_1], Geom.line),
                layer(xintercept = [0.5], Geom.vline),
                Guide.xlabel("x"),
                Guide.ylabel("Outcome"),
                Guide.title("A. Linear E[Y<sub>01</sub> | X<sub>i</sub>]"))

p_nonlin = plot(layer(x = x, y = y_nonlin, Geom.point),
                layer(x = data_nonlin_0[:x_0], y = data_nonlin_0[:fit_0], Geom.line),
                layer(x = data_nonlin_1[:x_1], y = data_nonlin_1[:fit_1], Geom.line),
                layer(xintercept = [0.5], Geom.vline),
                Guide.xlabel("x"),
                Guide.ylabel("Outcome"),
                Guide.title("B. Nonlinear E[Y<sub>01</sub> | X<sub>i</sub>]"))

function rd_mistake(x)
    1 / (1 + exp(-25 * (x - 0.5)))
end

p_mistake = plot(layer(x = x, y = y_mistake, Geom.point),
                 layer(x = data_mistake_0[:x_0], y = data_mistake_0[:fit_0], Geom.line),
                 layer(x = data_mistake_1[:x_1], y = data_mistake_1[:fit_1], Geom.line),
                 layer(rd_mistake, 0, 1),
                 layer(xintercept = [0.5], Geom.vline),
                 Guide.xlabel("x"),
                 Guide.ylabel("Outcome"),
                 Guide.title("C. Nonlinearity mistaken for discontinuity"))

draw(PNG("Figure 6-1-1-Julia.png", 6inch, 8inch), vstack(p_linear, p_nonlin, p_mistake))

# End of script
