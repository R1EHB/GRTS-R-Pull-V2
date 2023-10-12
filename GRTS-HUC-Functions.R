#
################  Functions for Shrimp-n-GRTS R Code ###############

####  Vector of HUCs to Analyze #####

# To be added. Maybe #

#####################################


########  Grab a record from the API and return it ####

## Function takes in the URL to grab, returns the content portion in a tibble

HUCDataContent <- function (URL="https://grts.epa.gov") {
    DataRequestRaw <- curl_fetch_memory(URL)
    DataRequest <- rawToChar(DataRequestRaw$content)

   # Spread the JSON Data
    DataRequest %>% spread_all -> GRTSInfo4HUC
   # Return GRTSInfo4HUC
    return (GRTSInfo4HUC)
}


##########################
