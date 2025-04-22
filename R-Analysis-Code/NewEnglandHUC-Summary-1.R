##
##
##
##

summarystat<- function(x) {
  z1 <- mean(x)
  z2 <- median(x)
  z3 <- sd(x)
  return(list(mean=z1, median=z2, sd=z3))
}

library(skimr)

library(readxl)
library(dplyr)

infile <- '../DataOutput/HUC-NewEng-test.xlsx'
outfile <- './DataOutput/R-Data.Rmd'




GRTS_df <- read_excel(path=infile)


## Key type Conversions
#print(GRTS_df$project_start_date)

GRTS_df$start_Project_Date <- as.Date(as.numeric(GRTS_df$project_start_date), origin = "1900-01-01")

# print(GRTS_df$start_Project_Date)
GRTS_df$n_lbsyr_n <- as.numeric(GRTS_df$n_lbsyr)
GRTS_df$p_lbsyr_n <- as.numeric(GRTS_df$p_lbsyr)
GRTS_df$sed_tonsyr_n <- as.numeric(GRTS_df$sed_tonsyr)
GRTS_df$FakeHUC <- as.numeric(GRTS_df$huc_12)

str (GRTS_df)
## print (mean (GRTS_df$sed_tonsyr_n ))

skim(GRTS_df)

x_origin=as.Date(01/01/1996)# , origin = "1900-01-01")
x_end=as.Date(01/01/2026)# , origin = "1900-01-01")

plot(GRTS_df$start_Project_Date,GRTS_df$n_lbsyr_n, xlim=c(9400,20440),ylim=c(0,110000))
# identify points

q()

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


