# R code for Figure 4.6.1                 #
# Required packages                       #
# - MASS: multivariate normal draws       #
# - ivmodel: IV regressions               #
# - parallel: Parallel process simulation #
# - ggplot2: making pretty graphs         #
# - RColorBrewer: pleasing color schemes  #
# - reshape: manipulate data              #
library(MASS)
library(ivmodel)
library(parallel)
library(ggplot2)
library(RColorBrewer)
library(reshape)

nsims = 100000
set.seed(1984, "L'Ecuyer")

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

    # OLS
    OLS           <- lm(y ~ x)
    COEFS["ols"]  <- summary(OLS)$coefficients[2, 1]

    # Run IV regressions
    ivregressions <- ivmodel(Y = y, D = x, Z = Z)
    COEFS["tsls"] <- coef.ivmodel(ivregressions)["TSLS", "Estimate"]
    COEFS["liml"] <- coef.ivmodel(ivregressions)["LIML", "Estimate"]

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
        stat_ecdf(geom = "step")                                                +
        xlab(expression(widehat(beta))) + ylab(expression(F[n](widehat(beta)))) +
        xlim(0, 2.5)                                                            +
        scale_linetype_manual(values = c("solid", "longdash", "twodash"))       +
        scale_color_manual(values = brewer.pal(3, "Set1"),
                           labels = c("OLS", "2SLS", "LIML"))                   +
        geom_vline(xintercept = 1.0, linetype = "longdash")                     +
        geom_hline(yintercept = 0.5, linetype = "longdash")                     +
        theme(axis.title.y = element_text(angle=0))                             +
        theme_set(theme_gray(base_size = 24))                                   
ggsave(file = "Figure 4-6-1-R.png", height = 8, width = 12, dpi = 300)

write.csv(df, "Figure 4-6-1.csv")
# End of script
