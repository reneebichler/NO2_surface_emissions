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
output_path <- "/proj/ie/proj/Wellcome-ZEAS/RemoteSensing/Results/DEM/"

## ------------------------------------------------------------------------------------
## Main
## ------------------------------------------------------------------------------------

## calculate mean value for each new grid cell using DEM
#tif <- terra::rast(paste0(input_path, "/Results/DEM/CONUS_LCZ_map_NLCD_v1.0_epsg4326.tif"))
tif <- terra:: rast(paste0(input_path, "Results/DEM/CONUS_merged_all_dem.tif"))

cellsize_name <- as.character(cellsize)

## Load grid file (shp)
grid <- read_sf(
    paste0(
        input_path,
        "Results/Grid/test_grid/00_grid_", cellsize_name, "x", cellsize_name, "_", xmin, "_", xmax, "_", ymin, "_", ymax,
        "/03_grid_", cellsize_name, "x", cellsize_name, "_", xmin, "_", xmax, "_", ymin, "_", ymax, "_intersect_buffer_", buffer, "m.shp"
    )
)

## Add a new column called "new_class" to grid (sf)
grid["dem_alt"] <- NA

## Create an empty data frame to store the new rows with the new class column
df_dem <- data.table()

## calculate mean value for each new grid cell using DEM
for (i in seq(1, nrow(grid))) {

    print(paste0("Process grid cell: ", i, "/", as.character(nrow(grid))))

    ## Show which grid cell is getting processed
    #ggplot() +
    #geom_sf(data = grid) +
    #geom_sf(data = grid[i,], fill = "red")

    ## Retrieve grid cell
    cell <- grid[i,]

    ## Crop and mask tif file
    aoi1 <- mask(crop(tif, cell), cell)

    ## Rename spatial raster
    names(aoi1) <- "value"
    
    ## Convert terra raster object to data frame
    aoi <- as.data.frame(aoi1, xy = TRUE)

    ## Calculate mean value for grid cell
    mean_val_rast = mean(aoi$value, na.rm = TRUE)

    ## Replace NA value with mean value
    grid$dem_alt[i] <- mean_val_rast

    df_dem <- rbind(df_dem, grid[i,])
    print(tail(df_dem))
}

## Create folder
folder_name <- paste0("00_dem_", cellsize_name, "x", cellsize_name, "_", xmin, "_", xmax, "_", ymin, "_", ymax)
folder_path <- paste0(output_path, folder_name)

## Check if the folder path exists. If not, create folder!
if (!file.exists(folder_path)) {
  dir.create(folder_path, recursive = TRUE)
  cat("Folder created at:", folder_path, "\n")
} else {
  cat("Folder already exists at:", folder_path, "\n")
}

## Export the new data frame as shapefile
st_write(
    obj = df_dem,
    dsn = paste0(folder_path, "/01_dem_grid_", cellsize_name, "x", cellsize_name, "_", xmin, "_", xmax, "_", ymin, "_", ymax, ".shp"),
    layer = paste0("01_dem_grid_", cellsize_name, "x", cellsize_name, "_", xmin, "_", xmax, "_", ymin, "_", ymax, ".shp")
)
print(paste0("Save: ", folder_path, "/01_dem_grid_", cellsize_name, "x", cellsize_name, "_", xmin, "_", xmax, "_", ymin, "_", ymax, ".shp"))

## Rasterize the data frame with the geometry object
## ToDo!!
sf_raster <- st_rasterize(df_dem %>% dplyr::select(class, cname, fname, oname, geometry))

## Export the raster file
write_stars(sf_raster, paste0(folder_path, "/02_dem_raster_", cellsize_name, "x", cellsize_name, "_", xmin, "_", xmax, "_", ymin, "_", ymax, ".tif"))
print(paste0("Save: ", folder_path, "/02_dem_raster_", cellsize_name, "x", cellsize_name, "_", xmin, "_", xmax, "_", ymin, "_", ymax, ".tif"))