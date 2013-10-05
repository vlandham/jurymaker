
library(ggplot2)
library(plyr)
library(scales)
# 
# library(sp)
# library(maps)
# library(maptools)


setwd('~/Dropbox/jurydata/reports/jurymaker')

input_filename <- '../all_dummy_results.csv'

input_data <- read.table(input_filename, sep = ",", header=TRUE)

max_amount <- 150000

results_data <- subset(input_data, amount < max_amount)
#results_data <- input_data

p <- ggplot(results_data, aes(factor(id)))
p <- p + geom_bar()
p

p <- ggplot(results_data, aes(factor(id), amount))
p <- p + geom_boxplot()
p

total_mean <- mean(results_data$amount)
results_means <- ddply(results_data, .(id), summarize, mean = mean(amount), median = median(amount))
p <- ggplot(results_means, aes(factor(id), mean)) + theme_bw()
p <- p + geom_bar(stat='identity') + scale_y_continuous("average dummy amount", labels = dollar) + scale_x_discrete("report ID")
p

zip_counts <- ddply(results_data, .(zip), summarise, count = length(zip), mean = mean(amount))
zip_counts <- zip_counts[order(-zip_counts$count), ]

# latlong2county <- function(pointsDF) {
#   # Prepare SpatialPolygons object with one SpatialPolygon
#   # per county
#   counties <- map('county', fill=TRUE, col="transparent", plot=FALSE)
#   IDs <- sapply(strsplit(counties$names, ":"), function(x) x[1])
#   counties_sp <- map2SpatialPolygons(counties, IDs=IDs,
#                                      proj4string=CRS("+proj=longlat +datum=wgs84"))
#   
#   # Convert pointsDF to a SpatialPoints object 
#   pointsSP <- SpatialPoints(pointsDF, 
#                             proj4string=CRS("+proj=longlat +datum=wgs84"))
#   
#   # Use 'over' to get _indices_ of the Polygons object containing each point 
#   indices <- over(pointsSP, counties_sp)
#   
#   # Return the county names of the Polygons object containing each point
#   countyNames <- sapply(counties_sp@polygons, function(x) x@ID)
#   countyNames[indices]
# }

# Test the function using points in Wisconsin and Oregon.
# testPoints <- data.frame(x = c(-90, -120), y = c(44, 44))
# latlong2county(testPoints)


zip_data_filename <- 'zip_to_county.csv'

zip_data <- read.table(zip_data_filename, sep=",", header = TRUE, quote = "\"'")

results_with_counties <- merge(results_data, zip_data, by.x = 'zip', by.y = 'zcta5', all.x = TRUE)

county_counts <- ddply(results_with_counties, .(County), summarise, count = length(County), mean = mean(amount))
county_counts <- county_counts[order(-county_counts$count), ]
county_counts <- subset(county_counts, !is.na(County))

top_county_counts <- county_counts[1:20,]

p <- ggplot(county_counts[1:10,], aes(factor(County, levels=county_counts$County), mean))
p <- p + geom_boxplot()
p

p <- ggplot(county_counts, aes(factor(County, levels=county_counts$County), count))
p <- p + geom_bar(stat = 'identity')
p

library('ggmap')
top_locations <- geocode(as.character(top_county_counts$County))
top_county_locations <- cbind(top_county_counts, top_locations)
map <- get_map(location = 'united states', zoom = 4)
ggmap(map, extent = 'normal') +
  geom_point(aes(x = lon, y = lat, size = count), data = top_county_locations, color = 'red')


p <- ggplot(top_county_counts, aes(factor(County, levels=county_counts$County), mean))
p <- p + geom_bar(stat = 'identity') + geom_abline(intercept = total_mean, color = 'red')
p
