# Julia code for Table 4-6-1                #
# Required packages                         #
# - DataFrames: data manipulation / storage #
# - Distributions: extended stats functions #
# - FixedEffectModels: IV regression        #
using DataFrames
using Distributions
using FixedEffectModels
using GLM
using Gadfly

# Number of simulations
nsims = 1000

# Set seed
srand(113643)

# Set parameters
Sigma = [1.0 0.8;
         0.8 1.0]
N     = 1000

function irrelevantInstrMC()
    # Create Z, xi and eta
    Z      = DataFrame(transpose(rand(MvNormal(eye(20)), N)))
    errors = DataFrame(transpose(rand(MvNormal(Sigma), N)))

    # Rename columns of Z and errors
    names!(Z, [Symbol("z$i") for i in 1:20])
    names!(errors, [:eta, :xi])

    # Create y and x
    df     = hcat(Z, errors);
    df[:x] = 0.1 .* df[:z1] .+ df[:xi]
    df[:y] = df[:x] .+ df[:eta]

    # Run regressions
    ols  = coef(lm(@formula(y ~ x), df))[2]
    tsls = coef(reg(df, @model(y ~ z1  + z2  + z3  + z4  + z5  + z6  + z7  + z8  + z9  + z10 +
                             z11 + z12 + z13 + z14 + z15 + z16 + z17 + z18 + z19 + z20)))[2]
    return([ols tsls])
end

# Simulate IV regressions
simulation_results = zeros(nsims, 2);
for i = 1:nsims
    simulation_results[i, :] = irrelevantInstrMC()
end

# Create empirical CDFs from simulated results
ols_ecdf  = ecdf(simulation_results[:, 1])
tsls_ecdf = ecdf(simulation_results[:, 2])

# Plot the empirical CDFs of each estimator
p = plot(layer(ols_ecdf, 0, 2.5, Theme(default_color = colorant"red")),
         layer(tsls_ecdf, 0, 2.5, Theme(line_style = :dot)),
         layer(xintercept = [0.5], Geom.vline,
               Theme(default_color = colorant"black", line_style = :dot)),
         layer(yintercept = [0.5], Geom.hline,
               Theme(default_color = colorant"black", line_style = :dot)),
         Guide.xlabel("Estimated β"),
         Guide.ylabel("F<sub>n</sub>(Estimated β)"))

# Export figure as .png
draw(PNG("Figure 4-6-1-Julia.png", 7inch, 6inch), p)

# End of script
