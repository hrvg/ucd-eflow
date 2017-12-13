# Code runs through raw SWAMP sediment data and calculates D16, D50, D84, Dmax
## Written by Colin Byrne, UC Davis Postdoc, 2017

############## *******LIBRARIES******* ################

############### ******INPUTS******* ###################
# Location of raw data files
root_dir <- "~/Documents/UC_Davis/Sacramento_Data/csv_files"
fname_raw_data <- "raw_swamp_sediment.csv"
fname_sedsize_table <- "sediment_size_table.csv"
fname_site_list <- "sac_3b_4_6_swamp_site_list.csv"

############### *******Code******** #####################

# Retrieve data from specific files
site_list <- scan(file=file.path(root_dir,fname_site_list),what=character(), sep=",")
sed_size <- read.csv(file.path(root_dir,fname_sedsize_table),header=TRUE, sep=",")
swamp_data <- read.csv(file.path(root_dir,fname_raw_data), header=TRUE, sep=",")

# Calculate number of sites of interest
site_num <- length(site_list)

# Initialize output vectors
d16 <- vector(mode='numeric', length=site_num)
d50 <- vector(mode='numeric', length=site_num)
d84 <- vector(mode='numeric', length=site_num)
dmax <- vector(mode='numeric', length= site_num)
CV_sed <- vector(mode='numeric', length= site_num)

x <- 0 
# Loop through each SWAMP site of interest
for (site_name in site_list) {
	
	x <- x + 1
	
	# for each SWAMP site of interest extract out the relevant data
	col_num <- c(2,7)
	site_data <- swamp_data[swamp_data$StationCode==site_name,col_num]
	
	# Determine the size of the site specific data
	nrow_site <- dim(site_data)[1]
	
	if (nrow_site > 0) {
	
		# Run through each data point to determine sediment sizes
		for (i in 1:nrow_site) {
		
			# Specific sample
			sample_size <- site_data$Result[i]
			
			# Check if data was recorded as number or sediment class
			if (is.na(as.numeric(as.character(sample_size)))==TRUE) {
			
				# Assign the correct sediment value
				if (sample_size == "RS" | sample_size == "RR") {
					site_data[i,3] <- 5000
				} else if (sample_size == "XB") {
					site_data[i,3] <- 2500
				} else if (sample_size == "SB") {
					site_data[i,3] <- 1000
				} else if (sample_size == "CB") {
					site_data[i,3] <- 250
				} else if (sample_size == "GC") {
					site_data[i,3] <- 64
				} else if (sample_size == "GF") {
					site_data[i,3] <- 16
				} else if (sample_size == "SA") {
					site_data[i,3] <- 2
				} else if (sample_size == "FN" | sample_size == "HP") {
					site_data[i,3] <- 0.06
				} else {site_data[i,3] <- NA}
			} else if (is.na(as.numeric(as.character(sample_size)))==FALSE & 
							as.numeric(as.character(sample_size)) == 0) {
				site_data[i,3] <- NA
			} else {site_data[i,3] <- as.numeric(as.character(sample_size))}
			
		}
		
		#print(site_data)		
		# Pause model to look at data
		#invisible(readline(prompt="Press [enter] to continue"))
		
		# Calculate sediment sizes
		d16[x] <- quantile(site_data[,3], probs=0.16, na.rm=TRUE, type=1)
		d50[x] <- quantile(site_data[,3], probs=0.50, na.rm=TRUE, type=1)
		d84[x] <- quantile(site_data[,3], probs=0.84, na.rm=TRUE, type=1)
		dmax[x] <- max(site_data[,3], na.rm=TRUE)
		CV_sed[x] <- (0.5 * (d50[x] / d16[x] + d84[x] / d50[x])) / mean(site_data[,3], na.rm=TRUE)
		
	} else {
		d50[x] <- NA
		d84[x] <- NA
		dmax[x] <- NA
		CV_sed[x] <- NA
	}
	
}
sediment_stats <- data.frame(site_list, d50, d84, dmax, CV_sed)
print(sediment_stats)

# Write output text file for import into ArcGIS or Excel
write.table(sediment_stats,file='~/Documents/UC_Davis/Sacramento_Data/csv_files/swamp_sediment_output.csv',
	sep=',',append = FALSE)