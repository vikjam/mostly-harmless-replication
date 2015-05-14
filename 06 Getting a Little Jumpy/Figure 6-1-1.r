# R code for Figure 6-1-1                 #
# Required packages                       #
# - ggplot2: making pretty graphs         #
# - gridExtra: combine graphs             #
library(ggplot2)
library(gridExtra)

# Generate series
nobs      = 100
x         <- runif(nobs)
y.linear  <- x + (x > 0.5) * 0.25 + rnorm(n = nobs, mean = 0, sd = 0.1)
y.nonlin  <- 0.5 * sin(6 * (x - 0.5)) + 0.5 + (x > 0.5) * 0.25 + rnorm(n = nobs, mean = 0, sd = 0.1)
y.mistake <- 1 / (1 + exp(-25 * (x - 0.5))) + rnorm(n = nobs, mean = 0, sd = 0.1)
rd.series <- data.frame(x, y.linear, y.nonlin, y.mistake)

# Make graph with ggplot2
g.data   <- ggplot(rd.series, aes(x = x, group = x > 0.5))

p.linear <- g.data + geom_point(aes(y = y.linear))  +
                     stat_smooth(aes(y = y.linear),
                                 method = "lm",
                                 se     = FALSE)    +
                     geom_vline(xintercept = 0.5)   +
                     ylab("Outcome")                +
                     ggtitle(bquote('A. Linear E[' * Y["0i"] * '|' * X[i] * ']'))

p.nonlin <- g.data + geom_point(aes(y = y.nonlin))  +
                     stat_smooth(aes(y = y.nonlin),
                                 method  = "lm",
                                 formula = y ~ poly(x, 2),
                                 se      = FALSE)   +
                     geom_vline(xintercept = 0.5)   +
                     ylab("Outcome")                +
                     ggtitle(bquote('B. Nonlinear E[' * Y["0i"] * '|' * X[i] * ']'))

f.mistake <- function(x) {1 / (1 + exp(-25 * (x - 0.5)))}
p.mistake <- g.data + geom_point(aes(y = y.mistake))     +
                      stat_smooth(aes(y = y.mistake),
                                  method = "lm",
                                  se     = FALSE)        +
                      stat_function(fun      = f.mistake,
                                    linetype = "dashed") +
                      geom_vline(xintercept = 0.5)       +
                      ylab("Outcome")                    +
                      ggtitle('C. Nonlinearity mistaken for discontinuity')

p.rd.examples <- arrangeGrob(p.linear, p.nonlin, p.mistake, ncol = 1)

ggsave(p.rd.examples, file = "Figure 6-1-1-R.pdf", width = 5, height = 9)

# End of script
