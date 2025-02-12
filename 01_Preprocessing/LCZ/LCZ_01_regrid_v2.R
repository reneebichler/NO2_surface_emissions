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

cellsize <- 0.01

xmin <- -124
xmax <- -66
ymin <- 25
ymax <- 49

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
  "10" = "10 - Heavy Industry",
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
  "10" = "Heavy Industry",
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

## Initialize result data frame
df_lcz <- data.table()

## Batch processing
grid_batches <- split(grid, seq(nrow(grid))) # Split for parallel-friendly processing if needed

print("Apply batch processing")
lapply(grid_batches, function(cell) {

  ## Crop and mask raster
  aoi <- mask(crop(tif, vect(cell)), cell)

  ## Calculate frequency table for classes
  t <- as.data.frame(table(terra::values(aoi)))

  if (nrow(t) > 0) {

    ## Exclude class "0"
    t <- subset(t, Var1 != 0)

    if (nrow(t) > 0) {

      ## Find the class with the highest frequency
      new_class <- t$Var1[which.max(t$Freq)]

      ## Add new class to grid
      cell$class <- new_class
      cell$cname <- categories_name[new_class]
      cell$fname <- categories_full_name[new_class]

    } else {
      cell$class <- NA
      cell$cname <- NA
      cell$fname <- NA
    }
    
  } else {
    cell$class <- NA
    cell$cname <- NA
    cell$fname <- NA
  }

  ## Append processed cell
  df_lcz <<- rbind(df_lcz, cell)

  print(cell)
})

## Export shapefile
folder_name <- paste0("00_lcz_", cellsize_name, "x", cellsize_name, "_", xmin, "_", xmax, "_", ymin, "_", ymax)
folder_path <- paste0(output_path, "LCZ/", folder_name)
print(paste0("Created folder name: ", folder_name))

## Check if directory exists
## Check if the folder path exists. If not, create folder!
if (!file.exists(folder_path)) {
  dir.create(folder_path, recursive = TRUE)
  print(paste0("Folder created at:", folder_path))
} else {
  print(paste0("Folder already exists at:", folder_path))
}

## Convert data frame/table into spatial feature object
df_lcz_sf <- st_as_sf(df_lcz)

## Export shapefile
print("Export shapefile")
st_write(df_lcz_sf, file.path(folder_path, paste0("01_lcz_grid_", cellsize_name, "x", cellsize_name, "_", xmin, "_", xmax, "_", ymin, "_", ymax, ".shp")))

## ToDo: Rasterize and export
#print("Rasterize shapefile")
#sf_raster <- st_rasterize(df_lcz_sf %>% dplyr::select(fname, geometry))
#print("Export raster file")
#write_stars(sf_raster, file.path(folder_path, paste0("02_lcz_raster_", cellsize_name, "x", cellsize_name, "_", xmin, "_", xmax, "_", ymin, "_", ymax, ".tif")))

print("Complete!")