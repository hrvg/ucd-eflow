# Calculates whether slope and contributing area binning was correct
# need to run stats_analysis.R
## Written by Colin Byrne, UC Davis Postdoc, 2017

srvy_or_swmp <- vector(mode='character', length=max(swamp_rows))
srvy_or_swmp[survey_rows] <- "survey"
srvy_or_swmp[swamp_rows] <- "swamp"

