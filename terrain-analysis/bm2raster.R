# Herve Guillon, November 2017
# WARNING : this function might be deprecated as the C code runs faster than calling back filebacked bigmatrices

bm2raster <- function(bm,x=DEM){
	bm <- as.matrix(bm)
	out <- raster(bm)
	projection(out) <- projection(x)  
	extent(out) <- extent(x)
	return(out)
}

# used as : 
# # saving as big matrices
# bigDEM <- raster2bm(br$DEM, datadir, 'bigDEM')
# bigslope <- raster2bm(br$slope, datadir, 'bigslope')
# bigaspect <- raster2bm(br$aspect, datadir, 'bigaspect')
# bigcurvplan <- raster2bm(br$curvplan, datadir, 'bigcurvplan')
# bigcurvprof <- raster2bm(br$curvprof, datadir, 'bigcurvprof')