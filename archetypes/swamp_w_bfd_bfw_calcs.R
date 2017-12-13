# Code runs through station wetted depth data for SWAMP sites and determines
# average wetted depth, CVd, w.d, d.d50
## Written by Colin Byrne, UC Davis Postdoc, 2017

rm(list=ls())

############### ******INPUTS******* ###################

root_dir <- "~/Documents/UC_Davis/Sacramento_Data/csv_files"
fname_swamp_ids <- "swamp_sites.csv"
fname_swamp_raw <- "swamp_w_bfd_bfw_raw.csv"

############### *******Code******** #####################

## Data manipulation
# Input raw data from compiled matrix
swamp_ids <- scan(file=file.path(root_dir,fname_swamp_ids),what=character(), sep=",")
swamp_raw <- read.csv(file.path(root_dir,fname_swamp_raw),header=TRUE, sep=",")

site_num <- length(swamp_ids)

# Initialize output vectors
width <- vector(mode='numeric', length=site_num)
bfd <- vector(mode='numeric', length=site_num)
bfw <- vector(mode='numeric', length=site_num)
CVw <- vector(mode='numeric', length=site_num)
CVbfd <- vector(mode='numeric', length=site_num)
CVbfw <- vector(mode='numeric', length=site_num)

x <- 0
for (site_name in swamp_ids){
	
	x <- x + 1
	
	# for each SWAMP site of interest extract out the relevant data
	site_width <- na.omit(swamp_raw$Result[(swamp_raw$StationCode==site_name &
												swamp_raw$Analyte=="Wetted Width")])
	site_bfd <- na.omit(swamp_raw$Result[(swamp_raw$StationCode==site_name &
												swamp_raw$Analyte=="Bankfull Height")])
	site_bfw <- na.omit(swamp_raw$Result[(swamp_raw$StationCode==site_name &
												swamp_raw$Analyte=="Bankfull Width")])
	
	# Determine the size of the site specific data
	#n_site <- length(site_data)
	
	#if (n_site > 0) {
		
	#} else {
	#	depth[x] <- NA
	#	CVd[x] <- NA
	#}
	
	width[x] <- mean(site_width)
	bfd[x] <- mean(site_bfd)
	bfw[x] <- mean(site_bfw)
	CVw[x] <- sd(site_width) / mean(site_width)
	CVbfd[x] <- sd(site_bfd) / mean(site_bfd)
	CVbfw[x] <- sd(site_bfw) / mean(site_bfw)
	
}

data_df <- data.frame(width, bfd, bfw, CVw, CVbfd, CVbfw,
						row.names=swamp_ids)

print(data_df)

# Write output text file for import into ArcGIS or Excel
write.table(data_df,file='~/Documents/UC_Davis/Sacramento_Data/csv_files/swamp_w_bfd_bfw_output.csv',
	sep=',',append = FALSE)
