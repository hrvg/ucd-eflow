## Script plots correlation, runs a rescale function and prepares raw data 
## for statistical analysis
## Written by Colin Byrne, UC Davis Postdoc, 2017

rm(list = ls())

############## *******LIBRARIES and FUNCTIONS******* ################
source("rescale0_1.R")
library("car")
library("corrplot")
library("psych")
library("vegan")
library("MASS")
library("ggplot2")
library("gridExtra")
library("NbClust")
library("rpart")
library("clusterSim")
library("RColorBrewer")
library("calibrate")

############### ******INPUTS******* ###################
root_dir <- "~/Documents/UC_Davis/Sacramento_Data/statistics"
fname_raw_matrix <- "pgr_data.csv"
fname_sa_bins <- "RSG_bins.csv"

############### *******Code******** #####################

## Data manipulation
# Input raw data from compiled matrix
raw_mat <- read.csv(file.path(root_dir,fname_raw_matrix), header=TRUE, sep=",")
sa_bins <- read.csv(file.path(root_dir, fname_sa_bins), header=FALSE, sep=",")

###### Here is a good place to identify which variables to look at ########
###### Depending on which variables are chosen na.omit will leave out certain sites ######
# Variable List for seasonal included
#	2	Ac
#	3	slope
#	4	d
#	5	w
#	6	w.d
#	7	d.D50
#	8	CV_d
#	9	CV_w
#	10	bf.d
#	11	bf.w
#	12	bf.w.d
#	13	bf.d.D50
#	14	CV_bf.d
#	15	CV_bf.w
#	16	sinuosity
#	17	e.ratio
#	18	D50
#	19	D84
#	20	Dmax
#	21	shear.stress
#	22	shields.stress
#	23	CV_sediment

# Which attributes to include?
att_col <- c(1:length(raw_mat[1,]))
remove_col <- c(-12,-13,-14,-15,-16)
raw_site_names <- names(raw_mat)

# Variable List for seasonal included
#	2	Ac
#	3	slope
#	4	bf.d
#	5	bf.w
#	6	bf.w.d
#	7	bf.d.D50
#	8	CV_bf.d
#	9	CV_bf.w
#	10	sinuosity
#	11	e.ratio
#	12	D50
#	13	D84
#	14	Dmax
#	15	shear.stress
#	16	shields.stress

# Currently selecting all attributes except correlated d.D50 with NAs omitted
select_mat <- raw_mat
select_mat <- select_mat[,remove_col]
#select_mat <- select_mat[,att_col]
select_mat$Ac[select_mat$Ac>1000] <- NA
select_mat <- na.omit(select_mat)

# Number and names of variables
var_num <- dim(select_mat)[2] - 1
var_names <- colnames(select_mat[2:(var_num+1)])

# Split raw matrix into Site IDs and data
site_ids <- select_mat[,1]
data_mat <- select_mat[,2:(var_num + 1)]

# Convert data matrix into data frame and split to Survey and SWAMP sites
data_df <- na.omit(data.frame(data_mat, row.names=site_ids))
survey_df <- data_df[is.na(as.numeric(row.names(data_df)))==FALSE,]
swamp_df <- data_df[is.na(as.numeric(row.names(data_df)))==TRUE,]

# Rescale matrix using rescale function
rescale_mat <- rescale0_1(data_mat)
rescale_df <- data.frame(rescale_mat, row.names=site_ids)
names(rescale_df)[1:var_num] <- var_names

## Check for correlation using default Pearson method
pearson_cor <- cor(rescale_df)

## Plot correlations with visual and numeric relationships
#dev.new()
corrplot.mixed(pearson_cor, lower="number", upper="ellipse")