## ------------------------------------------------------------------------------------
## Libraries
## ------------------------------------------------------------------------------------

library(sf)
library(terra)
library(stringr)

## ------------------------------------------------------------------------------------
## Variables
## ------------------------------------------------------------------------------------

## Input
state_path <- "/proj/ie/proj/Wellcome-ZEAS/RemoteSensing/DATA/GEODATA/s_18mr25/s_18mr25.shp"
dem_path <- "/proj/ie/proj/Wellcome-ZEAS/RemoteSensing/DATA/NASA_DEM"
output_path <- "/proj/ie/proj/Wellcome-ZEAS/RemoteSensing/Results"

## Output
nasa_dem_out <- "/proj/ie/proj/Wellcome-ZEAS/RemoteSensing/Results/DEM"

## ------------------------------------------------------------------------------------
## Main
## ------------------------------------------------------------------------------------

## Create raster that combines all created tif files
tif_files <- list.files(nasa_dem_out, pattern = "\\.tif$", full.names = TRUE, recursive = TRUE)

## Read the DEM files into a list of spatial raster objects
raster_all <- lapply(tif_files, rast)

## Merge the rasters into a single spatial raster
merged_raster_all <- do.call(mosaic, raster_all)

## Save merged raster
writeRaster(merged_raster_all, paste0(nasa_dem_out, "/CONUS_merged_all_dem.tif"), overwrite = TRUE, verbose = TRUE)
print(paste0("Save: ", nasa_dem_out, "/CONUS_merged_all_dem.tif"))

print("Complete!")