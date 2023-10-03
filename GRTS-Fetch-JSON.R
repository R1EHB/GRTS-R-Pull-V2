# GRTS JSON Test #




## Load Libraries ##
library(httr)
library(jsonlite)
library(data.table)
library(dplyr)
library(curl)

BaseURL <- "https://ordspub.epa.gov/ords/grts_rest/grts_rest_apex/grts_rest_apex/GetProjectsByHUC12/171100190303"
 raw_data <- curl_fetch_memory (BaseURL)

data <- str (raw_data)
parse_headers(raw_data$headers)
# parse_headers(raw_data$times)
content <- parse_headers(raw_data$content)
print (fromJSON (content, flatten=TRUE))


q()
