# GRTS JSON Test #


## Load Libraries ##
library(httr)
library(jsonlite)
library(data.table)
library(dplyr)
library(curl)
library(tidyjson)
library(tidyr)
# library(stringr)


# Set the URL to fetch, either in whole or in part #

# 010600030902  Oyster River
# 171100190303 Chambers Creek, WA

BaseURL <- "https://ordspub.epa.gov/ords/grts_rest/grts_rest_apex/grts_rest_apex/GetProjectsByHUC12/010600030902"

# Fetch the data using curl/https #
DataRequestRaw <- curl_fetch_memory (BaseURL)

# print (DataRequestRaw)

# TheData <- jsonlite::prettify(rawToChar(DataRequestRaw$content))

# print (TheData)



# Converts raw byte-level (in hex) data to basic strings (with JSON in this case)


DataRequest <- rawToChar(DataRequestRaw$content)

str (DataRequest)

# Now start several steps to disentangle the nested data from the https fetch operation #


DataRequest %>% spread_all -> GRTSInfo4HUC
str(GRTSInfo4HUC)

## Grab the metadata ##
document.id <- GRTSInfo4HUC$document.id
hasMore <- GRTSInfo4HUC$hasMore # Are more top-level records for this HUC?
limit <- GRTSInfo4HUC$limit # Limit of projects listed per HUC?
offset <- GRTSInfo4HUC$offset # Not sure what offset is
count <- GRTSInfo4HUC$count  # How many projects are in this HUC


HUCMetaData <- data.frame (document.id,hasMore,limit,offset,count)


# print (HUCMetaData)


## Clear these for reuse ##

rm (document.id, hasMore, limit, offset, count)


# Isolate the main data #


GRTSInfo4HUC$..JSON  -> HUCsDetails

 str (HUCsDetails)
 print (HUCsDetails)



ProjsInHUC.OuterList <- HUCsDetails[[1]] # One or more projects per HUC (in this URL fetch)

str (ProjsInHUC.OuterList ) # This is a nested list of all the projects in the huc.  Need to loop over each



## Gather up the Project-level metadata ##

hasMore <- ProjsInHUC.OuterList$hasMore
limit <- ProjsInHUC.OuterList$limit
offset <- ProjsInHUC.OuterList$offset
count  <- ProjsInHUC.OuterList$count

ProjMetaData <- data.frame (hasMore,limit,offset,count)
ProjLinks <- (ProjsInHUC.OuterList$links)

# str (ProjLinks)

## Clear these for reuse ##

rm (hasMore, limit, offset, count)

# str(ProjsInHUC.OuterList)
# print (ProjsInHUC.OuterList)

# It seems ProjMetaData and HUCMetaData elements should and do match, but watch for this later
print (ProjMetaData)
print (HUCMetaData)

# Loop over the elements of ProjsInHUC (i), from one to j
# j is count of projects from HUCMetaData or ProjMetaData

i=1
j <- HUCMetaData$count


# Create Data Frame with first row of data

# Note to self: delete somewhere the href...X and rel...X columns

ProjDetailList <-ProjsInHUC.OuterList[[1]][[i]]
temp_df <- do.call(cbind, ProjDetailList)
temp_frame <- as.data.frame(temp_df)
ProjDetailFrame  <- bind_cols (temp_frame, ProjMetaData, ProjLinks)

str (ProjDetailFrame)
  
for (i in 2:j) {
  print (i)
  ProjDetailList <-ProjsInHUC.OuterList[[1]][[i]]
  temp_df <- do.call(cbind, ProjDetailList)
  temp_frame <- as.data.frame(temp_df)
  temp_frame  <- bind_cols (temp_frame, ProjMetaData, ProjLinks)
 ProjDetailFrame <- bind_rows(ProjDetailFrame,temp_frame)

}

str (ProjDetailFrame)

# Keep only the variables we want

# drop href variables
VarNames <- colnames(ProjDetailFrame)
href_drop <- grepl (pattern='href...',VarNames)
ProjDetailFrame <- ProjDetailFrame[!href_drop]


# drop rel variables

VarNames <- colnames(ProjDetailFrame)
rel_drop  <- grepl (pattern='rel...' ,VarNames)
ProjDetailFrame <- ProjDetailFrame[!rel_drop]

# Drop from data frame those columns with href or rel

write.csv(ProjDetailFrame, file="test.csv")

q()

