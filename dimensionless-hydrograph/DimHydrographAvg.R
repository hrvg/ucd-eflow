rm(list = ls())

#Installing the needed R packages
install.packages("xlsx")
install.packages("rJava")

#Loading packages into library
library(xlsx)

setwd("C:/Users/noellepa/Documents/GagesData/R_data_functions")

#Bring in flow time series to convert into dimensionless hydrograph
QMatrix <- read.csv("NorthTahoeTest.csv", header=TRUE, check.names = FALSE, na.strings = "#N/A")
#QMatrix <- read.csv("TS_Class3.csv", header=TRUE, check.names = FALSE, na.strings = "#N/A")

hydroAvg <- data.frame(rep(NA, 366)) # will use later to average summary stats across FIDs

######## Outputs hydroAvg: Dimensionless daily summary stats (flow percentiles and max/min) for each FID
#Loop to read through each FID.
for (i in 2:length(QMatrix)) {
  QData <- QMatrix[ , c(1,2)]
  #Prepare data for analysis
  QData <- na.omit(QData)
  QData[,2] <- as.double(QData[,2])  #Make sure flow column is in number format
  colnames(QData)[1] <- c("date")
  FID <- colnames(QData)[2]
  QData$date <- as.Date(QData$date, "%m/%d/%Y")
  #Extract variables to use later
  dt <- QData$date
  Q <- QData[,2]
  
  
  # Define year, month, and julian day in separate variables
  yy=as.numeric(format.Date(dt,"%Y")) #date formatted as %y-%m-%d
  mo=as.numeric(format.Date(dt,"%m"))
  dj <- as.numeric(strftime(QData$date, format = "%j"))
  
  yrseq=unique(yy) #list all years in dataset
  l=length(yrseq) # count number of years in dataset

  #Create new columns with year, month, and julian date
  QData <- cbind(QData, yy, mo, dj)

  #build Jdate - Year matrix of flow data
  #First create empty dataframe
  drhMatrix <- data.frame(rep(NA, 366))

    for(i in 1:l){
      for(j in 1:366){
        yr=yrseq[i]
        a <- QData[yy==yr,] #dataframe subset for specific year
        ind_row <- match(j, a$dj) #find row that specific Julian date occurs
        drhMatrix[j,i] <- a[ind_row, 2] #extract flow value for specific Year-Jdate and insert into new matrix
      }
    }

  #Find average annual flow for each year in record
  Qmean=rep(NA,l)
    for(i in 1:l){
      yr=yrseq[i]
      Qmean[i]=mean(Q[yy==yr])
    }

  #Divide each daily flow value by avg annual daily flow. Save in new data frame.
  drhMatrix2 <- matrix(NA, nrow = 366, ncol = l)
  drhMatrix2 <- as.data.frame(drhMatrix2)
  
    for(i in 1:l){
      for(j in 1:366){
        yr <- yrseq[i]
        a <- QData[yy==yr,]
        a[,2] <- a[,2]/(Qmean[i])
        ind_row <- match(j, a$dj)
        drhMatrix2[j,i] <- a[ind_row, 2]
      }
    }

  
  l <- length(drhMatrix2[,1])
  
  #Calculate percentiles and annual max/min for every day of the year (across all years)
  percs <- data.frame(rep(NA, l))
  
  for(i in 1:l)  {
    percs[i,1] <- quantile(drhMatrix2[i,], probs = .9, na.rm = TRUE)
    percs[i,2] <- quantile(drhMatrix2[i,], probs = .75, na.rm = TRUE)
    percs[i,3] <- quantile(drhMatrix2[i,], probs = .5, na.rm = TRUE)
    percs[i,4] <- quantile(drhMatrix2[i,], probs = .25, na.rm = TRUE)
    percs[i,5] <- quantile(drhMatrix2[i,], probs = .1, na.rm = TRUE)
    percs[i,6] <-max(drhMatrix2[i,], na.rm = TRUE)
    percs[i,7] <-min(drhMatrix2[i,], na.rm = TRUE)
  }
  
  #Name columns with FID in 1st column for ease of identification within the dataframe
  colnames(percs) <- c(FID, "75%", "50%", "25%", "10%", "Max", "Min")
  
  ## Outputs hydroAvg
  hydroAvg <- cbind(hydroAvg, percs)
}
################################################

#Re-write first column of hydroAvg to be Julian Date
hydroAvg[,1] <- 1:366
colnames(hydroAvg)[1] <- "JD"

### Calculate average summary stat value across FIDs:########################

#Set indexing value for loop. Calculates the number of FIDs
l <- (length(hydroAvg[1,])-1)/7 
#length of list (equals 366 for average timeseries)
lrows <- length(hydroAvg[,1]) 

## Calculate average 90% across FIDs
perc90 <- as.data.frame(rep(NA, lrows)) #Create empty list for average 90th percentiles

list <- matrix(rep(NA, l)) #Create empty list to fill with average across each row
for(j in 1:lrows){
  for(i in 1:l){
    list[i] <- hydroAvg[j,][2 + 7*(i-1)] #Pull each 90% value from each row. Every row has one 90% for each FID.
  }
  perc90[j,1] <- mean(as.numeric(list)) #Calc **average** of all 90% values in each row.
}

## Calculate average 75% across FIDs
perc75 <- as.data.frame(rep(NA, lrows)) 

list <- matrix(rep(NA, l)) 
for(j in 1:lrows){
  for(i in 1:l){
    list[i] <- hydroAvg[j,][3 + 7*(i-1)] #Pull each 75% value from each row. Every row has one 75% for each FID.
  }
  perc75[j,1] <- mean(as.numeric(list)) #Calc average of all 90% values in each row.
}

## Calculate average 50% across FIDs
perc50 <- as.data.frame(rep(NA, lrows)) 
list <- matrix(rep(NA, l)) 

for(j in 1:lrows){
  for(i in 1:l){
    list[i] <- hydroAvg[j,][4 + 7*(i-1)] #Pull each 50% value from each row. Every row has one 50% for each FID.
  }
  perc50[j,1] <- mean(as.numeric(list)) #Calc average of all 50% values in each row.
}

## Calculate average 25% across FIDs
list <- matrix(rep(NA, l)) 
perc25 <- as.data.frame(rep(NA, lrows)) 

for(j in 1:lrows){
  for(i in 1:l){
    list[i] <- hydroAvg[j,][5 + 7*(i-1)] #Pull each 25% value from each row. Every row has one 25% for each FID.
  }
  perc25[j,1] <- mean(as.numeric(list)) #Calc average of all 25% values in each row.
}

## Calculate average 10% across FIDs
list <- matrix(rep(NA, l)) 
perc10 <- as.data.frame(rep(NA, lrows)) 

for(j in 1:lrows){
  for(i in 1:l){
    list[i] <- hydroAvg[j,][6 + 7*(i-1)] #Pull each 10% value from each row. Every row has one 10% for each FID.
  }
  perc10[j,1] <- mean(as.numeric(list)) #Calc average of all 10% values in each row.
}

## Calculate Mean of Max across FIDs
list <- matrix(rep(NA, l)) 
max <- as.data.frame(rep(NA, lrows)) 

for(j in 1:lrows){
  for(i in 1:l){
    list[i] <- hydroAvg[j,][7 + 7*(i-1)] #Pull each max value from each row. Every row has one max for each FID.
  }
  max[j,1] <- mean(as.numeric(list)) #Calc **average** of all max values in each row.
}

## Calculate Mean of Min across FIDs
list <- matrix(rep(NA, l)) 
min <- as.data.frame(rep(NA, lrows)) 

for(j in 1:lrows){
  for(i in 1:l){
    list[i] <- hydroAvg[j,][8 + 7*(i-1)] #Pull each min value from each row. Every row has one min for each FID.
  }
  min[j,1] <- mean(as.numeric(list)) #Calc average of all min values in each row.
}
###############################################

#Put the final table together with all average percentiles, max's, and min's
#Include a column with Julian day 
finalAvg <- cbind(1:366, perc90, perc75, perc50, perc25, perc10, max, min)
colnames(finalAvg) <- c("JD", "90%", "75%", "50%", "25", "10", "Max", "Min")

#Cut and paste rows in order of water year; Oct 1-Sept 30, (begin with julian date 274)
finalAvg <- rbind(finalAvg, finalAvg[1:273,])
finalAvg <- finalAvg[-(1:273),]

#Create monthly tick marks for plotting
x <- seq(from = 15, to = 360, by = 30.5)
colnames <- c("Oct", "Nov", "Dec", "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep")

xaxis <- sort(unique(dj)) #plot by daily increments

##Optionally set ylim to c(0,ymax) in plot function to capture entire range
ymax <- max(finalAvg[,7]) + 1 #Set max y-value of graph at highest value of avg. annual max

#Create dimensionless hydrograph plot of all FIDs
plot(xaxis, finalAvg[,2], type = "l", col = "navy", lwd = 2, xlab = "Days", 
     ylab = "Flow Percentile", xlim = c(0,366), ylim = c(0,7),  xaxt = "n")

axis(side = 1, at = x, labels = colnames)

#Add fill color to plot
polygon(c(xaxis, rev(xaxis)), c(finalAvg[,3], rev(finalAvg[,2])), col="lightsteelblue1", border = NA)
polygon(c(xaxis, rev(xaxis)), c(finalAvg[,4], rev(finalAvg[,3])), col="lightsteelblue1", border = NA)
polygon(c(xaxis, rev(xaxis)), c(finalAvg[,5], rev(finalAvg[,4])), col="lightsteelblue1", border = NA)
polygon(c(xaxis, rev(xaxis)), c(finalAvg[,6], rev(finalAvg[,5])), col="lightsteelblue1", border = NA)

#Add percentile lines on top of the fill color
lines(xaxis, finalAvg[,2], type = "l", col = "navy", lwd = 2)
lines(xaxis, finalAvg[,3], type = "l", col = "royalblue2", lwd = 1.5)
lines(xaxis, finalAvg[,4], type = "l", col = "red", lwd = 2)
lines(xaxis, finalAvg[,5], type = "l", col = "royalblue2", lwd = 1.5)
lines(xaxis, finalAvg[,6], type = "l", col = "navy", lwd = 2)
lines(xaxis, finalAvg[,7], type = "l", col = "black", lwd = 1.5)
lines(xaxis, finalAvg[,8], type = "l", col = "black", lwd = 1.5)

## Find some way to export graph to folder???

