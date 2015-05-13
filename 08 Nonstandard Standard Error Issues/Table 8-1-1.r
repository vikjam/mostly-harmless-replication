# R code for Table 8-1-1              #
# Required packages                   #
# - sandwich: robust standard error   #
# - parallel: parallelize simulation  #
# - plyr: apply functions             #
# - lmtest: simplifies testing        #
# - reshape2: reshapin' data          #
library(sandwich)
library(parallel)
library(plyr)
library(lmtest)
library(reshape2)

# Set seed for replication
set.seed(1984, "L'Ecuyer")

# Set number of simulations
nsims = 25000

# Create a function to extract standard errors
calculate.se <- function(lm.obj, type) {
    sqrt(vcovHC(lm.obj, type = type)[2,2])
}

# Create function to calculate max of conventional versus robust, returning max
compare.conv <- function(conventional, x) {
    max(conventional, x)
}

# Create function for rejection rate
reject.rate <- function(x) {
    mean(ifelse(x <= 0.05, 1, 0))
}

# Create function for simulation
clusterBiasSim <- function(sigma = 1,...) {
    # Set parameters of the simulation
    N   = 30
    r   = 0.9
    N_1 = r * 30

    # Generate data
    d              <- c(rep(0, N_1), rep(1, N - N_1))
    epsilon        <- rnorm(n = N, sd = sigma) * (d == 0) + rnorm(n = N) * (d == 1)
    y              <- 0 * d + epsilon  
    simulated.data <- data.frame(y = y, d = d)
    
    # Run regression
    lm.sim <- lm(y ~ d, data = simulated.data)
    b1     <- coef(lm.sim)[2]

    # Store a list of the standard error types
    se.types <- c("const", paste0("HC", 0:3))

    # Calculate standard errors
    se.sim <- sapply(se.types, calculate.se, lm.obj = lm.sim)

    # Calculate maximiums
    se.compare        <- sapply(se.sim[-1],
                                compare.conv,
                                conventional = se.sim[1])
    names(se.compare) <- paste0("max.const.", names(se.compare))
    
    # Return the results of a simulation
    data.frame(b1, t(se.sim), t(se.compare))
}

# Function for running simulations and returning table of results
summarizeBias <- function(nsims = 25000, sigma = 1) {
    # Run simulation
    simulated.results <- do.call(rbind,
                                 mclapply(1:nsims,
                                          clusterBiasSim,
                                          sigma = sigma))
    # Calculate rejections
    melted.sims     <- melt(simulated.results, measure = 2:10)
    melted.sims$z.p <- 2 * pnorm(abs(melted.sims$b1 / melted.sims$value),
                                 lower.tail = FALSE)
    melted.sims$t.p <- 2 * pt(abs(melted.sims$b1 / melted.sims$value),
                              df = 30 - 2,
                              lower.tail = FALSE)

    rejections <- aggregate(melted.sims[ , c("z.p", "t.p")],
                            by  = list(melted.sims$variable),
                            FUN = reject.rate)
    rownames(rejections) <- rejections$Group.1

    # Get means and standard deviations
    summarize.table <- sapply(simulated.results,
                              each(mean, sd),
                              na.rm = TRUE)
    summarize.table <- t(summarize.table)

    # Return all the results as one data.frame
    merge(summarize.table, rejections[-1], by = "row.names", all.x = TRUE)
}

# Panel A
print(summarizeBias(nsims = nsims, sigma = 0.5), digits = 3)
# Panel B
print(summarizeBias(nsims = nsims, sigma = 0.85), digits = 3)
# Panel C
print(summarizeBias(nsims = nsims, sigma = 1), digits = 3)

# End of file
