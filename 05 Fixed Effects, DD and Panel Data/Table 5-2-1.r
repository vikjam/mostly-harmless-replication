# R code for Figure 5-2-1         #
# Required packages               #
# - dplyr: easy data manipulation #
library(dplyr)

# Download data
download.file("http://economics.mit.edu/files/3845", "njmin.zip")
unzip("njmin.zip")

# Import data
njmin        <- read.table('public.dat',
                          header           = FALSE,
                          stringsAsFactors = FALSE,
                          na.strings       = c("", ".", "NA"))
names(njmin) <- c('SHEET', 'CHAIN', 'CO_OWNED', 'STATE', 'SOUTHJ', 'CENTRALJ',
                  'NORTHJ', 'PA1', 'PA2', 'SHORE', 'NCALLS', 'EMPFT', 'EMPPT',
                  'NMGRS', 'WAGE_ST', 'INCTIME', 'FIRSTINC', 'BONUS', 'PCTAFF',
                  'MEALS', 'OPEN', 'HRSOPEN', 'PSODA', 'PFRY', 'PENTREE', 'NREGS',
                  'NREGS11', 'TYPE2', 'STATUS2', 'DATE2', 'NCALLS2', 'EMPFT2',
                  'EMPPT2', 'NMGRS2', 'WAGE_ST2', 'INCTIME2', 'FIRSTIN2', 'SPECIAL2',
                  'MEALS2', 'OPEN2R', 'HRSOPEN2', 'PSODA2', 'PFRY2', 'PENTREE2',
                  'NREGS2', 'NREGS112')

# Calculate FTE employement
njmin$FTE  <- njmin$EMPFT  + 0.5 * njmin$EMPPT  + njmin$NMGRS
njmin$FTE2 <- njmin$EMPFT2 + 0.5 * njmin$EMPPT2 + njmin$NMGRS2

# Create function for calculating standard errors of mean
semean <- function(x, na.rm = FALSE) {
    n <- ifelse(na.rm, sum(!is.na(x)), length(x))
    sqrt(var(x, na.rm = na.rm) / n)
}

# Calucate means
summary.means <- njmin[ , c("FTE", "FTE2", "STATE")]         %>%
                 group_by(STATE)                             %>%
                 summarise_each(funs(mean(., na.rm = TRUE)))
summary.means <- as.data.frame(t(summary.means[ , -1]))

colnames(summary.means)  <- c("PA", "NJ")
summary.means$dSTATE     <- summary.means$NJ - summary.means$PA
summary.means            <- rbind(summary.means,
                                  summary.means[2, ] - summary.means[1, ])
row.names(summary.means) <- c("FTE employment before, all available observations",
                              "FTE employment after, all available observations",
                              "Change in mean FTE employment")

# Calucate
summary.semeans <- njmin[ , c("FTE", "FTE2", "STATE")]         %>%
                 group_by(STATE)                               %>%
                 summarise_each(funs(semean(., na.rm = TRUE)))
summary.semeans <- as.data.frame(t(summary.semeans[ , -1]))

colnames(summary.semeans)  <- c("PA", "NJ")
summary.semeans$dSTATE     <- sqrt(summary.semeans$NJ + summary.semeans$PA) / length

njmin         <- njmin[ , c("FTE", "FTE2", "STATE")]
njmin         <- melt(njmin,
                      id.vars       = c("STATE"),
                      variable.name = "Period",
                      value.name    = "FTE")
summary.means <- njmin                   %>%
                 group_by(STATE, Period) %>%
                 summarise_each(funs(mean(., na.rm = TRUE), semean(., na.rm = TRUE)))

# End of script
