# Herve Guillon, December 2017
# example code for calculating fractal dimension

# libraries
library(RandomFields)
library(fractaldim)
library(wavelets)

# 1d random fields
n <- 256
rf <- GaussRF(x = c(0,1, 1/n), model = "stable",
grid = TRUE, gridtriple = TRUE,
param = c(mean=0, variance=1, nugget=0, scale=1, kappa=1))
par(mfrow=c(5,2))
fd.estim.variogram (rf, nlags = 20, plot.loglog = TRUE)
fd.estim.variation (rf, nlags = 20, plot.loglog = TRUE)
fd.estim.variogram (rf,  nlags = 3, plot.loglog = TRUE, plot.allpoints = TRUE)
fd.estim.variation (rf, plot.loglog = TRUE, plot.allpoints = TRUE)
fd.estim.hallwood (rf, nlags = 10, plot.loglog = TRUE)
fd.estim.boxcount (rf, nlags = "all", plot.loglog = TRUE, plot.allpoints = TRUE)
fd.estim.periodogram (rf, plot.loglog = TRUE)
fd.estim.dctII (rf, plot.loglog = TRUE)
fd.estim.wavelet (rf, filter='d8',plot.loglog = TRUE)

# 2d random fields
n <- 256
rf2d <- GaussRF(x = c(0,1, 1/n), y = c(0,1, 1/n), model = "stable",
grid = TRUE, gridtriple = TRUE,
param = c(mean=0, variance=1, nugget=0, scale=1, kappa=1))
par(mfrow=c(1,3))
fd.estim.isotropic (rf2d, p.index = 1, direction= 'hv ', plot.loglog = TRUE, plot.allpoints = TRUE)
fd.estim.squareincr (rf2d, p.index = 1, plot.loglog = TRUE, plot.allpoints = TRUE)
fd.estim.filter1 (rf2d, p.index = 1, plot.loglog = TRUE, plot.allpoints = TRUE)