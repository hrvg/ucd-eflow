# After data_prep_correlation.R has been run, this code creates rescaled
# histograms of geomorphic attributes
## Written by Colin Byrne, UC Davis Postdoc, 2017

## Rescale UCD and SWAMP separately

#rescale_srvy <- rescale0_1(data_mat[survey_rows,])
#rescale_swmp <- rescale0_1(data_mat[swamp_rows,])

#sep_rescale <- data.frame(rbind(rescale_srvy, rescale_swmp), row.names=site_ids)
#names(sep_rescale)[1:var_num] <- var_names

## Plot rescaled together and rescaled separately

if (var_num %% 3 == 0) {
	hist_rnum <- var_num / 3
} else {hist_rnum <- var_num / 3 + 1}

# Histograms for chosen attributes

# Plot histogram for attributes rescaled together
#dev.new()
par(mfrow=c(3,hist_rnum))
for (j in 1:var_num) {
	hist_name <- names(rescale_df[j])
	hist(rescale_df[,j],main=paste(hist_name),xlab='')
}

# Plot histogram for attributes rescaled separately (UCD, SWAMP)
#dev.new()
#par(mfrow=c(3,hist_rnum))
#for (j in 1:var_num) {
#	hist_name <- names(sep_rescale[j])
#	hist(sep_rescale[,j],main=paste(hist_name),xlab='')
#	hist(sep_rescale[survey_rows,j])
#	hist(sep_rescale[swamp_rows,j])
#}
