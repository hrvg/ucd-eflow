## Analyzes StreamCat data for each RSG site
## Written by Colin Byrne, Postdoctoral Scholar, 2017

################ LIBRARIES ####################


################# INPUTS ######################
sc.dir <- "~/Documents/UC_DAVIS/StreamCat"
rsg_nhd_fname <- "~/Documents/UC_DAVIS/Sacramento_Data/RSG/RSG_NHD_COMIDs.csv"
rsg_data_fname <- "~/Documents/UC_DAVIS/Sacramento_Data/statistics/RSG_data.csv"

# File names for StreamCat data
#sc_fnames <- list.files(path=sc_dir)
sc.interests <- c("Dams_CA.csv", "FirePerimeters_CA.csv", "Mines_CA.csv", 
					"NLCD2011_CA.csv")

################ MAIN CODE ####################

# Acquire information for RSG COMIDs and RSG geomorphic attribute data 
rsg.comids <- read.csv(rsg_nhd_fname, header=TRUE, sep=",")
rsg.data <- read.csv(rsg_data_fname, header=TRUE, sep=",")

# Assign COMID to correct sites in attribute data
for (i in 1:length(rsg.data$Site_ID)) {
	rsg.data$COMID[i] <- 
		as.numeric(rsg.comids$COMID[as.numeric(rsg.comids$SiteID)==
										as.numeric(rsg.data$Site_ID[i])])
}

# Create 
rsg.sc.data <- rsg.data
x <- 0

# Run Analysis for certain files named above
for (fname in sc.interests) {
	x <- x + 1
	
	# Open iterative file
	file.raw <- read.csv(file.path(sc.dir,fname),header=TRUE, sep=",")
	
	# Collect attribute names
	col_names <- colnames(file.raw)
	
	# Add new anthropogenic attributes to geomorphic attributes
	for (i in 1:length(rsg.sc.data$Site_ID)) {
		
		# Only add watershed and catchment areas from first file
		if (fname == "Dams_CA.csv") {
			rsg.sc.data$CatAreaSqKm[i] <- 
				as.numeric(file.raw$CatAreaSqKm[as.numeric(file.raw$COMID)==
													as.numeric(rsg.sc.data$COMID[i])])
			rsg.sc.data$WsAreaSqKm[i] <- 
				as.numeric(file.raw$WsAreaSqKm[as.numeric(file.raw$COMID)==
													as.numeric(rsg.sc.data$COMID[i])])
			rsg.sc.data$DamNIDStorCat[i] <- 
				as.numeric(file.raw$DamNIDStorCat[as.numeric(file.raw$COMID)==
													as.numeric(rsg.sc.data$COMID[i])])
			rsg.sc.data$DamNIDStorWs[i] <- 
				as.numeric(file.raw$DamNIDStorWs[as.numeric(file.raw$COMID)==
													as.numeric(rsg.sc.data$COMID[i])])
		} else if (fname == "FirePerimeters_CA.csv") {
			rsg.sc.data$PctFire10yrCat[i] <- 
				sum(as.numeric(file.raw[as.numeric(file.raw$COMID)==
											as.numeric(rsg.sc.data$COMID[i]),6:16]))
			rsg.sc.data$PctFire10yrWs[i] <- 
				sum(as.numeric(file.raw[as.numeric(file.raw$COMID)==
											as.numeric(rsg.sc.data$COMID[i]),17:27]))
		} else if (fname == "Mines_CA.csv") {
			rsg.sc.data$MineDensCat[i] <- 
				as.numeric(file.raw$MineDensCat[as.numeric(file.raw$COMID)==
													as.numeric(rsg.sc.data$COMID[i])])
			rsg.sc.data$MineDensWs[i] <- 
				as.numeric(file.raw$MineDensWs[as.numeric(file.raw$COMID)==
													as.numeric(rsg.sc.data$COMID[i])])
		} else if (fname == "NLCD2011_CA.csv") {
			rsg.sc.data$PctUrbHi2011Cat[i] <- 
				as.numeric(file.raw$PctUrbHi2011Cat[as.numeric(file.raw$COMID)==
													as.numeric(rsg.sc.data$COMID[i])])
			rsg.sc.data$PctUrbHi2011Ws[i] <- 
				as.numeric(file.raw$PctUrbHi2011Ws[as.numeric(file.raw$COMID)==
													as.numeric(rsg.sc.data$COMID[i])])
			rsg.sc.data$PctUrbMd2011Cat[i] <- 
				as.numeric(file.raw$PctUrbMd2011Cat[as.numeric(file.raw$COMID)==
													as.numeric(rsg.sc.data$COMID[i])])
			rsg.sc.data$PctUrbMd2011Ws[i] <- 
				as.numeric(file.raw$PctUrbMd2011Ws[as.numeric(file.raw$COMID)==
													as.numeric(rsg.sc.data$COMID[i])])
			rsg.sc.data$PctCrop2011Cat[i] <- 
				as.numeric(file.raw$PctCrop2011Cat[as.numeric(file.raw$COMID)==
													as.numeric(rsg.sc.data$COMID[i])])
			rsg.sc.data$PctCrop2011Ws[i] <- 
				as.numeric(file.raw$PctCrop2011Ws[as.numeric(file.raw$COMID)==
													as.numeric(rsg.sc.data$COMID[i])])
			rsg.sc.data$PctHay2011Cat[i] <- 
				as.numeric(file.raw$PctHay2011Cat[as.numeric(file.raw$COMID)==
													as.numeric(rsg.sc.data$COMID[i])])
			rsg.sc.data$PctHay2011Ws[i] <- 
				as.numeric(file.raw$PctHay2011Ws[as.numeric(file.raw$COMID)==
													as.numeric(rsg.sc.data$COMID[i])])
		}
	}
	
}

# Write output text file for import into ArcGIS or Excel
write.table(rsg.sc.data,
		file='~/Documents/UC_Davis/Sacramento_Data/csv_files/r_outputs/rsg_gm_anthro_data.csv',
		sep=',',append = FALSE)
		
