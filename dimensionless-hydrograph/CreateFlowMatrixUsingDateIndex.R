CreateFlowMatrixUsingDateIndex <- function(dateIndices, QData) {
  if (dateIndices[1] == 1) {
    numberOfYears <- length(dateIndices)
  }
  else if (dateIndices[1] != 1) {
    numberOfYears <- length(dateIndices)+1
  }
  Qmatrix <- matrix(NA, nrow = 366, ncol = numberOfYears)
  for (i in 1:numberOfYears) {
    if (i == 1 & dateIndices[1] == 1) {
      endDate <- dateIndices[i+1]-1
      numberOfRecords <- length(QData[,2][dateIndices[i]:endDate])
      Qmatrix[1:numberOfRecords,i] <- QData[,2][dateIndices[i]:endDate]
    }
    else if (i == 1) {
      julianDate <- as.numeric(strftime(QData[,1], format = "%j")) #vector of julian days
      offset <- julianDate[dateIndices[1]]
      numberOfRecords <- length(QData[,2][1:dateIndices[1]-1])
      startDate <- julianDate[1] - offset
      endDate <- startDate + numberOfRecords -1
      Qmatrix[startDate:endDate,i] <- QData[,2][1:numberOfRecords]
      dateIndices <- c(1,dateIndices)
    } 
    else if (i == numberOfYears) {
      endDate <- length(QData[,2])
      numberOfRecords <- length(QData[,2][dateIndices[i]:endDate])
      Qmatrix[1:numberOfRecords,i] <- QData[,2][dateIndices[i]:endDate]
    }
    else {
      endDate <- dateIndices[i+1]-1
      numberOfRecords <- length(QData[,2][dateIndices[i]:endDate])
      Qmatrix[1:numberOfRecords,i] <- QData[,2][dateIndices[i]:endDate]
    }
   
  }
  return(Qmatrix)
}
