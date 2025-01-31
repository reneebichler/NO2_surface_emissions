## ------------------------------------------------------------------------------------
## Libraries
## ------------------------------------------------------------------------------------

# Load required libraries
library(randomForest)
library(dplyr)
library(ggplot2)
library(raster) # For handling .tif files
library(viridis) # For better color scales

## ------------------------------------------------------------------------------------
## Variables
## ------------------------------------------------------------------------------------

# Load .tif files (replace paths with actual file locations)
dem <- raster("path_to_dem_file.tif")  # DEM file
lcz <- raster("path_to_lcz_file.tif")  # Local Climate Zones file
osm <- raster("path_to_osm_file.tif")  # Road Proximity file

## ------------------------------------------------------------------------------------
## Main
## ------------------------------------------------------------------------------------

# Simulated example data (replace with your actual dataset)
set.seed(123)
data <- data.frame(
  TROPOMI_NO2 = runif(500, 0, 10), # Satellite NO2 (dummy data)
  Latitude = runif(500, 30, 50),   # Dummy latitude
  Longitude = runif(500, -125, -65), # Dummy longitude
  Surface_NO2 = rnorm(500, 5, 1.5) # Ground-based NO2 measurements (dummy data)
)

# Extract values from raster files for each data point
coordinates <- data.frame(data$Longitude, data$Latitude)
colnames(coordinates) <- c("Longitude", "Latitude")

data$Elevation <- extract(dem, coordinates)
data$LCZ <- extract(lcz, coordinates)
data$Road_Proximity <- extract(osm, coordinates)

# Handle missing data
data$Elevation[is.na(data$Elevation)] <- mean(data$Elevation, na.rm = TRUE)
data$LCZ[is.na(data$LCZ)] <- -1
data$Road_Proximity[is.na(data$Road_Proximity)] <- -1

# Convert LCZ and Road Proximity to factors
data$LCZ <- factor(data$LCZ, levels = unique(data$LCZ), labels = paste("LCZ", unique(data$LCZ), sep = "_"))
data$Road_Proximity <- factor(data$Road_Proximity, levels = unique(data$Road_Proximity), labels = c("Non_Near_Road", "Near_Road"))

# Transform the TROPOMI_NO2 variable using the Anscombe transform
anscombe_transform <- function(x) 2 * sqrt(x + 3/8)
data$TROPOMI_NO2_Transformed <- anscombe_transform(data$TROPOMI_NO2)

# Train a random forest regression model
rf_model <- randomForest(
  Surface_NO2 ~ TROPOMI_NO2_Transformed + Road_Proximity + LCZ + Elevation,
  data = data,
  ntree = 500,
  importance = TRUE
)

# Create a 0.01° x 0.01° grid for CONUS
lon_range <- seq(-125, -66, by = 0.01)
lat_range <- seq(25, 50, by = 0.01)
grid <- expand.grid(Longitude = lon_range, Latitude = lat_range)

# Extract raster data for the grid
grid$Elevation <- extract(dem, grid[, c("Longitude", "Latitude")])
grid$LCZ <- extract(lcz, grid[, c("Longitude", "Latitude")])
grid$Road_Proximity <- extract(osm, grid[, c("Longitude", "Latitude")])

# Handle missing data in the grid
grid$Elevation[is.na(grid$Elevation)] <- mean(data$Elevation, na.rm = TRUE)
grid$LCZ[is.na(grid$LCZ)] <- -1
grid$Road_Proximity[is.na(grid$Road_Proximity)] <- -1

# Convert LCZ and Road Proximity to factors
grid$LCZ <- factor(grid$LCZ, levels = unique(data$LCZ), labels = paste("LCZ", unique(data$LCZ), sep = "_"))
grid$Road_Proximity <- factor(grid$Road_Proximity, levels = unique(data$Road_Proximity), labels = c("Non_Near_Road", "Near_Road"))

# Add transformed TROPOMI NO2 (dummy data for now)
grid$TROPOMI_NO2 <- runif(nrow(grid), 0, 10) # Replace with actual data
grid$TROPOMI_NO2_Transformed <- anscombe_transform(grid$TROPOMI_NO2)

# Predict NO2 for the grid
grid$Predicted_NO2 <- predict(rf_model, newdata = grid)

# Plot the results as a map
ggplot(grid, aes(x = Longitude, y = Latitude, fill = Predicted_NO2)) +
  geom_raster() +
  scale_fill_viridis(name = "Predicted NO2 (ppb)", option = "C") +
  coord_fixed() +
  labs(
    title = "Predicted Surface NO2 Across CONUS",
    x = "Longitude",
    y = "Latitude"
  ) +
  theme_minimal()