# Ward's plotting
## Written by Colin Byrne, UC Davis Postdoc, 2017

## Wards plot
dev.new()
plot(ward_fit, labels=site_ids, cex=0.7, hang=-1)
#rect.hclust(ward_fit, k=7, border="red") # box clusters at various cut levels
rect.hclust(ward_fit, k=3, border="blue")

## NMDS plot

nmds_color <- c("black","red","green3","blue","cyan",
					"magenta","yellow","gray","purple",
					"brown")[as.factor(groups[,1])]
x <- nmds$points[,1]
y <- nmds$points[,2]
dev.new()
plot(x,y, xlab="NMDS1", ylab="NMDS2", type="n", pch=16) # Plots NMDS with site names
points(x,y,pch=16,cex=.8,col=nmds_color)
#textxy(x, y, site_ids)
legend(x="topright", legend = levels(as.factor(groups[,1])), 
			col=c("black","red","green3","blue","cyan",
			"magenta","yellow","gray","purple",
			"brown"), pch=16)
plot(env_vectors,col=c("black"),cex=.8)
