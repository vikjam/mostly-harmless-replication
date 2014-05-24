# R code for Figure 4.6.1           #
# Required packages                 #
# - MASS: multivariate normal draws #
# - AER: running IV regressions     #
# - ggplot2: making pretty graphs   #

library(AER)
library(MASS)
library(ivpack)
library(parallel)
library(ggplot2)

nsims = 10
set.seed(42, "L'Ecuyer")

irrelevantInstrMC <- function(...) {
    # Store coefficients
    COEFS <- rep(NA, 3)
    names(COEFS) <- c("ols", "tsls", "liml")

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
    COEFS[1] <- summary(OLS)$coefficients[1, 1]

    # 2SLS
    TSLS <- ivreg(y ~ x, ~ Z)
    COEFS[2] <- summary(TSLS)$coefficients[1, 1]

    # Return results
    return(COEFS)
}

# Run simulations
SIMBETAS <- data.frame(t(simplify2array(mclapply(1:nsims, irrelevantInstrMC))))

df <- data.frame(x = c(SIMBETAS$ols, SIMBETAS$tsls)), g = gl(2, 100))
ggplot(df, aes(x, colour = g)) + stat_ecdf()

# End of script
