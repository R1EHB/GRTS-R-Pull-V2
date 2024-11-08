# Get GRTS Data for RI
# Using for Load Listings 2024
# 4 April 2024

# Revised to test using Python for initial data fetch
# Then analyze in R
# November 6, 2024

# Easier to disentangle the json returned by the API with python than with R

# Also note need to work around TLS 1.2 and renegotiation problem with main webserver at ordspub.epa.gov.


## Load Libraries ##
library(reticulate)
library(jsonlite)
library(stringr)
# library(readr)

# For work computer, win11
# use_condaenv("base")


# For home computer, linux
use_virtualenv("Rthonic")

# use_venv

# use_python("/.........../python")
# psys <- reticulate::import("sys")
# pspect <- reticulate::import("inspect")

#getData <- reticulate::import ("main-fetch-using-URLlib3-ModifedRequests")

source_python("main-fetch-using-URLlib3-ModifedRequests.py")

infile <- './DataInput/RI-huc.csv'
outfile <- 'HUC-Oly-test'

filename2read_csv <- JSON_data2R(infile, outfile)

print (filename2read_csv)

GRTS_df <- read.csv(filename2read_csv, header = TRUE, sep = ";" )
GRTS_df$H12 <- as.character (GRTS_df$huc_12)
str (GRTS_df)

print(GRTS_df$H12)
print (str_length(GRTS_df$H12))
GRTS_df$HUC_Twelve <- ""

    ifelse( (str_length(GRTS_df$H12) == 11),
    GRTS_df$HUC_Twelve <- paste ('0', GRTS_df$H12, sep=""),
    GRTS_df$HUC_Twelve <- GRTS_df$H12
    )


print (GRTS_df$HUC_Twelve)

q()


