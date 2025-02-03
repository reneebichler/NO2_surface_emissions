## ------------------------------------------------------------------------------------
## Libraries
## ------------------------------------------------------------------------------------

library(terra)
library(sf)
library(data.table)
library(ggplot2)

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
## Main
## ------------------------------------------------------------------------------------

## Load the raster and grid shapefile
tif <- terra::rast(paste0(input_path, "Results/DEM/CONUS_merged_all_dem.tif"))

cellsize_name <- as.character(cellsize)

grid <- read_sf(
    paste0(
        input_path,
        "Results/Grid/00_grid_", cellsize_name, "x", cellsize_name, "_", xmin, "_", xmax, "_", ymin, "_", ymax,
        "/03_grid_", cellsize_name, "x", cellsize_name, "_", xmin, "_", xmax, "_", ymin, "_", ymax, "_intersect_buffer_", buffer, "m.shp"
    )
)

## Initialize result data frame
df_dem <- data.table()

## Batch processing
grid_batches <- split(grid, seq(nrow(grid))) # Split for parallel-friendly processing if needed

print("Apply batch processing")
lapply(grid_batches, function(cell) {

    ## Crop and mask raster
    aoi <- mask(crop(tif, vect(cell)), cell)

    ## Calculate mean value
    mean_val_cell <- mean(terra::values(aoi), na.rm = TRUE)

    ## Add mean value to grid cell
    cell$altitude <- mean_val_cell

    ## Append processed cell
    df_dem <<- rbind(df_dem, cell)

    print(tail(df_dem))
})

## Create folder
folder_name <- paste0("00_dem_", cellsize_name, "x", cellsize_name, "_", xmin, "_", xmax, "_", ymin, "_", ymax)
folder_path <- paste0(output_path, "DEM/", folder_name)

## Check if the folder path exists. If not, create folder!
if (!file.exists(folder_path)) {
    dir.create(folder_path, recursive = TRUE)
    print(paste0("Folder created at:", folder_path))
} else {
    print(paste0("Folder already exists at:", folder_path))
}

## Convert data frame/table into spatial feature object
df_dem_sf <- st_as_sf(df_dem)

## Export the new data frame as shapefile
st_write(
    obj = df_dem_sf,
    dsn = paste0(folder_path, "/01_dem_grid_", cellsize_name, "x", cellsize_name, "_", xmin, "_", xmax, "_", ymin, "_", ymax, ".shp"),
    layer = paste0("01_dem_grid_", cellsize_name, "x", cellsize_name, "_", xmin, "_", xmax, "_", ymin, "_", ymax, ".shp")
)
print(paste0("Saved shapefile to:", folder_path))

## Export shapefile
print("Export shapefile")
st_write(df_dem_sf, file.path(folder_path, paste0("01_dem_grid_", cellsize_name, "x", cellsize_name, "_", xmin, "_", xmax, "_", ymin, "_", ymax, ".shp")))

## Rasterize and export
print("Rasterize shapefile")
sf_raster <- st_rasterize(df_dem_sf %>% dplyr::select(altitude, geometry))
print("Export raster file")
write_stars(sf_raster, file.path(folder_path, paste0("02_dem_raster_", cellsize_name, "x", cellsize_name, "_", xmin, "_", xmax, "_", ymin, "_", ymax, ".tif")))

print("Complete!")