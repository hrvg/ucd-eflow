# Whisker and box plots for significant NMDS vectors
# Significance determined by env_vectors output in stats_analysis.R
## Written by Colin Byrne, 2017

library("multcomp")

groups <- as.factor(groups)

sig_att_numbers <- c(1,2,3,4,5,6,7,8,9,10,11,12)
sig_num <- length(sig_att_numbers)

if (sig_num %% 3 == 0) {
	plot_rnum <- sig_num / 3
} else {plot_rnum <- sig_num / 3 + 1}

# Box and whisker plots for chosen attributes

dev.new()
par(mfrow=c(3,plot_rnum))
z <- 0
for (j in sig_att_numbers) {
	z <- z + 1
	att_name <- names(data_mat[j])
	f <- paste(att_name, "~", "groups")
	#boxplot(as.formula(f), data=data_mat, main=att_name)
	
	aov.fit <- aov(as.formula(f), data=data_mat)
	
	# par(las=2)
	# plot(TukeyHSD(aov.fit))

	par(mar=c(5,4,6,2))
	tuk <- glht(aov.fit, linfct=mcp(groups="Tukey"))
	plot(cld(tuk, level=0.05), col="lightgrey")
}