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

Data must have headers! Enter dates in month-day-year style, using the "date" cell format in Excel.     
Timeseries data does not necessarily need to start and end on the water year dates, but data must be continuous with no missing values in the middle of a set. For example, data arranged to with a January 1st - December 31st water year could begin on February 2nd, 1988, and run continuously until March 1st of 2010, and January 1st will mark the beginning of each new water year.

## Testing

Simply run `yarn test` and all your tests in the `test/` directory will be run.

## Sequelize CLI

```
$ npm install -g sequelize-cli

$ sequelize model:create --name TodoItem --attributes content:string,complete:boolean #Generate a model
```

## Help

For more information on all the things you can do with Sequelize CLI visit [sequelize cli ](https://github.com/sequelize/cli).

## Changelog

__0.1.0__

- Initial release

## License

Copyright (c) 2016

Licensed under the [MIT license](LICENSE).
