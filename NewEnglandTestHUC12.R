# GRTS JSON New England HUC Test #


## Load Libraries ##
library(httr)
library(jsonlite)
library(data.table)
library(dplyr)
library(curl)
library(tidyjson)
library(tidyr)

BaseURL <- "https://ordspub.epa.gov/ords/grts_rest/grts_rest_apex/grts_rest_apex/GetProjectsByHUC12/"


# Get the new england HUC12 list



myHUC12Vector <- read.csv(file='HUC12NewEnglandvector.csv' , header = T, colClasses = c("HUC12_Code"="character"))


head (myHUC12Vector)
str (myHUC12Vector)

# vec_len <- length (myHUC12Vector)

# Temporarily put vec_len as 10 for testing

vec_len = 10



## Loop through all the HUC12 in the vector for pulling ##
### For the first element, simply copy the jSON data to the coarseGRTS List ###
### For the second to n elements, append the coarseGRTS List ###

### Note that the coarseGRTS list has been initialized with what is known to be the full ###

## Loop over the HUC12 values to retreive from GRTS

# -- This puts the information into a list, where the main list index is the position of the HUC12
# --- element above (1...n, where n=number of HUCs in the vector myHUC12Vector above)
# -- A dataframe is embedded in each list, and that dataframe has each project and info as an observation

# Create a progress bar for the loop

pb = txtProgressBar(min = 0, max = vec_len, initial = 0) 

# Setup first element
 URL <- paste0(BaseURL, myHUC12Vector$HUC12_Code[1])
  
  DataRequestRaw <- curl_fetch_memory(URL)
  DataRequest <- rawToChar(DataRequestRaw$content)
#  str (DataRequest)

  # Now start several steps to disentangle the nested data from the https fetch operation #
  DataRequest %>% spread_all -> GRTSInfo4HUC

 # Now loop
for (i in 2:vec_len) {
  URL <- paste0(BaseURL, myHUC12Vector$HUC12_Code[i])
  
  DataRequestRaw <- curl_fetch_memory(URL)
  DataRequest <- rawToChar(DataRequestRaw$content)
#  str (DataRequest)

  # Now start several steps to disentangle the nested data from the https fetch operation #
  DataRequest %>% spread_all -> tempGRTSInfo4HUC
 GRTSInfo4HUC <- bind_rows (GRTSInfo4HUC, tempGRTSInfo4HUC)
}

  str(GRTSInfo4HUC)
  

## Grab the metadata ##
document.id <- GRTSInfo4HUC$document.id
hasMore <- GRTSInfo4HUC$hasMore # Are more top-level records for this HUC?
limit <- GRTSInfo4HUC$limit # Limit of projects listed per HUC?
offset <- GRTSInfo4HUC$offset # Not sure what offset is
count <- GRTSInfo4HUC$count  # How many projects are in this HUC


HUCMetaData <- data.frame (document.id,hasMore,limit,offset,count)


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

