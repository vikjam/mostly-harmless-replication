# R code for Table 3-3-2     #
# Required packages          #
# - haven: read .dta files   #
# - knitr: print markdown    #
library(haven)
library(knitr)

# Download the files
download.file("http://economics.mit.edu/files/3828", "nswre74.dta")
download.file("http://economics.mit.edu/files/3824", "cps1re74.dta")
download.file("http://economics.mit.edu/files/3825", "cps3re74.dta")

# Read the Stata files into R
nswre74  <- read_dta("nswre74.dta")
cps1re74 <- read_dta("cps1re74.dta")
cps3re74 <- read_dta("cps3re74.dta")

# Function to create propensity trimmed data
propensity.trim <- function(dataset) {
    # Specify control formulas
    controls <- c("age", "age2", "ed", "black", "hisp", "nodeg", "married", "re74", "re75")
    # Paste together probit specification
    spec <- paste("treat", paste(controls, collapse = " + "), sep = " ~ ")
    # Run probit
    probit <- glm(as.formula(spec), family = binomial(link = "probit"), data = dataset)
    # Predict probability of treatment
    pscore <- predict(probit, type = "response")
    # Return data set within range
    dataset[which(pscore > 0.1 & pscore < 0.9), ]
}

# Propensity trim data
cps1re74.ptrim <- propensity.trim(cps1re74)
cps3re74.ptrim <- propensity.trim(cps3re74)

# Create function for summary statistics
summarize <- function(dataset, treat) {
    # Variables to summarize
    summary.variables <- c("age", "ed", "black", "hisp", "nodeg", "married", "re74", "re75")
    # Calculate mean, removing missing
    summary.means <- sapply(dataset[treat, summary.variables], mean, na.rm = TRUE)
    summary.count <- sum(treat)
    c(summary.means, count = summary.count)
}

# Summarize data
nswre74.treat.stats   <- summarize(nswre74, nswre74$treat == 1)
nswre74.control.stats <- summarize(nswre74, nswre74$treat == 0)
cps1re74.stats        <- summarize(cps1re74, cps1re74$treat == 0)
cps3re74.stats        <- summarize(cps3re74, cps3re74$treat == 0)
cps1re74.ptrim.stats  <- summarize(cps1re74.ptrim, cps1re74.ptrim$treat == 0)
cps3re74.ptrim.stats  <- summarize(cps3re74.ptrim, cps3re74.ptrim$treat == 0)

# Combine the summary statistics
summary.stats <- rbind(nswre74.treat.stats,
                       nswre74.control.stats,
                       cps1re74.stats,
                       cps3re74.stats,
                       cps1re74.ptrim.stats,
                       cps3re74.ptrim.stats)

# Round the digits and transpose table
summary.stats <- cbind(round(summary.stats[ , 1:6], 2),
                       formatC(round(summary.stats[ , 7:9], 0),
                               format   = "d",
                               big.mark = ","))
summary.stats <- t(summary.stats)

# Format table with row and column names
row.names(summary.stats) <- c("Age",
                              "Years of schooling",
                              "Black",
                              "Hispanic",
                              "Dropout",
                              "Married",
                              "1974 earnings",
                              "1975 earnings",
                              "Number of Obs.")

colnames(summary.stats)  <- c("NSW Treat", "NSW Control",
                              "Full CPS-1", "Full CPS-3",
                              "P-score CPS-1", "P-score CPS-3")

# Print table in markdown
print(kable(summary.stats))

# End of script
