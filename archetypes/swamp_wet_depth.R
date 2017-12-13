# Code runs through station wetted depth data for SWAMP sites and determines
# average wetted depth, CVd, w.d, d.d50
## Written by Colin Byrne, UC Davis Postdoc, 2017

rm(list=ls())

############### ******INPUTS******* ###################

root_dir <- "~/Documents/UC_Davis/Sacramento_Data/csv_files"
fname_swamp_ids <- "swamp_sites.csv"
fname_wet_w <- "swamp_wet_width.csv"
fname_wet_d <- "swamp_depth.csv"
fname_d50 <- "swamp_d50.csv"
fname_wet_d02 <- "swamp_depth02.csv"
fname_wet_all <- "RSG_WS_PRG_swamp_thalweg_center_depth.csv"

############### *******Code******** #####################

## Data manipulation
# Input raw data from compiled matrix
swamp_ids <- scan(file=file.path(root_dir,fname_swamp_ids),what=character(), sep=",")
depth_mat <- read.csv(file.path(root_dir,fname_wet_d), header=TRUE, sep=",")
width <- read.csv(file.path(root_dir, fname_wet_w), header=FALSE, sep=",")
d50 <- read.csv(file.path(root_dir, fname_d50), header=FALSE, sep=",")
depth_mat02 <- read.csv(file.path(root_dir,fname_wet_d02), header=TRUE, sep=",")
depth_mat_raw <- read.csv(file.path(root_dir,fname_wet_all),header=TRUE, sep=",")

data_df <- data.frame(width[,1], d50[,1], row.names=swamp_ids)
names(data_df)[1:2] <- c("width", "d50")
names(depth_mat)[4] <- "StationCode"

site_num <- dim(data_df)[1]
depth_col <- 5

# Initialize output vector
depth <- vector(mode='numeric', length=site_num)
CVd <- vector(mode='numeric', length=site_num)

x <- 0
for (site_name in swamp_ids){
	
	x <- x + 1
	
	# for each SWAMP site of interest extract out the relevant data
	site_data <- na.omit(depth_mat_raw[depth_mat_raw$StationCode==site_name, 3]) / 100
	
	# Determine the size of the site specific data
	n_site <- length(site_data)
	
	if (n_site > 0) {
		depth[x] <- mean(site_data)
		CVd[x] <- (sd(site_data) / mean(site_data))
	} else {
		depth[x] <- NA
		CVd[x] <- NA
	}
	
}

data_df$depth <- depth
data_df$CVd <- CVd
data_df$w.d <- data_df$width / data_df$depth
data_df$d.d50 <- data_df$depth / (data_df$d50 / 1000)

print(data_df)

# Write output text file for import into ArcGIS or Excel
write.table(data_df,file='~/Documents/UC_Davis/Sacramento_Data/csv_files/swamp_wet_depth_calcs.csv',
	sep=',',append = FALSE)
