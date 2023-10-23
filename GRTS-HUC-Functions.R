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

    urlused <- DataRequestRaw$url     # URL in typical URI format
    status_code <- DataRequestRaw$status_code # html status code, integer
    type <- DataRequestRaw$type # chr "application/json"
    headers <- DataRequestRaw$headers # In a raw format
    modified <- DataRequestRaw$modified # POSIXct[1:1], format: NA
    times <- DataRequestRaw$times #  Named num [1:6] .....

    # content is in raw format and has nested data
    # content will be extracted by other functions
    # Won't propagate complicated variables from the header at this time. As in:
    #  no type, headers, times.

    # str (urlused)
    # str (status_code)
    # str (type)
    # str (headers)
    # str (modified)
    # str (times)

    metaData_URL <- data.frame (urlused, status_code, modified)

    return(metaData_URL)
   
    
}
	


## Function takes in the HUCdata (mixed metadata and payload) retrieved from the API and
### returns the HUCmetadata portion as a dataframe

HUCmetaData <- function (DataRequestRaw) {

    ## Grab the metadata ##

    HUCdataBlobRaw <- DataRequestRaw$content
    HUCdataBlob <- rawToChar(HUCdataBlobRaw)
    
    HUCdataBlob %>% spread_all -> HUCmetaDataBall

    #   str (HUCmetaDataBall)
    
    document.id <- HUCmetaDataBall$document.id # document id (integer). Sequential?
    hasMore <- HUCmetaDataBall$hasMore # Are more top-level records for this HUC?
    limit <- HUCmetaDataBall$limit # Limit of projects listed per HUC?
    offset <- HUCmetaDataBall$offset # Not sure what offset is
    count <- HUCmetaDataBall$count  # How many projects are in this HUC

    # The Payload is in 'HUCmetaDataBall$..JSON'. Will leave extraction of this data to a different function.
    
    HUCMetaData <- data.frame (document.id,hasMore,limit,offset,count) 
    return (HUCMetaData)
}

####


## Function takes in the HUCdata (mixed metadata and payload) retrieved from the API and
### returns the payload portion.

HUCpayloadData <- function (DataRequestRaw) {

    FrontMetaData <- HUCmetaData (DataRequestRaw)
    
    HUCdataBlobRaw <- DataRequestRaw$content
    HUCdataBlob <- rawToChar(DataRequestRaw$content)
    HUCdataBlob %>% spread_all -> HUCPayloadBallJson

    HUCPayloadMessyList <- HUCPayloadBallJson$..JSON
    HUCPayloadBall <- HUCPayloadMessyList[[1]]  # Untangling a messy list


    # Now, in addition to the "Front meta data (FrontMetadata)"
      # structure, there is also a partial replica of the data at the
      # end, plus some links. This is RearMetaData.

    # The payload is in a nested list, top of which is 'items'
    # Rear Metadata is in fields:
        # hasMore
	# limit
	# offset
	# count
	# links (which itself is a nested list)
	    # These links currently are of only partial use.
	    # One is the URL we fetched at the beginning of the cycle of a HUC
	    # Another looks like it might be a link to a schema, but gives a 404 error

    # Extract the rear metadata (skipping the 'links' double-nested list)

    hasMore <- HUCPayloadBall$hasMore
    limit   <- HUCPayloadBall$limit
    offset  <- HUCPayloadBall$offset
    count   <- HUCPayloadBall$count
    #   skip links <- HUCPayloadBall$links

    RearMetaData <- data.frame (hasMore, limit, offset, count)
    # str (RearMetaData)

    # Now we have a cleaner list of nested lists that we can continue to disentangle by project
    # Expect > 0 projects per huc, especially need to loop through > 1 projects
    # This is a nested list of all the projects in the HUC.
    ## Need to loop over each
    
    # Loop over the elements of ProjsInHUC (i), from one to j
    # j is number of projects from ProjInHUC

     i=1
     j <- RearMetaData$count # Number of projects in this HUC. Will loop over that

     # Test to see if j < 1. If so, stop processing and return NULL or similar

     if (j < 1) {
         # create a blank data frame
	 empty.df <- CreateBlankProjectDetailFrame()
	 return (empty.df)
     }
	

     ProjDetailList <- HUCPayloadBall[[1]][[i]]
     # str (ProjDetailList)


    # Create Data Frame with first row of data
      # Another option might be to create an empty dataframe with the right column names and data types

    temp_df <- do.call(cbind, ProjDetailList)
    temp_frame <- as.data.frame(temp_df)
    ProjDetailFrame  <- bind_cols (temp_frame, RearMetaData)

    if (i > 1) { # skip it if not; already got the one project per HUC above
       for (i in 2:j) {
  	 ProjDetailList <- HUCPayloadBall[[1]][[i]]
  	 temp_df <- do.call(cbind, ProjDetailList)
  	 temp_frame <- as.data.frame(temp_df)
  	 temp_frame  <- bind_cols (temp_frame, RearMetaData)
 	 ProjDetailFrame <- bind_rows(ProjDetailFrame,temp_frame)
       }
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




CreateBlankProjectDetailFrame <- function () {


     t.df <- data.frame (state = character(), st_prj_no = character(),
     	  prj_seq = character(),prj_title = character(), approp_year = character(),      
  	  total_319_funds = character(), project_dollars = character(),
  	  program_dollars = character(), epa_other = character(),
  	  other_federal = character(), state_funds = character(),
  	  state_in_kind = character(), local_funds = character(),
	  other_funds = character(),local_in_kind = character(),
  	  total_budget = character(), will_has_load_reductions_ind = character(),
  	  huc_8 = character(), huc_12 = character(), statewide_ind = character(),               
  	  project_start_date = character (),status= character(),
	  project_link = character(),ws_protect_ind = character(), grant_no = character(),                    
	  hasMore = logical (), limit = integer(), offset = integer (), count = integer(),
	  stringsAsFactors=FALSE)

    return (t.df)
}