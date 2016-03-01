# R code for Figure 6-2-1         #
# Required packages               #
# - haven: read Stata .dta files  #
# - ggplot2: making pretty graphs #
# - gridExtra: combine graphs     #
library(haven)
library(ggplot2)
library(gridExtra)

# Download the data
download.file("http://economics.mit.edu/files/1359", "final4.dta")
download.file("http://economics.mit.edu/files/1358", "final5.dta")

# Load the data
grade4 <- read_dta("final4.dta")
grade5 <- read_dta("final5.dta")

# Restrict sample
grade4 <- grade4[which(grade4$classize & grade4$classize < 45 & grade4$c_size > 5), ]
grade5 <- grade5[which(grade5$classize & grade5$classize < 45 & grade5$c_size > 5), ]

# Find means class size by grade size
grade4cmeans <- aggregate(grade4$classize,
                          by  = list(grade4$c_size),
                          FUN = mean,
                          na.rm = TRUE)
grade5cmeans <- aggregate(grade5$classize,
                          by  = list(grade5$c_size),
                          FUN = mean,
                          na.rm = TRUE)

# Rename aggregaed columns
colnames(grade4cmeans) <- c("c_size", "classize.mean")
colnames(grade5cmeans) <- c("c_size", "classize.mean")

# Create function for Maimonides Rule
maimonides.rule <- function(x) {x / (floor((x - 1)/40) + 1)}

# Plot each grade
g4 <- ggplot(data = grade4cmeans, aes(x = c_size))
p4 <- g4 + geom_line(aes(y = classize.mean))            +
           stat_function(fun      = maimonides.rule,
                         linetype = "dashed")           +
           expand_limits(y = 0)                         +
           scale_x_continuous(breaks = seq(0, 220, 20)) +
           ylab("Class size")                           +
           xlab("Enrollment count")                     +
           ggtitle("B. Fourth grade")

g5 <- ggplot(data = grade5cmeans, aes(x = c_size))
p5 <- g5 + geom_line(aes(y = classize.mean))            +
           stat_function(fun      = maimonides.rule,
                         linetype = "dashed")           +
           expand_limits(y = 0)                         +
           scale_x_continuous(breaks = seq(0, 220, 20)) + 
           ylab("Class size")                           +
           xlab("Enrollment count")                     +
           ggtitle("A. Fifth grade")

first.stage <- arrangeGrob(p5, p4, ncol = 1)
ggsave(first.stage, file = "Figure 6-2-1-R.png", height = 8, width = 5, dpi = 300)

# End of script
