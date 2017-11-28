DefineDateIndices <- function(QData, month, day) {
  indices <- numeric()
  numRows <- length(QData[,1])
  
  #identify index value for each time start month and day are repeated in timeseries
  for (rowIndex in 1:numRows) {
    mo <- as.numeric(strsplit(QData[rowIndex,1], "-")[[1]][2])
    dy <- as.numeric(strsplit(QData[rowIndex,1], "-")[[1]][3])
    if (mo == month & dy == day) {
      indices <- c(indices, rowIndex) 
    } 
  }
  
  # Create a vector of julian dates starting from beginning of water year
  julianDate <- as.numeric(strftime(QData[,1][indices[1]], format = "%j"))
  dateVector <- seq(from = julianDate, to = julianDate + 365)
  for (i in 1:length(dateVector)) {
    if (dateVector[i] > 366) {
      dateVector[i] <- dateVector[i] - 366
    }
  }
  
  valuesList <- list(indices, dateVector)
  return(valuesList)
}

