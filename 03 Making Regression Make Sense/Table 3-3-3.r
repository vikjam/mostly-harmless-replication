# R code for Table 3-3-2     #
# Required packages          #

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

estimateTrainingFX <- function(dataset) {
    # Raw difference
    spec_raw  <- as.formula("re78 ~ treat")
    coef_raw  <- lm(spec_raw, data = dataset)$coefficients["treat"]

    # Demographics
    demos     <- c("age", "age2", "ed", "black", "hisp", "nodeg", "married")
    spec_demo <- paste("re78",
                       paste(c("treat", demos),
                             collapse = " + "),
                             sep      = " ~ ")
    coef_demo <- lm(spec_demo, data = dataset)$coefficients["treat"]

    # 1975 Earnings
    spec_re75 <- paste("re78 ~ treat + re75")
    coef_re75 <- lm(spec_demo, data = dataset)$coefficients["treat"]

    # Demographics, 1975 Earnings
    spec_demo_re75 <- paste("re78",
                            paste(c("treat", demos, "re75"),
                                  collapse = " + "),
                                  sep      = " ~ ")
    coef_demo_re75 <- lm(spec_demo_re75, data = dataset)$coefficients["treat"]

    # Demographics, 1974 and 1975 Earnings
    spec_demo_re74_re75 <- paste("re78",
                                 paste(c("treat", demos, "re74", "re75"),
                                       collapse = " + "),
                                       sep      = " ~ ")
    coef_demo_re74_re75 <- lm(spec_demo_re74_re75, data = dataset)$coefficients["treat"]

    c(raw            = coef_raw,
      demo           = coef_demo,
      re75           = coef_re75,
      demo_re75      = coef_demo_re75,
      demo_re74_re75 = coef_demo_re74_re75)

}

nswre74.ols  <- estimateTrainingFX(nswre74)
nswre74.ols  <- estimateTrainingFX(nswre74)
cps1re74.ols <- estimateTrainingFX(cps1re74)
cps3re74.ols <- estimateTrainingFX(cps3re74)

# End of script
