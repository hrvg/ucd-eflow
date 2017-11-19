CreateFlowMatrixUsingDateIndex <- function(dateIndices, QData) {
  #Format size of matrix: size depends on if the data begins on the start date of the water year.
  #If start date of data is offset from start date of water year, need an extra column in matrix.
  if (dateIndices[1] == 1) {
    numberOfWaterYears <- length(dateIndices)
  }
  else if (dateIndices[1] != 1) {
    numberOfWaterYears <- length(dateIndices)+1
  }
  #Populate matrix, sorting by water year. Method of sorting changes depending on if the data begins
  #on the start date of the water year. 
  
  Qmatrix <- matrix(NA, nrow = 366, ncol = numberOfWaterYears)
  for (i in 1:numberOfWaterYears) {
    #Case for first water year, when data begins on the start date of the water year.
    if (i == 1 & dateIndices[1] == 1) {
      endDate <- dateIndices[i+1]-1
      numberOfRecords <- length(QData[,2][dateIndices[i]:endDate])
      Qmatrix[1:numberOfRecords,i] <- QData[,2][dateIndices[i]:endDate]
    }
    #Case for first water year, when data doesn't begin on the start date of the water year.
    else if (i == 1) {
      julianDate <- as.numeric(strftime(QData[,1], format = "%j")) 
      #Use julian date to help calculate offset between start date of data and start date of water year
      offset <- julianDate[dateIndices[1]] 
      numberOfRecords <- length(QData[,2][1:dateIndices[1]-1])
      #Difference between start date of data and start date of water year
      startDate <- julianDate[1] - offset 
      endDate <- startDate + numberOfRecords - 1
      Qmatrix[startDate:endDate,i] <- QData[,2][1:numberOfRecords]
      dateIndices <- c(1,dateIndices)
    } 
    #Case for final column of matrix (last water year of data)
    else if (i == numberOfWaterYears) {
      endDate <- length(QData[,2])
      numberOfRecords <- length(QData[,2][dateIndices[i]:endDate])
      Qmatrix[1:numberOfRecords,i] <- QData[,2][dateIndices[i]:endDate]
    }
    #Case for populating middle of the matrix (all water years except first and last)
    else {
      endDate <- dateIndices[i+1]-1
      numberOfRecords <- length(QData[,2][dateIndices[i]:endDate])
      Qmatrix[1:numberOfRecords,i] <- QData[,2][dateIndices[i]:endDate]
    }
   
  }
  return(Qmatrix)
}
