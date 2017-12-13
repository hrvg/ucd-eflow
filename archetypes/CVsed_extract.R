# Calculates CVsed for all UCDavis survey sites based upon raw XS data sheets
## Written by Colin Byrne, UC Davis Postdoc, 2017

rm(list = ls())

############## *******LIBRARIES******* ################
library("openxlsx")

############### ******INPUTS******* ###################
# Location of raw data files
root_dir <- "~/Documents/UC_Davis/Sacramento_Data/raw_data_xs/all_sites"
file_names <- list.files(path=root_dir)
file_num <- length(file_names)
csv_dir <- "~/Documents/UC_Davis/Sacramento_Data/csv_files"

############### *******Code******** #####################

# Initialize output vectors
hydro_class <- vector(mode='character', length=file_num)
site_id_split <- vector(mode='character', length=file_num)
site_id <- vector(mode='character', length=file_num)
site_CVsed <- vector(mode='numeric', length=file_num)

d16 <- vector(mode='numeric', length=file_num)
d50 <- vector(mode='numeric', length=file_num)
d84 <- vector(mode='numeric', length=file_num)
dmax <- vector(mode='numeric', length=file_num)
sedsd <- vector(mode='numeric', length=file_num)
sedmean <- vector(mode='numeric', length=file_num)
CV_sed <- vector(mode='numeric', length=file_num)

# Cycle through all files in directory
for (i in 1:file_num) {
	
	# Name file of interest within loop step
	i_fname <- file.path(root_dir,file_names[i])
	hydro_class[i] <- unlist(strsplit(file_names[i],'[_.]+'))[4]
	site_id[i] <- unlist(strsplit(file_names[i],'[_.]+'))[5]
	
	# Import the data associated with the file
	i_data_raw <- read.xlsx(i_fname,na.strings="")
	
	# Identify the rows/columns of interest for longitudinal profile
	rstart <- which(i_data_raw[,1]=="<2")
	rend <- which(i_data_raw[,2]=="SUM (10)") - 1
	rlabels <- i_data_raw[rstart:rend,1]
	
	# Total sediment samples
	tot_samp <- sum(data.matrix(i_data_raw[rstart:rend,3:13]),na.rm=TRUE)
	
	# Create vector of total sample length
	site_samp <- vector(mode="numeric", length=tot_samp)
	
	k <- 1
	for (j in rstart:rend) {
		# Calculate number of samples in sediment class
		samp_num <- sum(data.matrix(i_data_raw[j,3:13]),na.rm=TRUE)
		
		# Assign the correct sediment size
		lab_row <- j - rstart + 1
		
		if (rlabels[lab_row]=="<2") {
			samp_size <- 2
		} else if (rlabels[lab_row]=="2.8") {
			samp_size <- 2.8
		} else if (rlabels[lab_row]=="4") {
			samp_size <- 4
		} else if (rlabels[lab_row]=="5.6") {
			samp_size <- 5.6
		} else if (rlabels[lab_row]=="8") {
			samp_size <- 8
		} else if (rlabels[lab_row]=="11") {
			samp_size <- 11
		} else if (rlabels[lab_row]=="16") {
			samp_size <- 16
		} else if (rlabels[lab_row]=="22.6") {
			samp_size <- 22.6
		} else if (rlabels[lab_row]=="32") {
			samp_size <- 32
		} else if (rlabels[lab_row]=="45") {
			samp_size <- 45
		} else if (rlabels[lab_row]=="64") {
			samp_size <- 64
		} else if (rlabels[lab_row]=="90") {
			samp_size <- 90
		} else if (rlabels[lab_row]=="128") {
			samp_size <- 128
		} else if (rlabels[lab_row]=="190") {
			samp_size <- 190
		} else if (rlabels[lab_row]==">190") {
			samp_size <- 1000
		} else {samp_size <- 5000}
		
		# Fill in the site_samp matrix with the correct number of samples
		# in each sediment size class
		site_samp[k:(k+samp_num)] <- samp_size;
		
		k <- k + samp_num + 1
		
		if (tot_samp < k) {break}
	}
	
	# Convert any 0 values to NA
	site_samp[site_samp == 0] <- NA
	
	# Calculate sediment sizes
	d16[i] <- quantile(site_samp, probs=0.16, na.rm=TRUE, type=1)
	d50[i] <- quantile(site_samp, probs=0.50, na.rm=TRUE, type=1)
	d84[i] <- quantile(site_samp, probs=0.84, na.rm=TRUE, type=1)
	dmax[i] <- max(site_samp, na.rm=TRUE)
	sedsd[i] <- 0.5 * (d50[i] / d16[i] + d84[i] / d50[i])
	sedmean[i] <- mean(site_samp, na.rm=TRUE)
	CV_sed[i] <- sedsd[i] / sedmean[i]
	
	#cat(hydro_class[i], site_id[i], rstart, rend, "\n", sep='\t')
	
}

sediment_stats <- data.frame(hydro_class, site_id, d50, d84, sedsd, sedmean, dmax, CV_sed)
print(sediment_stats)

# Write output text file for import into ArcGIS or Excel
write.table(sediment_stats,file='~/Documents/UC_Davis/Sacramento_Data/csv_files/r_outputs/UCDsites_sediment_output.csv',
	sep=',',append = FALSE)