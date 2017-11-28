#This code generates a dimensionless hydrograph plot from flow timeseries data, with user-defined water year
#Developed by Noelle Patterson, UC Davis Water Management Lab, 2017

rm(list = ls())

#Define working directory and file where timeseries flow data is located
workingDir <- getwd()
inputFile <- "DimHydrograph_TestData.csv"

#Define water year by two-digit month and day
month <- 10
day <- 01

setwd(workingDir)
inputData <- read.csv(inputFile, header=TRUE, check.names = FALSE, na.strings = "#N/A")

QData <- inputData[ , c(1,2)] 

QData <- na.omit(QData)

colnames(QData) <- c("date", "Q")
QData$date <- as.Date(QData$date, "%m/%d/%Y") #Make sure date column is in date format
QData$Q <- as.double(QData$Q)  #Make sure flow column is in number format
QData <- as.matrix(QData)

source("DefineDateIndices.R")
list <- DefineDateIndices(QData, month, day) # input two digit month and day into function
dateIndices <- unlist(list[1]) #Extract date indices from list
dateVector <- unlist(list[2]) # Extract julian date vector from list

source("CreateFlowMatrixUsingDateIndex.R")
Qmatrix <- CreateFlowMatrixUsingDateIndex(dateIndices, QData)

#Find average annual flow for each water year in record
Qmean <- rep(NA, ncol(Qmatrix))
for(i in 1:ncol(Qmatrix)) {
  Qmean[i] <- mean(as.numeric(Qmatrix[,i]), na.rm = TRUE)
}

#Divide each daily flow value by avg annual daily flow. Save in a new data frame.
QmatrixNorm <- matrix(NA, nrow = 366, ncol = ncol(Qmatrix))
QmatrixNorm <- as.data.frame(QmatrixNorm)
for (i in 1:ncol(Qmatrix)) {
  QmatrixNorm[,i] <- as.numeric(Qmatrix[,i])/Qmean[i]
}

#Calculate percentiles and annual max/min for every day of the year (across all years)
rowLength <- length(QmatrixNorm[,1])
Qstats <- data.frame(rep(NA, rowLength))

for(i in 1:rowLength)  {
  Qstats[i,1] <- quantile(QmatrixNorm[i,], probs = .9, na.rm = TRUE)
  Qstats[i,2] <- quantile(QmatrixNorm[i,], probs = .75, na.rm = TRUE)
  Qstats[i,3] <- quantile(QmatrixNorm[i,], probs = .5, na.rm = TRUE)
  Qstats[i,4] <- quantile(QmatrixNorm[i,], probs = .25, na.rm = TRUE)
  Qstats[i,5] <- quantile(QmatrixNorm[i,], probs = .1, na.rm = TRUE)
  Qstats[i,6] <-max(QmatrixNorm[i,], na.rm = TRUE)
  Qstats[i,7] <-min(QmatrixNorm[i,], na.rm = TRUE)
}

#Add a column with Julian day 
Qstats <- cbind(dateVector, Qstats)
colnames(Qstats) <- c("julianDay", "90%", "75%", "50%", "25%", "10%", "Max", "Min")

# Plotting Dimensionless Hydrograph #################################################

xaxis <- c(1:rowLength)

ymax <- max(Qstats[,7] + 1) #Set y-axis limit above max flow value
#ymax <- max(Qstats[,1] + 1) #Alternatively set y-axis limit above 90% flow, if not plotting max flow line 

#Create dimensionless hydrograph plot
plot(xaxis, Qstats[,2], type = "l", col = "navy", lwd = 2, xlab = "Julian Date", 
     ylab = "Daily streamflow/Average Annual Streamflow", xlim = c(0,366), ylim = c(0,ymax), xaxt = "n")
title(main = "Dimensionless Hydrograph")
grid(NA, NULL, lty = "solid", lwd = 1)
x <- pretty(xaxis, 12) #generate well-spaced tick marks for x-axis
x <- c(1, x[!x %in% c(0)]) #Replace tick mark at x-axis=0 with a tick at x-axis=1 
axis(side = 1, at = x, labels = dateVector[x]) #Label x-axis tick marks with corresponding julian date
legend("topright", legend = c("0.90", "0.75", "0.50", "0.25", "0.10", "max/min"), lty = 1, 
       lwd = 2.5, col = c("navy", "royalblue2", "red", "royalblue2", "navy", "black"), inset = .02)


#Add fill color to plot
polygon(c(xaxis, rev(xaxis)), c(Qstats[,3], rev(Qstats[,2])), col="lightsteelblue1", border = NA)
polygon(c(xaxis, rev(xaxis)), c(Qstats[,4], rev(Qstats[,3])), col="lightsteelblue1", border = NA)
polygon(c(xaxis, rev(xaxis)), c(Qstats[,5], rev(Qstats[,4])), col="lightsteelblue1", border = NA)
polygon(c(xaxis, rev(xaxis)), c(Qstats[,6], rev(Qstats[,5])), col="lightsteelblue1", border = NA)

#Add percentile lines on top of the fill color
lines(xaxis, Qstats[,2], type = "l", col = "navy", lwd = 2)
lines(xaxis, Qstats[,3], type = "l", col = "royalblue2", lwd = 1.5)
lines(xaxis, Qstats[,4], type = "l", col = "red", lwd = 2)
lines(xaxis, Qstats[,5], type = "l", col = "royalblue2", lwd = 1.5)
lines(xaxis, Qstats[,6], type = "l", col = "navy", lwd = 2)
lines(xaxis, Qstats[,7], type = "l", col = "black", lwd = 1.5) #Comment out line if not plotting max flow values
lines(xaxis, Qstats[,8], type = "l", col = "black", lwd = 1.5) #Comment out line if not plotting min flow values



dev.copy(pdf, paste(substr(inputFile, 1, nchar(inputFile)-4),'pdf',sep='.'))
dev.off()

