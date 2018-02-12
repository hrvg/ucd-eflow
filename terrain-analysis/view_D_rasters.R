###########################
######## LIBRARIES ########
###########################

library(sp)
library(rgdal)
library(raster)
source("./farm_scripts/envpath.R")
root.dir <- get_rootdir()

#############################################
########## READ DEM AND HS RASTERS ##########
#############################################

dem.dir <- 'data/california-rivers/10m-DEM_hydrologic-recondition_(Colin-Byrne)/NAD83_CA_TA_proj/sac10m_taproj'
dem.file <- 'hdr.adf'
hs.file <- 'hs.grd'
DEM <- raster(file.path(root.dir,dem.dir,dem.file))
hs <- raster(file.path(root.dir,dem.dir,hs.file))

##############################
###### READ STD RASTERS ######
##############################

lf <- list.files(path = root.dir, pattern = '*_std.grd')
k  <- unlist(lapply(lf, function(x) as.numeric(unlist(strsplit(x,'_'))[1])))
k <- k[order(k)]
lr <- lapply(lf[order(k)], function(x) raster(file.path(root.dir,x)))
# dev.new()
# par(mfrow=c(3,5))
scales <- lapply(lr, function(x) (round(res(x)[1])))

lf <- list.files(path = root.dir, pattern = '*_resampled.grd')
rlr <- lapply(lf[order(scales)], function(x) raster(file.path(root.dir,x)))
crlr <- lapply(seq(1,length(rlr)), function(i) clamp(rlr[[i]], lower=0, upper=Inf, useValues=FALSE,  overwrite=TRUE, filename=file.path(root.dir,paste0(as.character(k[i]),'_clamped')))) # remove error from interpolation
min.res <- 1.87 # from Haneberg, 2006
rclmat <- matrix(c(-Inf, min.res, min.res), ncol=3, byrow=TRUE)
rcrlr <- lapply(seq(1,length(crlr)), function(i) reclassify(crlr[[i]], rclmat, overwrite=TRUE, filename=file.path(root.dir,paste0(as.character(k[i]),'_reclass')))) # remove values between 0 and the vertical accuracy of the 10 m DEM, prevent log10 error 
# par(mfrow=c(3,5))
# lapply(seq(1,length(rcrlr)), function(i) plot(rcrlr[[i]],main=as.character(k[i])))