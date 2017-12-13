## K-means clustering
# Create scree plot to determine the correct number of groups
## Adapted from Belize Lane by Colin Byrne, UC Davis Postdoc, 2017

print("********K-means clustering**********")
max_clust <- 15
seed <- 233
wss <- (nrow(rescale_df)-1)*sum(apply(rescale_df, 2, var))
for (i in 2:max_clust) {
	set.seed(seed)
	wss[i] <- sum(kmeans(rescale_df, centers=i)$withinss)
}

# Run the kmeans clustering for a chosen number of clusters
clust_k <- 3 #indicate number of clusters
k_means <- kmeans(rescale_df, clust_k, nstart=12, iter.max=1000) 
db <- index.DB(rescale_df, k_means$cluster)

# Print Davies-Bouldin clustering index to assess cluster strength
cat("Davies-Bouldin =", db$DB, "\n") 


## Plot K-means
# Scree plot
dev.new()
plot(1:max_clust, wss, type="b", xlab="number of Clusters", 
		ylab="Within groups sum of squares")


## Plots k-means clusters based upon two geomorphic attributes after
# stats_analysis.R has been run

clust_num <- 3
x_col <- 3
y_col <- 12

x_var <- names(rescale_df[x_col])
y_var <- names(rescale_df[y_col])

final<-cbind(k_means$cluster, rescale_df)
#palette(c("red","orange","cyan","magenta","blue", "green"))#,"purple","yellow"))
a<-rescale_df[,x_col]
b<-rescale_df[,y_col]
#plot(a,b,col=k_means$clust, pch=16, xlab=x_var, ylab=y_var)
#points(k_means$centers, col = 1:clust_num, pch = 8) # plots cluster "centers"
#legend('topright', legend = levels(factor(k_means$clust)),
#		col = 1:clust_num, cex = 0.8, pch = 16)