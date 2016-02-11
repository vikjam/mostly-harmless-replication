# R code for Figure 4-1-1             #
# Required packages                   #
# foreign: read Stata .dta files      #
library(foreign)
library(plm)
library(lmtest)

# Download the data and unzip it
# download.file('http://economics.mit.edu/~dautor/outsourcingatwill_table7.zip', 'outsourcingatwill_table7.zip')
# unzip('outsourcingatwill_table7.zip')

# Load the data
autor <- read.dta('table7/autor-jole-2003.dta')

# Log total employment: from BLS employment & earnings
autor$lnemp <- log(autor$annemp)

# Non-business-service sector employment from CBP
autor$nonemp  <- autor$stateemp - autor$svcemp
autor$lnnon   <- log(autor$nonemp)
autor$svcfrac <- autor$svcemp / autor$nonemp

# Total business services employment from CBP
autor$bizemp <- autor$svcemp + autor$peremp
autor$lnbiz  <- log(autor$biz)

# Restrict sample
autor <- autor[which(autor$year >= 79 & autor$year <= 95), ]
autor <- autor[which(autor$state != 98), ]

# State dummies, year dummies, and state*time trends
autor$t  <- autor$year - 78
autor$t2 <- autor$t^2

# Generate more aggregate demographics
autor$clp     <- autor$clg    + autor$gtc
autor$a1624   <- autor$m1619  + autor$m2024 + autor$f1619 + autor$f2024
autor$a2554   <- autor$m2554  + autor$f2554
autor$a55up   <- autor$m5564  + autor$m65up + autor$f5564 + autor$f65up
autor$fem     <- autor$f1619  + autor$f2024 + autor$f2554 + autor$f5564 + autor$f65up
autor$white   <- autor$rs_wm  + autor$rs_wf
autor$black   <- autor$rs_bm  + autor$rs_bf
autor$other   <- autor$rs_om  + autor$rs_of
autor$married <- autor$marfem + autor$marmale

# Modify union variable (1. Don't interpolate 1979, 1981; 2. Rescale into percentage)
autor$unmem[79 >= autor$year & autor$year >= 81] <- NA
autor$unmem                                      <- autor$unmem * 100

# Make into a panel data set
p.df <- pdata.frame(autor, index = c('state', 'year'))

# Diff-in-diff regression
p.did <- plm(lnths ~ lnemp    + admico_2 + admico_1 + admico0 + admico1 + admico2 + admico3 + mico4    +
                     admppa_2 + admppa_1 + admppa0  + admppa1 + admppa2 + admppa3 + mppa4   + admgfa_2 +
                     admgfa_1 + admgfa0  + admgfa1  + admgfa2 + admgfa3 + mgfa4   +
                     factor(year) + t:factor(state),
                     data  = p.df)

# Compute Stata like degrees of freedom adjustment
G   <- length(unique(p.df$state))
N   <- length(p.df$state)
DFA <- (G / (G - 1)) * (N - 1) / did$df.residual
 
# Calculate cluster VCE
did_vcov <- DFA * vcovHC(did, type = "HC1", cluster = "group", adjust = TRUE)
coeftest(pdid, vcov = did_vcov)

# End of script
