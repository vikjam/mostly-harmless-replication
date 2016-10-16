# R code for Figure 6.1.2                 #
# Required packages                       #
# - haven: read .dta files                #
# - data.table: alternative to data.frame #
# - ggplot2: making pretty graphs         #
# - gridExtra: combine graphs             #
library(haven)
library(data.table)
library(ggplot2)
library(gridExtra)

# Download data and unzip the data
# download.file('http://economics.mit.edu/faculty/angrist/data1/mhe/lee', 'Lee2008.zip')
# unzip('Lee2008.zip')

# Load the .dta file as data.table
lee <- data.table(read_dta('Lee2008/individ_final.dta'))

# Subset by non-missing in the outcome and running variable for panel (a)
panel.a <- na.omit(lee[, c("myoutcomenext", "difshare"), with = FALSE])

# Create indicator when crossing the cut-off
panel.a <- panel.a[ , d := (difshare >= 0) * 1.0]

# Predict with local polynomial logit of degree 4
logit   <- glm(formula = myoutcomenext ~ poly(difshare, degree = 4) +
										            poly(difshare, degree = 4) * d,
	             family  = binomial(link = "logit"),
	             data    = panel.a)
panel.a <- panel.a[ , pmyoutcomenext := predict(logit, panel.a, type = "response")]

# Create local average by 0.005 interval of the running variable
breaks  <- round(seq(-1, 1, by = 0.005), 3)
panel.a <- panel.a[ , i005 := as.numeric(as.character(cut(difshare,
	                                                       breaks = breaks,
	                                                       labels = head(breaks, -1),
	                                                       right  = TRUE))), ]

panel.a <- panel.a[ , list(m_next  = mean(myoutcomenext),
	                         mp_next = mean(pmyoutcomenext)),
                   by = i005]

# Plot panel (a)
panel.a <- panel.a[which(panel.a$i005 > -0.251 & panel.a$i005 < 0.251), ]
plot.a  <- ggplot(data = panel.a, aes(x = i005))                       +
           geom_point(aes(y = m_next))                                 +
           geom_line(aes(y = mp_next, group = i005 >= 0))              +
           geom_vline(xintercept = 0, linetype = 'longdash')           +
           xlab('Democratic Vote Share Margin of Victory, Election t') +
           ylab('Probability of Victory, Election t+1')                +
           ggtitle('a')

# Subset the outcome for panel (b)
panel.b <- lee[ , i005 := as.numeric(as.character(cut(difshare,
	                                                   breaks = breaks,
	                                                   labels = head(breaks, -1),
	                                                   right  = TRUE))), ]

panel.b <- panel.b[ , list(m_vic  = mean(mofficeexp, na.rm = TRUE),
	                         mp_vic = mean(mpofficeexp, na.rm = TRUE)),
                   by = i005]

panel.b <- panel.b[which(panel.b$i005 > -0.251 & panel.b$i005 < 0.251), ]
plot.b  <- ggplot(data = panel.b, aes(x = i005))                       +
           geom_point(aes(y = m_vic))                                  +
           geom_line(aes(y = mp_vic, group = i005 >= 0))               +
           geom_vline(xintercept = 0, linetype = 'longdash')           +
           xlab('Democratic Vote Share Margin of Victory, Election t') +
           ylab('No. of Past Victories as of Election t')              +
           ggtitle('b')

lee.p  <- arrangeGrob(plot.a, plot.b)
ggsave(lee.p, file = "Figure 6-1-2-R.png", height = 12, width = 8, dpi = 300)

# End of script
