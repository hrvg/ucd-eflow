# Plots NMDS with vectors assuming stats_analysis.R has been run
## Written by Colin Byrne, UC Davis Postdoc, 2017

## NMDS analysis
print("********NMDS Analysis**********")
pc_analysis<-prcomp(rescale_df) # performs principal component analysis
env_vectors<-envfit(pc_analysis, rescale_df) # fits vectors of variables
dist_df <- dist(rescale_df) # calculates Euclidean distances between rows
nmds <- metaMDS(dist_df,try=100) # 
#nmds # prints outputs to screen
# Analyze vectors for significance
#sig_env <- row.names(env_vectors[4]<=0.001)
