# R code for Table 7.1.1           #
# Required packages                #
# - haven: read in .dta files      #
# - quantreg: quantile regressions #
# - knitr: markdown tables         #
library(haven)
library(quantreg)
library(knitr)

# Download data and unzip the data
download.file('http://economics.mit.edu/files/384', 'angcherfer06.zip')
unzip('angcherfer06.zip')

# Create a function to run the quantile/OLS regressions so we can use a loop
quant.mincer <- function(tau, data) {
    r <- rq(logwk ~ educ + black + exper + exper2,
            weights = perwt,
            data    = data,
            tau     = tau)
    return(rbind(summary(r)$coefficients["educ", "Value"],
                 summary(r)$coefficients["educ", "Std. Error"]))
}

# Create function for producing the results
calculate.qr <- function(year) {

    # Create file path
    dta.path <- paste('Data/census', year, '.dta', sep = "")

    # Load year into the census
    df <- read_dta(dta.path)

    # Run quantile regressions
    taus <- c(0.1, 0.25, 0.5, 0.75, 0.9)
    qr   <- sapply(taus, quant.mincer, data = df)

    # Run OLS regressions and get RMSE
    ols     <- lm(logwk ~ educ + black + exper + exper2,
                  weights = perwt,
                  data    = df)
    coef.se <- rbind(summary(ols)$coefficients["educ", "Estimate"],
                     summary(ols)$coefficients["educ", "Std. Error"])
    rmse    <- sqrt(sum(summary(ols)$residuals^2) / ols$df.residual)

    # Summary statistics
    obs  <- length(na.omit(df$educ))
    mean <- mean(df$logwk, na.rm = TRUE)
    sd   <- sd(df$logwk, na.rm = TRUE)

    return(cbind(rbind(obs, NA),
                 rbind(mean, NA),
                 rbind(sd, NA),
                 qr,
                 coef.se,
                 rbind(rmse, NA)))

}

# Generate results
results <- rbind(calculate.qr("80"),
                 calculate.qr("90"),
                 calculate.qr("00"))

# Name rows and columns
row.names(results) <- c("1980", "", "1990", "", "2000", "")
colnames(results)  <- c("Obs", "Mean", "Std Dev",
                        "0.1", "0.25", "0.5", "0.75", "0.9",
                        "OLS", "RMSE")

# Format decimals
results              <- round(results, 3)
results[ , c(2, 10)] <- round(results[ , c(2, 10)], 2)
results[ , 1]        <- formatC(results[ , 1], format = "d", big.mark = ",")

# Export table
print(kable(results))

# End of file
