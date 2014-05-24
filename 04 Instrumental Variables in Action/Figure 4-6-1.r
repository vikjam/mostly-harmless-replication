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
library(reshape)

nsims = 10000
set.seed(42, "L'Ecuyer")

irrelevantInstrMC <- function(...) {
    # Store coefficients
    COEFS        <- rep(NA, 3)
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
    OLS      <- lm(y ~ x)
    COEFS[1] <- summary(OLS)$coefficients[2, 1]
    print(summary(OLS))

    # 2SLS
    TSLS     <- ivreg(y ~ x, ~ Z)
    COEFS[2] <- summary(TSLS)$coefficients[2, 1]

    # Return results
    return(COEFS)
}

# Run simulations
SIMBETAS <- data.frame(t(simplify2array(mclapply(1:nsims, irrelevantInstrMC))))

df           <- melt(SIMBETAS[ , 1:2])
names(df)    <- c("Estimator", "beta")
df$Estimator <- factor(df$Estimator, 
                       levels = c("ols", "tsls", "liml"),
                       labels = c("OLS", "2SLS", "LIML"))
g <- ggplot(df, aes(x = beta, colour = Estimator, linetype = Estimator))              + 
        stat_ecdf(geom = "smooth")                                                    +
        xlab(expression(widehat(beta))) + ylab(expression(F[n](widehat(beta))))       +
        scale_linetype_manual(values = c("solid", "longdash", "dotted"))              +
        scale_color_manual(values = brewer.pal(3, "Set1"), labels = c("OLS", "2SLS")) +
        theme_set(theme_gray(base_size = 24))                                   
ggsave(file = "iv-mc-r.png", height = 9, width = 12, dpi = 200)

# End of script
