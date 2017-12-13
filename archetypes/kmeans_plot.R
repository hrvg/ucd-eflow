# Plots k-means clusters based upon two geomorphic attributes after
# stats_analysis.R has been run
## Written by Colin Byrne, UC Davis Postdoc, 2017

clust_num <- 6
x_col <- 3
y_col <- 12

x_var <- names(rescale_df[x_col])
y_var <- names(rescale_df[y_col])

final<-cbind(k_means$cluster, rescale_df)
palette(c("red","orange","cyan","magenta","blue", "green"))#,"purple","yellow"))
a<-rescale_df[,x_col]
b<-rescale_df[,y_col]
plot(a,b,col=k_means$clust, pch=16, xlab=x_var, ylab=y_var)
points(k_means$centers, col = 1:clust_num, pch = 8) # plots cluster "centers"
legend('topright', legend = levels(factor(k_means$clust)),
		col = 1:clust_num, cex = 0.8, pch = 16)