# Julia code for Table 8-1-1                #
# Required packages                         #
# - DataFrames: data manipulation / storage #
# - Distributions: extended stats functions #
# - GLM: regression                         #
using DataFrames
using Distributions
using GLM

# Set seed
srand(08421)

nsims = 25000

function generateHC(sigma)
    # Set parameters of the simulation
    n   = 30
    r   = 0.9
    n_1 = int(r * 30)

    # Generate simulation data
    d        = ones(n)
    d[1:n_1] = 0

    r0      = Normal(0, sigma)
    r1      = Normal(0, 1)
    epsilon = [rand(r0, n_1), rand(r1, n - n_1)]

    y = 0 * d + epsilon

    simulated  = DataFrame(y = y, d = d, epsilon = epsilon)

    # Run regression, grab coef., conventional std error, and residuals
    regression = lm(y ~ d, simulated)
    b1         = coef(regression)[2]
    conv       = stderr(regression)[2]
    ehat       = simulated[:y] - predict(regression)

    # Calculate robust standard errors
    X   = [ones(n) simulated[:d]]
    vcovHC0 = inv(transpose(X) * X) * (transpose(X) * diagm(ehat.^2) * X) * inv(transpose(X) * X)
    hc0 = sqrt(vcovHC0[2, 2])
    vcovHC1 = (n / (n - 2)) * vcovHC0
    hc1 = sqrt(vcovHC1[2, 2])
    h = diag(X * inv(transpose(X) * X) * transpose(X))
    meat2 = diagm(ehat.^2) ./ (1 - h)
    vcovHC2 = inv(transpose(X) * X) * (transpose(X) * meat2 * X) * inv(transpose(X) * X)
    hc2 = sqrt(vcovHC2[2, 2])
    meat3 = diagm(ehat.^2) ./ (1 - h).^2
    vcovHC3 = inv(transpose(X) * X) * (transpose(X) * meat3 * X) * inv(transpose(X) * X)
    hc3 = sqrt(vcovHC3[2, 2])

    return [b1 conv hc0 hc1 hc2 hc3 max(conv, hc0) max(conv, hc1) max(conv, hc2) max(conv, hc3)]
end

# Function to run simulation
function simulateHC(nsims, sigma)
    # Run simulation
    simulation_results = zeros(nsims, 10)

    for i = 1:nsims
        simulation_results[i, :] = generateHC(sigma)
    end

    # Calculate mean and standard deviation
    mean_est = mean(simulation_results, 1)
    std_est  = std(simulation_results, 1)

    # Calculate rejection rates
    test_stats = simulation_results[:, 1] ./ simulation_results[:, 2:10]
    reject_z   = mean(2 * pdf(Normal(0, 1), -abs(test_stats)) .<= 0.05, 1)
    reject_t   = mean(2 * pdf(TDist(30 - 2), -abs(test_stats)) .<= 0.05, 1)

    # Combine columns
    value_labs   = ["Beta_1" "conv" "HC0" "HC1" "HC2" "HC3" "max(conv, HC0)" "max(conv, HC1)" "max(conv, HC2)" "max(conv, HC3)"]
    summ_stats   = [mean_est; std_est]
    reject_stats = [0 reject_z; 0 reject_t]

    all_stats = convert(DataFrame, transpose([value_labs; summ_stats; reject_stats]))
    names!(all_stats, [:estimate, :mean, :std, :reject_z, :reject_t])
    all_stats[1, 4:5] = NA

    return(all_stats)
end

println("Panel A")
println(simulateHC(nsims, 0.5))

println("Panel B")
println(simulateHC(nsims, 0.85))

println("Panel C")
println(simulateHC(nsims, 1))

# End of script

