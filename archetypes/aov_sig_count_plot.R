## Creates bar plot of instances of significance for each output
## Colin Byrne, 2017

# Assumes output of stats.out from source("hydro_class_compare.R")

bf.d.i <- nrow(stats.out[stats.out$bf.d.aov<0.001,])
bf.w.i <- nrow(stats.out[stats.out$bf.w.aov<0.001,])
bf.w.d.i <- nrow(stats.out[stats.out$bf.w.d.aov<0.001,])
bf.d.D50.i <- nrow(stats.out[stats.out$bf.d.D50.aov<0.001,])
CV_bf.d.i <- nrow(stats.out[stats.out$CV_bf.d.aov<0.001,])
CV_bf.w.i <- nrow(stats.out[stats.out$CV_bf.w.aov<0.001,])
sinuosity.i <- nrow(stats.out[stats.out$sinuosity.aov<0.001,])
e.ratio.i <- nrow(stats.out[stats.out$e.ratio.aov<0.001,])
D50.i <- nrow(stats.out[stats.out$D50.aov<0.001,])
D84.i <- nrow(stats.out[stats.out$D84.aov<0.001,])
Dmax.i <- nrow(stats.out[stats.out$Dmax.aov<0.001,])

bar.h <- c(bf.d.i, bf.w.i, bf.w.d.i, bf.d.D50.i, CV_bf.d.i, CV_bf.w.i, sinuosity.i,
			e.ratio.i, D50.i, D84.i, D84.i, Dmax.i) / nrow(stats.out)

dev.new()
barplot(bar.h, names.arg=colnames(stats.out[,7:ncol(stats.out)]))