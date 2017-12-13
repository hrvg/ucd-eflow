## Boxplots of geomorphic attributes split by hydrologic class
## Written by Colin Byrne, UC Davis Postdoc, 2017

rm(list = ls())

############### ******INPUTS******* ###################

root_dir <- "~/Documents/UC_Davis/Sacramento_Data/statistics"
fname_raw_matrix <- "all_hydro_data.csv"

############### *******Code******** #####################

## Data manipulation
# Input raw data from compiled matrix
raw_mat <- read.csv(file.path(root_dir,fname_raw_matrix), header=TRUE, sep=",")

# Which attributes to include?
att_col <- c(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16)
remove_col <- c(-4,-5,-6,-7,-8,-9,-21,-22,-23)
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
#select_mat <- select_mat[,remove_col]
#select_mat <- select_mat[,att_col]
#select_mat$Ac[select_mat$Ac>1000] <- NA
select_mat <- na.omit(select_mat)

# Find rows with index of each hydrologic classification
lsr.index <- as.numeric(which(apply(select_mat, 1, 
							function(x) any(grepl("LSR", x)))))
rsg.index <- as.numeric(which(apply(select_mat, 1, 
							function(x) any(grepl("RSG", x)))))
ws.index <- as.numeric(which(apply(select_mat, 1, 
							function(x) any(grepl("WS", x)))))
pgr.index <- as.numeric(which(apply(select_mat, 1, 
							function(x) any(grepl("PGR", x)))))
							
# Dimensions of each index
lsr.num <- length(lsr.index)
rsg.num <- length(rsg.index)
ws.num <- length(ws.index)
pgr.num <- length(pgr.index)
							
# Create matrices for each hydrologic class
lsr.mat <- select_mat[lsr.index,2:16]
rsg.mat <- select_mat[rsg.index,2:16]
ws.mat <- select_mat[ws.index,2:16]
pgr.mat <- select_mat[pgr.index,2:16]

var_num <- dim(lsr.mat)[2]
var_names <- colnames(lsr.mat)

if (var_num %% 3 == 0) {
	hist_rnum <- var_num / 3
} else {hist_rnum <- var_num / 3 + 1}

dev.new()
par(mfrow=c(3,hist_rnum))
for (j in 1:var_num) {
	att_name <- names(lsr.mat[j])
	data_df <- data.frame(values = as.numeric(select_mat[,j+1]),
					vars = rep(c('lsr', 'rsg', 'ws', 'pgr'), 
							times = c(lsr.num, rsg.num, ws.num, pgr.num)))
	boxplot(values ~ vars, data=data_df, main=var_names[j],
				col=c('lightblue1','green4', 'purple2', 'orange'))
}

