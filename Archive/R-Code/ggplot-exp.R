library(ggplot2)
library(formattable)

# ggplot(mpg, aes(displ, hwy, colour = class)) + 
#  geom_point() +geom_boxplot()

#Projects.DF <- readRDS(file="Projects.rds")
Projects.DF <- read.csv(file="test.csv")
Projects.DF$total_319_funds <- noquote (Projects.DF$total_319_funds)
Projects.DF$total_319_funds <- gsub(',', '', Projects.DF$total_319_funds)
Projects.DF$total_319_funds <- gsub('[$,]','',Projects.DF$total_319_funds)
Projects.DF$total_319_funds <- as.numeric(Projects.DF$total_319_funds)
Projects.DF$total_cost      <- currency(Projects.DF$total_319_funds, digits = 0L)
FFY    <- as.character(Projects.DF$approp_years)


Ticks <- c(0,250000,500000)
yLabels <- c("$0", "$250k", "$500k")

ggplot (Projects.DF, aes(x=state,y=total_cost)) + geom_boxplot() +
scale_y_continuous (name="cost", breaks = Ticks, labels = yLabels)

Yrs = c(2000, 2005, 2010, 2015, 2020, 2025)

# str (Projects.DF)
ggplot (Projects.DF, aes(x =approp_year,y=total_cost, group=approp_year))  + geom_boxplot() +
 scale_y_continuous (name="cost", breaks = Ticks, labels = yLabels)  +
 scale_x_continuous (name="FFY", breaks = Yrs)

ggplot (Projects.DF, aes(x =approp_year,y=total_cost, group=approp_year))  + geom_boxplot() +
 scale_y_continuous (name="cost", breaks = Ticks, labels = yLabels)  +
 scale_x_continuous (name="FFY", breaks = Yrs) + geom_jitter()


# str (Projects.DF)
q()
