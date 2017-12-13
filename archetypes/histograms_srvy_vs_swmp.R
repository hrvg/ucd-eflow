## Histograms of Survey vs SWAMP data for each variable
## Written by Colin Byrne, UC Davis Postdoc, 2017

if (var_num %% 3 == 0) {
	hist_rnum <- var_num / 3
} else {hist_rnum <- var_num / 3 + 1}


par(mfrow=c(3,hist_rnum))
for (j in 1:var_num) {
	max_val <- max(survey_df[,j], swamp_df[,j])
	min_val <- min(survey_df[,j], swamp_df[,j])
	brk_vals <- seq(min_val, max_val, length.out=11)
	hist(survey_df[,j], breaks=brk_vals, col=rgb(1,0,0,0.5),main=var_names[j],
			xlab=var_names[j])
	hist(swamp_df[,j], add=TRUE, breaks=brk_vals, col=rgb(0,0,1,0.5))
}