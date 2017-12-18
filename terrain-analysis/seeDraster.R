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

# main

datadir <- 'F:/hguillon/research/data/california-rivers/10m-DEM_hydrologic-recondition_(Colin-Byrne)/NAD83_CA_TA_proj/sac10m_taproj/'
datafile <- 'hdr.adf'

DEM <- raster(paste0(datadir,datafile))

# huc4 <- shapefile(paste0('F:/hguillon/research/data/california-rivers/gis-files/Shape/','WBDHU4.shp'))
# huc4 <- spTransform(huc4, crs(DEM))
# phuc4 <- polygons(huc4)
# huc6 <- shapefile(paste0('F:/hguillon/research/data/california-rivers/gis-files/Shape/','WBDHU6.shp'))
# huc6 <- spTransform(huc6, crs(DEM))
# phuc6 <- polygons(huc6)
huc8 <- shapefile(paste0('F:/hguillon/research/data/california-rivers/gis-files/Shape/','WBDHU8.shp'))
huc8 <- spTransform(huc8, crs(DEM))
phuc8 <- polygons(huc8)
# huc10 <- shapefile(paste0('F:/hguillon/research/data/california-rivers/gis-files/Shape/','WBDHU10.shp'))
# huc10 <- spTransform(huc10, crs(DEM))
# phuc10 <- polygons(huc10)
huc12 <- shapefile(paste0('F:/hguillon/research/data/california-rivers/gis-files/Shape/','WBDHU12.shp'))
huc12 <- spTransform(huc12, crs(DEM))
phuc12 <- polygons(huc12)


# Yuba River extent (for faster calculations)
huc_id = "18020125"
i <- which(huc8$HUC8 == huc_id)

DEM_yuba <- crop(DEM,phuc8[i])

outdir = 'F:/hguillon/research/exploitation/out/'

lf <- list.files(path = outdir, pattern = '.grd')
lf <- lf[1:38]
lr <- lapply(lf, function(x) raster(paste0(outdir,x)))
lrr <- lapply(lr, function(x) reclassify(x, c(-10,0,NA)))

# plot(DEM_yuba, col = topo.colors(20))
plot(phuc8[i], lwd=3)
brk <- seq(0,3,0.5)
invisible(lapply(lrr, function(x) image(x, breaks = brk, col=terrain.colors(length(brk)-1), add=TRUE)))


values <- lapply(lrr, function(x) getValues(x))
max.length <- max(sapply(values, length))
l <- lapply(values, function(v) { c(v, rep(NA, max.length-length(v)))})

ilist <- grep(huc_id,huc12$HUC12)
names <-  huc12$NAME[ilist]

## Rbind
ldat <- lapply(seq(1,length(names),1), function(i){
		data.frame(D=values[[i]], catchment=names[i])
})


ll <- do.call(rbind, ldat)
df <- data.frame(ll)

ggplot(df, aes(D, fill=catchment, colour=catchment)) +
  geom_density(alpha=0.0, lwd=1, adjust=0.5) 


# library(scales) # For percent_format()
# ggplot(df, aes(D, fill=catchment, colour=catchment)) +
# geom_histogram(aes(y=2*(..density..)/sum(..density..)), alpha=0.6, 
#              position="identity", lwd=0.2) +
# scale_y_continuous(labels=percent_format()) 