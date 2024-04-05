# Get GRTS Data for RI
# Using for Load Listings 2024
# 4 April 2024

# Note: for openSSL 3.0.2 on linux, need to do:

#You could also just add Options = UnsafeLegacyServerConnect to the
#  existing /etc/ssl/openssl.cnf under [system_default_sect].

#NB. In OpenSSL < 3.0.4 there was a bug that ignored the
# UnsafeLegacyServerConnect option. If you are stuck with <= 3.0.3, you
# could use (the more unsafe) UnsafeLegacyRenegotiation instead.

# https://stackoverflow.com/questions/75763525/curl-35-error0a000152ssl-routinesunsafe-legacy-renegotiation-disabled


## Set BaseURL ##

# Old BaseURL API Endpoint
#BaseURL <- "https://ofmpub.epa.gov/apex/grts_rest/GetProjectsByHUC12/"

# New URL (per matt moss, 5 april 2024)
BaseURL <- "https://ordspub.epa.gov/ords/grts_rest/grts_rest_apex/grts_rest_apex/GetProjectsByHUC12/"

# Get the RI HUC12 list



# myRIHUC12Vector <- read.csv(file="../HUC-Data-Lists/RI-huc.csv",header = T,sep="\t", colClasses = c("HUC12_Code"="character"))
myRIHUC12Vector <- read.csv(file="../HUC-Data-Lists/RI-huc.csv",header = T,sep="\t")

head (myRIHUC12Vector)
str (myRIHUC12Vector)



## Load Libraries ##
library(httr)
library(jsonlite)
library(data.table)
library(dplyr)
library(readr)


### Coarse GRTS Data Structure ###
### Right from URL; not converted ###


# X
# x
# X.ref (chr) {(URL API)etc}
# items.state (chr)
# items.prj_seq (int)
# items.prj_title (chr)
# items.total_319_funds (chr) {Need to convert to int or float}
# items.description (chr)
# items.will_has_load_reductions_ind (chr) {need to convert to boolean}
# items.project_type (chr)
# items.huc_8 (chr)
# items.huc_12 (chr)
# items.pollutants (chr)
# items.statewide_ind (chr) {need to convert to boolean}
# items.project_start_date (chr) {need to convert to date}
# items.project_link (chr)
# items.status (chr)
# items.ws_protect_ind (chr)
# items.watershed_plans (chr) 


# vec_len <- length (myRIHUC12Vector)

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

for (i in 1:vec_len) {
    URL <- paste0(BaseURL, myRIHUC12Vector$huc12[i])

    raw_data <- httr::GET (URL)
    temp <- fromJSON(rawToChar(raw_data$content), flatten = TRUE)
    if (i==1) {
       coarseGRTS <- temp
    }  else {
    	 coarseGRTS <- append (coarseGRTS,temp)
       }
       setTxtProgressBar(pb,i)

}

close(pb)

str(coarseGRTS)
 q()

## now split and combine the list of dataframes into one dataframe.
## It will yield a mix of API URL interspersed with the data of interest retreived from that API URL call.
## So need to drop those URL rows

Messy_GRTS_DF <- rbindlist(coarseGRTS, use.names=TRUE, fill=TRUE, idcol=TRUE)

GRTS_DF <- subset (Messy_GRTS_DF, .id=="items")
GRTS_DF$Numeric_total_319_funds <-  parse_number(GRTS_DF$total_319_funds)

Vector_total_319_funds <- as.vector (GRTS_DF$Numeric_total_319_funds)



#str (GRTS_DF)

## Write the file to CSV for checking ##
write.csv(GRTS_DF, file="GRTS_RIcheck.CSV")

hist(Vector_total_319_funds)
boxplot(Vector_total_319_funds)

q()


