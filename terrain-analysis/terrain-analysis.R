# Basic terrain analysis scripts
# Loading raster and doing basics terrain analysis metrics

library(raster)
library(rgdal)
library(RSAGA)
saga_env <- rsaga.env(path="C:/Program Files (x86)/SAGA-GIS-2.2.2")
library(sp)

memory.limit(size = 2^15+2^18)

datadir <- 'F:/hguillon/research/data/california-rivers/10m-DEM_hydrologic-recondition_(Colin-Byrne)/CAhuc4_rasters/elevation/wbd1802_z/'
datafile <- 'hdr.adf'

DEM <- raster(paste(datadir,datafile,sep=''))

par(pty="s")
image(DEM, 
	main='Sacramento Basin Elevation Map', 
	xlab='Easting (m)',
	ylab='Northing (m)',
	col=rainbow(10000))


slopes <- terrain(DEM, opt='slope', unit='tangent', neighbors=8)

image(slopes, 
	main='Sacramento Basin Slope Map', 
	xlab='Easting (m)',
	ylab='Northing (m)',
	col=rainbow(10000))


# rsaga.slope.asp.curv(in.dem = fid, out.slope = 'slopes', env = saga_env)