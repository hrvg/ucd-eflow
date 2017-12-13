## Scatter plot of Ac and S binned bf.w.d for LSR and RSG sites
## Colin Byrne, 2017

#plot(1:length(bf.w.d.out[,1]), bf.w.d.out[,1])
#points(1:length(bf.w.d.out[,1]), y = bf.w.d.out[,2], col=2)

dev.new()
plot(lsr.mat$slope, lsr.mat$bf.w.d, col=1, ylab="bf.w.d", log='x')
points(rsg.mat$slope, rsg.mat$bf.w.d, col=4)