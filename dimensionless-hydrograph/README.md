# Dimensionless Hydrograph Calculator for single timeseries

>

## About

This tool plots a dimensionless hydrograph of input flow timeseries data. The plot includes color-coded lines for the 90th, 75th, 50th, 25th, and 10th percentiles , and the maximum and minimum annual flow of the input data. The data is organized and processed by water year, which is defined by the user and can be any start date within the calendar year. 

## Input Data Requirements
Enter your timeseries data in csv format, with the date in column 1 and flow in column 2:

| Date | Flow | 
|----------|------------|
| 10/01/2016 | 37 | 
| 10/02/2016 | 43 | 
| etc... | etc... | 

Data must have headers! Enter dates in month/day/year style as shown in the example.     
Timeseries data do not necessarily need to start and end on the water year dates, but data must be continuous with no missing values in the middle of a set. Therefore inputted data may begin on any date and end on any date, as long as there are no missing values within that range.

## Testing

Find test data in the DimHydrograph_TestData.csv file in the dimensionless-hydrograph repository. Save the test data in a local folder which you will use as your working directory.  

Next, save DimHydrographSingle.R and its dependent functions (CreateFlowMatrixUsingDateIndex.R and DefineDateIndices.R) to your working directory. Open DimHydrographSingle.R and modify the workingDir and inputFile variables (lines 7 and 8) to match the location of the test data on your machine. Make sure the water year variables are set as month=10 and day=01 in lines 11 and 12 to match the results of the test data. 

You are now ready to run the code! The resulting Qstats matrix contains the data used to plot the dimensionless hydrograph. Compare the values of your resulting Qstats table with the DimHydrographTestResults.csv table in the dimensionless-hydrograph repository to verify your code is running correctly. You may also compare the output plot with the dimensionlessHydrograph.pdf file in the repository.  

![Preview the output test plot here.](dimensionlessHydrograph.pdf)

## Plotting Details

Plots are saved by default in the working directory to a pdf file named dimensionlessHydrograph.pdf, in lines 106-107:

```
dev.copy(pdf, "dimensionlessHydrograph.pdf")
dev.off()
```
A new plot generated with the same filename in the same working directory will overwrite any existing plots. Therefore if you need to create multiple plots, you must modify the code to rename the plot each time. 

## Help

For assistance using this code, you may contact the developer at nkpatterson@ucdavis.edu. 

## Changelog

__0.1.0__

- Initial release


