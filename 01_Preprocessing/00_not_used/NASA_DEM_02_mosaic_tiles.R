## ------------------------------------------------------------------------------------
## Libraries
## ------------------------------------------------------------------------------------

library(sf)
library(terra)
library(stringr)

## ------------------------------------------------------------------------------------
## Variables
## ------------------------------------------------------------------------------------

state_path <- "/proj/ie/proj/Wellcome-ZEAS/RemoteSensing/DATA/GEODATA/s_18mr25/s_18mr25.shp"
dem_path <- "/proj/ie/proj/Wellcome-ZEAS/RemoteSensing/DATA/NASA_DEM"
output_path <- "/proj/ie/proj/Wellcome-ZEAS/RemoteSensing/Results"
nasa_dem_out <- "/proj/ie/proj/Wellcome-ZEAS/RemoteSensing/Results/DEM"

## ------------------------------------------------------------------------------------
## Main
## ------------------------------------------------------------------------------------

## Read shapefile as spatial feature
polygon_sf <- read_sf(state_path)

## Convert polygon to EPSG 4326
polygon_sf <- st_transform(polygon_sf, crs = "EPSG:4326")

## List all .hgt files in folder
print("Filelist in progress ...")
dem_l <- list.files(dem_path, pattern = "\\.hgt$", full.names = TRUE, recursive = TRUE)

## Convert files in list to a raster
dem_rast <- lapply(dem_l, rast)

## The fisrt mosaic file is the first raster file
## Later this file gets updated through the foor loop
mosaic_file <- dem_rast[[1]]

## Creat loop for mosaic
for (i in seq(2, length(dem_l))) {

    print(paste0("Processing tile ", i, " / ", length(dem_l)))

    ## Merge the rasters into a single spatial raster
    merged_raster_all <- mosaic(dem_rast[[i]], mosaic_file)

    ## Update the merged mosaic file for the next loop
    mosaic_file <- merged_raster_all
}

## Save merged raster
writeRaster(mosaic_file, paste0(nasa_dem_out, "/CONUS_merged_dem_tiles.tif"), overwrite = TRUE, verbose = TRUE)
print(paste0("Save: ", nasa_dem_out, "/CONUS_merged_dem_tiles.tif"))