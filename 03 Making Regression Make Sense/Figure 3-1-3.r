# R code for Figure 3.1.3                           #
# Required packages                                 #
# - sandwhich: robust standard errors               #
# - lmtest: print table with robust standard errors #
# - data.table: aggregate function                  #
library(sandwich)
library(lmtest)

# Download data and unzip the data
download.file('http://economics.mit.edu/files/397', 'asciiqob.zip')
unzip('asciiqob.zip')

# Read the data into a dataframe
pums        <- read.table('asciiqob.txt',
                          header           = FALSE,
                          stringsAsFactors = FALSE)
names(pums) <- c('lwklywge', 'educ', 'yob', 'qob', 'pob')

# Panel A
# Estimate OLS regression
reg.model <- lm(lwklywge ~ educ, data = pums)
# Robust standard errors
robust.reg.vcov <- vcovHC(reg.model, "HC1")
# Print results
print(summary(reg.model))
print(coeftest(reg.model, vcov = robust.reg.vcov))

# Panel B
# Figure out which observations appear in the regression
sample          <- !is.na(predict(reg.model, data = pums))
pums.data.table <- data.table(pums[sample, ])
# Aggregate
educ.means <- pums.data.table[ , list(mean  = mean(lwklywge),
                                      count = length(lwklywge)),
                                  by = educ]
# Estimate weighted OLS regression
wgt.reg.model <- lm(lwklywge ~ educ,
                    weights = pums.data.table$count,
                    data    = pums.data.table)
# Robust standard errors with weighted OLS regression
wgt.robust.reg.vcov  <- vcovHC(wgt.reg.model, "HC1")
# Print results
print(summary(wgt.reg.model))
print(coeftest(wgt.reg.model, vcov = wgt.reg.vcov))

# End of file
