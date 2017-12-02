# Herve Guillon, December 2017
# Loading Sacramento Basin DEM and performing basic terrain analysis : slope, aspect, planform and profile curvatures

# header
scriptname <- 'terrain-analysis.R'
source("tweet-start-stop.R")
tweetstart(scriptname)

# lirsaries
library(raster)
library(rgdal)
library(RSAGA)
saga_env <- rsaga.env(path="C:/Program Files (x86)/SAGA-GIS-2.2.2")
library(sp)

# memory management
memory.limit(size = 2^15+2^18)
rasterOptions(tmpdir = 'F:/tmp/R/')

# user defined functions
source('terrain_.R')
source('raster2bm.R')

get_terrain_metrics <- function(file){
	DEM <- raster(paste0(datadir,datafile))
	terrain_metrics <- terrain_(DEM, opt=c('slope','aspect','curvplan','curvprof'), unit='tangent', neighbors=8) # faster and reliable but does not compute curvature
	rs <- stack(DEM,terrain_metrics)
	return(rs)
}

# main
datadir <- 'F:/hguillon/research/data/california-rivers/10m-DEM_hydrologic-recondition_(Colin-Byrne)/CAhuc4_rasters/elevation/wbd1802_z/'
datafile <- 'hdr.adf'
rs <- get_terrain_metrics(paste0(datadir,datafile))

# graph
par(pty="s")

image(rs$hdr, 
	main='Sacramento Basin Elevation Map', 
	xlab='Easting (m)',
	ylab='Northing (m)',
	col=rainbow(10000))

image(rs$slope, 
	main='Sacramento Basin Slope Map', 
	xlab='Easting (m)',
	ylab='Northing (m)',
	col=rainbow(10000))

image(rs$aspect, 
	main='Sacramento Basin Aspect Map', 
	xlab='Easting (m)',
	ylab='Northing (m)',
	col=rainbow(10000))

image(rs$curvplan, 
	main='Sacramento Basin Planform Curvature Map', 
	xlab='Easting (m)',
	ylab='Northing (m)',
	col=rainbow(10000))

image(rs$curvprof, 
	main='Sacramento Basin Profile Curvature Map', 
	xlab='Easting (m)',
	ylab='Northing (m)',
	col=rainbow(10000))


# footer
tweetstop(scriptname)