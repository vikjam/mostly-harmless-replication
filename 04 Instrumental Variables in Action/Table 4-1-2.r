# R code for Table 4-1-2        #
# Required packages             #
# - data.table: data management #
# - systemfit: SUR              #
library(data.table)
library(systemfit)

# Download data and unzip the data
download.file('http://economics.mit.edu/files/397', 'asciiqob.zip')
unzip('asciiqob.zip')

# Read the data into a data.table
pums        <- fread('asciiqob.txt',
                     header           = FALSE,
                     stringsAsFactors = FALSE)
names(pums) <- c('lwklywge', 'educ', 'yob', 'qob', 'pob')

# Create binary variable
pums$z <- (pums$qob == 3 | pums$qob == 4) * 1

# Compare means (and differences)
ttest.lwklywge <- t.test(lwklywge ~ z, pums)
ttest.educ     <- t.test(educ ~ z, pums)

# Compute Wald estimate
sur  <- systemfit(list(first  = educ ~ z,
	                   second = lwklywge ~ z),
                  data   = pums,
                  method = "SUR")
wald <- deltaMethod(sur, "second_z / first_z")

wald.estimate <- (mean(pums$lwklywge[pums$z == 1]) - mean(pums$lwklywge[pums$z == 0])) /
                 (mean(pums$educ[pums$z == 1]) - mean(pums$educ[pums$z == 0]))
wald.se       <- wald.estimate^2 * ()

# OLS estimate
ols <- lm(lwklywge ~ educ, pums)

# Construct table
lwklywge.row <- c(ttest.lwklywge$estimate[1],
				  ttest.lwklywge$estimate[2],
				  ttest.lwklywge$estimate[2] - ttest.lwklywge$estimate[1])
educ.row     <- c(ttest.educ$estimate[1],
				  ttest.educ$estimate[2],
				  ttest.educ$estimate[2] - ttest.educ$estimate[1])
wald.row.est <- c(NA, NA, wald$Estimate)
wald.row.se  <- c(NA, NA, wald$SE)

ols.row.est <- c(NA, NA, summary(ols)$coef['educ' , 'Estimate'])
ols.row.se  <- c(NA, NA, summary(ols)$coef['educ' , 'Std. Error'])

table           <- rbind(lwklywge.row, educ.row,
	                     wald.row.est, wald.row.se,
	                     ols.row.est, ols.row.se)
colnames(table) <- c("Born in the 1st or 2nd quarter of year",
	                 "Born in the 3rd or 4th quarter of year",
	                 "Difference")
rownames(table) <- c("ln(weekly wage)",
	                 "Years of education",
	                 "Wald estimate",
	                 "Wald std error",
	                 "OLS estimate",
	                 "OLS std error")

# End of script
