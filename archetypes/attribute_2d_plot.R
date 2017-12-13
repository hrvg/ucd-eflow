# Plots a two-dimensional variable data based upon rescale_df 
# which is created in the stats_analysis.R script
## Written by Colin Byrne, UC Davis Postdoc, 2017

# Column attributes
# 1 - Ac
# 2 - slope
# 3 - bankfull depth
# 4 - bankfull width
# 5 - bankfull width/depth ratio
# 6 - bankfull depth/D50 ratio
# 7 - Coef of Variance of bankfull depth
# 8 - Coef of Variance of bankfull width
# 9 - sinuosity
# 10 - entrenchment ratio
# 11 - D50
# 12 - D84
# 13 - Dmax
# 14 - shear stress
# 15 - shields stress

x1_num <- 1
y1_num <- 2

x1 <- data_df[,x1_num]
y1 <- data_df[,y1_num]

x1_name <- names(rescale_df)[x1_num]
y1_name <- names(rescale_df)[y1_num]

att_color <- c("black","red","green3","blue","cyan",
					"magenta","yellow","gray","purple",
					"brown")[as.factor(sa_bins[,1])] 

plot(x1, y1, type="p", log="x", col=att_color, xlab=x1_name, ylab=y1_name, pch=16)
textxy(x1, y1, site_ids)
legend(x="topright", legend = levels(as.factor(sa_bins[,1])), 
			col=c("black","red","green3","blue","cyan",
			"magenta","yellow","gray","purple",
			"brown"), pch=16)