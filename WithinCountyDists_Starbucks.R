# This code calculates the distance between Starbucks within a county.  It first
# does it for the locations present as of 2013. It then adds the 2014 locations
# and recalculates distances.  Then adds 2015 and recaclculates.  And finally
# adds 2016.
#Load dplyr and tidyr (but not plyr) for processing.
library(tidyr)
library(dplyr)
# Set the working directory. Read the file that has individual Starbucks locations
# (Starbucks_w_years_Counties) and load the master county file (Starbucks_by_County)
# for joining.
setwd("C:/Analytics/Summer2017_Project/Data")
starbucks <-read.csv("Starbucks_w_Years_Counties.csv", stringsAsFactors = FALSE)
starcounty <-read.csv("Starbucks_by_County.csv", stringsAsFactors = FALSE)
starbucks$newstatecounty<- paste(tolower(gsub(" ", "",starbucks$StateName, 
     fixed = TRUE)),tolower(gsub(" ", "",starbucks$county, fixed = TRUE)),sep=",")
# Strip leading and trailing blanks.
starbucks$newstatecounty <- gsub("^\\s+|\\s+$", "", starbucks$newstatecounty)
#************** Start 2013 *******************
starbucks2013<-filter(starbucks,yearseen==2013)
# Set up a list of counties. Then process each county individually.
county.list <- unique(starbucks$newstatecounty)

across.counties <-
  lapply(county.list,
         function(a.county) {
           dists <- dist(subset(starbucks2013, newstatecounty == a.county,
                                select = c(longgrid,latigrid)))
           return(list(distmin2013 = min(dists),
                       distmax2013 = max(dists),
                       distmean2013 = mean(dists),
                       distsd2013=sd(dists)))
         })

names(across.counties) <- county.list
#Create a data frame that has the distances for each county. Then add county
# as a variable.
outdists <- do.call(rbind, across.counties)
outdists <- as.data.frame(outdists)
outdists$newstatecounty<-rownames(outdists)
# Convert variables in outdists that are currently lists to numbers and chars.
outdists$newstatecounty <- as.character(outdists$newstatecounty)
outdists$distmin2013<-as.numeric(outdists$distmin2013)
outdists$distmax2013<-as.numeric(outdists$distmax2013)
outdists$distmean2013<-as.numeric(outdists$distmean2013)
outdists$distsd2013<-as.numeric(outdists$distsd2013)
# Now set all counties with fewer than two Starbucks to missing.
outdists$distmin2013<-ifelse((is.nan(outdists$distmin2013) | 
        is.infinite(outdists$distmin2013)),NA,outdists$distmin2013)
outdists$distmax2013<-ifelse((is.nan(outdists$distmax2013) |
        is.infinite(outdists$distmax2013)),NA,outdists$distmax2013)
outdists$distmean2013<-ifelse((is.nan(outdists$distmean2013) |
        is.infinite(outdists$distmean2013)),NA,outdists$distmean2013)
outdists$distsd2013<-ifelse((is.nan(outdists$distsd2013) |
       is.infinite(outdists$distsd2013)),NA,outdists$distsd2013)
# Now get one observation per statecounty containing distance information.
countuniq <-outdists[ !duplicated(outdists$newstatecounty,fromLast=TRUE), ]

#Select variables for final file. Read file to join to. Join, and output.
distout2013 <- select(countuniq,newstatecounty,distmin2013,distmax2013,distmean2013,
                distsd2013)
outcounty<-right_join(starcounty,distout2013,"newstatecounty")
#************** End 2013/Start 2014 *******************
#************** Start 2014 *******************
starbucks2014<-filter(starbucks,yearseen<=2014)
# Set up a list of counties. Then process each county individually.
county.list <- unique(starbucks$newstatecounty)

across.counties <-
  lapply(county.list,
         function(a.county) {
           dists <- dist(subset(starbucks2014, newstatecounty == a.county,
                                select = c(longgrid,latigrid)))
           return(list(distmin2014 = min(dists),
                       distmax2014 = max(dists),
                       distmean2014 = mean(dists),
                       distsd2014=sd(dists)))
         })

names(across.counties) <- county.list
#Create a data frame that has the distances for each county. Then add county
# as a variable.
outdists <- do.call(rbind, across.counties)
outdists <- as.data.frame(outdists)
outdists$newstatecounty<-rownames(outdists)
# Convert variables in outdists that are currently lists to numbers and chars.
outdists$newstatecounty <- as.character(outdists$newstatecounty)
outdists$distmin2014<-as.numeric(outdists$distmin2014)
outdists$distmax2014<-as.numeric(outdists$distmax2014)
outdists$distmean2014<-as.numeric(outdists$distmean2014)
outdists$distsd2014<-as.numeric(outdists$distsd2014)
# Now set all counties with fewer than two Starbucks to missing.
outdists$distmin2014<-ifelse((is.nan(outdists$distmin2014) | 
                                is.infinite(outdists$distmin2014)),NA,outdists$distmin2014)
outdists$distmax2014<-ifelse((is.nan(outdists$distmax2014) |
                                is.infinite(outdists$distmax2014)),NA,outdists$distmax2014)
outdists$distmean2014<-ifelse((is.nan(outdists$distmean2014) |
                                 is.infinite(outdists$distmean2014)),NA,outdists$distmean2014)
outdists$distsd2014<-ifelse((is.nan(outdists$distsd2014) |
                               is.infinite(outdists$distsd2014)),NA,outdists$distsd2014)
# Now get one observation per statecounty containing distance infromation.
countuniq <-outdists[ !duplicated(outdists$newstatecounty,fromLast=TRUE), ]

#Select variables for final file. Read file to join to. Join, and output.
distout2014 <- select(countuniq,newstatecounty,distmin2014,distmax2014,distmean2014,
                      distsd2014)
outcounty<-left_join(outcounty,distout2014,"newstatecounty")
#************** End 2014/Start 2015 *******************
#************** Start 2015 *******************
starbucks2015<-filter(starbucks,yearseen<=2015)
# Set up a list of counties. Then process each county individually.
county.list <- unique(starbucks$newstatecounty)

across.counties <-
  lapply(county.list,
         function(a.county) {
           dists <- dist(subset(starbucks2015, newstatecounty == a.county,
                                select = c(longgrid,latigrid)))
           return(list(distmin2015 = min(dists),
                       distmax2015 = max(dists),
                       distmean2015 = mean(dists),
                       distsd2015=sd(dists)))
         })

names(across.counties) <- county.list
#Create a data frame that has the distances for each county. Then add county
# as a variable.
outdists <- do.call(rbind, across.counties)
outdists <- as.data.frame(outdists)
outdists$newstatecounty<-rownames(outdists)
# Convert variables in outdists that are currently lists to numbers and chars.
outdists$newstatecounty <- as.character(outdists$newstatecounty)
outdists$distmin2015<-as.numeric(outdists$distmin2015)
outdists$distmax2015<-as.numeric(outdists$distmax2015)
outdists$distmean2015<-as.numeric(outdists$distmean2015)
outdists$distsd2015<-as.numeric(outdists$distsd2015)
# Now set all counties with fewer than two Starbucks to missing.
outdists$distmin2015<-ifelse((is.nan(outdists$distmin2015) | 
                                is.infinite(outdists$distmin2015)),NA,outdists$distmin2015)
outdists$distmax2015<-ifelse((is.nan(outdists$distmax2015) |
                                is.infinite(outdists$distmax2015)),NA,outdists$distmax2015)
outdists$distmean2015<-ifelse((is.nan(outdists$distmean2015) |
                                 is.infinite(outdists$distmean2015)),NA,outdists$distmean2015)
outdists$distsd2015<-ifelse((is.nan(outdists$distsd2015) |
                               is.infinite(outdists$distsd2015)),NA,outdists$distsd2015)
# Now get one observation per statecounty containing distance infromation.
countuniq <-outdists[ !duplicated(outdists$newstatecounty,fromLast=TRUE), ]

#Select variables for final file. Read file to join to. Join, and output.
distout2015 <- select(countuniq,newstatecounty,distmin2015,distmax2015,distmean2015,
                      distsd2015)
outcounty<-left_join(outcounty,distout2015,"newstatecounty")
#************** End 2015/Start 2016 *******************
#************** Start 2016 *******************
starbucks2016<-filter(starbucks,yearseen<=2016)
# Set up a list of counties. Then process each county individually.
county.list <- unique(starbucks$newstatecounty)

across.counties <-
  lapply(county.list,
         function(a.county) {
           dists <- dist(subset(starbucks2016, newstatecounty == a.county,
                                select = c(longgrid,latigrid)))
           return(list(distmin2016 = min(dists),
                       distmax2016 = max(dists),
                       distmean2016 = mean(dists),
                       distsd2016=sd(dists)))
         })

names(across.counties) <- county.list
#Create a data frame that has the distances for each county. Then add county
# as a variable.
outdists <- do.call(rbind, across.counties)
outdists <- as.data.frame(outdists)
outdists$newstatecounty<-rownames(outdists)
# Convert variables in outdists that are currently lists to numbers and chars.
outdists$newstatecounty <- as.character(outdists$newstatecounty)
outdists$distmin2016<-as.numeric(outdists$distmin2016)
outdists$distmax2016<-as.numeric(outdists$distmax2016)
outdists$distmean2016<-as.numeric(outdists$distmean2016)
outdists$distsd2016<-as.numeric(outdists$distsd2016)
# Now set all counties with fewer than two Starbucks to missing.
outdists$distmin2016<-ifelse((is.nan(outdists$distmin2016) | 
                                is.infinite(outdists$distmin2016)),NA,outdists$distmin2016)
outdists$distmax2016<-ifelse((is.nan(outdists$distmax2016) |
                                is.infinite(outdists$distmax2016)),NA,outdists$distmax2016)
outdists$distmean2016<-ifelse((is.nan(outdists$distmean2016) |
                                 is.infinite(outdists$distmean2016)),NA,outdists$distmean2016)
outdists$distsd2016<-ifelse((is.nan(outdists$distsd2016) |
                               is.infinite(outdists$distsd2016)),NA,outdists$distsd2016)
# Now get one observation per statecounty containing distance infromation.
countuniq <-outdists[ !duplicated(outdists$newstatecounty,fromLast=TRUE), ]

#Select variables for final file. Read file to join to. Join, and output.
distout2016 <- select(countuniq,newstatecounty,distmin2016,distmax2016,distmean2016,
                      distsd2016)
outcounty<-left_join(outcounty,distout2016,"newstatecounty")
#************** End 2016 *******************
# File now contains all spatial information for 2013, 2014, and 2015.
# Output the file.
write.csv(outcounty, file = "Starbucks_by_County_Kim.csv", row.names=FALSE)
