# Dimensionless Hydrograph Calculator for multiple timeseries

>

## About

This tool plots a dimensionless hydrograph for a dataset of multiple timeseries. The plot includes color-coded lines for the 90th, 75th, 50th, 25th, and 10th percentiles, and the maximum and minimum annual flow across an average of all timeseries in the input data. The data is organized and processed by a user-defined water year.

## Input Data Requirements

Enter your timeseries data in csv format, with the date in column 1 and flows in subsequent columns:

| Date | Flow1 | Flow2 | Flow3 | etc. |
|-------|-------|-------|------|------|
| 10/01/2016 | 37 | 45 | 32 | etc. |
| 10/02/2016 | 43 | 42 | 35 | etc. |
| etc. | etc. | etc. | etc. | etc. |

Data must have headers! Enter dates in month/day/year format as shown in the example.     
Timeseries data do not necessarily need to start and end on the water year dates, and the columns of timeseries do not need to start and end on the same day as each other. However, each timeseries must be continuous, with **no missing values in the middle of a column**. If your data contains NAs in the middle of a timeseries, the data must be preprocessed to remove these NAs through a method such as interpolation. The dates column must span the entire range in which any one timeseries contains data.

## Testing

Find test data in the DimHydrographAvg_TestData.csv file in the dim-hydrograph-average repository. This test file contains flow gage data from publicly available US Geological Survey records. You will use this data to test the dimensionless hydrograph tool on your machine.

First, save the dim-hydrograph-average folder to a local folder you will use as your working directory. This folder contains the scripts, test data, and test results you will need to perform a test of the dimensionless hydrograph tool. The scripts include the DimHydrographAvg.R file plus two dependent functions. The initial lines of code in the DimHydrographAvg.R file set the working directory as your current directory. If this does not point to your local dim-hydrograph-average folder, you will need to change the workingDir variable manually. Make sure the water year variables in DimHydrographAvg.R are set as month=10 and day=01 in lines 12 and 13 to match the results of the test data.

You are now ready to run the code! The resulting AvgQMatrix variable contains the data used to plot the dimensionless hydrograph. Compare the values of your resulting AvgQMatrix table with the DimHydrographAvg_TestData.csv table to verify your code is running correctly. You may also compare the output plot with the DimHydrographAvg_Results.pdf file in the repository.  

![Preview the output test plot here.](DimHydrographAvg_Results.pdf)

## Plotting Details

Plots are saved by default in the working directory to a pdf file with the same name as your inputFile variable:

```
dev.copy(pdf, paste(substr(inputFile, 1, nchar(inputFile)-4),'pdf',sep='.'))
dev.off()
```
A new plot generated with the same filename in the same working directory will overwrite any existing plots of the same name. Therefore if you need to create multiple plots, make sure your inputFile variable is renamed each time.

The plotting section of the DimHydrographAvg.R script includes an alternative option for creating a plot without lines for max and min flow. Eliminating these lines is occasionally desireable because they tend to reduce visibility of the 10-90 percentile flows. If you choose to remove the max and min plotting lines, follow the instructions in the code comments to comment out certain lines and change the y-axis bounds.

## Help

For assistance using this code, you may contact the developer at nkpatterson@ucdavis.edu.

## Changelog

__0.1.0__

- Initial release
