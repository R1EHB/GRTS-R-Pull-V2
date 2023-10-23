# Test GRTS Processing Module
# Get data by HUC12 API from GRTS
# Test with smaller list of HUC12
# Then aggregate up from HUC12 level to bigger areas.


# Get Blackstone HUC12 list for testing
# WoonyList <- read.csv(file="HUC12-Blackstone-Woony.csv")

# Version One

WoonyList <-scan("HUC12-Blackstone-Woony.csv", what = "character")

#print (WoonyList)

BaseURL<-'https://grts.epa.gov/ords/grts_rest/grts_rest_apex/GetProjectsByHUC12/'

# print (BaseURL)

URLs <- paste(BaseURL,WoonyList[1], sep = '')

WL <- length(WoonyList)

for (i in 2:WL) {
    URLs <- append (URLs,paste(BaseURL,WoonyList[i], sep = '') )
    }

# print (URLs)

# Create a DataFrame

HUC_Projects <- as.data.frame(WoonyList)
HUC_Projects$URLs <- URLs
HUC_Projects$HUC12 <- HUC_Projects$WoonyList

# str (HUC_Projects)

## Get HUC12 names

# Using a RI list

RI_HUCS <- read.csv(file="RIHUC12List.csv", header = TRUE, colClasses = c("HUC12"="character"))

# Do a merge

str (RI_HUCS)
str (HUC_Projects)

MergeHUC <- merge (HUC_Projects, RI_HUCS, all.x=TRUE)

HUC_Projects <- MergeHUC

HUC_Projects <- within (HUC_Projects, rm (WoonyList, Index))

str (HUC_Projects)

q()


# Now get info per HUC12 and insert number of projects into dataFrame

library (rjson)

# Loop over list of HUCs to evaluate

for (i in 1:WL) {
# print (HUC_Projects$URLs[i])
    FooFooTemp <- fromJSON (file=HUC_Projects$URLs[i],method = "C", unexpected.escape = "error", simplify = TRUE)
#    print (length(FooFooTemp$items))
    HUC_Projects$NumProj[i] <- length(FooFooTemp$items)

str (FooFooTemp)
#     HUC_Projects$NameWater[i] <- 
  }

q()

# print (HUC_Projects)

# Get last five digits of HUC to make labels nicer

HUC_Projects$Short <- substring(HUC_Projects$WoonyList, first=8, last=12)


# Plot isn't really helpful here

# plot (HUC_Projects$Short , HUC_Projects$NumProj)

table  (HUC_Projects$Short, HUC_Projects$NumProj) 


q()

