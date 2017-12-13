## Classification and Regression Tree (CART) Analysis for Sacramento sites
## Adapted from Belize Lane by Colin Byrne, 2017

## CART
print("********CART**********")
sig_att_numbers <- c(2,3,4,7,8,9,10,11,12,13,14,15,16,17,18,19,20)
# play with using different combinations of variables in CART
# + bf.w + bf.d + bf.d.D50 + CV_bf.w + e.ratio
cart_fit <- rpart(groups ~ slope + CV_bf.w + bf.d.D50 + e.ratio + sinuosity,
				data=data_df, method="class",minsplit=3) 
#summary(cart_fit)
plotcp(cart_fit)

cp_value <- 0.059 #readline("CP value: ")

prune_cart<-prune(cart_fit,cp_value)

# Evaluate misclassification rate
pred_cart <- predict(prune_cart, data_df, type=c("class"))
misclass <- cbind(groups, pred_cart)
perc_class <- nrow(misclass[misclass[,1]==misclass[,2],]) / length(misclass[,1]) * 100
cat("Percent correctly classified =", perc_class, "\n")
#misclass

## Plot CART classification tree
dev.new()
par(mfcol=c(1,1))
plot(prune_cart, margin=.03, uniform=TRUE, branch=.1,
		main=paste("% correct =",signif(perc_class,digits=3),sep=' '))
text(prune_cart, use.n=TRUE)

data_df$ward.grp <- groups
data_df$cart.grp <- pred_cart