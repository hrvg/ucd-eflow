# This code generates a dimensionless hydrograph plot from a collection of averaged flow timeseries data, 
# with a user-defined water year.
# Developed by Noelle Patterson, UC Davis Water Management Lab, 2017

rm(list = ls())

# Define working directory and file where timeseries flow data is located
workingDir <- getwd()
inputFile <- "DimHydrographAvg_TestData.csv"

# Define water year by two-digit month and day
month <- 10
day <- 01

setwd(workingDir)
QMatrix <- read.csv(inputFile, header=TRUE, check.names = FALSE, na.strings = "#N/A")

# Outputs QMatrixAvg: Dimensionless daily summary stats (flow percentiles and max/min) for each timeseries ####

source("DefineDateIndices.R")
source("CreateFlowMatrixUsingDateIndex.R")
lst <- list()

# Calculate average summary stat values for each timeseries ######################
for (n in 2:length(QMatrix)) {
  QData <- QMatrix[, c(1,n)] 
  QData <- na.omit(QData)
  colnames(QData) <- c("date", "Q")
  QData$date <- as.Date(QData$date, "%m/%d/%Y") # Make sure date column is in date format
  QData$Q <- as.double(QData$Q)  # Make sure flow column is in number format
  QData <- as.matrix(QData)
  
  list <- DefineDateIndices(QData, month, day) # Input two digit month and day into function
  dateIndices <- unlist(list[1]) # Extract date indices from list
  dateVector <- unlist(list[2]) # Extract julian date vector from list

  IndivQMatrix <- CreateFlowMatrixUsingDateIndex(dateIndices, QData)
  
  # Find average annual flow for each water year in record
  Qmean <- rep(NA, ncol(IndivQMatrix))
  for(i in 1:ncol(IndivQMatrix)) {
    Qmean[i] <- mean(as.numeric(IndivQMatrix[,i]), na.rm = TRUE)
  }
  
  # Divide each daily flow value by avg annual daily flow. Save in QmatrixNorm.
  QmatrixNorm <- matrix(NA, nrow = 366, ncol = ncol(IndivQMatrix))
  QmatrixNorm <- as.data.frame(QmatrixNorm)
  for (i in 1:ncol(IndivQMatrix)) {
    QmatrixNorm[,i] <- as.numeric(IndivQMatrix[,i])/Qmean[i]
  }
  
  # Calculate percentiles and annual max/min of normalized flows for every day of the year 
  # (across all years)
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
  
  colnames(Qstats) <- c("90%", "75%", "50%", "25%", "10%", "Max", "Min")
  
  # Create a list where each item is a matrix of summary stats for a single gage
  lst[[n-1]] <- as.matrix(Qstats)
  
}

# Calculate average summary stat values across all timeseries ###########################

AvgQMatrix <- Reduce("+", lst)/length(lst)
AvgQMatrix <- cbind(dateVector, AvgQMatrix)

# Plot average hydrograph across all timeseries ##########################################

xaxis <- c(1:rowLength)

ymax <- max(AvgQMatrix[,7] + 1) # Set y-axis limit above max flow value
#ymax <- max(AvgQMatrix[,2] + 1) # Alternatively set y-axis limit above 90% flow, if not plotting max flow line 

# Create dimensionless hydrograph plot
plot(xaxis, AvgQMatrix[,2], type = "l", col = "navy", lwd = 2, xlab = "Julian Date", 
     ylab = "Daily streamflow/Average Annual Streamflow", xlim = c(0,366), ylim = c(0,ymax), xaxt = "n")
title(main = "Average Dimensionless Hydrograph")
grid(NA, NULL, lty = "solid", lwd = 1)
x <- pretty(xaxis, 12) # Generate well-spaced tick marks for x-axis
x <- c(1, x[!x %in% c(0)]) # Replace tick mark at x-axis=0 with a tick at x-axis=1 
axis(side = 1, at = x, labels = dateVector[x]) # Label x-axis tick marks with corresponding julian date
legend("topright", legend = c("0.90", "0.75", "0.50", "0.25", "0.10", "max/min"), lty = 1, 
       lwd = 2.5, col = c("navy", "royalblue2", "red", "royalblue2", "navy", "black"), inset = .02)


# Add fill color to plot
polygon(c(xaxis, rev(xaxis)), c(AvgQMatrix[,3], rev(AvgQMatrix[,2])), col="lightsteelblue1", border = NA)
polygon(c(xaxis, rev(xaxis)), c(AvgQMatrix[,4], rev(AvgQMatrix[,3])), col="lightsteelblue1", border = NA)
polygon(c(xaxis, rev(xaxis)), c(AvgQMatrix[,5], rev(AvgQMatrix[,4])), col="lightsteelblue1", border = NA)
polygon(c(xaxis, rev(xaxis)), c(AvgQMatrix[,6], rev(AvgQMatrix[,5])), col="lightsteelblue1", border = NA)

# Add percentile lines on top of the fill color
lines(xaxis, AvgQMatrix[,2], type = "l", col = "navy", lwd = 2)
lines(xaxis, AvgQMatrix[,3], type = "l", col = "royalblue2", lwd = 1.5)
lines(xaxis, AvgQMatrix[,4], type = "l", col = "red", lwd = 2)
lines(xaxis, AvgQMatrix[,5], type = "l", col = "royalblue2", lwd = 1.5)
lines(xaxis, AvgQMatrix[,6], type = "l", col = "navy", lwd = 2)
lines(xaxis, AvgQMatrix[,7], type = "l", col = "black", lwd = 1.5) # Comment out line if not plotting max flow values
lines(xaxis, AvgQMatrix[,8], type = "l", col = "black", lwd = 1.5) # Comment out line if not plotting min flow values

# Save plot in a pdf named after the input data file
dev.copy(pdf, paste(substr(inputFile, 1, nchar(inputFile)-4),'pdf',sep='.'))
dev.off()

