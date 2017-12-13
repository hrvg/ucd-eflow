## Ward's hierarchical clustering
## Adapted from Belize Lane by Colin Byrne, UC Davis Postdoc, 2017

print("********Ward's clustering**********")
group_num <- 3

ward_fit <- hclust(dist_df, method="ward.D") # ward.D vs ward.D2
clust_num <- NbClust(rescale_df, distance="euclidean", min.nc=2, max.nc=15,
						method="ward.D")
print(table(clust_num$Best.n[1,]))

# choose tree cut level (k) and evaluate results
groups <- as.matrix(cutree(ward_fit, k=group_num)) # cut tree into k clusters
rescale_grouped <- as.data.frame(cbind(rescale_df,groups))
rescale_grouped <- rescale_grouped[order(groups),]
