raster2bm <- function(x, backingdir, backingfile){
	# Modified after a code from Robert Hijmans.
	# Code was retrieved from :
	# http://r-sig-geo.2731867.n2.nabble.com/convert-Raster-object-to-bigmatrix-object-td6668252.html
	# x : raster object
	library(raster)
	library(bigmemory)
	z <- filebacked.big.matrix(, nrow=nrow(x), 
		ncol=ncol(x),
		backingfile=backingfile,
		backingpath=backingdir,
		descriptorfile=extension(backingfile, '.desc'),
		type='double')
	tr <- blockSize(x)
	for (i in 1:tr$n) {
			z[(tr$row[i]):(tr$row[i]+tr$nrows[i]-1),1:ncol(z)] <- matrix(getValues(x, row=tr$row[i], nrows=tr$nrows[i]), nrow=tr$nrows[i], byrow=TRUE)
		}
	return(z)
} 


# Snippets for testing above code

# datadir <- 'F:/hguillon/research/data/california-rivers/10m-DEM_hydrologic-recondition_(Colin-Byrne)/CAhuc4_rasters/elevation/wbd1802_z/'
# datafile <- 'hdr.adf'
# library(raster)
# DEM <- raster(paste0(datadir,datafile))
# bigDEM <- raster2bm(DEM, datadir, 'bigDEM')
# library(bigmemory)
# bigDEM <- attach.big.matrix(paste0(datadir,'bigDEM','.desc'))
