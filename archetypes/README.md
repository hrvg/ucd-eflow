Files uploaded to the archetypes folder used for the hydrogeomorphic classification are as follows:
1) RSG_data_prep_correlation.R - opens data from csv file, decide which geomorphic attributes to use for classification here
    - Define the number of clusters/groups to use in the following scripts (set.num)
2) nmds_analysis.R - performs the non-metric multi-dimensional scaling
3) wards_analysis.R - performs the Ward's clustering
4) wards_nmds_plot.R - creates plots for NMDS and Ward's with the desired number of groups
5) kmeans_analysis.R - creates the scree plot of interest for the data
6) cart_code_RSG.R - Adjust CART analysis here
7) tukey_box_by_group.R - Creates box and whisker plots with Tukey's Honestly significant differences 
                          plotted as a,b,c,etc. groups
