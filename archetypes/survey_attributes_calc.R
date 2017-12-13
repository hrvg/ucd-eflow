# Code will analyze a set of surveyed width and depth measurements
# and calculate all attributes w, d, w.d, CV_w, CV_d, bf.w, bf.d, bf.w.d,
# CV_bf.w, CV_bf.d
# Must have the package called 'openxlsx'
## Written by Colin Byrne, UC Davis Postdoc, 2017

rm(list = ls())

############## *******LIBRARIES******* ################
library("openxlsx")

############### ******INPUTS******* ###################
# Location of raw data files
root_dir <- "~/Documents/UC_Davis/Sacramento_Data/raw_data_xs/all_sites"
file_names <- list.files(path=root_dir)
file_num <- length(file_names)

############### *******Code******** #####################

# Initialize output vectors
hyd.class <- vector(mode='character', length=file_num)
site_id_split <- vector(mode='character', length=file_num)
site.id <- vector(mode='character', length=file_num)
wet.d <- vector(mode='numeric', length=file_num)
wet.w <- vector(mode='numeric', length=file_num)
w.d <- vector(mode='numeric', length=file_num)
CV_d <- vector(mode='numeric', length=file_num)
CV_w <- vector(mode='numeric', length=file_num)
bf.d <- vector(mode='numeric', length=file_num)
bf.w <- vector(mode='numeric', length=file_num)
bf.w.d <- vector(mode='numeric', length=file_num)
CV_bf.d <- vector(mode='numeric', length=file_num)
CV_bf.w <- vector(mode='numeric', length=file_num)

for (i in 1:file_num) {
	
	# Name file of interest within loop step
	i_fname <- file.path(root_dir,file_names[i])
	hyd.class[i] <- unlist(strsplit(file_names[i],'[_.]+'))[4]
	site.id[i] <- unlist(strsplit(file_names[i],'[_.]+'))[5]
	
	# Import the data associated with the file
	i_data_raw <- read.xlsx(i_fname)

	# Identify the rows/columns of interest for wetted depth
	att.index.col <- as.numeric(which(apply(i_data_raw, 2, 
							function(x) any(grepl("Water depth at thalweg", x)))))
	wd.index <- as.numeric(which(apply(i_data_raw, 1, 
							function(x) any(grepl("Water depth at thalweg", x)))))
	att.cols <- (att.index.col[1]+2):(att.index.col[1]+2+10)
	# Identify the rows of interest for bankfull depth
	bfd.index <- as.numeric(which(apply(i_data_raw, 1, 
							function(x) any(grepl("Bankfull depth at thalweg", x)))))
	# Identify wetted width rows
	ww.index <- as.numeric(which(apply(i_data_raw, 1, 
							function(x) any(grepl("L edge of water", x)))))
	# Identify bankfull width rows
	bfw.index <- as.numeric(which(apply(i_data_raw, 1, 
							function(x) any(grepl("L bankfull", x)))))
	
	# Calculate attributes 
	d.wet <- as.numeric(i_data_raw[wd.index,att.cols])
	l.wet <- as.numeric(i_data_raw[ww.index,att.cols])
	r.wet <- as.numeric(i_data_raw[ww.index+1,att.cols])
	d.bf <- as.numeric(i_data_raw[bfd.index,att.cols])
	l.bf <- as.numeric(i_data_raw[bfw.index,att.cols])
	r.bf <- as.numeric(i_data_raw[bfw.index+3,att.cols])
	
	wet.d[i] <- mean(na.omit(d.wet))
	wet.w[i] <- mean(na.omit(r.wet - l.wet))
	w.d[i] <- wet.w[i] / wet.d[i]
	CV_d[i] <- sd(na.omit(d.wet)) / mean(na.omit(d.wet))
	CV_w[i] <- sd(na.omit(r.wet - l.wet)) / mean(na.omit(r.wet - l.wet))
	
	bf.d[i] <- mean(na.omit(d.bf))
	bf.w[i] <- mean(na.omit(r.bf - l.bf))
	bf.w.d[i] <- bf.w[i] / bf.d[i]
	CV_bf.d[i] <- sd(na.omit(d.bf)) / mean(na.omit(d.bf))
	CV_bf.w[i] <- sd(na.omit(r.bf - l.bf)) / mean(na.omit(r.bf - l.bf))
	
}

att_df <- data.frame(hyd.class, site.id, wet.d, wet.w, w.d, CV_d, CV_w, bf.d, bf.w,
						 bf.w.d, CV_bf.d, CV_bf.w)

write.table(att_df,
		file='~/Documents/UC_Davis/Sacramento_Data/csv_files/r_outputs/survey_att_outputs.csv',
		sep=',',append = FALSE)
		
		