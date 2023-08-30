# Script to figure out what the full set of columns are used 

BaseURL <- "https://ofmpub.epa.gov/apex/grts_rest/GetProjectsByHUC12/"
# myHUC12 <- "020503030802"

# myHUC12Vector <- c("020503030802", "020503030803","171100190303")


# Read In list of HUC12 from CSV file


HUC12Frame <- read.csv(file="HUC12Vector.csv",header = T, colClasses = c("x"="character"))

# X is index number ; x is HUC12.  Change this later in HUC-It to be clearer


# str (HUC12Frame)

# Sample the list of HUC12s

SampleSize=25
HUC12Sample <- sample (HUC12Frame$x, size=SampleSize)

# print (HUC12Sample)

myHUC12Vector <- HUC12Sample


library(httr)
library(jsonlite)
URL <- paste0(BaseURL, myHUC12Vector[1])
# print (URL)


raw_data <- GET (URL)
GRTS <- fromJSON(rawToChar(raw_data$content), flatten = TRUE)
str (as.data.frame(GRTS))

# names (GRTS)
# names (GRTS$next)
# names (GRTS$items)

# VarNames <- names (as.data.frame(GRTS))
# print (VarNames)


for (i in 2:length(myHUC12Vector)) {
    print (i)
    URL <- paste0(BaseURL, myHUC12Vector[i])
    raw_data <- GET (URL)
    temp <- fromJSON(rawToChar(raw_data$content), flatten = TRUE)
   
    str (as.data.frame(temp))
}



# Let's take a closer look at the structure of 


q()



print (myHUC12Vector)
length (myHUC12Vector)

q()

library(httr)
URL <- paste0(BaseURL, myHUC12)

raw_data <- GET (URL)

print (raw_data)
library ("jsonlite")
GRTS <- fromJSON(rawToChar(raw_data$content), flatten = TRUE)

myHUC12 <- "020503030803"
URL <- paste0(BaseURL, myHUC12)
raw_data <- GET (URL)
print(raw_data)

temp <- fromJSON(rawToChar(raw_data$content), flatten = TRUE)
append (GRTS, temp)
str (GRTS)
View(GRTS)
q()


foo <-jsonlite::fromJSON("https://ofmpub.epa.gov/apex/grts_rest/GetProjectsByHUC12/020503030802")

print (foo)

