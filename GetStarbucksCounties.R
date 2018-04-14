# This will get the counties for all the Starbucks locations
# given their lat and long.

# Function to capitalise all words in a string field.
simpleCap <- function(x) {
  s <- strsplit(x, " ")[[1]]
  paste(toupper(substring(s, 1,1)), substring(s, 2),
        sep="", collapse=" ")
}

#Function to extract county in lower 48 states from lat/long.
library(sp)
library(maps)
library(maptools)

# The single argument to this function, pointsDF, is a data.frame in which:
#   - column 1 contains the longitude in degrees (negative in the US)
#   - column 2 contains the latitude in degrees
latlong2state <- function(pointsDF) {
  # Prepare SpatialPolygons object with one SpatialPolygon
  # per state (plus DC, minus HI & AK)
  county <- map('county', fill=TRUE, col="transparent", plot=FALSE)
  IDs <- sapply(strsplit(county$names, ":"), function(x) x[1])
  county_sp <- map2SpatialPolygons(county, IDs=IDs,
                                   proj4string=CRS("+proj=longlat +datum=WGS84"))
   # Convert pointsDF to a SpatialPoints object 
  pointsSP <- SpatialPoints(pointsDF, 
                            proj4string=CRS("+proj=longlat +datum=WGS84"))
   # Use 'over' to get _indices_ of the Polygons object containing each point 
  indices <- over(pointsSP, county_sp)
   # Return the state names of the Polygons object containing each point
  countyNames <- sapply(county_sp@polygons, function(x) x@ID)
  countyNames[indices]
}

# Read the Starbucks data in, then create a variable containing the
# first three digits of the Postcode (i.e., the ZIP code).
setwd("C:/Analytics/Summer2017_Project/Data")
starbucks <-read.csv("Starbucks_Locations_US_csv.csv", stringsAsFactors = FALSE)
starbucks$zip3 <- substr(starbucks$Postcode,1,3)
# Get the county name.  Retain the state name in case there are the
# same county names in different states.
latlong=data.frame(x=starbucks$Longitude,y=starbucks$Latitude)
# The following statement strips out the state name leaving only the county.
starbucks$county<-lapply(strsplit(latlong2state(latlong),split=","),"[",2)
starbucks$statecounty<-latlong2state(latlong)
# Capitalise everything in the state and county variables.


#name <- c("zip code", "state", "final count")

starbucks$county<-sapply(starbucks$county, simpleCap)
starbucks$statecounty <- sapply(starbucks$statecounty, simpleCap)
#Write this file with county name and 3-digit zip code to a csv.
write.csv(starbucks, file="Starbucks_w_counties.csv")
