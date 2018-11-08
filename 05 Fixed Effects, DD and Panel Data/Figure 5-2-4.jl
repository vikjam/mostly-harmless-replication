# Load packages
using FileIO, StatFiles, DataFrames
using FixedEffectModels

# Download the data and unzip it
download("http://economics.mit.edu/~dautor/outsourcingatwill_table7.zip", "outsourcingatwill_table7.zip")
run(`unzip -o outsourcingatwill_table7.zip`)

# Import data
autor = DataFrame(load("table7/autor-jole-2003.dta"));

# Log total employment: from BLS employment & earnings
autor[:lnemp] = autor[:annemp]

# Non-business-service sector employment from CBP
autor[:nonemp]  = autor[:stateemp] .- autor[:svcemp]
autor[:lnnon]   = log.(autor[:nonemp])
autor[:svcfrac] = autor[:svcemp] ./ autor[:nonemp]

# Total business services employment from CBP
autor[:bizemp] = autor[:svcemp] .+ autor[:peremp]
autor[:lnbiz]  = log.(autor[:bizemp])

# Restrict sample
autor = autor[autor[:year] .>= 79, :];
autor = autor[autor[:year] .<= 95, :];
autor = autor[autor[:state] .!= 98, :];

# State dummies, year dummies, and state*time trends
autor[:t]  = autor[:year] .- 78
autor[:t2] = autor[:t].^2

# Generate more aggregate demographics
autor[:clp]     = autor[:clg]    .+ autor[:gtc]
autor[:a1624]   = autor[:m1619]  .+ autor[:m2024] .+ autor[:f1619] .+ autor[:f2024]
autor[:a2554]   = autor[:m2554]  .+ autor[:f2554]
autor[:a55up]   = autor[:m5564]  .+ autor[:m65up] .+ autor[:f5564] .+ autor[:f65up]
autor[:fem]     = autor[:f1619]  .+ autor[:f2024] .+ autor[:f2554] .+ autor[:f5564] .+ autor[:f65up]
autor[:white]   = autor[:rs_wm]  .+ autor[:rs_wf]
autor[:black]   = autor[:rs_bm]  .+ autor[:rs_bf]
autor[:other]   = autor[:rs_om]  .+ autor[:rs_of]
autor[:married] = autor[:marfem] .+ autor[:marmale]

# Create pooled variable from state
autor[:statepooled] = categorical(autor[:state])
autor[:yearpooled]  = categorical(autor[:year])

# Diff-in-diff regression
reg(autor,
    @model(lnths ~  lnemp   + admico_2 + admico_1 + admico0  + admico1  + admico2 +
           admico3 + mico4    + admppa_2 + admppa_1 + admppa0  + admppa1 +
           admppa2 + admppa3  + mppa4    + admgfa_2 + admgfa_1 + admgfa0 +
           admgfa1 + admgfa2  + admgfa3  + mgfa4,
           fe = statepooled + yearpooled + statepooled&t))

# End of script
