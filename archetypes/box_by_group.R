# Whisker and box plots for significant NMDS vectors
# Significance determined by env_vectors output in stats_analysis.R
## Written by Colin Byrne, 2017

sig_att_numbers <- c(1,2,3,4,5,6,7,8,9,10,11,12,13)
sig_num <- length(sig_att_numbers)

if (sig_num %% 3 == 0) {
	plot_rnum <- sig_num / 3
} else {plot_rnum <- sig_num / 3 + 1}

# Box and whisker plots for chosen attributes

#dev.new()
par(mfrow=c(3,plot_rnum))
z <- 0
for (j in sig_att_numbers) {
	z <- z + 1
	att_name <- names(data_mat[j])
	f <- paste(att_name, "~", "groups")
	boxplot(as.formula(f), data=data_mat, main=att_name)
}