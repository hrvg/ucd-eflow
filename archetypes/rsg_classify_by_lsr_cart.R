# Check classification of RSG based on LSR CART analysis
## Written by Colin Byrne, UC Davis Postdoc, 2017

# Which attributes are included
# Level 1 - D84
# Level 2 - CV_bf.w, Ac
# Level 3 - bf.w, CV_bf.w
# Level 4 - slope, CV_bf.d
# Level 5 - e.ratio, bf.w.d
# Level 6 - bf.w.d

############### ******INPUTS******* ###################

root_dir <- "~/Documents/UC_Davis/Sacramento_Data/statistics"
fname_raw_matrix <- "RSG_data.csv"

############### *******Code******** #####################

## Data manipulation
# Input raw data from compiled matrix
raw_mat <- read.csv(file.path(root_dir,fname_raw_matrix), header=TRUE, sep=",")
#sa_bins <- read.csv(file.path(root_dir, fname_sa_bins), header=FALSE, sep=",")

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
att_col <- c(1,2,3,11,12,14,15,16,17,19)
raw_site_names <- names(raw_mat)

# Currently selecting all attributes except correlated d.D50 with NAs omitted
select_mat <- raw_mat
#select_mat <- select_mat[,remove_col]
select_mat <- select_mat[,att_col]
select_mat <- na.omit(select_mat)

# Number and names of variables
var_num <- dim(select_mat)[2] - 1
var_names <- colnames(select_mat[2:(var_num+1)])

# Split raw matrix into Site IDs and data
site_ids <- select_mat[,1]
data_mat <- select_mat[,2:(var_num + 1)]

# Convert data matrix into data frame and split to Survey and SWAMP sites
data_df <- na.omit(data.frame(data_mat, row.names=site_ids))

site_num <- dim(data_df)[1]
#lsr_class <- vector(mode='numeric', length=site_num)

#data_df$class_assess <- "u"

for (i in 1:site_num) {
	if (data_df$CV_bf.w[i] > 0.055) {
		if (data_df$CV_bf.w[i] < 0.88) {
			if (data_df$CV_bf.d[i] < 0.64) {
				if (data_df$slope[i] < 0.065) {
					if (data_df$bf.w.d[i] > 33) {
						data_df$lsr_class_nd[i] <- 2.1
					} else {data_df$lsr_class_nd[i] <- 5}
				} else {data_df$lsr_class_nd[i] <- 1}
			} else {data_df$lsr_class_nd[i] <- 4.1}
		} else {
			if (data_df$slope[i] < 0.0125) {
				if (data_df$bf.w.d[i] > 33) {
					data_df$lsr_class_nd[i] <- 2.2
				} else {data_df$lsr_class_nd[i] <- 7}
			} else {data_df$lsr_class_nd[i] <- 4.2}
		}
	} else {
		if (data_df$sinuosity[i] < 1.55) {
			if (data_df$e.ratio[i] < 3.5) {
				data_df$lsr_class_nd[i] <- 6
			} else {
				if (data_df$e.ratio[i] > 6) {
					data_df$lsr_class_nd[i] <- 3
				} else {data_df$lsr_class_nd[i] <- 8}
			}
		} else {data_df$lsr_class_nd[i] <- 9}
	}
}

for (i in 1:site_num) {
	if (data_df$D84[i] < 4000) {
		if (data_df$CV_bf.w[i] < 0.77) {
			if (data_df$bf.w[i] < 30) {
				if (data_df$slope[i] < 0.065) {
					if (data_df$e.ratio[i] < 6) {
						if (data_df$bf.w.d[i] < 30) {
							data_df$lsr_class_all[i] <- 5.1
						} else {data_df$lsr_class_all[i] <- 2}
					} else {data_df$lsr_class_all[i] <- 3}
				} else {data_df$lsr_class_all[i] <- 1}
			} else {data_df$lsr_class_all[i] <- 9}
		} else {
			if (data_df$bf.w > 12) {
				data_df$lsr_class_all[i] <- 2
			} else {data_df$lsr_class_all[i] <- 4}
		}
	} else {
		if (data_df$Ac[i] < 4500) {
			if (data_df$CV_bf.w[i] < 0.18) {
				data_df$lsr_class_all[i] <- 6.1
			} else {
				if (data_df$CV_bf.d[i] < 0.64) {
					if (data_df$bf.w.d[i] > 15) {
						data_df$lsr_class_all[i] <- 6.2
					} else {data_df$lsr_class_all[i] <- 5.2}
				} else {data_df$lsr_class_all[i] <- 4}
			}
		} else {data_df$lsr_class_all[i] <- 8}
	}
	
	if (data_df$lsr_class_all[i] == data_df$lsr_class_nd[i]) {
		data_df$class.check[i] <- 1
	} else {data_df$class.check[i] <- 0}
		
	#print(data_df[i,])
	#data_df$class_assess[i] <- readline(prompt=
	#					"Match? (y)es,(n)o,(m)aybe,(u)nkown: ")
						
}

#print(data_df)

write.table(data_df,
		file='~/Documents/UC_Davis/Sacramento_Data/csv_files/r_outputs/rsg_class_by_lsr_cart.csv',
		sep=',',append = FALSE)