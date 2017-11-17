rm(list = ls())

#Installing the needed R packages
install.packages("xlsx")
install.packages("rJava")

#Loading packages into library
library(xlsx)

#setwd("C:/Users/noellepa/Documents/LakeTahoe.reference/DimensionlessHydrographs")
setwd("E:/Noelle/R")

#Bring in flow time series to convert into dimensionless hydrograph
allData <- read.csv("TimeSeriesTahoe.csv", header=TRUE, check.names = FALSE, na.strings = "#N/A")

QData <- allData[ , c(1,2)] #Bring in each gage individually by changing the column number in allData
#Prepare data for analysis
QData <- na.omit(QData)

colnames(QData) <- c("date", "Q")
QData$date <- as.Date(QData$date, "%m/%d/%Y") #Put date column in date format
QData$Q <- as.double(QData$Q)  #Make sure flow column is in number format
QData <- as.matrix(QData)

#Extract variables to use later
dt <- QData[,1]

source("DateIndices.R")
list <- DateIndices(QData, 10, 01) # input two digit month and day into function
dateIndices <- unlist(list[1])
dateVector <- unlist(list[2])

source("CreateFlowMatrixUsingDateIndex.R")
Qmatrix <- CreateFlowMatrixUsingDateIndex(dateIndices, QData)

#Qmatrix <- cbind(dateVector, Qmatrix)

# Define year, month, and julian day in separate variables
year <- as.numeric(format.Date(Qmatrix$date,"%Y")) #vector of years
mo <- as.numeric(format.Date(dt,"%m")) #vector of months 


#Create new columns with year, month, and julian date
QData <- cbind(QData, yy, mo, dj)
rowl <- length(QData[,1])

yearSequence=unique(year)

#Find average annual flow for each water year in record
Qmean <- rep(NA, nrow(Qmatrix))
for(i in 1:nrow(Qmatrix)) {
  Qmean[i] <- mean(as.numeric(Qmatrix[i,]), na.rm = TRUE)
}

#Divide each daily flow value by avg annual daily flow. Save in new data frame.
QmatrixNorm <- matrix(NA, nrow = 366, ncol = ncol(Qmatrix))
QmatrixNorm <- as.data.frame(QmatrixNorm)

for (i in 1:366) {
  QmatrixNorm[i,] <- as.numeric(Qmatrix[i,])/Qmean[i]
}

# for(i in 1:l){
#   for(j in 1:366){
#     yr <- yrseq[i]
#     a <- QData[yy==yr,]
#     a[,2] <- a[,2]/(Qmean[i])
#     ind_row <- match(j, a$dj)
#     QmatrixNorm[j,i] <- a[ind_row, 2]
#   }
# }


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

#Create monthly tick marks for plotting
x <- seq(from = 1, to = 360, by = 31.5)
colnames <- c("Oct", "Nov", "Dec", "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep")

#plot by daily increments
xaxis <- dateVector

#Set max y-value of graph at highest value of avg. annual max
ymax <- max(Qstats[,7]) + 1

#Create dimensionless hydrograph plot
plot(xaxis, Qstats[,2], type = "l", col = "navy", lwd = 2, xlab = "Water Year", 
     ylab = "Flow Percentile", xlim = c(0,366), ylim = c(0,10), xaxt = "n")
axis(side = 1, at = x, labels = colnames)

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
lines(xaxis, Qstats[,7], type = "l", col = "black", lwd = 1.5)
lines(xaxis, Qstats[,8], type = "l", col = "black", lwd = 1.5)

