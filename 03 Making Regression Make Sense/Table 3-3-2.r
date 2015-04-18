# R code for Table 3-3-2     #
# Required packages          #
# - foreign: read .dta files #

library(foreign)

# Download the files
download.file("http://economics.mit.edu/files/3824", "cps1re74.dta")
download.file("http://economics.mit.edu/files/3825", "cps3re74.dta")
download.file("http://economics.mit.edu/files/3828", "nswre74.dta")

# Read the Stata files into R
cps1re74 <- read.dta("cps1re74.dta")
cps3re74 <- read.dta("cps3re74.dta")
nswre74  <- read.dta("nswre74.dta")


