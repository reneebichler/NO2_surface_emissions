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

cellsize <- 1

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

## Split grid into batches
grid_batches <- split(grid, seq(nrow(grid)))

print("Apply batch processing")

## Preallocate a list to store results
results <- vector("list", length(grid_batches))

## Batch processing
results <- lapply(seq_along(grid_batches), function(i) {
    cell <- grid_batches[[i]]
  
    # Crop and mask raster
    aoi <- mask(crop(tif, vect(cell)), cell)

    ## Calculate mean value
    mean_val_cell <- mean(terra::values(aoi), na.rm = TRUE)

    if (!is.na(mean_val_cell)) {

        ## Add mean value to grid cell
        cell$altitude <- mean_val_cell
    
    } else {
      cell$altitude <- -999
    }

    print(cell)
    return(cell)
})

## Combine results into a single data.table
df_dem <- rbindlist(results)

## Convert to spatial feature object
df_dem_sf <- st_as_sf(df_dem)

## Create output folder
folder_name <- paste0("00_dem_", cellsize_name, "x", cellsize_name, "_", xmin, "_", xmax, "_", ymin, "_", ymax)
folder_path <- file.path(output_path, "DEM", folder_name)

if (!file.exists(folder_path)) {
    dir.create(folder_path, recursive = TRUE)
    print(paste0("Folder created at: ", folder_path))
} else {
    print(paste0("Folder already exists at: ", folder_path))
}

## Export shapefile
print("Export shapefile")
st_write(df_dem_sf, file.path(folder_path, paste0("01_dem_grid_", cellsize_name, "x", cellsize_name, "_", xmin, "_", xmax, "_", ymin, "_", ymax, ".shp")))

## Give permission to folder
system(paste0("chmod -R 777 ", folder_path))

print("Complete!")