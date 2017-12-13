## Function performs an analysis of variance
## Written by Colin Byrne, UC Davis Postdoc, 2017

column_aov <- function(gm.att, hyd.clss) {
	
	aggregate(gm.att, by=list(hyd.clss), FUN=mean)
	aggregate(gm.att, by=list(hyd.clss), FUN=sd)
	hyd.clss <- as.factor(hyd.clss)
	
	aov.fit <- aov(gm.att ~ hyd.clss)

	aov.p <- summary(aov.fit)[[1]][["Pr(>F)"]][[1]]

	return(aov.p)	
}