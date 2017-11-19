ConvertToWaterYearMatrix <- function(QData, month, day) {
  indexOfWaterYears <- numeric()
  numRows <- length(QData[,1])
  
  #Create new column in matrix each time start month and day are repeated in the timeseries
  for (rowIndex in 1:numRows) {
    mo <- as.numeric(strsplit(QData[rowIndex,1], "-")[[1]][2]) #identify all QData records with user-defined start month
    dy <- as.numeric(strsplit(QData[rowIndex,1], "-")[[1]][3]) #identify all QData records with user-defined start day
    if (mo == month & dy == day){
      indexOfWaterYears <- c(indexOfWaterYears, rowIndex) 
    } 
  }
  return(indexOfWaterYears)
}

