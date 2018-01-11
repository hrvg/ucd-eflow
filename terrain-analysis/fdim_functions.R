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
	# if (!is.na(x$sd)){
	ly <- log10(x$sd)
	if (all(is.finite(ly))){
		model <- lm(ly ~ log10(x$scale))
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

get_Draster <- function(i,DEM,r.=r,phuc=phuc12,huc=huc12,outdir = 'F:/hguillon/research/exploitation/out/'){
	p <- phuc[i]
	name <- huc$NAME[i]
	id <- huc$HUC12[i]
	print(paste0('Start : ',name))
	updateStatus(paste(' Beep boop beep. I am starting my analysis of ',name,' at ',Sys.time(),'!',sep=''))
	wDEM <- crop(DEM,p)
	mDEM <- mask(wDEM,p)
	# mDEM <- wDEM
	stds <- lapply(r., get_std, DEM=mDEM, rmin=min(r.))
	stds_values <- lapply(stds, function(x) getValues(x))
	v <- seq(1,ncell(stds[[1]]),1) %>% rep(times = length(r.))
	df <- data.frame(ncell = v, sd = unlist(stds_values))
	df %>% arrange(ncell) -> df
	df$scale = rep(r, times = ncell(stds[[1]]))
	l <- split(df, df$ncell)
	ll <- lapply(l, log10reg)
	Ds <- lapply(ll, getD)
	D_raster <- raster(stds[[1]])
	D_raster <- setValues(D_raster,as.vector(unlist(Ds)))
	writeRaster(D_raster, filename = paste0(outdir,name), format='raster')
	updateStatus(paste(' Beep boop beep. I am done with my analysis of ',name,' at ',Sys.time(),'!',sep=''))
	print(paste0('Stop : ',name))
	pct <- which(ilist==i)/length(ilist)*100
	print(paste0(pct,' done.'))
}


get_Draster_survey <- function(i,DEM,r.=r,phuc=phuc12,huc=huc12,outdir = 'F:/hguillon/research/exploitation/out/'){
	p <- polys[[i]]
	name <- names[i]
	print(paste0('Start : ',name))
	# updateStatus(paste(' Beep boop beep. I am starting my analysis of survey site',name,' at ',Sys.time(),'!',sep=''))
	wDEM <- crop(DEM,p)
	# mDEM <- mask(wDEM,p)
	mDEM <- wDEM
	stds <- lapply(r., get_std, DEM=mDEM, rmin=min(r.))
	stds_values <- lapply(stds, function(x) getValues(x))
	v <- seq(1,ncell(stds[[1]]),1) %>% rep(times = length(r.))
	df <- data.frame(ncell = v, sd = unlist(stds_values))
	df %>% arrange(ncell) -> df
	df$scale = rep(r, times = ncell(stds[[1]]))
	l <- split(df, df$ncell)
	ll <- lapply(l, log10reg)
	Ds <- lapply(ll, getD)
	D_raster <- raster(stds[[1]])
	D_raster <- setValues(D_raster,as.vector(unlist(Ds)))
	writeRaster(D_raster, filename = paste0(outdir,name), format='raster')
	# updateStatus(paste(' Beep boop beep. I am done with my analysis of ',name,' at ',Sys.time(),'!',sep=''))
	print(paste0('Stop : ',name))
	pct <- which(ilist==i)/length(ilist)*100
	print(paste0(pct,' done.'))
}
