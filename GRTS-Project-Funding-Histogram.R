# Another GRTS JSON Test #
# This time pull a bunch of HUC12 at random from the full North America + US Territories and Possessions list
# Collect info on per project funding and run a histogram


## Set BaseURL ##
BaseURL <- "https://ofmpub.epa.gov/apex/grts_rest/GetProjectsByHUC12/"


# Get a big sample of projects



HUC12Frame <- read.csv(file="HUC12Vector.csv",header = T, colClasses = c("x"="character"))

# X is index number ; x is HUC12.  Change this later in HUC-It to be clearer




# Sample the list of HUC12s

# SampleSize=500
SampleSize=5

HUC12Sample <- sample (HUC12Frame$x, size=SampleSize)



myHUC12Vector <- HUC12Sample




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

vec_len <- length (myHUC12Vector)



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
    URL <- paste0(BaseURL, myHUC12Vector[i])
    raw_data <- GET (URL)
    temp <- fromJSON(rawToChar(raw_data$content), flatten = TRUE)
    if (i==1) {
       coarseGRTS <- temp
    }  else {
    	 coarseGRTS <- append (coarseGRTS,temp)
       }
       setTxtProgressBar(pb,i)

}

close(pb)

## now split and combine the list of dataframes into one dataframe.
## It will yield a mix of API URL interspersed with the data of interest retreived from that API URL call.
## So need to drop those URL rows

Messy_GRTS_DF <- rbindlist(coarseGRTS, use.names=TRUE, fill=TRUE, idcol=TRUE)

GRTS_DF <- subset (Messy_GRTS_DF, .id=="items")
GRTS_DF$Numeric_total_319_funds <-  parse_number(GRTS_DF$total_319_funds)

Vector_total_319_funds <- as.vector (GRTS_DF$Numeric_total_319_funds)



#str (GRTS_DF)

## Write the file to CSV for checking ##
write.csv(GRTS_DF, file="GRTS_DF.CSV")

hist(Vector_total_319_funds)
boxplot(Vector_total_319_funds)

q()


