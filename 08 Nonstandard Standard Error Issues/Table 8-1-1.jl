# Julia code for Table 8-1-1                #
# Required packages                         #
# - DataFrames: data manipulation / storage #
# - Distributions: extended stats functions #
# - GLM: regression                         #
# - YTables: output markdown                #
using DataFrames
using Distributions
using GLM
using YTables

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
    ehat  = simulated[:y] - predict(regression)

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

    return [b1 conv hc0 hc1 hc2 hc3]
end

simulation_results = zeros(nsims, 6)

for i = 1:nsims
    simulation_results[i, :] = generateHC(0.5)
end
