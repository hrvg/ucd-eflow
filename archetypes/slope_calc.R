# Code will analyze a set of elevation measurements and calculate slope based
# upon least squares regression analysis
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
csv_dir <- "~/Documents/UC_Davis/Sacramento_Data/csv_files"
fname_inverse <- "inverse_survey.csv"

############### *******Code******** #####################

# Load data associated with inverting survey transect data
inv_yn <- read.csv(file.path(csv_dir,fname_inverse), header=TRUE, sep=",")

# Initialize output vectors
hydro_class <- vector(mode='character', length=file_num)
site_id_split <- vector(mode='character', length=file_num)
site_id <- vector(mode='character', length=file_num)
site_slope <- vector(mode='numeric', length=file_num)

# Cycle through all files in directory
for (i in 1:file_num) {
	
	# Name file of interest within loop step
	i_fname <- file.path(root_dir,file_names[i])
	hydro_class[i] <- unlist(strsplit(file_names[i],'[_.]+'))[4]
	site_id[i] <- unlist(strsplit(file_names[i],'[_.]+'))[5]
	
	# Import the data associated with the file
	i_data_raw <- read.xlsx(i_fname)
	
	# Identify the rows/columns of interest for longitudinal profile
	lp_index <- which(apply(i_data_raw, 1, function(x) any(grepl("Longitudinal profile", x))))
	longtopo_rows <- (lp_index[1] + 3):(lp_index[1]+3+10)
	# Identify the columns of interest for depth at thalweg
	td_index <- which(apply(i_data_raw, 2, function(x) any(grepl("Water depth at thalweg", x))))
	thaldpth_cols <- (td_index[1]+2):(td_index[1]+2+10)
	# Identify whether the reach is 150 or 250 meters long
	length_col <- which(apply(i_data_raw, 2, function(x) any(grepl("(use 150m reach)", x))))
	if (is.na(i_data_raw[7,length_col+1]) == FALSE) {
		reach_length <- 150
	} else {reach_length <- 250}
	
	ds_distance_all <- seq(0,reach_length, reach_length / 10)
	
	
	# Extract survey and backsight elevations and thalweg depth
	survey_z_raw <- as.numeric(i_data_raw[longtopo_rows,2])
	backsight_z_raw <- as.numeric(i_data_raw[longtopo_rows,6])
	thalweg_d_raw <- as.numeric(i_data_raw[28,thaldpth_cols])
	
	# If statement determines whether longitudinal elevations were surveyed
	if (sum(!is.na(survey_z_raw)) > 0) {
	
		# Remove missing data from 11 transects if survey elevations were not taken
		survey_z <- survey_z_raw[is.na(survey_z_raw)==FALSE]
		backsight_z <- backsight_z_raw[is.na(survey_z_raw)==FALSE]
		thalweg_d <- thalweg_d_raw[is.na(survey_z_raw)==FALSE]
		ds_distance <- ds_distance_all[is.na(survey_z_raw)==FALSE]
	
		# Calculate number of transects with survey elevations 
		transect_num <- length(survey_z)
	
		# Create vector for final elevations with thalweg depth and backsight adjustments
		final_z <- vector(mode='numeric',length=transect_num)
		adjust <- vector(mode='numeric',length=transect_num)
		
		inv_row <- 
		
		# Flip transects if surveyed 11-1
		if (as.numeric(inv_yn$Inverse[hydro_class[i]==as.character(inv_yn$Hydro) & 
					as.numeric(site_id[i])==inv_yn$SiteID] == 1)  |
			as.numeric(inv_yn$Inverse[hydro_class[i]==as.character(inv_yn$Hydro) & 
					as.numeric(site_id[i])==inv_yn$SiteID] == 2)) {
				survey_z <- rev(survey_z)
				backsight_z <- rev(backsight_z)
				thalweg_d <- rev(thalweg_d)
				ds_distance <- rev(ds_distance)
				cat("Reversed!!!\n")
		}
		
		# Calculate depth of water at thalweg and backsight adjusted height
		# for each transect point
		for (j in 1:transect_num) {
		
			# Calculate adjustment number if backsighted
			if (j == 1) {
				adjust[j] <- 0
			} else if (j!=1 & is.na(backsight_z[j-1]) == FALSE) {
				adjust[j] <- survey_z[j-1] - backsight_z[j-1]
			} else {adjust[j] <- adjust[j-1]}
			
			# Calculate adjusted survey height
			if (is.na(thalweg_d[j])==FALSE) {
				final_z[j] <- survey_z[j] - thalweg_d[j] + adjust[j]
			} else {final_z[j] <- survey_z[j] + adjust[j]}
		}
		
		# Calculate slope based on least squares regression
		i_data <- data.frame(ds_distance, -final_z)
		linear_model <- lm(-final_z ~ ds_distance, i_data)
		site_slope[i] <- coefficients(linear_model)[2]
		
		# Plot linear model if you wish
		plot(ds_distance, -final_z)
		abline(linear_model)
		
		# Print to screen if desired, otherwise commented out
		cat(hydro_class[i], site_id[i],'\n')
		cat('Surv', survey_z,'\n')
		cat('Thal', thalweg_d,'\n')
		cat('Back', backsight_z, '\n')
		cat('BAdj', adjust,'\n')
		cat('FinZ', final_z,'\n')
		cat('Slope', site_slope[i],'\n')
		
		# Pause model to look at plot
		invisible(readline(prompt="Press [enter] to continue"))

	} else {
		site_slope[i] <- NA
	}
	
}

# Compile slopes into table and order by Hydrologic Class and site ID

raw_df <- data.frame(hydro_class, site_id, abs(site_slope))

final_df <- raw_df[order(raw_df$hydro_class,raw_df$site_id),]

print(final_df)

# Write output text file for import into ArcGIS or Excel
write.table(final_df,
		file='~/Documents/UC_Davis/Sacramento_Data/csv_files/r_outputs/slopes.csv',
		sep=',',append = FALSE)

