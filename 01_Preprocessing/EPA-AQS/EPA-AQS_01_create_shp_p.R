## ------------------------------------------------------------------------------------
## Libraries
## ------------------------------------------------------------------------------------

library(sf)

## ------------------------------------------------------------------------------------
## Variables
## ------------------------------------------------------------------------------------

## Input
folder_path <- "/proj/ie/proj/Wellcome-ZEAS/RemoteSensing/DATA/EPA-AQS/"

## Output
path_out <- "/proj/ie/proj/Wellcome-ZEAS/RemoteSensing/Results/EPA-AQS"

pollutant <- "42602"

xmin <- -125    # -180
xmax <- -67     # 180
ymin <- 25      # -90
ymax <- 49      # 90

## ------------------------------------------------------------------------------------
## Main
## ------------------------------------------------------------------------------------

filename_p2 <- paste0("xminlon_", xmin, "_xmaxlon_", xmax, "_yminlat_", ymin, "_ymaxlat_", ymax)
folder_path1 <- paste0(folder_path, "bounding_box_", filename_p2)
folder_path2 <- paste0(path_out, "bounding_box_", filename_p2)

## List files
df_path <- list.files(path = folder_path1, pattern = paste0("EPA-AQS_h_\\d{4}-\\d{2}-\\d{2}-\\d{4}-\\d{2}-\\d{2}_", pollutant, "_xminlon_", xmin, "_xmaxlon_", xmax, "_yminlat_", ymin, "_ymaxlat_", ymax, ".csv"), recursive = FALSE, full.names = TRUE, include.dirs = TRUE)

## Merge all csv file in one data frame
print("Read all files in the list of files.")
df <- do.call(rbind, lapply(df_path, read.csv))

## Create a list of coordinate pairs
df["coords"] <- paste0(df$latitude, ",", df$longitude)
coord_l <- unique(df$coords)

df_unique_latlon <- data.frame()
i = 1

for (coords in coord_l) {
    print(paste0(i, " / ", length(coord_l)))
    print(paste0("Process lat/lon: ", coords))

    coords_split <- strsplit(coords, split = ",")
    lat <- coords_split[[1]][1]
    lon <- coords_split[[1]][2]

    df_sub <- subset(df, subset = latitude == lat & longitude == lon)
    df_latlon <- data.frame("latitude" = unique(lat), "longitude" = unique(lon))

    print(df_latlon)
    i = i + 1
    df_unique_latlon <- rbind(df_unique_latlon, df_latlon)
}

## Check if the folder path exists. If not, create folder!
if (!file.exists(folder_path2)) {
    dir.create(folder_path1, recursive = TRUE)
    cat("Folder created at:", folder_path2, "\n")
} else {
    cat("Folder already exists at:", folder_path2, "\n")
}

## Create spatial points data frame
write.csv(df_unique_latlon, file = paste0(folder_path2, "/unique_lat_lon.csv"))
print(paste0("Saving: ", paste0(folder_path2, "/unique_lat_lon.csv")))

## xxxx
df_unique_latlon <- read.csv("/proj/ie/proj/Wellcome-ZEAS/RemoteSensing/Results/EPA-AQS/bounding_box_xminlon_-125_xmaxlon_-67_yminlat_25_ymaxlat_49/unique_lat_lon.csv")

## Convert to sf object
sf_points <- st_as_sf(df_unique_latlon, coords = c("longitude", "latitude"), crs = 4326)

## Define output path
output_shapefile <- paste0(folder_path2, "/unique_lat_lon.shp")

## Write the shapefile
st_write(sf_points, output_shapefile, delete_layer = TRUE)

## Print message
print(paste0("Shapefile saved at: ", output_shapefile))