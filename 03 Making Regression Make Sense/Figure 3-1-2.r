# R code for Figure 3.1.2               #
# Required packages                     #
# - ggplot2: making pretty graphs       #
# - data.table: simple way to aggregate #
library(ggplot2)
library(data.table)

# Download data and unzip the data
download.file('http://economics.mit.edu/files/397', 'asciiqob.zip')
unzip('asciiqob.zip')

# Read the data into a dataframe
pums        <- read.table('asciiqob.txt',
                          header           = FALSE,
                          stringsAsFactors = FALSE)
names(pums) <- c('lwklywge', 'educ', 'yob', 'qob', 'pob')

# Estimate OLS regression
reg.model <- lm(lwklywge ~ educ, data = pums)

# Calculate means by educ attainment and predicted values
pums.data.table <- data.table(pums)
educ.means      <- pums.data.table[ , list(mean = mean(lwklywge)), by = educ]
educ.means$yhat <- predict(reg.model, educ.means)

# Create plot
p <- ggplot(data = educ.means, aes(x = educ)) +
     geom_point(aes(y = mean))                +
     geom_line(aes(y = mean))                 +
     geom_line(aes(y = yhat))                 +
     ylab("Log weekly earnings, $2003")       +
     xlab("Years of completed education")

ggsave(filename = "Figure 3-1-2-R.pdf")


# End of file
