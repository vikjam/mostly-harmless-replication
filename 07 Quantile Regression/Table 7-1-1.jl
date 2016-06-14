# Julia code for Table 8-1-1                #
# Required packages                         #
# - DataRead: import Stata datasets         #
# - DataFrames: data manipulation / storage #
# - QuantileRegression: quantile regression #
# - GLM: OLS regression                     #
using DataRead
using DataFrames
using QuantileRegression
using GLM

# Download the data and unzip it
download("http://economics.mit.edu/files/384", "angcherfer06.zip")
run(`unzip angcherfer06.zip`)

# Load the data
dta_path = string("Data/census", "80", ".csv")
df       = readtable(dta_path)

# Summary statistics
obs = size(df[:logwk], 1)
μ   = mean(df[:logwk])
σ   = std(df[:logwk])

# Run OLS
wls      = glm(logwk ~ educ + black + exper + exper2, df,
	           Normal(), IdentityLink(),
	           wts = convert(Array, (df[:perwt])))
wls_coef = coef(wls)[2]
wls_se   = stderr(wls)[2]
wls_rmse = sqrt(sum((df[:logwk] - predict(wls)).^2) / df_residual(wls))

# Print results
print(obs, μ, σ, wls_coef, wls_se, wls_rmse)

# End of script
