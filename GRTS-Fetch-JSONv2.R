# GRTS JSON Test #




## Load Libraries ##
library(httr)
library(jsonlite)
library(data.table)
library(dplyr)
library(curl)
library(tidyjson)

BaseURL <- "https://ordspub.epa.gov/ords/grts_rest/grts_rest_apex/grts_rest_apex/GetProjectsByHUC12/171100190303"

reqData <- curl_fetch_memory (BaseURL)

str (reqData)
# TheData <- jsonlite::prettify(rawToChar(reqData$content))
TheData <- rawToChar(reqData$content)


TheData %>% spread_all -> SpreadData

str(SpreadData)


col (SpreadData)
print (SpreadData[1,1])

spread_all(SpreadData[1,1]) -> foo
col (foo[1])
print (foo[1][1])
spread_all(foo[1][1]) -> tostada
spread_all(tostada[1][1]) -> tacos
print (tacos)

spread_all (tacos[1][1]) -> foofoo

print(foofoo)









q()

data <- str (raw_data)
parse_headers(raw_data$headers)
# parse_headers(raw_data$times)
content <- parse_headers(raw_data$content)
print (fromJSON (content, flatten=TRUE))



