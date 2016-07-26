# R code for Table 4-1-1        #
# Required packages             #
# - data.table: data management #
# - sandwich: standard errors   #
# - AER: running IV regressions #

library(data.table)
library(sandwich)
library(AER)

# Download data and unzip the data
download.file('http://economics.mit.edu/files/397', 'asciiqob.zip')
unzip('asciiqob.zip')

# Read the data into a data.table
pums        <- fread('asciiqob.txt',
                     header           = FALSE,
                     stringsAsFactors = FALSE)
names(pums) <- c('lwklywge', 'educ', 'yob', 'qob', 'pob')

# Column 1: OLS
col1 <- lm(lwklywge ~ educ, pums)

# Column 2: OLS with YOB, POB dummies
col2 <- lm(lwklywge ~ educ + factor(yob) + factor(pob), pums)

# Create dummies for quarter of birth
qobs      <- unique(pums$qob)
qobs.vars <- sapply(qobs, function(x) paste0('qob', x))
pums[, (qobs.vars) := lapply(qobs, function(x) qob == x)]

# Column 3: 2SLS with instrument QOB = 1
col3 <- ivreg(lwklywge ~ educ, ~ qob1, pums)

# Column 4: 2SLS with YOB, POB dummies and instrument QOB = 1
col4 <- ivreg(lwklywge ~ factor(yob) + factor(pob) + educ,
	                   ~ factor(yob) + factor(pob) + qob1,
	          pums)

# Create dummy for quarter 1 or 2
pums[, qob1or2 := qob == 1 | qob == 2]

# Column 5: 2SLS with YOB, POB dummies and instrument (QOB = 1 | QOB = 2)
col5 <- ivreg(lwklywge ~ factor(yob) + factor(pob) + educ,
                       ~ factor(yob) + factor(pob) + qob1or2,
              pums)

# Column 6: 2SLS with YOB, POB dummies and full QOB dummies
col6 <- ivreg(lwklywge ~ factor(yob) + factor(pob) + educ,
	                   ~ factor(yob) + factor(pob) + factor(qob),
	          pums)

# Column 7: 2SLS with YOB, POB dummies and full QOB dummies interacted with YOB
col7 <- ivreg(lwklywge ~ factor(yob) + factor(pob) + educ,
	                   ~ factor(pob) + factor(qob) * factor(yob),
	          pums)

# Column 8: 2SLS with age, YOB, POB dummies and with full QOB dummies interacted with YOB
col8 <- ivreg(lwklywge ~ factor(yob) + factor(pob) + educ,
	                   ~ factor(pob) + factor(qob) * factor(yob),
	          pums)

# End of script
