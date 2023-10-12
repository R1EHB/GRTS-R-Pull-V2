# Test the GRTS Functions #



## Load Libraries ##
library(httr)
library(jsonlite)
library(data.table)
library(dplyr)
library(curl)
library(tidyjson)
library(tidyr)
library(magrittr)  # add to main


# Test the URL Fetch and spread #

source ("GRTS-HUC-Functions.R")

BaseURL <-
  "https://ordspub.epa.gov/ords/grts_rest/grts_rest_apex/grts_rest_apex/GetProjectsByHUC12/"


# Get the new england HUC12 list

myHUC12Vector <-
  read.csv(
    file = 'HUC12NewEnglandvector.csv' ,
    header = T,
    colClasses = c("HUC12_Code" = "character")
  )


head (myHUC12Vector)
str (myHUC12Vector)

# vec_len <- length (myHUC12Vector)

# Temporarily put vec_len as 10 for testing

vec_len = 2

for (i in 1:vec_len) {
    URL <- paste0(BaseURL, myHUC12Vector$HUC12_Code[i])
    HUCdataBlob <- URLfetch(URL)
    MetaData <- HUCmetaData (HUCdataBlob)
}

str (MetaData)


q()
