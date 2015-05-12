# R code for Table 8-1-1              #
# Required packages                   #
# - sandwich: robust standard error   #
library(sandwich)

# Set seed for replication
set.seed(1984, "L'Ecuyer")

# Set number of simulations
nsims = 25

clusterBiasSim <- function(sigma = 1,...) {
    # Set parameters of the simulation
    N   = 30
    r   = 0.9
    N_1 = r * 30

    # Generate data
    d       <- c(rep(0, N_1), rep(1, N - N_1))
    epsilon <- rnorm(n = N, sd = sigma, ) * (d == 0) + rnorm(n = N) * (d == 1)
    y       <- 0 * d + epsilon  
    simulated.data <- data.frame(y = y, d = d)
    
    # Run regression
    lm.sim <- lm(y ~ d, data = simulated.data)
    b1     <- coef(lm.sim)[2]

    # Calculate standard errors
    conventional <- sqrt(vcov(lm.sim)[2, 2])
    hc0          <- sqrt(vcovHC(lm.sim, type = "HC0")[2, 2])
    hc1          <- sqrt(vcovHC(lm.sim, type = "HC1")[2, 2])
    hc2          <- sqrt(vcovHC(lm.sim, type = "HC2")[2, 2])
    hc3          <- sqrt(vcovHC(lm.sim, type = "HC3")[2, 2])

    # Return the results of a simulation
    data.frame(b1            = b1,
               conventional  = conventional,
               hc0           = hc0,
               hc1           = hc1,
               hc2           = hc2,
               hc3           = hc3)
}

# Run simulations
simulated.results <- do.call(rbind, lapply(1:nsims, clusterBiasSim, sigma = 1))
