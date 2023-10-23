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

myHUC12DF <-
  read.csv(
    file = 'HUC12NewEnglandvector.csv' ,
    header = T,
    colClasses = c("HUC12_Code" = "character")
  )


# head (myHUC12DF)
# str (myHUC12DF)

 vec_len <- nrow (myHUC12DF)

# Temporarily put vec_len as 10 for testing

# vec_len = 140

# print (vec_len)



t <- data.frame (urlused=character(), status_code=integer(), modified=character(), stringsAsFactors=FALSE)

# Create a progress bar for the loop

pb <-  txtProgressBar(min = 0, max = vec_len, initial = 0, style = 3,
   width = 50, char = "=")
		     
for (i in 1:vec_len) {

    # URL Metadata
    URL <- paste0(BaseURL, myHUC12DF$HUC12_Code[i])
    URL_result <- URLfetch(URL)
    j <- URLmetaData (URL_result)
    t <- rbind (t,j)

    # will move extraction of HUC metadata to a subfunction of HUCpayloadData
    # HUC Metadata
    # HUCmetaData(URL_result)

    if (i==1) {
       Projects.DF <- HUCpayloadData(URL_result)
    }

    if (i > 1) {
       temp.df <- HUCpayloadData(URL_result)
       Projects.DF <- bind_rows (Projects.DF, temp.df)
    }

    setTxtProgressBar(pb, i)

}

close (pb)

write.csv (Projects.DF, file="test.csv")
saveRDS (Projects.DF, file="Projects.rds")
q()
