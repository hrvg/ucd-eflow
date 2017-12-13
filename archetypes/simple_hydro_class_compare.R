## Boxplots lookign into the differences between hydrologic classifications
## based upon data organized into Area and Slope bins
## Written by Colin Byrne, UC Davis Postdoc, 2017

rm(list = ls())

############### *****LIBRARIES***** ###################
source("column_aov.R")
library(MASS)
library(multcomp)

############### ******INPUTS******* ###################

root_dir <- "~/Documents/UC_Davis/Sacramento_Data/statistics"
fname_raw_matrix <- "all_hydro_data.csv"

csv.root <- "~/Documents/UC_Davis/Sacramento_Data/csv_files"

Ac.iterate <- read.csv(file.path(csv.root, "area_min_max_simple.csv"), header=TRUE, sep=",")
S.iterate <- read.csv(file.path(csv.root, "slope_min_max_simple.csv"), header=TRUE, sep=",")

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

# Calculate total number of iterations
tot.combos <- length(Ac.iterate[,1]) * length(S.iterate[,1])

# Extract area and slope combinations of interest
stats.num <- 0

for (i in 1:length(Ac.iterate[,1])) {
	for (j in 1:length(S.iterate[,1])) {
		
		minS <- S.iterate[j,1]
		maxS <- S.iterate[j,2]
		minAc <- Ac.iterate[i,1]
		maxAc <- Ac.iterate[i,2]
		
		lsr.AcS <- lsr.mat[lsr.mat$slope > minS & lsr.mat$slope < maxS &
							 lsr.mat$Ac > minAc & lsr.mat$Ac < maxAc,]
		rsg.AcS <- rsg.mat[rsg.mat$slope > minS & rsg.mat$slope < maxS &
							 rsg.mat$Ac > minAc  & rsg.mat$Ac < maxAc,]
		ws.AcS <- ws.mat[ws.mat$slope > minS & ws.mat$slope < maxS &
							 ws.mat$Ac > minAc  & ws.mat$Ac < maxAc,]
		pgr.AcS <- pgr.mat[pgr.mat$slope > minS & pgr.mat$slope < maxS &
							 pgr.mat$Ac > minAc  & pgr.mat$Ac < maxAc,]
							 
		# Number of sites for each hydrologic class
		lsr.rows <- nrow(lsr.AcS)
		rsg.rows <- nrow(rsg.AcS)
		ws.rows <- nrow(ws.AcS)
		pgr.rows <- nrow(pgr.AcS)
		
		# ## All hydrologic classifications
		
		# if (lsr.rows > 5) {lsr.yn <- 1} else {lsr.yn <- 0}
		# if (rsg.rows > 5) {rsg.yn <- 1} else {rsg.yn <- 0}
		# if (ws.rows > 5) {ws.yn <- 1} else {ws.yn <- 0}
		# if (pgr.rows > 5) {pgr.yn <- 1} else {pgr.yn <- 0}
		# level.num <- sum(lsr.yn, rsg.yn, ws.yn, pgr.yn)
		
		# # Recombine for MANOVA analysis
		# hydro.AcS <- as.matrix(rbind(lsr.AcS, rsg.AcS, ws.AcS, pgr.AcS))

		# if (level.num > 3 & nrow(hydro.AcS) > 15) {
			
			# stats.num <- stats.num + 1
			
			# # Create variable with hydrologic class as factor (COULD BE IMPROVED)
			# hydro.class <- vector(mode="character", length=lsr.rows+rsg.rows+ws.rows+pgr.rows)
			# hydro.class[1:lsr.rows] <- "LSR"
			# hydro.class[(lsr.rows+1):(rsg.rows+lsr.rows)] <- "RSG"
			# hydro.class[(rsg.rows+lsr.rows+1):(ws.rows+rsg.rows+lsr.rows)] <- "WS"
			# hydro.class[(ws.rows+rsg.rows+lsr.rows+1):(pgr.rows+ws.rows+rsg.rows+lsr.rows)] <- "PGR"
			# hydro.class <- as.factor(hydro.class)
			
			# # MANOVA
			# aggregate(hydro.AcS, by=list(hydro.class), FUN=mean)
			# cov(hydro.AcS)
			# manova.fit <- manova(hydro.AcS ~ hydro.class) 
			# p.manova <- as.numeric(summary(manova.fit)$stats[1, "Pr(>F)"])
			
			# if (stats.num == 1) {
				# manova.out <- cbind(minS, maxS, minAc, maxAc, lsr.rows, rsg.rows, ws.rows,
									# pgr.rows, p.manova)
			# } else {
				# manova.out <- rbind(manova.out,cbind(minS, maxS, minAc, maxAc, lsr.rows, 
										# rsg.rows, ws.rows, pgr.rows, p.manova))
			# }
			
		# }	
		
		## Only LSR and RSG comparison
		if (lsr.rows > 5) {lsr.yn <- 1} else {lsr.yn <- 0}
		if (rsg.rows > 5) {rsg.yn <- 1} else {rsg.yn <- 0}
		level.num <- sum(lsr.yn, rsg.yn)
		
		# Recombine for MANOVA analysis
		hydro.AcS <- as.matrix(rbind(lsr.AcS[,3:13], rsg.AcS[,3:13]))

		if (level.num > 1 & nrow(hydro.AcS) > 15) {
			
			stats.num <- stats.num + 1
			
			# Create variable with hydrologic class as factor (COULD BE IMPROVED)
			hydro.class <- vector(mode="character", length=lsr.rows+rsg.rows)
			hydro.class[1:lsr.rows] <- "LSR"
			hydro.class[(lsr.rows+1):(rsg.rows+lsr.rows)] <- "RSG"
			hydro.class <- as.factor(hydro.class)
			
			aov.hydro.AcS <- hydro.AcS
			
			# MANOVA
			aggregate(hydro.AcS, by=list(hydro.class), FUN=mean)
			cov(hydro.AcS)
			manova.fit <- manova(hydro.AcS ~ hydro.class) 
			p.manova <- as.numeric(summary(manova.fit)$stats[1, "Pr(>F)"])
			
			for (k in 1:11) {
				if (k == 1) {bf.d.aov <- column_aov(aov.hydro.AcS[,k],hydro.class)}
				if (k == 2) {bf.w.aov <- column_aov(aov.hydro.AcS[,k],hydro.class)}
				if (k == 3) {bf.w.d.aov <- column_aov(aov.hydro.AcS[,k],hydro.class)}
				if (k == 4) {bf.d.D50.aov <- column_aov(aov.hydro.AcS[,k],hydro.class)}
				if (k == 5) {CV_bf.d.aov <- column_aov(aov.hydro.AcS[,k],hydro.class)}
				if (k == 6) {CV_bf.w.aov <- column_aov(aov.hydro.AcS[,k],hydro.class)}
				if (k == 7) {sinuosity.aov <- column_aov(aov.hydro.AcS[,k],hydro.class)}
				if (k == 8) {e.ratio.aov <- column_aov(aov.hydro.AcS[,k],hydro.class)}
				if (k == 9) {D50.aov <- column_aov(aov.hydro.AcS[,k],hydro.class)}
				if (k == 10) {D84.aov <- column_aov(aov.hydro.AcS[,k],hydro.class)}
				if (k == 11) {Dmax.aov <- column_aov(aov.hydro.AcS[,k],hydro.class)}
			}
			
			if (stats.num == 1) {
				stats.out <- cbind(minS, maxS, minAc, maxAc, lsr.rows, rsg.rows, p.manova, bf.d.aov,
									bf.w.aov, bf.w.d.aov, bf.d.D50.aov, CV_bf.d.aov, CV_bf.w.aov,
									sinuosity.aov, e.ratio.aov, D50.aov, D84.aov, Dmax.aov)
			} else {
				stats.out <- rbind(stats.out,cbind(minS, maxS, minAc, maxAc, lsr.rows, 
										rsg.rows, p.manova, bf.d.aov, bf.w.aov, bf.w.d.aov, 
										bf.d.D50.aov, CV_bf.d.aov, CV_bf.w.aov, sinuosity.aov, 
										e.ratio.aov, D50.aov, D84.aov, Dmax.aov))
			}
			
		}	
			
	}
}

stats.out <- as.data.frame(stats.out)
sig.manova <- stats.out[stats.out$p.manova<0.001,]

fract.sig <- nrow(sig.manova)/nrow(stats.out)
print(fract.sig)

# if (var_num %% 3 == 0) {
	# hist_rnum <- var_num / 3
# } else {hist_rnum <- var_num / 3 + 1}

# dev.new()
# par(mfrow=c(3,hist_rnum))
# for (j in 1:var_num) {
	# att_name <- names(lsr.mat[j])
	# data_df <- data.frame(values = as.numeric(hydro.AcS[,j]),
					# vars = rep(c('lsr', 'rsg', 'ws', 'pgr'), 
							# times = hydro.rows))
	# boxplot(values ~ vars, data=data_df, main=var_names[j],
				# col=c('lightblue1','green4', 'purple2', 'orange'))
# }


