####################################
########## PRE REGRESSION ##########
####################################

# s <- stack(rcrlr)
# ss <- calc(s, log10) 
# writeRaster(ss, file.path(root.dir,'stacked_log10_stds'), overwrite=TRUE)
ss <- stack(file.path(root.dir,'stacked_log10_stds'))



getHbyscale <- function(i,j){
	X <- cbind(1, log10(scales)[i:j])
	invXtX <- solve(t(X) %*% X) %*% t(X) ## pre-computing constant part of least squares
	quickfun <- function(y) (invXtX %*% y)[2] ## much reduced regression model; [2] is to get the slope
	return( calc(ss[[i:j]], quickfun) )
}

lij <- lapply(seq(0,length(scales)-5), function(x) c(1+x,5+x))
ls <- lapply(lij, function(l) getHbyscale(unlist(l)[1],unlist(l)[2]))


par(pty="s")
plot(x1)


x2 <- calc(x1, fun=function(x){3-x})
par(pty="s")
plot(x2)


x3 

# Or for a much faster approach

# X <- cbind(1, y)
# invXtX <- solve(t(X) %*% X) %*% t(X)
# quickfun <- function(i) (invXtX %*% i)
# m <- calc(s, quickfun) 
# names(m) <- c('intercept', 'slope')

filledContour(x1,main='Spatial Hurst coefficient',
	color.palette=function(y)rev(heat.colors(y)),nlevels=4, zlim=c(0,1))