# Open data file written previously and do some simple statistics and data viz
# Part of GRTS R data testing suite


# Load libraries

library(ggplot2)
library(qwraps2)
library(magrittr)
library(stringr)
library(formattable)

Projects.DF <- readRDS (file="Projects.rds")

head (Projects.DF)



# Convert columns of interest to numeric, many steps unfortunately


Projects.DF$total_319_funds <- noquote (Projects.DF$total_319_funds)
Projects.DF$total_319_funds <- gsub(',', '', Projects.DF$total_319_funds)
Projects.DF$total_319_funds <- gsub('[$,]','',Projects.DF$total_319_funds)
Projects.DF$total_319_funds <- as.numeric(Projects.DF$total_319_funds)
Projects.DF$total_cost      <- currency(Projects.DF$total_319_funds, digits = 0L)



Projects.DF$approp_year <- noquote (Projects.DF$approp_year)
Projects.DF$approp_year <- as.numeric(Projects.DF$approp_year)

# head(Projects.DF$approp_year)


mci_funds <- mean_ci(Projects.DF$total_319_funds)
mci_years <- mean_ci(Projects.DF$approp_year)
print (mci_funds)
print (mci_years)

png ("funds_319.png")
yAxisRange <- c(100,1000,100000)
yTickLabels <- c("$100","$1k","$100k")
boxplot (Projects.DF$total_cost, ann = FALSE)
# axis(side=2, at=yAxisRange, labels = yTickLabels)


dev.off()

png ("AppropYear.png")
boxplot (Projects.DF$approp_year)
dev.off()

png("fundsByAppropYear.png")
boxplot (total_cost ~ approp_year, Projects.DF)
dev.off()

q()



