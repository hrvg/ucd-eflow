## Download USGS gage data and analyze
## Written by Colin Byrne, Postdoctoral Scholar, UC-Davis, 2017

# Import libraries
library(waterData)

# Import discharge at ABQ gage
q08330000 <- importDVs("08330000", code="00060", stat="00003",
						sdate = "2010-01-01", edate = "2016-12-31")