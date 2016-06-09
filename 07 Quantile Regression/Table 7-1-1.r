# R code for Table 7.1.1           #
# Required packages                #
# - haven: read in .dta files      #
# - quantreg: quantile regressions #
# - broom: manipulate results      #
# - knitr: markdown tables         #
library(haven)
library(quantreg)
library(broom)
library(plyr)

# Download data and unzip the data
download.file('http://economics.mit.edu/files/384', 'angcherfer06.zip')
unzip('angcherfer06.zip')

# Create a function to run the quantile regressions so we can use a loop
quant.mincer <- function(tau, data) {
    qr <- rq(logwk ~ educ + black + exper + exper2,
             weights = perwt,
             data    = data,
             tau     = tau)
    return(qr)
}

# Create function for producing the results
calculate.qr <- function(year) {

    # Create file path
    dta.path <- paste('Data/census', year, '.dta', sep = "")

    # Load year into the census
    df <- read_dta(dta.path)

    # Run quantile regressions
    taus              <- c(0.25, 0.5, 0.75, 0.9)
    qr.results        <- lapply(taus, quant.mincer, data = df)
    names(qr.results) <- paste("qr", taus, sep = "")

    # Run OLS regressions and get MSE
    qr.results$ols <- lm(logwk ~ educ + black + exper + exper2,
                         weights = perwt,
                         data    = df)
    qr.results$mse <- mean(summary(qr.results$ols)$residuals^2, na.rm = TRUE)

    # Summary statistics
    qr.results$obs  <- length(na.omit(df$educ))
    qr.results$mean <- mean(df$educ, na.rm = TRUE)
    qr.results$sd   <- sd(df$educ, na.rm = TRUE)

    return(qr.results)

}

years          <- c("80", "90", "00")
results        <- lapply(years, calculate.qr)
names(results) <- paste("y", results, sep = "")

extract.results <- function(year) {
    coef.row <- cbind(year$obs, year$mean, year$sd, year$mse)
    se.row   <-  
    return(rbind(coef.row, se.row))
}

# End of file
