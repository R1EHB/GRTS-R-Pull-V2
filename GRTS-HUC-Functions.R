#
################  Functions for Shrimp-n-GRTS R Code ###############

####  Vector of HUCs to Analyze #####

# To be added. Maybe #

#####################################


########  These functions get data from the API and unmangle it ####

## Function takes in the URL to grab, returns the resulting metadata and content

# URLfetch

URLfetch <- function (URL="https://grts.epa.gov") {
    DataRequestRaw <- curl_fetch_memory(URL)
    return (DataRequestRaw)
}


####

### URLmetaData
## Function takes in the URLdata (mixed metadata and payload) retrieved from the API and
### Returns the metadata from http retrieval (curl)

URLmetaData <- function (DataRequestRaw) {

    urlused <- DataRequestRaw$url
    status_code <- DataRequestRaw$status_code
    type <- DataRequestRaw$type
    headers <- DataRequestRaw$headers
    modified <- DataRequestRaw$modified
    times <- DataRequestRaw$times

    # content is in raw format and has nested data
    # content will be extracted by other functions

    # metaData_URL <- data.frame (urlused, retrieval_status_code,retrieval_type,retrieval_headers, retrieval_modified,
#	       		  retrieval_times)

    # return(metaData_URL)
}
	






## Function takes in the HUCdata (mixed metadata and payload) retrieved from the API and
### returns the metadata portion as a dataframe

HUCmetaData <- function (HUCdataBlob) {
    
    ## Grab the metadata ##
    document.id <- HUCdataBlob$document.id
    hasMore <- HUCdataBlob$hasMore # Are more top-level records for this HUC?
    limit <- HUCdataBlob$limit # Limit of projects listed per HUC?
    offset <- HUCdataBlob$offset # Not sure what offset is
    count <- HUCdataBlob$count  # How many projects are in this HUC

    str(document.id)
    # MetaData <- data.frame (document.id,hasMore,limit,offset,count) 
    # str(MetaData)
    # return (MetaData)
}

####


## Function takes in the HUCdata (mixed metadata and payload) retrieved from the API and
### returns the payload portion.

HUCpayloadData <- function (HUCdataBlob) {
    ContentBlob <- rawToChar(HUCdataBlob$content)
    ContentBlob %>% spread_all -> HUCsDetails

#HUCsDetails <- ContentBlob$..JSON

    # This is a nested list of all the projects in the HUC.
    ## Need to loop over each
    
    ProjsInHUC.List <- HUCsDetails[[1]]  # One or more projects per HUC (in this URL fetch)
    
    # Gather up the Project-level metadata 

    hasMore <- ProjsInHUC.List$hasMore
    limit   <- ProjsInHUC.List$limit
    offset  <- ProjsInHUC.List$offset
    count   <- ProjsInHUC.List$count

    ProjMetaData <- data.frame (hasMore,limit,offset,count)
    ProjLinks <- (ProjsInHUC.List$links)

    # Loop over the elements of ProjsInHUC (i), from one to j
    # j is number of projects from ProjInHUC

    i=1
    j <- ProjInHUC$count
    
    # Create Data Frame with first row of data


    ProjDetailList <-ProjsInHUC.List[[1]][[i]]
    temp_df <- do.call(cbind, ProjDetailList)
    temp_frame <- as.data.frame(temp_df)
    ProjDetailFrame  <- bind_cols (temp_frame, ProjMetaData, ProjLinks)

    for (i in 2:j) {
    	print (i)
  	ProjDetailList <-ProjsInHUC.List[[1]][[i]]
  	temp_df <- do.call(cbind, ProjDetailList)
  	temp_frame <- as.data.frame(temp_df)
  	temp_frame  <- bind_cols (temp_frame, ProjMetaData, ProjLinks)
 	ProjDetailFrame <- bind_rows(ProjDetailFrame,temp_frame)
    }


    # Keep only the variables we want

    # drop href variables
    VarNames <- colnames(ProjDetailFrame)
    href_drop <- grepl (pattern='href...',VarNames)
    ProjDetailFrame <- ProjDetailFrame[!href_drop]


    # drop rel variables

    VarNames <- colnames(ProjDetailFrame)
    rel_drop  <- grepl (pattern='rel...' ,VarNames)
    ProjDetailFrame <- ProjDetailFrame[!rel_drop]

    return (ProjDetailFrame)
}



