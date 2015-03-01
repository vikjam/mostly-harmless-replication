# R code for Figure 4.6.1                 #
# Required packages                       #
# - MASS: multivariate normal draws       #
# - AER: running IV regressions           #
# - RcompAngrist: LIML estimators         #
# - parallel: Parallel process simulation #
# - ggplot2: making pretty graphs         #

library(AER)
library(MASS)
library(RcompAngrist)
library(parallel)
library(ggplot2)
library(RColorBrewer)
library(reshape)

nsims = 1000
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
    x = 0.1 * Z[ , 1] + xi
    y = x + eta

    # Create data.frame from the simulated values
    simulated.data        <- data.frame(cbind(y, x, Z))
    names(simulated.data) <- c("y", "x", paste("z", seq(20), sep=""))

    # OLS
    OLS           <- lm(y ~ x)
    COEFS["ols"]  <- summary(OLS)$coefficients[2, 1]

    # 2SLS
    TSLS          <- ivreg(y ~ x, ~ Z)
    COEFS["tsls"] <- summary(TSLS)$coefficients[2, 1]

    # LIML
    LIML          <- kclass(y ~ x | Z)
    COEFS["liml"] <- LIML$coefficients[1]

    # Return results
    return(COEFS)
}

# Run simulations
SIMBETAS <- data.frame(t(simplify2array(mclapply(1:nsims, irrelevantInstrMC))))

df           <- melt(SIMBETAS[ , 1:3])
names(df)    <- c("Estimator", "beta")
df$Estimator <- factor(df$Estimator, 
                       levels = c("ols", "tsls", "liml"),
                       labels = c("OLS", "2SLS", "LIML"))

g <- ggplot(df, aes(x = beta, colour = Estimator, linetype = Estimator))        +
        stat_ecdf(geom = "smooth")                                              +
        xlab(expression(widehat(beta))) + ylab(expression(F[n](widehat(beta)))) +
        scale_linetype_manual(values = c("solid", "longdash", "twodash"))       +
        scale_color_manual(values = brewer.pal(3, "Set1"),
                           labels = c("OLS", "2SLS", "LIML"))                   +
        theme_set(theme_gray(base_size = 24))                                   
ggsave(file = "iv-mc-r.png", height = 9, width = 12, dpi = 200)

# End of script
