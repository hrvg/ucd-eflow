# setup
- UNIX system used for coding and testing on synthetic/limited data
- Win7 system used as a remote computing server
- Win7 system grab the scripts stored on the UNIX system 
- Win7 system uses the datafiles stored on its hard-drives 

# setting up R
- download RStudio
- installing packages with RStudio
- in case of trouble installing gdal : sudo apt-get install libgdal1-dev

## libraries
- raster
- rgdal
- RSAGA
- sp
- bigmemory
- bigalgebra
- biganalytics
- MapReduce
- RandomFields
- fractaldim
- wavelets

# efficient memory management and coding
- use raster options controlling memory
- create a swap partition to virtually expand RAM
- call C code in R (60 times faster!)
- less efficient options using only one use of the raster.focal function :
	+ pairing functions
	+ encoding (Godel encoding, encoded = a1 + a2 k1 + a3 k1 k2 then Euclidean division)

# useful R raster commands
- rasterOptions(tmpdir = 'F:/tmp/R/') : change the directory where .gri and .grd temp files (backing Raster* objects) are stored
- removeTmpFiles(h=0.) : remove temporary Raster* files with age less than h
- compareRaster(x,y,values=True) : compare the values of two Raster*

# C scripts and R

## compiling C code in Windows : .dll file
- install Rtools from https://cran.r-project.org/bin/windows/Rtools/
- update PATH environment variable (Advanced system settings) for R and Rtools
- compile on Windows system by typing 'R CMD SHLIB script.c' in a command shell, .o and .dll files are created
- copy back .c, .o and .dll files to UNIX machine (see setup)

## compiling C code in UNIX : .so file
- compile on UNIX system by typing 'R CMD SHLIB script.c' in a command shell, .o and .so files are created

## calling C scripts in R
- UNIX : dyn.load("terrain_.dll")
- Windows : dyn.load("terrain_.so")
- R : .Call(<C function call>)