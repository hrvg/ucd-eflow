/* Robert Hijmans, October 2011 */
/* Modified by Herve Guillon, November 2017 */
/* Added options for computation of planform and profile curvature */
/* WARNING : Latlon data might not be taken into account and the weights in each metrics might need to be adjusted (e.g. as for slope) */
/* TO DO : properly take into account the variable spacing that may arise when using latlon (i.e. geo) */


#include <R.h>
#include <Rinternals.h>
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "Rdefines.h"
#include "R_ext/Rdynload.h"
#include "Rmath.h"

#include "util.h" 


// start of utic.c content
// this is ugly and should be changed
// R CMD SHLIB on Windows was returning undefined functions errors and that was my work-around

double mod(double x, double n) {
	return(x - n * floor(x/n));
}

double normalizeLonDeg(double lon) {
	return( mod( (lon + 180), 360 ) - 180 );
}

double normalizeLonRad(double lon) {
	return( mod( (lon + M_PI), M_2PI) - M_PI);
}


/* Convert degrees to radians */
double toRad(double deg) {
	return( deg * 0.0174532925199433 );
}

double toDeg(double rad) {
	return( rad * 57.2957795130823 );
}


double distPlane(double x1, double y1, double x2, double y2) {
	return( sqrt(pow((x2-x1),2) + pow((y2-y1), 2)) );
}

// end of util.c content


double distHav(double lon1, double lat1, double lon2, double lat2, double r) {

	double dLat, dLon, a;

	lon1 = toRad(lon1);
	lon2 = toRad(lon2);
	lat1 = toRad(lat1);
	lat2 = toRad(lat2);

	dLat = lat2-lat1;
	dLon = lon2-lon1;
	a = sin(dLat/2.) * sin(dLat/2.) + cos(lat1) * cos(lat2) * sin(dLon/2.) * sin(dLon/2.);
	return 2. * atan2(sqrt(a), sqrt(1.-a)) * r;
}


SEXP _do_terrain_(SEXP d, SEXP dim, SEXP res, SEXP un, SEXP opt, SEXP lonlat, SEXP geoy) {
					
	R_len_t i, j;
	SEXP val;
	int nrow, ncol, n, unit, *option;
	double *xd, *xval, dx, dy, *gy, *ddx;
	double zy, zx;
	
	PROTECT(d = coerceVector(d, REALSXP));
	PROTECT(opt = coerceVector(opt, INTSXP));
	
	nrow = INTEGER(dim)[0];
	ncol = INTEGER(dim)[1];
	n = nrow * ncol;
	
	unit = INTEGER(un)[0];
	dx = REAL(res)[0];
	dy = REAL(res)[1];

	option = INTEGER(opt);
	int nopt = 0;
	for (i =0; i<10; i++) {
		nopt += option[i];
	}

	int geo = INTEGER(lonlat)[0];
	PROTECT(geoy = coerceVector(geoy, REALSXP));
	gy = REAL(geoy);
	if (geo) {
		double r = 6378137;
		ddx=(double *) malloc(nrow*sizeof(double));	
		for (i=0; i<nrow; i++) {
			ddx[i] = distHav(-dx, gy[i], dx, gy[i], r) / 2 ;
		}
	} else {
		// to avoid a warning about ddx perhaps not being initialized
		ddx=(double *) malloc(sizeof(double));
		ddx[0] = 1;
	}

	PROTECT( val = allocVector(REALSXP, n*nopt) );

	xd = REAL(d);
	xval = REAL(val);
	
	int add=0;
	int addn=0;
	
	if (option[0]) {  
	// terrain ruggedness
		for (i = ncol+1; i < (ncol * (nrow-1)-1); i++) {
			xval[i] = (fabs(xd[i-1-ncol]-xd[i]) + fabs(xd[i-1]-xd[i]) + fabs(xd[i-1+ncol]-xd[i]) +  fabs(xd[i-ncol]-xd[i]) +
				fabs(xd[i+ncol]-xd[i]) +  fabs(xd[i+1-ncol]-xd[i]) + fabs(xd[i+1]-xd[i]) +  fabs(xd[i+1+ncol]-xd[i])) / 8;
		}
		add++;
	} 
	if (option[1]) {
		addn = add * n;
	// topograhic position
		for (i = ncol+1; i < (ncol * (nrow-1)-1); i++) {
			xval[i+addn] = xd[i] - (xd[i-1-ncol] + xd[i-1] + xd[i-1+ncol] + xd[i-ncol]
								+ xd[i+ncol] + xd[i+1-ncol] + xd[i+1] + xd[i+1+ncol]) / 8;
		}
		add++;
	} 
	if (option[2]) {
	// roughness 
		addn = add * n;
		int a[9] = { -1-ncol, -1, -1+ncol, -ncol, 0, ncol, 1-ncol, 1, 1+ncol };
		double min, max, v;
		for (i = ncol+1; i < (ncol * (nrow-1)-1); i++) {
			min = xd[i + a[0]];
			max = xd[i + a[0]];
			for (j = 1; j < 9; j++) {
				v = xd[i + a[j]]; 
				if (v > max) {
					max = v;
				} else if (v < min) {
					min = v;
				}
			}
			xval[i+addn] = max - min;
		}
		add++;
	} 
	

	if (option[3]) {
	// slope 4 neighbors	
		addn = add * n;
		if (geo) {
			int k, q;
			double xwi[2] = {-1,1};
			double xw[2] = {0,0};
			double yw[2] = {-1,1};

			
			for (i=0; i<2; i++) {
				yw[i] = yw[i] / (2 * dy);
			}			
			for (i = ncol; i < (ncol * (nrow-1)-1); i++) {
				if (i % ncol == 0) {
					q = i / ncol;
					for (k=0; k<2; k++) {
						xw[k] = xwi[k] / (-2 * ddx[q]);
					}
				}
				zx = xd[i-1] * xw[0] + xd[i+1] * xw[1];
				zy = xd[i-ncol] * yw[0] + xd[i+ncol] * yw[1];
				xval[i+addn] = sqrt( pow(zy, 2) + pow(zx, 2) ) ;
			}
			
	
		} else {
		
			double xw[2] = {-1,1};
			double yw[2] = {-1,1};
			for (i=0; i<2; i++) {
				xw[i] = xw[i] / (-2 * dx);
				yw[i] = yw[i] / (2 * dy);
			}
			for (i = ncol+1; i < (ncol * (nrow-1)-1); i++) {
				zx = xd[i-1] * xw[0] + xd[i+1] * xw[1];
				zy = xd[i-ncol] * yw[0] + xd[i+ncol] * yw[1];
				xval[i+addn] = sqrt( pow(zy, 2) + pow(zx, 2)  );
			}
		}

		if (unit == 0) {
			double adj = 180 / M_PI;
			for (i = ncol+1; i < (ncol * (nrow-1)-1); i++) {
				xval[i+addn] = atan(xval[i+addn]) * adj;
			}
		} else if (unit == 1) {
			for (i = ncol+1; i < (ncol * (nrow-1)-1); i++) {
				xval[i+addn] = atan(xval[i+addn]);
			}
		} 
		
		
		add++;		
	} 


	if (option[4]) {
	// aspect 4 neighbors	
		addn = add * n;

		if (geo) {
			int k, q;
			double xwi[2] = {-1,1};
			double xw[2] = {0,0};
			double yw[2] = {-1,1};

			
			for (i=0; i<2; i++) {
				yw[i] = yw[i] / (2 * dy);
			}			
			for (i = ncol; i < (ncol * (nrow-1)-1); i++) {
				if (i % ncol == 0) {
					q = i / ncol;
					for (k=0; k<2; k++) {
						xw[k] = xwi[k] / (-2 * ddx[q]);
					}
				}
				zx = xd[i-1] * xw[0] + xd[i+1] * xw[1];
				zy = xd[i-ncol] * yw[0] + xd[i+ncol] * yw[1];
				zx = atan2(zy, zx);
				xval[i+addn] = mod( M_PI_2 - zx, M_2PI);
			}
			if (unit == 0) {
				double adj = 180 / M_PI;
				for (i = ncol+1; i < (ncol * (nrow-1)-1); i++) {
					xval[i+addn] = xval[i+addn] * adj;
				}
			}				
	
		
		} else {
	
			double xw[2] = {-1,1};
			double yw[2] = {-1,1};
			for (i=0; i<2; i++) {
				xw[i] = xw[i] / (-2 * dx);
				yw[i] = yw[i] / (2 * dy);
			}
			for (i = ncol+1; i < (ncol * (nrow-1)-1); i++) {
				zx = xd[i-1] * xw[0] + xd[i+1] * xw[1];
				zy = xd[i-ncol] * yw[0] + xd[i+ncol] * yw[1];
				zx = atan2(zy, zx);
				xval[i+addn] = mod( M_PI_2 -zx, M_2PI);
			}
			if (unit == 0) {
				double adj = 180 / M_PI;
				for (i = ncol+1; i < (ncol * (nrow-1)-1); i++) {
					xval[i+addn] = xval[i+addn] * adj;
				}
			}
		}
		
		add++;
	
	} 
	
	
	if (option[5]) {
	// slope 8 neighbors	
		addn = add * n;
		if (geo) {
			int k, q;
			double xwi[6] = {-1,-2,-1,1,2,1};
			double xw[6] = {0,0,0,0,0,0};
			double yw[6] = {-1,1,-2,2,-1,1};
			
			for (i=0; i<6; i++) {
				yw[i] = yw[i] / (8 * dy);
			}
						
			for (i = ncol; i < (ncol * (nrow-1)-1); i++) {
				if (i % ncol == 0) {
					q = i / ncol;
					for (k=0; k<6; k++) {
						xw[k] = xwi[k] / (8 * ddx[q]);
					}
				}
				zx = xd[i-1-ncol] * xw[0] + xd[i-1] * xw[1] + xd[i-1+ncol] * xw[2]
						+ xd[i+1-ncol] * xw[3] + xd[i+1] * xw[4] + xd[i+1+ncol] * xw[5];
				zy = xd[i-1-ncol] * yw[0] + xd[i-1+ncol] * yw[1] + xd[i-ncol] * yw[2] 
						+ xd[i+ncol] * yw[3] + xd[i+1-ncol] * yw[4] + xd[i+1+ncol] * yw[5];
				xval[i+addn] = sqrt( pow(zy, 2) + pow(zx, 2)  );
								
			}
			
		} else {
		
			double xw[6] = {-1,-2,-1,1,2,1};
			double yw[6] = {-1,1,-2,2,-1,1};
			for (i=0; i<6; i++) {
				xw[i] = xw[i] / (-8 * dx);
				yw[i] = yw[i] / (8 * dy);
			}
			for (i = ncol+1; i < (ncol * (nrow-1)-1); i++) {
				zx = xd[i-1-ncol] * xw[0] + xd[i-1] * xw[1] + xd[i-1+ncol] * xw[2]
						+ xd[i+1-ncol] * xw[3] + xd[i+1] * xw[4] + xd[i+1+ncol] * xw[5];
				zy = xd[i-1-ncol] * yw[0] + xd[i-1+ncol] * yw[1] + xd[i-ncol] * yw[2] 
						+ xd[i+ncol] * yw[3] + xd[i+1-ncol] * yw[4] + xd[i+1+ncol] * yw[5];
				xval[i+addn] = sqrt( pow(zy, 2) + pow(zx, 2) );

			}
		}

		if (unit == 0) {
			double adj = 180 / M_PI;
			for (i = ncol+1; i < (ncol * (nrow-1)-1); i++) {
				xval[i+addn] = atan(xval[i+addn]) * adj;
			}
		} else if (unit == 1) {
			for (i = ncol+1; i < (ncol * (nrow-1)-1); i++) {
				xval[i+addn] = atan(xval[i+addn]);
			}
		} 
		
		add++;
		
	} 	
	
	if (option[6]) {
	// aspect 8 neighbors	
		addn = add * n;
	
		if (geo) {
			int k, q;
			double xwi[6] = {-1,-2,-1,1,2,1};
			double xw[6] = {0,0,0,0,0,0};
			double yw[6] = {-1,1,-2,2,-1,1};
			
			for (i=0; i<6; i++) {
				yw[i] = yw[i] / (8 * dy);
			}
						
			for (i = ncol; i < (ncol * (nrow-1)-1); i++) {
				if (i % ncol == 0) {
					q = i / ncol;
					for (k=0; k<6; k++) {
						xw[k] = xwi[k] / (-8 * ddx[q]);
					}
				}
				zx = xd[i-1-ncol] * xw[0] + xd[i-1] * xw[1] + xd[i-1+ncol] * xw[2]
						+ xd[i+1-ncol] * xw[3] + xd[i+1] * xw[4] + xd[i+1+ncol] * xw[5];
				zy = xd[i-1-ncol] * yw[0] + xd[i-1+ncol] * yw[1] + xd[i-ncol] * yw[2] 
						+ xd[i+ncol] * yw[3] + xd[i+1-ncol] * yw[4] + xd[i+1+ncol] * yw[5];
				zx = atan2(zy, zx);
				xval[i+addn] = mod( M_PI_2 -zx, M_2PI);
			}
			if (unit == 0) {
				double adj = 180 / M_PI;
				for (i = ncol+1; i < (ncol * (nrow-1)-1); i++) {
					xval[i+addn] = xval[i+addn] * adj;
				}
			}
		
		} else {
	
			double xw[6] = {-1,-2,-1,1,2,1};
			double yw[6] = {-1,1,-2,2,-1,1};
			for (i=0; i<6; i++) {
				xw[i] = xw[i] / (-8 * dx);
				yw[i] = yw[i] / (8 * dy);
			}
			for (i = ncol+1; i < (ncol * (nrow-1)-1); i++) {
				zx = xd[i-1-ncol] * xw[0] + xd[i-1] * xw[1] + xd[i-1+ncol] * xw[2]
						+ xd[i+1-ncol] * xw[3] + xd[i+1] * xw[4] + xd[i+1+ncol] * xw[5];
				zy = xd[i-1-ncol] * yw[0] + xd[i-1+ncol] * yw[1] + xd[i-ncol] * yw[2] 
						+ xd[i+ncol] * yw[3] + xd[i+1-ncol] * yw[4] + xd[i+1+ncol] * yw[5];
				zx = atan2(zy, zx);
				xval[i+addn] = mod( M_PI_2 -zx, M_2PI);
			}
			if (unit == 0) {
				double adj = 180 / M_PI;
				for (i = ncol+1; i < (ncol * (nrow-1)-1); i++) {
					xval[i+addn] = xval[i+addn] * adj;
				}
			}
			
		}
		
		add++;
		
	} if (option[7]) { 
	  // flow direction
		addn = add * n;
		int v;
		double d[8] = {0,0,0,0,0,0,0,0};
		double p[8] = {1,2,4,8,16,32,64,128}; // pow(2, j)
		double dxy = sqrt(dx * dx + dy * dy);
		double dmin;
		GetRNGstate();
		for (i = ncol+1; i < (ncol * (nrow-1)-1); i++) {
			if (R_IsNA(xd[i])) {
				xval[i+addn] = R_NaReal;
			} else {
				d[0] = (xd[i] - xd[i+1]) / dx;
				d[1] = (xd[i] - xd[i+1+ncol]) / dxy;
				d[2] = (xd[i] - xd[i+ncol]) / dy;
				d[3] = (xd[i] - xd[i-1+ncol]) / dxy;
				d[4] = (xd[i] - xd[i-1]) / dx;
				d[5] = (xd[i] - xd[i-1-ncol]) / dxy;
				d[6] = (xd[i] - xd[i-ncol]) / dy;
				d[7] = (xd[i] - xd[i+1-ncol]) / dxy;
				// using the lowest neighbor, even if it is higher than the focal cell.
				dmin = d[0];
				v = 0;
				for (j=1; j<8; j++) {
					if (d[j] > dmin) {
						dmin = d[j];
						v = j;
					} else if (d[j] == dmin) {
						if (unif_rand() > 0.5) {
							dmin = d[j];
							v = j;
						}
					}
				}
				xval[i+addn] = p[v];
			}
		}
		PutRNGstate();
		add++;
	}

	// a snippet to add to terrain.c?

	if (option[8]) {
		// planform curvature 8 neighbors	
			addn = add * n;
			double r, t, s;
			if (geo) {
				int k, q;
				double xwi[6] = {-1,-1,-1,1,1,1};
				double xw[6] = {0,0,0,0,0,0};
				double yw[6] = {-1,1,-1,1,-1,1};
				
				for (i=0; i<6; i++) {
					yw[i] = yw[i] / (8 * dy);
				}
							
				for (i = ncol; i < (ncol * (nrow-1)-1); i++) {
					if (i % ncol == 0) {
						q = i / ncol;
						for (k=0; k<6; k++) {
							xw[k] = xwi[k] / (8 * ddx[q]);
						}
					}
					zx = xd[i-1-ncol] * xw[0] + xd[i-1] * xw[1] + xd[i-1+ncol] * xw[2]
							+ xd[i+1-ncol] * xw[3] + xd[i+1] * xw[4] + xd[i+1+ncol] * xw[5];
					zy = xd[i-1-ncol] * yw[0] + xd[i-1+ncol] * yw[1] + xd[i-ncol] * yw[2] 
							+ xd[i+ncol] * yw[3] + xd[i+1-ncol] * yw[4] + xd[i+1+ncol] * yw[5];
					r = ( xd[i-1-ncol] + xd[i-1] + xd[i-1+ncol] + xd[i+1-ncol] + xd[i+1] + xd[i+1+ncol] - 2 * ( xd[i-ncol] + xd[i] + xd[i+ncol] ) ) / ( 3 * pow(dx,3) );
					t = ( xd[i-1-ncol] + xd[i-ncol] + xd[i+1-ncol] + xd[i-1+ncol] + xd[i+ncol] + xd[i+1+ncol] - 2 * ( xd[i-1] + xd[i] + xd[i+1] ) ) / ( 3 * pow(dy,3) );
	 				s = ( xd[i+1-ncol] + xd[i-1+ncol] - xd[i-1-ncol] - xd[i+1+ncol] ) / ( 4 * dx * dy );
					xval[i+addn] = -(pow(zy,2)*r-2*zx*zy*s+pow(zx,2)*t)/((pow(zx,2)+pow(zy,2))*sqrt(1+pow(zx,2)+pow(zy,2)));
									
				}
				
			} else {
			
				double xw[6] = {-1,-1,-1,1,1,1};
				double yw[6] = {-1,1,-1,1,-1,1};
				for (i=0; i<6; i++) {
					xw[i] = xw[i] / (-8 * dx);
					yw[i] = yw[i] / (8 * dy);
				}
				for (i = ncol+1; i < (ncol * (nrow-1)-1); i++) {
					zx = xd[i-1-ncol] * xw[0] + xd[i-1] * xw[1] + xd[i-1+ncol] * xw[2]
							+ xd[i+1-ncol] * xw[3] + xd[i+1] * xw[4] + xd[i+1+ncol] * xw[5];
					zy = xd[i-1-ncol] * yw[0] + xd[i-1+ncol] * yw[1] + xd[i-ncol] * yw[2] 
							+ xd[i+ncol] * yw[3] + xd[i+1-ncol] * yw[4] + xd[i+1+ncol] * yw[5];
					r = ( xd[i-1-ncol] + xd[i-1] + xd[i-1+ncol] + xd[i+1-ncol] + xd[i+1] + xd[i+1+ncol] - 2 * ( xd[i-ncol] + xd[i] + xd[i+ncol] ) ) / ( 3 * pow(dx,3) );
					t = ( xd[i-1-ncol] + xd[i-ncol] + xd[i+1-ncol] + xd[i-1+ncol] + xd[i+ncol] + xd[i+1+ncol] - 2 * ( xd[i-1] + xd[i] + xd[i+1] ) ) / ( 3 * pow(dy,3) );
	 				s = ( xd[i+1-ncol] + xd[i-1+ncol] - xd[i-1-ncol] - xd[i+1+ncol] ) / ( 4 * dx * dy );
					xval[i+addn] = -(pow(zy,2)*r-2*zx*zy*s+pow(zx,2)*t)/((pow(zx,2)+pow(zy,2))*sqrt(1+pow(zx,2)+pow(zy,2)));

				}
			}

		add++;
			
	}
	if (option[9]) {
		// profile curvature 8 neighbors	
			addn = add * n;
			double r, s, t;
			if (geo) {
				int k, q;
				double xwi[6] = {-1,-1,-1,1,1,1};
				double xw[6] = {0,0,0,0,0,0};
				double yw[6] = {-1,1,-1,1,-1,1};
				
				for (i=0; i<6; i++) {
					yw[i] = yw[i] / (8 * dy);
				}
							
				for (i = ncol; i < (ncol * (nrow-1)-1); i++) {
					if (i % ncol == 0) {
						q = i / ncol;
						for (k=0; k<6; k++) {
							xw[k] = xwi[k] / (8 * ddx[q]);
						}
					}
					zx = xd[i-1-ncol] * xw[0] + xd[i-1] * xw[1] + xd[i-1+ncol] * xw[2]
							+ xd[i+1-ncol] * xw[3] + xd[i+1] * xw[4] + xd[i+1+ncol] * xw[5];
					zy = xd[i-1-ncol] * yw[0] + xd[i-1+ncol] * yw[1] + xd[i-ncol] * yw[2] 
							+ xd[i+ncol] * yw[3] + xd[i+1-ncol] * yw[4] + xd[i+1+ncol] * yw[5];
					r = ( xd[i-1-ncol] + xd[i-1] + xd[i-1+ncol] + xd[i+1-ncol] + xd[i+1] + xd[i+1+ncol] - 2 * ( xd[i-ncol] + xd[i] + xd[i+ncol] ) ) / ( 3 * pow(dx,3) );
					t = ( xd[i-1-ncol] + xd[i-ncol] + xd[i+1-ncol] + xd[i-1+ncol] + xd[i+ncol] + xd[i+1+ncol] - 2 * ( xd[i-1] + xd[i] + xd[i+1] ) ) / ( 3 * pow(dy,3) );
	 				s = ( xd[i+1-ncol] + xd[i-1+ncol] - xd[i-1-ncol] - xd[i+1+ncol] ) / ( 4 * dx * dy );
					xval[i+addn] = -(pow(zx,2)*r+2*zx*zy*s+pow(zy,2)*t)/((pow(zx,2)+pow(zy,2))*pow(sqrt(1+pow(zx,2)+pow(zy,2)),3));  
				}
				
			} else {
			
				double xw[6] = {-1,-1,-1,1,1,1};
				double yw[6] = {-1,1,-1,1,-1,1};
				for (i=0; i<6; i++) {
					xw[i] = xw[i] / (-8 * dx);
					yw[i] = yw[i] / (8 * dy);
				}
				for (i = ncol+1; i < (ncol * (nrow-1)-1); i++) {
					zx = xd[i-1-ncol] * xw[0] + xd[i-1] * xw[1] + xd[i-1+ncol] * xw[2]
							+ xd[i+1-ncol] * xw[3] + xd[i+1] * xw[4] + xd[i+1+ncol] * xw[5];
					zy = xd[i-1-ncol] * yw[0] + xd[i-1+ncol] * yw[1] + xd[i-ncol] * yw[2] 
							+ xd[i+ncol] * yw[3] + xd[i+1-ncol] * yw[4] + xd[i+1+ncol] * yw[5];
					r = ( xd[i-1-ncol] + xd[i-1] + xd[i-1+ncol] + xd[i+1-ncol] + xd[i+1] + xd[i+1+ncol] - 2 * ( xd[i-ncol] + xd[i] + xd[i+ncol] ) ) / ( 3 * pow(dx,3) );
					t = ( xd[i-1-ncol] + xd[i-ncol] + xd[i+1-ncol] + xd[i-1+ncol] + xd[i+ncol] + xd[i+1+ncol] - 2 * ( xd[i-1] + xd[i] + xd[i+1] ) ) / ( 3 * pow(dy,3) );
	 				s = ( xd[i+1-ncol] + xd[i-1+ncol] - xd[i-1-ncol] - xd[i+1+ncol] ) / ( 4 * dx * dy );
					xval[i+addn] = -(pow(zx,2)*r+2*zx*zy*s+pow(zy,2)*t)/((pow(zx,2)+pow(zy,2))*pow(sqrt(1+pow(zx,2)+pow(zy,2)),3));  
				}
			}

			add++;
			
	} 
	
// Set edges to NA	
// first row	
	for (j=0; j<add; j++) {
	    int jn = j * n;
		for (i = 0; i < ncol; i++) {  
			xval[i+jn] = R_NaReal;
		}
	// last row	
		for (i = ncol * (nrow-1); i < n; i++) {  
			xval[i+jn] = R_NaReal; 
		}
	// first and last columns
		for (i = 1; i < nrow; i++) {  
			xval[i * ncol + jn] = R_NaReal;
			xval[i * ncol - 1 + jn] = R_NaReal;
		}
	}

	free(ddx);
	UNPROTECT(4);
	return(val);
}