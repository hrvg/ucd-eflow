# header
scriptname <- 'survey-site.R'
source("tweet-start-stop.R")
# tweetstart(scriptname)

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
source('get_points.R')

getpol <- function(i,dl=1000,.crs=crs(DEM)){
	x_min <- pts@coords[i,1] - dl
	x_max <- pts@coords[i,1] + dl
	y_min <- pts@coords[i,2] - dl
	y_max <- pts@coords[i,2] + dl
	coords = matrix(c(x_min, y_min,
	               x_min, y_max,
	               x_max, y_max,
	               x_max, y_min,
	               x_min, y_min), 
	             ncol = 2, byrow = TRUE)
	p <-  Polygon(coords)
	sp1 <-  SpatialPolygons(list(Polygons(list(p), ID = "a")), proj4string=.crs)
	return(sp1)
}

# main
datadir <- 'F:/hguillon/research/data/california-rivers/10m-DEM_hydrologic-recondition_(Colin-Byrne)/NAD83_CA_TA_proj/sac10m_taproj/'
datafile <- 'hdr.adf'

DEM <- raster(paste0(datadir,datafile))

pts <- kml_points(paste0('F:/hguillon/research/data/california-rivers/Geospatial/KMZ/','sites_visited_20180105.kml'))
names <- pts$name
lon <- pts$longitude
lat <- pts$latitude
lonlat <- cbind(lon,lat)
crdref <- CRS('+proj=longlat +datum=WGS84')
pts <- SpatialPoints(lonlat, proj4string = crdref)
pts <- spTransform(pts, crs(DEM))
ilist <- seq(1,nrow(pts@coords),1)
.dl <- 1000
polys <- lapply(ilist,getpol, dl=.dl)

r <- c(400,200,100,50,25)
odir <- 'F:/hguillon/research/exploitation/out/run4/'
lapply(ilist, get_Draster_survey, DEM=DEM, outdir=odir)

tweetstop(scriptname)

# viz

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