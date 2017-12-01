# Herve Guillon, November 2017
 
# Pairing functions based on Szudzik's Elegant Pairing Function
# http://szudzik.com/ElegantPairing.pdf

# Before using these functions it might be useful to tinker with R number of significant digits :
# options(digits=22)
# default value is 7, max is 22

# Not sure if the elegantTriple and Quad are the best implementation

elegantPair <- function(x, y){
	ifelse(x>=y,x^2+x+y,y^2+x) 	
}

elegantUnpair <- function(z){
	sqrtz <- floor(sqrt(z))
	sqz <- sqrtz * sqrtz
	if((z - sqz) >= sqrtz)
		return(c(sqrtz,z - sqz - sqrtz))
	else return(c(z - sqz, sqrtz))
}

elegantTriple<- function(x,y,z){
	return(elegantPair(elegantPair(x,y),z))
}

elegantUntriple <- function(z){
	xyz <- elegantUnpair(z)
	xy <- xyz[1]
	z <- xyz[2]
	xy <- elegantUnpair(xy)
	x <- xy[1]
	y<- xy[2]
	return(c(x,y,z))
}

elegantQuad <- function(w,x,y,z){
	return(elegantPair(elegantTriple(w,x,y),z))
}

elegantUnquad <- function(z){
	wxyz <- elegantUnpair(z)
	wxy <- wxyz[1]
	z <- wxyz[2]
	wxy <- elegantUntriple(wxy)
	w <- wxy[1]
	x <- wxy[2]
	y <- wxy[3]
	return(c(w,x,y,z))
}