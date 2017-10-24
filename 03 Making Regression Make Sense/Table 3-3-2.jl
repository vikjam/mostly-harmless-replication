# Load packages
using DataFrames
using FileIO, StatFiles
using GLM

# Download the data
download("http://economics.mit.edu/files/3828", "nswre74.dta")
download("http://economics.mit.edu/files/3824", "cps1re74.dta")
download("http://economics.mit.edu/files/3825", "cps3re74.dta")

# Read the Stata files into Julia
nswre74  = DataFrame(load("nswre74.dta"))
cps1re74 = DataFrame(load("cps1re74.dta"))
cps3re74 = DataFrame(load("cps3re74.dta"))

summary_vars = [:age, :ed, :black, :hisp, :nodeg, :married, :re74, :re75]
nswre74_stat = aggregate(nswre74, summary_vars, [mean])

# Calculate propensity scores
probit = glm(@formula(treat ~ age + age2 + ed + black + hisp + 
                      nodeg + married + re74 + re75),
             cps1re74,
             Binomial(),
             ProbitLink())
cps1re74[:pscore] = predict(probit)

probit = glm(@formula(treat ~ age + age2 + ed + black + hisp +
                      nodeg + married + re74 + re75),
             cps3re74,
             Binomial(),
             ProbitLink())
cps3re74[:pscore] = predict(probit)

# Create function to summarize data
function summarize(data, condition)
    stats         = aggregate(data[condition, summary_vars],
                              mean)
    stats[:count] = size(data[condition, summary_vars])[1]
    return(stats)
end

# Summarize data
nswre74_treat_stats    = summarize(nswre74, nswre74[:treat] .== 1)
nswre74_control_stats  = summarize(nswre74, nswre74[:treat] .== 0)
cps1re74_control_stats = summarize(cps1re74, cps1re74[:treat] .== 0)
cps3re74_control_stats = summarize(cps3re74, cps3re74[:treat] .== 0)
cps1re74_ptrim_stats   = summarize(cps1re74, broadcast(&, cps1re74[:treat]  .== 0,
                                             cps1re74[:pscore] .> 0.1,
                                             cps1re74[:pscore] .< 0.9))
cps3re74_ptrim_stats   = summarize(cps3re74, broadcast(&, cps3re74[:treat]  .== 0,
                                             cps3re74[:pscore] .> 0.1,
                                             cps3re74[:pscore] .< 0.9))

# Combine summary stats, add header and print to markdown
table      = vcat(nswre74_treat_stats,
                  nswre74_control_stats,
                  cps1re74_control_stats,
                  cps3re74_control_stats,
                  cps1re74_ptrim_stats,
                  cps3re74_ptrim_stats)
table[:id] = 1:size(table, 1)
table      = stack(table, [:age_mean, :ed_mean, :black_mean, :hisp_mean,
                           :nodeg_mean, :married_mean, :re74_mean, :re75_mean, :count])
table      = unstack(table, :variable, :id, :value)

names!(table, [:Variable, :NSWTreat, :NSWControl,
               :FullCPS1, :FullCPS3, :PscoreCPS1, :PscoreCPS3])

println(table)

# End of script
