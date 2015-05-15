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

# Labels
pums.qob.means$labels                          <- pums.qob.means$yob
pums.qob.means$labels[pums.qob.means$qob != 1] <- ""

# Plot data
g.pums <- ggplot(pums.qob.means, aes(x = yqob), group = 1)

p.educ <- g.pums + geom_line(aes(y = educ, group = 1))                        +
                   geom_point(aes(y = educ, shape = factor(qob)))             +
                   geom_text(aes(y = educ, label = qob),
                             size  = 4,
                             hjust = 0.5, vjust = -0.5,
                             show_guide = FALSE)                              +
                   scale_x_discrete(labels = pums.qob.means$labels)           +
                   scale_shape_manual(values = c(15, 0, 0, 0), guide = FALSE) +
                   xlab("Year of birth")                                      +
                   ylab("Years of education")                                 +
                   theme_set(theme_gray(base_size = 12))

p.lwklywge <- g.pums + geom_line(aes(y = lwklywge, group = 1))                +
                   geom_point(aes(y = lwklywge, shape = factor(qob)))         +
                   geom_text(aes(y = lwklywge, label = qob),
                             size  = 4,
                             hjust = -0.5, vjust = 0,
                             show_guide = FALSE)                              +
                   scale_x_discrete(labels = pums.qob.means$labels)           +
                   scale_shape_manual(values = c(15, 0, 0, 0), guide = FALSE) +
                   xlab("Year of birth")                                      +
                   ylab("Log weekly earnings")                                +
                   theme_set(theme_gray(base_size = 12))

p.ivgraph  <- arrangeGrob(p.educ, p.lwklywge)

ggsave(p.ivgraph, file = "Figure 4-1-1-R.png", height = 12, width = 8, dpi = 300)

# End of script
