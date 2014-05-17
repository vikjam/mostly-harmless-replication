# R code for Figure 4.6.1           #
# Required packages                 #
# - MASS: multivariate normal draws #
# - AER: running IV regressions     #
# - ggplot2: making pretty graphs   #

library(AER)
library(MASS)

nsims = 10000
set.seed(42)

# Set parameters
Sigma  = matrix(c(1, 0.8, 0.8, 1), 2, 2)
errors = mvrnorm(n = 1000, rep(0, 2), Sigma)
eta    = errors[ , 1]
xi     = errors[ , 2]

# Create Z, x, y
Z = sapply(1:20, function(x) rnorm(1000))
x = 0.1*Z[ , 1] + xi
y = x + eta

# OLS
OLS <- lm(y ~ x)
# 2SLS


# End of script
