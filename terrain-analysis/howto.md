# cross compilaton

install Rtools from https://cran.r-project.org/bin/windows/Rtools/
update PATH

Windows 10 and Windows 8

    In Search, search for and then select: System (Control Panel)
    Click the Advanced system settings link.
    Click Environment Variables. In the section System Variables, find the PATH environment variable and select it. Click Edit. If the PATH environment variable does not exist, click New.

compile on Windows machine
copy back .c, .o and .dll files to UNIX machine
execute from Windows machine (source code is still on UNIX machine)

# C compilation
R CMD SHLIB script.c

# useful R raster commands

rasterOptions(tmpdir = 'F:/tmp/R/')
removeTmpFiles(h=0.)
compareRaster(x,y,values=True)