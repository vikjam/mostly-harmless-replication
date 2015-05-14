# R code for Table 8-1-1              #
# Required packages                   #
# - sandwich: robust standard error   #
# - parallel: parallelize simulation  #
# - plyr: apply functions             #
# - lmtest: simplifies testing        #
# - reshape2: reshapin' data          #
# - knitr: print markdown tables      #
library(sandwich)
library(parallel)
library(plyr)
library(lmtest)
library(reshape2)
library(knitr)

# Set seed for replication
set.seed(1984, "L'Ecuyer")

# Set number of simulations
nsims = 25000

# Set parameters of the simulation
N   = 30
r   = 0.9
N_1 = r * 30

# Store a list of the standard error types
se.types <- c("const", paste0("HC", 0:3))

# Create a function to extract standard errors
calculate.se <- function(lm.obj, type) {
    sqrt(vcovHC(lm.obj, type = type)[2, 2])
}

# Create function to calculate max of conventional versus robust, returning max
compare.conv <- function(conventional, x) {
    pmax(conventional, x)
}

# Create function for rejection rate
reject.rate <- function(x) {
    mean(ifelse(x <= 0.05, 1, 0))
}

# Create function for simulation
clusterBiasSim <- function(sigma = 1,...) {
    # Generate data
    d              <- c(rep(0, N_1), rep(1, N - N_1))
    epsilon        <- rnorm(n = N, sd = sigma) * (d == 0) + rnorm(n = N) * (d == 1)
    y              <- 0 * d + epsilon  
    simulated.data <- data.frame(y = y, d = d)
    
    # Run regression
    lm.sim <- lm(y ~ d, data = simulated.data)
    b1     <- coef(lm.sim)[2]

    # Calculate standard errors
    se.sim <- sapply(se.types, calculate.se, lm.obj = lm.sim)
    
    # Return the results of a simulation
    data.frame(b1, t(se.sim))
}

# Function for running simulations and returning table of results
summarizeBias <- function(nsims = 25000, sigma = 1) {
    # Run simulation
    simulated.results <- do.call(rbind,
                                 mclapply(1:nsims,
                                          clusterBiasSim,
                                          sigma = sigma))

    # Calculate maximums
    se.compare        <- sapply(simulated.results[ , se.types[-1]],
                                compare.conv,
                                conventional = simulated.results$const)
    colnames(se.compare) <- paste0("max.const.", colnames(se.compare))
    simulated.results <- data.frame(simulated.results, se.compare)

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

# Function for printing results to markdown
printBias <- function(obj.df) {
    colnames(obj.df) <- c("Estimate", "Mean", "Std", "Normal", "t")
    obj.df$Estimate  <- c("Beta_1", "Conventional",
                          paste0("HC", 0:3),
                          paste0("max(Conventional, HC", 0:3, ")"))
    print(kable(obj.df, digits = 3))
}

# Panel A
panel.a <- summarizeBias(nsims = nsims, sigma = 0.5)
printBias(panel.a)
# Panel B
panel.b <- summarizeBias(nsims = nsims, sigma = 0.85)
printBias(panel.b)
# Panel C
panel.c <- summarizeBias(nsims = nsims, sigma = 1)
printBias(panel.c)

# End of file
