###########################
######## LIBRARIES ########
###########################

library(sp)
library(rgdal)
library(raster)
source("./farm_scripts/envpath.R")
root.dir <- get_rootdir()

#########################################
########## VISUALIZING RASTERS ##########
#########################################

dem.dir <- 'data/california-rivers/10m-DEM_hydrologic-recondition_(Colin-Byrne)/NAD83_CA_TA_proj/sac10m_taproj'
dem.file <- 'hdr.adf'
DEM <- raster(file.path(root.dir,dem.dir,dem.file))

shp.dir <- 'data/california-rivers/gis-files/Shape'
huc4 <- shapefile(file.path(root.dir,shp.dir,'WBDHU4.shp'))
huc4 <- spTransform(huc4, crs(DEM))
phuc4 <- polygons(huc4)
huc8 <- shapefile(file.path(root.dir,shp.dir,'WBDHU8.shp'))
huc8 <- spTransform(huc8, crs(DEM))
phuc8 <- polygons(huc8)
huc12 <- shapefile(file.path(root.dir,shp.dir,'WBDHU12.shp'))
huc12 <- spTransform(huc12, crs(DEM))
phuc12 <- polygons(huc12)

current_scheme <- 'huc12'
print(current_scheme)

# main huc id
main.huc = "1802"

# Yuba River extent (for faster calculations)
yub.huc = "18020125"
iyub <- which(huc8$HUC8 == yub.huc)

DEM_yuba <- crop(DEM,phuc8[iyub])

r <- aggregate(DEM_yuba, fact=3, fun=sd)
rr <- aggregate(DEM_yuba, fact=6, fun=sd)
rrr <- aggregate(DEM_yuba, fact=9, fun=sd)

# k <- 32 %/% res(DEM)[1]
scales.all <- 2**(5:16) # 32 to 65536 m
k <- sapply(scales.all, function(x) x %/%res(DEM)[1])
# nk <- 50
# k <- as.vector(outer(k,seq(1,nk)))
lr <- lapply(k, function(x) aggregate(DEM, fact=x, fun=sd))
lapply(seq(1,length(lr)), function(i) writeRaster(lr[[i]],file.path(root.dir,paste0(as.character(k[i]),'_std'))))
rlr <- lapply(lr, function(x) resample(x,lr[[1]]))
lapply(seq(1,length(rlr)), function(i) writeRaster(rlr[[i]],file.path(root.dir,paste0(as.character(k[i]),'_resampled')), overwrite=TRUE))

####################################
########## PRE REGRESSION ##########
####################################

s <- stack(rlr)
ss <- calc(s, log10) 
scales <- as.vector(outer(res(lr[[1]])[1],seq(1,nk)))
X <- cbind(1, log10(scales))
invXtX <- solve(t(X) %*% X) %*% t(X) ## pre-computing constant part of least squares
quickfun <- function(y) (invXtX %*% y)[2] ## much reduced regression model; [2] is to get the slope
x1 <- calc(ss, quickfun) 
x2 <- calc(x1, fun=function(x){3-x})


############################################
###### YUBA FDIM RASTER FROM DECEMBER ######
############################################

outdir = 'F:/hguillon/research/exploitation/out/'
lf <- list.files(path = outdir, pattern = '.grd')
lf <- lf[1:38]
lr <- lapply(lf, function(x) raster(paste0(outdir,x)))
lr$tolerance <- 0.5
lrsr2 <- do.call(merge, lr)

par(mfrow=c(2,2))
plot(x2)
hist(x2)
plot(lrsr2)
hist(lrsr2)

lrsr3 <- reclassify(lrsr2, c(-Inf,0,NA))
x3 <- reclassify(x2, c(-Inf,0,NA))

par(mfrow=c(2,2))
plot(x3)
hist(x3,breaks=seq(0,7,0.1))
plot(lrsr3)
hist(lrsr3,breaks=seq(0,7,0.1))

dev.new()
filledContour(lrsr3,main='Fractal dimension (1,3)',
	color.palette=function(y)rev(heat.colors(y)),nlevels=50, zlim=c(1,3),add=TRUE)


dev.new()
filledContour(x1,main='Fractal dimension (1,3)',
	color.palette=function(y)rev(heat.colors(y)),nlevels=20, zlim=c(-10,10),add=TRUE)


m <- c(-100, 0.5, 0,  0.5, 100, 1)
rclmat <- matrix(m, ncol=3, byrow=TRUE)
x4 <- reclassify(x1, rclmat)



library(RandomFields)
library(fractaldim)
library(wavelets)

# fd.estim.isotropic (DEM_yuba, p.index = 1, direction= 'hv ', plot.loglog = TRUE, plot.allpoints = TRUE)
# fd.estim.squareincr (DEM_yuba, p.index = 1, plot.loglog = TRUE, plot.allpoints = TRUE)


foo <- function(x, na.rm = TRUE){
	fdest <- fd.estim.isotropic (x, p.index = 1, direction= 'hv ', plot.loglog = FALSE, plot.allpoints = FALSE)
	return(fdest$fd)
}

rfd <- aggregate(DEM_yuba, fact=18, fun=foo)

vv <- getValuesFocal(DEM_yuba, ngb = 3)
dim(vv)