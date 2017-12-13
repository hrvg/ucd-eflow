# Script runs a rescale function, produces scree plot for PC analysis
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
fname_raw_matrix <- "RSG_data.csv"
fname_sa_bins <- "RSG_bins.csv"
survey_rows <- c(1:33)
swamp_rows <- c(34:53)

############### *******Code******** #####################

## Data manipulation
# Input raw data from compiled matrix
raw_mat <- read.csv(file.path(root_dir,fname_raw_matrix), header=TRUE, sep=",")
sa_bins <- read.csv(file.path(root_dir, fname_sa_bins), header=FALSE, sep=",")

###### Here is a good place to identify which variables to look at ########
###### Depending on which variables are chosen na.omit will leave out certain sites ######
# Variable List
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
att_col <- c(1,2,8,9,10,11,12,14,16,17,18,19,20,21,22)
remove_col <- c(-7)
raw_site_names <- names(raw_mat)

# Currently selecting all attributes except correlated d.D50 with NAs omitted
select_mat <- raw_mat
select_mat <- select_mat[,remove_col]
#select_mat <- select_mat[apply(select_mat, 1, function(row) all(row != 0)),]
#select_mat <- select_mat[,att_col]
select_mat <- na.omit(select_mat)

# Number and names of variables
var_num <- dim(select_mat)[2] - 1
var_names <- colnames(select_mat[2:(var_num+1)])

# Split raw matrix into Site IDs and data
site_ids <- select_mat[,1]
data_mat <- select_mat[,2:(var_num + 1)]

# Convert data matrix into data frame and split to Survey and SWAMP sites
data_df <- na.omit(data.frame(data_mat, row.names=site_ids))
survey_df <- data_df[survey_rows,]
swamp_df <- data_df[swamp_rows,]

# Rescale matrix using rescale function
rescale_mat <- rescale0_1(data_mat)
rescale_df <- data.frame(rescale_mat, row.names=site_ids)
names(rescale_df)[1:var_num] <- var_names

## Check for correlation using default Pearson method
pearson_cor <- cor(rescale_df)

## NMDS analysis
print("********NMDS Analysis**********")
pc_analysis<-prcomp(rescale_df) # performs principal component analysis
env_vectors<-envfit(pc_analysis, rescale_df) # fits vectors of variables
dist_df <- dist(rescale_df) # calculates Euclidean distances between rows
nmds <- metaMDS(dist_df,try=50) # 
#nmds # prints outputs to screen
# Analyze vectors for significance
#sig_env <- row.names(env_vectors[4]<=0.001)

## Ward's hierarchical clustering
print("********Ward's clustering**********")
ward_fit <- hclust(dist_df, method="ward.D") # ward.D vs ward.D2
clust_num <- NbClust(rescale_df, distance="euclidean", min.nc=2, max.nc=15,
						method="ward.D")
print(table(clust_num$Best.n[1,]))

# choose tree cut level (k) and evaluate results
groups <- as.matrix(cutree(ward_fit, k=10)) # cut tree into k clusters
rescale_grouped <- as.data.frame(cbind(rescale_df,groups))
rescale_grouped <- rescale_grouped[order(groups),]

## K-means clustering
# Create scree plot to determine the correct number of groups
print("********K-means clustering**********")
max_clust <- 15
seed <- 233
wss <- (nrow(rescale_df)-1)*sum(apply(rescale_df, 2, var))
for (i in 2:max_clust) {
	set.seed(seed)
	wss[i] <- sum(kmeans(rescale_df, centers=i)$withinss)
}

# Run the kmeans clustering for a chosen number of clusters
clust_k <- 10 #indicate number of clusters
k_means <- kmeans(rescale_df, clust_k, nstart=12, iter.max=1000) 
db <- index.DB(rescale_df, k_means$cluster)

# Print Davies-Bouldin clustering index to assess cluster strength
cat("Davies-Bouldin =", db$DB, "\n") 

## CART
print("********CART**********")
sig_att_numbers <- c(2,3,4,5,7,8,11,12,14,17,18,19,21)
cart_fit <- rpart(groups ~ slope + CV_bf.d + Dmax,
				data=data_df, method="class",minsplit=3) # play with using different combinations of variables in CART
#summary(cart_fit)
prune_cart<-prune(cart_fit,0.03)

# Evaluate misclassification rate
pred_cart <- predict(prune_cart, data_df, type=c("class"))
misclass <- cbind(groups, pred_cart)
perc_class <- nrow(misclass[misclass[,1]==misclass[,2],]) / length(misclass[,1]) * 100
cat("Percent correctly classified =", perc_class, "\n")
#misclass

## MANOVA


## ANOVA for each variable



############### *******Output******** #####################
## Print Pearson correlation values
#print(pearson_cor)
#dev.new()
## Plot scatter plot matrices to see visual linear relationships
#scatterplotMatrix(rescale_df, spread=FALSE)
## Plot correlations with visual and numeric relationships
#dev.new()
#corrplot.mixed(pearson_cor, lower="number", upper="ellipse")
## Plot scree plot with suggested number of Principal Components
#dev.new()
#fa.parallel(rescale_df, fa="pc", n.iter=100)
#dev.new()

## NMDS plots
#fname_sa_bins <- "RSG_bins.csv"
#sa_bins <- read.csv(file.path(root_dir, fname_sa_bins), header=TRUE, sep=",")
#dev.new()
#plot(nmds, type="t") # Plots NMDS with site names
#plot(env_vectors)
#legend(x="bottomleft", legend = levels(sa_bins), col=1:10, pch=16)
#plot(nmds, type="t") # Plots NMDS with site names
#plot(env_vectors)

## Histograms of Survey vs SWAMP data for each variable
#par(mfrow=c(3,5))
#for (j in 1:var_num) {
#	max_val <- max(survey_df[,j], swamp_df[,j])
#	min_val <- min(survey_df[,j], swamp_df[,j])
#	brk_vals <- seq(min_val, max_val, length.out=11)
#	hist(survey_df[,j], breaks=brk_vals, col=rgb(1,0,0,0.5),main=var_names[j], xlab=var_names[j])
#	hist(swamp_df[,j], add=TRUE, breaks=brk_vals, col=rgb(0,0,1,0.5))
#}

## Wards plot
dev.new()
plot(ward_fit, labels=site_ids, cex=0.7, hang=-1)
#rect.hclust(ward_fit, k=5, border="red") # box clusters at various cut levels
rect.hclust(ward_fit, k=5, border="blue")

## Plot CART classification tree
dev.new()
par(mfcol=c(1,1))
plot(prune_cart, margin=.03, uniform=TRUE, branch=.1)
text(prune_cart)

## Plot K-means
# Scree plot
dev.new()
plot(1:max_clust, wss, type="b", xlab="number of Clusters", 
		ylab="Within groups sum of squares")
		
#plot k classes across 2 variables
#dev.new()
#final<-cbind(k_means$cluster, rescale_df)
#palette(c("red","orange","cyan","magenta","blue", "green"))#,"purple","yellow"))
#a<-rescale_df[,2]
#b<-rescale_df[,8]
#plot(a,b,col=k_means$clust, pch=16)
#points(k_means$centers, col = 1:5, pch = 8) # plots cluster "centers"
#legend('topright', legend = levels(factor(k_means$clust)), col = 1:8, cex = 0.8, pch = 16)

