## "C:\Users\ebeck\OneDrive - Environmental Protection Agency (EPA)\Sync4OneDrive\GRTS2025\GRTS-R-Pull-V2\DataOutput\HUC-NewEng-test.pandas.xlsx"
##
##
## Using panda generated version of excel


## total_319_funds	project_dollars	program_dollars	epa_other	other_federal	state_funds	state_in_kind	local_funds	other_funds	local_in_kind	total_budget


summarystat<- function(x) {
  z1 <- mean(x)
  z2 <- median(x)
  z3 <- sd(x)
  return(list(mean=z1, median=z2, sd=z3))
}

library(skimr)

library(readxl)
library(dplyr)
library(vioplot)
library(lubridate)
library(readr)

infile <- '../DataOutput/HUC-NewEng-test.pandas.xlsx'
outfile <- './DataOutput/R-Data.Rmd'


GRTS_df <- read_excel(path=infile)


## Key type Conversions



GRTS_df$project_start_date <- mdy(GRTS_df$project_start_date)


GRTS_df$n_lbsyr <- as.numeric(GRTS_df$n_lbsyr)
GRTS_df$p_lbsyr <- as.numeric(GRTS_df$p_lbsyr)
GRTS_df$sed_tonsyr <- as.numeric(GRTS_df$sed_tonsyr)
GRTS_df$FakeHUC <- as.numeric(GRTS_df$huc_12)
GRTS_df$total_319_funds <- parse_number(GRTS_df$total_319_funds)
GRTS_df$project_dollars <- parse_number(GRTS_df$project_dollars)
GRTS_df$program_dollars <- parse_number(GRTS_df$program_dollars)
GRTS_df$epa_other <- parse_number(GRTS_df$epa_other)
GRTS_df$other_federal <- parse_number(GRTS_df$other_federal)
GRTS_df$state_funds <- parse_number(GRTS_df$state_funds)
GRTS_df$state_in_kind <- parse_number(GRTS_df$state_in_kind)
GRTS_df$local_funds <- parse_number(GRTS_df$local_funds)
GRTS_df$other_funds <- parse_number(GRTS_df$other_funds)
GRTS_df$local_in_kind <- parse_number(GRTS_df$local_in_kind)
GRTS_df$total_budget <- parse_number(GRTS_df$total_budget)

head (GRTS_df)



#### 
str (GRTS_df)


skim(GRTS_df)

x_origin <- year (ymd(19960101))
x_end <- year (ymd(20260101))

year_date <- year(GRTS_df$project_start_date)

plot(year_date,GRTS_df$n_lbsyr,log="y",xlim=c(x_origin, x_end),
     ylim=c(0.1,110000), main="lbs N per Year Reduced log10",xlab="Year", ylab= "lbs N")
# identify points

q()


