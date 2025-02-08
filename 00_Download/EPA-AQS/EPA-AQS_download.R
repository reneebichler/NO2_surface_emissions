## ------------------------------------------------------------------------------------
## Libraries
## ------------------------------------------------------------------------------------

library(RAQSAPI)
library(keyring)
library(leaflet)
library(ggplot2)
library(sf)
library(geojsonio)

sf::sf_use_s2(FALSE)

## ------------------------------------------------------------------------------------
## Variables
## ------------------------------------------------------------------------------------

aoi_l <- c("USA")

mmdd_l <- c("0131", "0229", "0331", "0430", "0531", "0630", "0731", "0831", "0930", "1031", "1130", "1231")
yyyy_l <- c("2019", "2020", "2021", "2022", "2023", "2024")

time_resolution <- "h"
pollutant <- "NO2"

storage <- "/proj/ie/proj/Wellcome-ZEAS/RemoteSensing/"
polygon_path <- "DATA/GEODATA/s_18mr25/CONUS.shp"

## ------------------------------------------------------------------------------------
## Main
## ------------------------------------------------------------------------------------

for (aoi in aoi_l) {

    ## Create folder path
    folder_name <- aoi
    folder_path <- paste0(storage, "DATA/EPA-AQS/")

    ## Check if the folder path exists. If not, create folder!
    if (!file.exists(folder_path)) {
        dir.create(folder_path, recursive = TRUE)
        cat("Folder created at:", folder_path, "\n")
    } else {
        cat("Folder already exists at:", folder_path, "\n")
    }

    ## Set up the key dictionary for different pollutants
    pollutant_keys <- c(
        "NO2" = "42602"
    )

    for (yyyy in yyyy_l) {
        for (mmdd in mmdd_l) {

            ed <- paste0(yyyy, mmdd)
            sd <- gsub(".{2}$", "01", ed)

            print(paste0("Year: ", yyyy, " Start: ", sd, " End: ", ed))

            ## Convert the start and end date into a date object
            sd <- as.Date(sd, format = "%Y%m%d")
            ed <- as.Date(ed, format = "%Y%m%d")

            ## Read the polygon file
            #polygon <- st_read("/Users/reneebichler/surface/DATA/GEODATA/map.geojson") 
            polygon <- st_read(paste0(storage, polygon_path))

            ## Convert the polygon to a bounding box
            bounding_box <- st_bbox(polygon)

            ## Optionally, convert the bounding box to an `sf` object for spatial operations
            boundingbox <- st_as_sfc(bounding_box)

            ## Retrieve the x and y coordinates from the new bounding box
            boundingbox_coord <- as.data.frame(st_coordinates(boundingbox))

            minlat = min(boundingbox_coord$Y)
            maxlat = max(boundingbox_coord$Y)
            minlon = min(boundingbox_coord$X)
            maxlon = max(boundingbox_coord$X)

            errors <- 0L

            res <- try({
                ## Set the credentials to access the EPA-AQS API
                RAQSAPI::aqs_credentials(username = "renee.bichler@outlook.com", key = "khakifox24")

                print("Search for data in bbox")

                ## Retrieve the EPA-AQS data that's within the bounding box
                aqs_bbox <- RAQSAPI::aqs_sampledata_by_box(
                    parameter = pollutant_keys[[pollutant]],
                    bdate = sd,
                    edate = ed,
                    minlat = minlat,
                    maxlat = maxlat,
                    minlon = minlon,
                    maxlon = maxlon
                )

                print(aqs_bbox)
                
                ## Create column with combined date and time
                aqs_bbox["datetime_local"] <- as.POSIXct(paste0(aqs_bbox$date_local, "T", aqs_bbox$time_local), format = "%Y-%m-%dT%H:%M")

                ## Extract information from boundingbox for filename
                pollutant_bbox <- unique(aqs_bbox$parameter_code)

                ## Create folder path
                filename_p1 <- paste0("EPA-AQS_", time_resolution, "_", sd, "-", ed, "_", pollutant_bbox, "_")
                filename_p2 <- paste0("xminlon_", round(minlon), "_xmaxlon_", round(maxlon), "_yminlat_", round(minlat), "_ymaxlat_", round(maxlat))
                
                folder_path1 <- paste0(folder_path, "bounding_box_", filename_p2)
                filename <- paste0(folder_path1, "/", filename_p1, filename_p2,  ".csv")

                ## Check if the folder path exists. If not, create folder!
                if (!file.exists(folder_path1)) {
                    dir.create(folder_path1, recursive = TRUE)
                    cat("Folder created at:", folder_path1, "\n")
                } else {
                    cat("Folder already exists at:", folder_path1, "\n")
                }

                print("Export csv")

                ## Save data as csv file
                write.csv(aqs_bbox, file = filename)
                print(paste0("Saving: ", filename))

                print("Export geojson")

                ## Export geojson of bounding box
                geojson_write(boundingbox, geometry = "LINESTRING", file = paste0(folder_path1, "/bounding_box_", filename_p2, ".geojson"))

            }, silent = TRUE)

            if (inherits(res, "try-error")) {
                errors <- errors + 1L
                print(paste0("Error: ", errors))

            } else {
                print("Continue!")
            }
        }
    }
}

print("Complete!")