# R code for Table 8-1-1              #
# Required packages                   #
# - sandwich: robust standard error   #
library(sandwich)
library(data.table)
library(knitr)

# Set seed for replication
set.seed(1984, "L'Ecuyer")

# Set parameters
NSIMS = 25000
N     = 30
r     = 0.9
N1    = r * N
sigma = 1  

# Generate random data
dvec           <- c(rep(0, N1), rep(1, N - N1))
simulated.data <- data.table(sim     = rep(1:NSIMS, each = N),
                             y       = NA, 
                             d       = rep(dvec, NSIMS),
                             epsilon = NA)
simulated.data[ , epsilon := ifelse(d == 1,
                                    rnorm((N - N1) * 25),
                                    rnorm(N1 * NSIMS, sd = sigma))]
simulated.data[ , y := 0 * d + epsilon]

# Store a list of the standard error types
se.types <- c("const", paste0("HC", 0:3))

# Create a function to extract standard errors
calculate.se <- function(lm.obj, type) {
    sqrt(vcovHC(lm.obj, type = type)[2, 2])
}

# Function to calculate results
calculateBias <- function(formula) {
    lm.sim <- lm(formula)
    b1     <- coef(lm.sim)[2]
    se.sim <- sapply(se.types, calculate.se, lm.obj = lm.sim)
    c(b1, se.sim)
}
simulated.results <- simulated.data[ , as.list(calculateBias(y ~ d)), by = sim]

# End of script
