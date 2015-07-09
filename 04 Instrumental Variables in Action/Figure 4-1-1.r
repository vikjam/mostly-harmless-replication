# R code for Figure 4-1-1         #
# Required packages               #
# - dplyr: easy data manipulation #
# - lubridate: data management    #
# - ggplot2: making pretty graphs #
# - gridExtra: combine graphs     #
library(lubridate)
library(dplyr)
library(ggplot2)
library(gridExtra)

# Download data and unzip the data
download.file('http://economics.mit.edu/files/397', 'asciiqob.zip')
unzip('asciiqob.zip')

# Read the data into a dataframe
pums        <- read.table('asciiqob.txt',
                          header           = FALSE,
                          stringsAsFactors = FALSE)
names(pums) <- c('lwklywge', 'educ', 'yob', 'qob', 'pob')

# Collapse for means
pums.qob.means      <- pums %>% group_by(yob, qob) %>% summarise_each(funs(mean))

# Add dates
pums.qob.means$yqob <- ymd(paste0("19",
                                  pums.qob.means$yob,
                                  pums.qob.means$qob * 3),
                           truncated = 2)

# Function for plotting data
plot.qob <- function(ggplot.obj, ggtitle, ylab) {
  gg.colours <- c("firebrick", rep("black", 3), "white")
  ggplot.obj + geom_line()                                              +
               geom_point(aes(colour = factor(qob)),
                              size = 5)                                 +
               geom_text(aes(label = qob, colour = "white"),
                         size  = 3,
                         hjust = 0.5, vjust = 0.5,
                         show_guide = FALSE)                            +
               scale_colour_manual(values = gg.colours, guide = FALSE)  +
               ggtitle(ggtitle)                                         +
               xlab("Year of birth")                                    +
               ylab(ylab)                                               +
               theme_set(theme_gray(base_size = 10))
}

# Plot
p.educ     <- plot.qob(ggplot(pums.qob.means, aes(x = yqob, y = educ)),
                       "A. Average education by quarter of birth (first stage)",
                       "Years of education")
p.lwklywge <- plot.qob(ggplot(pums.qob.means, aes(x = yqob, y = lwklywge)),
                       "B. Average weekly wage by quarter of birth (reduced form)",
                       "Log weekly earnings")

p.ivgraph  <- arrangeGrob(p.educ, p.lwklywge)

ggsave(p.ivgraph, file = "Figure 4-1-1-R.png", height = 12, width = 8, dpi = 300)

# End of script
