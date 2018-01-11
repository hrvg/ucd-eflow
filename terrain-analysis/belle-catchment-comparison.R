# Comparison between a fractal approach and what Belle and Helen have done in term of processes classification

# header
scriptname <- 'catch-comparison.R'
source("tweet-start-stop.R")
tweetstart(scriptname)

# libraries
library(rgdal)
library(raster)
library(RSAGA)
saga_env <- rsaga.env(path="C:/Program Files (x86)/SAGA-GIS-2.2.2")
library(sp)
library(data.table)
library(parallel)
library(dplyr)
library(ggplot2)
library(purrr)

# user defined functions
source("fdim_functions.R")

# main
datadir <- 'F:/hguillon/research/data/california-rivers/10m-DEM_hydrologic-recondition_(Colin-Byrne)/NAD83_CA_TA_proj/sac10m_taproj/'
datafile <- 'hdr.adf'

DEM <- raster(paste0(datadir,datafile))

huc12 <- shapefile(paste0('F:/hguillon/research/data/california-rivers/gis-files/Shape/','WBDHU12.shp'))
huc12 <- spTransform(huc12, crs(DEM))
phuc12 <- polygons(huc12)

# FID S_67 180201570202	Lost Creek-Deer Creek
# FID 3 180200021206	Lower Roberts Reservoir-Pit River
# FID 7 180201210407	Clear Creek-North Fork Feather River
# FID S_154 180201220102	Upper Red Clover Creek
# FID 2 180201230403	Sulphur Creek
# FID S_238 180201560203	North Fork Elder Creek
# FID 58 180200030802	Peacock Creek-Pit River
# FID S_32 180201530101	Deer Creek

names <- c("S_67", "3", "7", "S_154", "2", "S_238", "58", "S_32")
huc12_list <- c("180201570202", "180200021206", "180201210407", "180201220102", "180201230403", "180201560203", "180200030802", "180201530101")

ilist <- lapply(huc12_list, function(x) which(huc12$HUC12==x))

r <- c(400,200,100)
odir <- 'F:/hguillon/research/exploitation/out/run3/'
lapply(ilist, get_Draster, DEM=DEM, outdir=odir)

tweetstop(scriptname)


# viz

names <- c("S_67", "3", "7", "S_154", "2", "S_238", "58", "S_32")
odir <- 'F:/hguillon/research/exploitation/out/run3/'
outdir <-  odir

lf <- list.files(path = outdir, pattern = '.grd')
lf <- lf[1:length(names)]
lr <- lapply(lf, function(x) raster(paste0(outdir,x)))
lrr <- lapply(lr, function(x) reclassify(x, c(-10,0,NA)))



# histograms
values <- lapply(lrr, function(x) getValues(x))
max.length <- max(sapply(values, length))
l <- lapply(values, function(v) { c(v, rep(NA, max.length-length(v)))})
ldat <- lapply(seq(1,length(names),1), function(i){data.frame(D=values[[i]], catchment=names[i])})
ll <- do.call(rbind, ldat)
df <- data.frame(ll)

ggplot(df, aes(D, fill=catchment, colour=catchment)) +
  geom_density(alpha=0.0, lwd=1, adjust=0.5) 