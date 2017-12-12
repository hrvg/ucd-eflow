# Herve Guillon, December 2017
# Loading Sacramento Basin DEM and performing basic terrain analysis : slope, aspect, planform and profile curvatures

# header
scriptname <- 'getfdim.R'
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

# memory management
memory.limit(size = 2^15+2^18)
rasterOptions(tmpdir = 'F:/tmp/R/')

# parallelization management
no_cores <- detectCores() - 1

# user defined functions
get_std <- function(r=1000,DEM,fixed_size=TRUE,rmin=250){
	library(raster)
	ext <- extent(DEM)
	f <- c(rmin %/% res(DEM)[1], rmin %/% res(DEM)[2])
	xmin <- ext[1]
	xmax <- ext[2]
	ymin <- ext[3]
	ymax <- ext[4]
	DX <- ext[2]-ext[1]
	DY <- ext[4]-ext[3]
	stdevs <- vector("list", (DX%/%r)*(DY%/%r))
	ymax_ <- ymax
	ymin_ <- ymax_ - r
	i <- 1
	while (ymin_ >= ymin) {
		xmin_ <- xmin
		xmax_ <- xmin_ + r
		while (xmax_ <= xmax) {
			raster_ <- crop(DEM,extent(xmin_,xmax_,ymin_,ymax_))
			std <- cellStats(raster_,stat=sd)
			vals <- as.vector(rep(std,ncell(raster_)))
			stdevs[i] <- raster(raster_)
			stdevs[i] <- setValues(raster_,vals)
			xmin_ <- xmin_ + r
			xmax_ <- xmax_ + r
			i <- i + 1
		}
		ymax_ <- ymax_ - r
		ymin_ <- ymin_ - r
	}
	if (fixed_size) {
		vals <- as.vector(rep(NA,ncell(DEM)))
		stdevs[i] <- setValues(DEM,vals)
	}
	all_stds <- do.call(merge, stdevs)
	all_stds <- aggregate(all_stds, fact=f)
	return(all_stds)
}

log10reg <- function(x){
	if (!is.na(x$sd)){
		model = lm(log10(x$sd) ~ log10(x$scale))
		return (model)
	}
	else{
		return (NA)
	}
}

getD <- function(x){
	if (!is.na(x)){
		return (3-x$coefficients[2])
	}
	else{
		return (NA)
	}
}

getq <- function(x){
	if (!is.na(x)){
		return (x$coefficients[1])
	}
	else{
		return (NA)
	}
}

# main

datadir <- 'F:/hguillon/research/data/california-rivers/10m-DEM_hydrologic-recondition_(Colin-Byrne)/NAD83_CA_TA_proj/sac10m_taproj/'
datafile <- 'hdr.adf'

DEM <- raster(paste0(datadir,datafile))

# Yuba River extent (for faster calculations)
e <- extent(-159140,-35058,114398,191331)
DEM_yuba <- crop(DEM,e)

# scales
r <- c(20000,10000,5000)

# get std rasters
cl <- makeCluster(no_cores)
stds <- parLapply(cl, r, get_std, DEM=DEM_yuba, rmin=min(r))

# getValues
stds_values <- parLapply(cl, stds, function(x) getValues(x))

# df
v <- seq(1,ncell(stds[[1]]),1) %>% rep(times = length(r))
df <- data.frame(ncell = v, sd = unlist(stds_values))
df %>% arrange(ncell) -> df
df$scale = rep(r, times = ncell(stds[[1]]))
l <- split(df, df$ncell)
ll <- parLapply(cl, l, log10reg)
Ds <- parLapply(cl, ll, getD)
# qs <- parLapply(cl, ll, getq)

stopCluster(cl)

D_raster <- raster(stds[[1]])
D_raster <- setValues(D_raster,as.vector(unlist(Ds)))

par(pty="s")
plot(D_raster, 
	main='Fractal Dimension Map', 
	xlab='Easting (m)',
	ylab='Northing (m)',
	col=rainbow(10000,start=0,end=1/6))

tweetstop(scriptname)