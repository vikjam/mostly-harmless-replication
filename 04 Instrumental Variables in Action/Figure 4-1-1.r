# R code for Figure 4-1-1         #
# Required packages               #
# - xts: date management          #
# - dplyr: easy data manipulation #
# - ggplot2: making pretty graphs #
# - gridExtra: combine graphs     #
library(dplyr)
library(xts)
library(ggplot2)
library(gridExtra)

# Download data and unzip the data
# download.file('http://economics.mit.edu/files/397', 'asciiqob.zip')
# unzip('asciiqob.zip')

# Read the data into a dataframe
pums = read.table('asciiqob.txt',
                  header           = FALSE,
                  stringsAsFactors = FALSE)
names(pums) <- c('lwklywge', 'educ', 'yob', 'qob', 'pob')

# Collapse for means
pums.qob.means <- pums %>% group_by(yob, qob) %>% summarise_each(funs(mean))
pums.qob.xts   <- xts(x        = pums.qob.means,
                      order.by = as.yearqtr(paste(1900 + pums.qob.means$yob, pums.qob.means$qob, sep = "-")))
pums.qob.xts$date <- as.Date(time(pums.qob.xts))

# Plot data
g.pums <- ggplot(pums.qob.xts, aes(x = date))

p.educ <- g.pums + geom_line(aes(y = educ))

# End of script
