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
use_condaenv("base")
# use_python("/.........../python")
# psys <- reticulate::import("sys")
# pspect <- reticulate::import("inspect")

#getData <- reticulate::import ("main-fetch-using-URLlib3-ModifedRequests")

source_python("main-fetch-using-URLlib3-ModifedRequests.py")

infile <- './DataInput/RI-huc.csv'
outfile <- 'HUC-Oly-test'

filename2read_json <- JSON_data2R(infile, outfile)

print (filename2read_json)

GRTS_df <- read_json(filename2read_json)
head (GRTS_df)

q()


