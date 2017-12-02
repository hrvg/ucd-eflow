# Herve Guillon, December 2017
# Twitter configuration for transforming a computer into a bot tweeting about computations performed

# libraries
library(twitteR)

source('twitter-cfg.R') # this non-shared file contains the key, secrets and token from the Twitter API

setup_twitter_oauth(consumer_key, consumer_secret, access_token, access_secret)
rm(consumer_key, consumer_secret, access_token, access_secret)

# user defined functions

tweetstart <- function(scriptname){
	updateStatus(paste('Beep boop beep. I have started running ',scriptname,' at ',Sys.time(),'!',sep=''))
	}

tweetstop <- function(scriptname){
	updateStatus(paste(' Beep boop beep. I have finished running ',scriptname,' at ',Sys.time(),'!',sep=''))
	}