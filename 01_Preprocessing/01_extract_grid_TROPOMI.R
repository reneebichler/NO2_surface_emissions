## ------------------------------------------------------------------------------------
## Description
## ------------------------------------------------------------------------------------

## coming soon...

## ------------------------------------------------------------------------------------
## Libraries
## ------------------------------------------------------------------------------------

library(terra)
library(stars)

## To avoid the following error when applying st_intersection()
## Error in wk_handle.wk_wkb(wkb, s2_geography_writer(oriented = oriented,  : 
sf::sf_use_s2(FALSE)

## ------------------------------------------------------------------------------------
## Variables
## ------------------------------------------------------------------------------------

## Input
raster_path <- "/proj/ie/proj/Wellcome-ZEAS/RemoteSensing/DATA/Sentinel-5P/CONUS_S5P_OFFL_L3_NO2_ym_2020-01-01_2020-12-31.tif"
polygon_path <- "/proj/ie/proj/Wellcome-ZEAS/RemoteSensing/DATA/GEODATA/s_18mr25/CONUS.shp"

## Output
path_out <- "/proj/ie/proj/Wellcome-ZEAS/RemoteSensing/Results/Grid/"

## ------------------------------------------------------------------------------------
## Main
## ------------------------------------------------------------------------------------

## Read raster file
raster <- rast(raster_path)

## Read the polygon file
print(paste0("Read polygon: ", polygon_path))
polygon_sf <- st_read(polygon_path)

## Make sure the polygon grid is in 4326
polygon_sf <- st_transform(polygon_sf, crs = "EPSG:4326")

print("Convert the polygon into a vector feature")
clip_vect <- vect(polygon_sf)

## Crop and mask
print("Crop and mask the input grid based on the polygon")
cropped <- crop(raster, clip_vect)
clipped <- mask(cropped, clip_vect)

## Convert raster to polygon
print("Convert raster to polygon to extract the grid")
grid_sf <- stars:::st_as_sf.stars(stars::st_as_stars(clipped), point = FALSE, merge = FALSE, connect8 = TRUE)

## Make sure the polygon grid is in 4326 
grid_sf <- st_transform(grid_sf, crs = "EPSG:4326")

## ToDo: Create folder
polygon_split <- strsplit(polygon_path, split = "/")
polygon_name <- gsub(".shp", "", polygon_split[[1]][length(polygon_split[[1]])])
folder_name <- paste0("00_", polygon_name, "_S5P_TROPOMI_L3_1km_grid")
folder_path <- paste0(path_out, folder_name)

## Check if the folder path exists. If not, create folder!
if (!file.exists(folder_path)) {
  dir.create(folder_path, recursive = TRUE)
  cat("Folder created at:", folder_path, "\n")
} else {
  cat("Folder already exists at:", folder_path, "\n")
}

## Export the shapefile with lat/lon centerpoint information
filename1 <- paste0("01_", polygon_name, "_S5P_TROPOMI_L3_1km_grid.shp")
st_write(
    st_as_sf(grid_sf),
    dsn = paste0(folder_path, "/"),
    layer = filename1,
    driver = "ESRI Shapefile",
    delete_layer = TRUE
)
print(paste0("Process: ", folder_path, "/", filename1))
print("Complete!")