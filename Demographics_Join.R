# This code srips specific words -- e.g., "county" -- off of
# fields and prepares a field to join them with statecounty.
library(tidyr)
library(dplyr)
library(tidyverse)

# Library tm will elimiinate stopwords from strings for me.
library(tm)
# Start the program.Set working directory and read file.
setwd("C:/Analytics/Summer2017_Project/Data")
demogr<- read.csv("county_facts_updated4.csv", header=TRUE,sep=",",
                      quote="\"", stringsAsFactors=FALSE)
DD<- read.csv("DD_by_County.csv", header=TRUE,sep=",",
                    quote="\"", stringsAsFactors=FALSE)
WF<- read.csv("WF_by_County.csv", header=TRUE,sep=",",
                  quote="\"", stringsAsFactors=FALSE)
starcounty<- read.csv("Starbucks_by_County_Kim_Dist.csv", header=TRUE,sep=",",
                      quote="\"", stringsAsFactors=FALSE)
# Define the words we want to eliminate.
stopwords = c("county","city","census","area","and","borough","muunicipality")
#Prepare the statecounty for the second file.  Combine the State with County. Then
# produce the statecounty without blanks and all lowercase.

demogr$newstatecounty<- tolower(demogr$statecounty)
# Now eliminate the stopwords.
demogr$newstatecounty=removeWords(demogr$newstatecounty,stopwords)
# Now get rid of inner blanks, full stops, and apostrophes.
demogr$newstatecounty=gsub(" ","",demogr$newstatecounty)
demogr$newstatecounty=gsub("'","",demogr$newstatecounty)
demogr$newstatecounty=gsub("[.]","",demogr$newstatecounty)
# Strip leading and trailing blanks.
demogr$newstatecounty <- trimws(demogr$newstatecounty)
DD$newstatecounty <- trimws(DD$statecounty)
WF$newstatecounty=trimws(WF$statecounty)
# Now prepare file for output/joining.
#outfile <- select(demogr,newstatecounty,percapincm,medhshldincm,medfmlyincm,numhshlds)
# Now join starcounty and outfile based on statecounty.
starout=left_join(starcounty,DD,by="newstatecounty")
starout=left_join(starout,WF,by="newstatecounty")
starout=left_join(starout,demogr,by="newstatecounty")
starout$numDD=ifelse(is.na(starout$numDD),0,starout$numDD)
starout$numWF=ifelse(is.na(starout$numWF),0,starout$numWF)
drops <- c("statecounty.y","statecounty.x.x","statecounty.y.y","state_abbreviation"
           ,"Statename")
starfinal<-starout[ , !(names(starout) %in% drops)]
# Now output the file withe the joined information.
write.csv(starout, file = "Starbucks_Massive_Final.csv", row.names=FALSE)
