## ------------------------------------------------------------------------------------
## Libraries
## ------------------------------------------------------------------------------------

## Source: https://stackoverflow.com/questions/21977720/r-finding-closest-neighboring-point-and-number-of-neighbors-within-a-given-rad (last access 11/20/2024)

library(sf)
library(terra)
library(stringr)
library(stringi)

## ------------------------------------------------------------------------------------
## Variables
## ------------------------------------------------------------------------------------

source("/Users/reneebichler/GitHub/NO2_ML_analysis/01_Preprocessing/process_cams_era5_d.R")

## Variables
dist <- 1
pollutant <- "42602"
site <- "2002"
aqs_buffer <- 3000

var_name <- c("Sentinel-5P")
instrument <- "TROPOMI"
var_nc <- "tropospheric_NO2_column_number_density"
time_resolution <- "D"

storage <- "/Volumes/MyBook"

path_inp <- paste0(storage,"/RESULTS/EPA-AQS/CA/aoi_CSV")
path_out <- paste0(storage,"/RESULTS/EPA-AQS/CA/aoi_GEODATA")

path_out_slr <- paste0(storage,"/RESULTS/Surface/TROPOMI/sites/aoi_CSV")

nc_path <- paste0(storage, "/DATA")

## ------------------------------------------------------------------------------------
## Main
## ------------------------------------------------------------------------------------

## Read EPA-AQS data
df_aqs_path <- list.files(path=path_inp, pattern=paste0("EPA-AQS_h_\\d{4}-\\d{2}-\\d{2}-\\d{4}-\\d{2}-\\d{2}_", pollutant, "_xminlon_-119_xmaxlon_-117_yminlat_33_ymaxlat_34_", site, ".csv"), recursive=FALSE, full.names=TRUE, include.dirs=TRUE)
aqs_df <- read.csv(df_aqs_path)

## Get filename from EPA-AQSinput file
df_aqs_path_split <- strsplit(df_aqs_path, split="/")
filename <- paste0(str_sub(df_aqs_path_split[[1]][length(df_aqs_path_split[[1]])], end=-5), '_buf_', as.character(aqs_buffer))

## Create point in terra
p <- paste0("POINT (", aqs_df$longitude[1]," ", aqs_df$latitude[1],")")
point_terra <- vect(p, crs="+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs")

## Create a buffer around the point/site [width in m]
print("Create buffer around spatial point object")
polygon <- buffer(point_terra, width=aqs_buffer)
plot(polygon)
plot(polygon, border="red", add=TRUE, lwd=3.5)

## Export the shapefile
writeVector(polygon, filename=paste0(path_out, "/", filename, ".geojson"), filetype="GeoJSON", overwrite=TRUE)

polygon_sf <- st_as_sf(polygon)

## List TROPOMI files
DB <- paste0(nc_path, "/", var_name, "/NO2/L3/OFFL")
u <- paste0(".nc")
file_l <- list.files(DB, sprintf(u), recursive=TRUE, full.names=TRUE, include.dirs=TRUE)
print(file_l)

## Crop Tropomi data based on buffer geojson close to station
df_crop_aoi <- crop_tropomi_nc(polygon_sf, file_l, var_nc)

## get start and end date
sd <- stri_sub(names(df_crop_aoi)[3], 2, 11)
ed <- stri_sub(tail(names(df_crop_aoi),1), 2, 11)

#print(paste0("UTC time: ", utc, " Start date: ", sd,  " and end date: ", ed))
write.csv(df_crop_aoi, file=paste0(path_out_slr, "/", instrument, "_", time_resolution, "_TVC_", sd, "-", ed, "_crop_site_", site, ".csv"))
print(paste0("Saving: ", instrument, "_", time_resolution, "_TVC_", sd, "-", ed, "_crop_site_", site, ".csv"))

ml_level <- 1

## calculate daily mean based on daily data for each utc zone
df_d_mean_aoi <- generate_d_mean_df(df_crop_aoi, var_nc, site, ml_level)
write.csv(df_d_mean_aoi, file=paste0(path_out_slr, "/", instrument, "_", time_resolution, "_TVC_", sd, "-", ed, "_d_crop_mean_site_", site, ".csv"))
print(paste0(instrument, "_", time_resolution, "_TVC_", sd, "-", ed, "_d_crop_mean_site_", site, ".csv"))

## calculate monthly mean based on daily data for each utc zone
df_m_mean_aoi <- generate_m_mean_df(df_crop_aoi, var_nc, site, ml_level)
write.csv(df_m_mean_aoi, file=paste0(path_out_slr, "/", instrument, "_", time_resolution, "_TVC_", sd, "-", ed, "_m_crop_mean_site_", site, ".csv"))
print(paste0(instrument, "_", time_resolution, "_TVC_", sd, "-", ed, "_m_crop_mean_site_", site, ".csv"))