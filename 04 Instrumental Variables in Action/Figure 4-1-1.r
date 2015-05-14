# R code for Figure 4-1-1         #
# Required packages               #
# - dplyr: easy data manipulation #
# - ggplot2: making pretty graphs #
# - gridExtra: combine graphs     #
library(dplyr)
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
pums.qob.means      <- pums %>% group_by(yob, qob) %>% summarise_each(funs(mean))
pums.qob.means$yqob <- factor(paste(pums.qob.means$yob, pums.qob.means$qob, sep = "-"))

# Plot data
g.pums <- ggplot(pums.qob.means, aes(x = yqob))

p.educ <- g.pums + geom_line(aes(y = educ)) +
                   scale_x_continuous(breaks = 30:39)

# End of script
