# Basic terrain analysis scripts
# Loading raster and doing basics terrain analysis metrics
scriptname <- 'terrain-analysis.R'
source("twitter-config.R")
tweetstart(scriptname)

memory.limit(size = 2^15+2^18)

library(raster)
rasterOptions(tmpdir = 'F:/tmp/R/')

library(rgdal)
library(RSAGA)
saga_env <- rsaga.env(path="C:/Program Files (x86)/SAGA-GIS-2.2.2")
library(sp)

source('DEMderiv.R')
source('raster2bm.R')
source('terrain_.R')

datadir <- 'F:/hguillon/research/data/california-rivers/10m-DEM_hydrologic-recondition_(Colin-Byrne)/CAhuc4_rasters/elevation/wbd1802_z/'
datafile <- 'hdr.adf'

DEM <- raster(paste(datadir,datafile,sep=''))

tweetstart('All metrics analysis')
terrain_metrics <- terrain_(DEM, opt=c('slope','aspect','curvplan','curvprof'), unit='tangent', neighbors=8) # faster and reliable but does not compute curvature
tweetstop('All metrics analysis')

par(pty="s")

image(DEM, 
	main='Sacramento Basin Elevation Map', 
	xlab='Easting (m)',
	ylab='Northing (m)',
	col=rainbow(10000))

image(terrain_metrics$slope, 
	main='Sacramento Basin Elevation Map', 
	xlab='Easting (m)',
	ylab='Northing (m)',
	col=rainbow(10000))

image(terrain_metrics$aspect, 
	main='Sacramento Basin Elevation Map', 
	xlab='Easting (m)',
	ylab='Northing (m)',
	col=rainbow(10000))


image(terrain_metrics$curvplan, 
	main='Sacramento Basin Elevation Map', 
	xlab='Easting (m)',
	ylab='Northing (m)',
	col=rainbow(10000))

image(terrain_metrics$curvprof, 
	main='Sacramento Basin Elevation Map', 
	xlab='Easting (m)',
	ylab='Northing (m)',
	col=rainbow(10000))

bigslope <- raster2bm(terrain_metrics$slope, datadir, 'bigslope')
bigaspect <- raster2bm(terrain_metrics$aspect, datadir, 'bigaspect')
bigcurvplan <- raster2bm(terrain_metrics$curvplan, datadir, 'bigcurvplan')
bigcurvprof <- raster2bm(terrain_metrics$curvprof, datadir, 'bigcurvprof')


# rm(slopes_aspects)
# removeTmpFiles(h=0.)


tweetstop(scriptname)