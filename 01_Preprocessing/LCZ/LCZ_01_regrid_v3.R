## ------------------------------------------------------------------------------------
## Libraries
## ------------------------------------------------------------------------------------

library(terra)
library(sf)
library(stars)
library(dplyr)
library(ggplot2)
library(data.table)

## ------------------------------------------------------------------------------------
## Variables
## ------------------------------------------------------------------------------------

cellsize <- 1

xmin <- -125
xmax <- -65
ymin <- 24
ymax <- 50

buffer <- 0

## Input
input_path <- "/proj/ie/proj/Wellcome-ZEAS/RemoteSensing/"

## Output
output_path <- "/proj/ie/proj/Wellcome-ZEAS/RemoteSensing/Results/"

## ------------------------------------------------------------------------------------
## Functions and dictionaries
## ------------------------------------------------------------------------------------

categories_full_name <- c(
  "1" = "1 - Compact highrise",
  "2" = "2 - Compact midrise",
  "3" = "3 - Compact lowrise",
  "4" = "4 - Open highrise",
  "5" = "5 - Open midrise",
  "6" = "6 - Open lowrise",
  "7" = "7 - Lightweight lowrise",
  "8" = "8 - Large lowrise",
  "9" = "9 - Sparsely built",
  "10" = "10 - Heavy industry",
  "11" = "A - Dense trees",
  "12" = "B - Scattered trees",
  "13" = "C - Bush, scrub",
  "14" = "D - Low plants",
  "15" = "E - Bare rock or paved",
  "16" = "F - Bare soil or sand",
  "17" = "G - Water"
)

categories_name <- c(
  "1" = "Compact highrise",
  "2" = "Compact midrise",
  "3" = "Compact lowrise",
  "4" = "Open highrise",
  "5" = "Open midrise",
  "6" = "Open lowrise",
  "7" = "Lightweight lowrise",
  "8" = "Large lowrise",
  "9" = "Sparsely built",
  "10" = "Heavy industry",
  "11" = "Dense trees",
  "12" = "Scattered trees",
  "13" = "Bush, scrub",
  "14" = "Low plants",
  "15" = "Bare rock or paved",
  "16" = "Bare soil or sand",
  "17" = "Water"
)

## ------------------------------------------------------------------------------------
## Main
## ------------------------------------------------------------------------------------

## Load raster and grid
tif <- terra::rast(paste0(input_path, "DATA/Demuzere_2020/CONUS_LCZ_map_NLCD_v1.0_epsg4326.tif"))

cellsize_name <- as.character(cellsize)

grid <- st_read(
  paste0(
    input_path,
    "Results/Grid/00_grid_", cellsize_name, "x", cellsize_name, "_", xmin, "_", xmax, "_", ymin, "_", ymax, 
    "/03_grid_", cellsize_name, "x", cellsize_name, "_", xmin, "_", xmax, "_", ymin, "_", ymax, "_intersect_buffer_", buffer, "m.shp"
  )
)

## Split grid into batches
grid_batches <- split(grid, seq(nrow(grid)))

print("Apply batch processing")

## Preallocate a list to store results
results <- vector("list", length(grid_batches))

## Batch processing
results <- lapply(seq_along(grid_batches), function(i) {
  cell <- grid_batches[[i]]
  
  ## Crop and mask raster
  aoi <- mask(crop(tif, vect(cell)), cell)
  
  ## Calculate frequency table for classes
  t <- as.data.frame(table(terra::values(aoi)))

  ## Information: If the cagetory is NULL the value will be 0
  
  if (nrow(t) > 0) {

    ## Exclude class "0"
    t <- subset(t, Var1 != 0)
    
    if (nrow(t) > 0) {
      ## Find the class with the highest frequency
      new_class <- t$Var1[which.max(t$Freq)]
      
      ## Add new class information to the cell
      cell$class <- new_class
      cell$cname <- categories_name[as.character(new_class)]
      cell$fname <- categories_full_name[as.character(new_class)]
    
    } else {
      cell$class <- 0
      cell$cname <- "NULL"
      cell$fname <- "NULL"
    }

  } else {
    cell$class <- 0
    cell$cname <- "NULL"
    cell$fname <- "NULL"
  }
  
  print(cell)

  ## Return the processed cell
  return(cell)
})

## Combine results into a single data.table
df_lcz <- rbindlist(results)

## Convert to spatial feature object
df_lcz_sf <- st_as_sf(df_lcz)

## Create output folder
folder_name <- paste0("00_lcz_", cellsize_name, "x", cellsize_name, "_", xmin, "_", xmax, "_", ymin, "_", ymax)
folder_path <- file.path(output_path, "LCZ", folder_name)

if (!file.exists(folder_path)) {
  dir.create(folder_path, recursive = TRUE)
  print(paste0("Folder created at: ", folder_path))
} else {
  print(paste0("Folder already exists at: ", folder_path))
}

## Export shapefile
print("Export shapefile")
st_write(df_lcz_sf, file.path(folder_path, paste0("01_lcz_grid_", cellsize_name, "x", cellsize_name, "_", xmin, "_", xmax, "_", ymin, "_", ymax, ".shp")))

## Rasterize and export
print("Rasterize shapefile")
sf_raster <- st_rasterize(df_lcz_sf %>% dplyr::select(class, geometry))
print("Export raster file")
write_stars(sf_raster, file.path(folder_path, paste0("02_lcz_raster_", cellsize_name, "x", cellsize_name, "_", xmin, "_", xmax, "_", ymin, "_", ymax, ".tif")))

## Give permission to folder
system(paste0("chmod -R 777 ", folder_path))

print("Complete!")