ConvertToWaterYearMatrix <- function(QData, month, day) {
  indexOfWaterYears <- numeric()
  numRows <- length(QData[,1])
  
  for (rowIndex in 1:numRows) {
    mo <- as.numeric(strsplit(QData[rowIndex,1], "-")[[1]][2])
    dy <- as.numeric(strsplit(QData[rowIndex,1], "-")[[1]][3])
    if (mo == month & dy == day){
      indexOfWaterYears <- c(indexOfWaterYears, rowIndex)
    } 
  }
  
  return(indexOfWaterYears)
}

