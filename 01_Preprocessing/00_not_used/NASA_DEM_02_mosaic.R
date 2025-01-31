## ------------------------------------------------------------------------------------
## Libraries
## ------------------------------------------------------------------------------------

library(sf)
library(terra)
library(stringr)

## ------------------------------------------------------------------------------------
## Variables
## ------------------------------------------------------------------------------------

<<<<<<<< HEAD:01_Preprocessing/00_not_used/NASA_DEM_02_mosaic.R
state_path <- "/proj/ie/proj/Wellcome-ZEAS/RemoteSensing/DATA/GEODATA/s_18mr25/s_18mr25.shp"
dem_path <- "/proj/ie/proj/Wellcome-ZEAS/RemoteSensing/DATA/NASA_DEM"
output_path <- "/proj/ie/proj/Wellcome-ZEAS/RemoteSensing/Results"
========
## Input
state_path <- "/proj/ie/proj/Wellcome-ZEAS/RemoteSensing/DATA/GEODATA/s_18mr25/s_18mr25.shp"
dem_path <- "/proj/ie/proj/Wellcome-ZEAS/RemoteSensing/DATA/NASA_DEM"
output_path <- "/proj/ie/proj/Wellcome-ZEAS/RemoteSensing/Results"

## Output
>>>>>>>> b16c90554cdf44630a91eee6ff11a373b9abc05d:01_Preprocessing/DEM/NASA_DEM_02_mosaic_states.R
nasa_dem_out <- "/proj/ie/proj/Wellcome-ZEAS/RemoteSensing/Results/DEM"

## ------------------------------------------------------------------------------------
## Main
## ------------------------------------------------------------------------------------

## Read shapefile as spatial feature
polygon_sf <- read_sf(state_path)

## Filter only for CONUS and exclude the following
exclude <- c(
    "Alaska", "American Samoa", "Hawaii", "Puerto Rico", "Marshall Islands",
    "Fed States of Micronesia", "Rhode Island", "Virgin Islands", "Guam", "Palau",
    "Northern Mariana Islands"
)

## Remove all areas in exclude from polygon
polygon_sf <- polygon_sf %>% filter(!polygon_sf$NAME %in% exclude)

## Convert polygon to EPSG 4326
polygon_sf <- st_transform(polygon_sf, crs = "EPSG:4326")

## List all .hgt files in folder
print("Filelist in progress ...")
dem_l <- list.files(dem_path, pattern = "\\.hgt$", full.names = TRUE, recursive = TRUE)

## Store the file names that belong to a certain bounding box
dem_aoi_df <- data.frame()

for (polygon_idx in seq(1, length(polygon_sf$NAME))) {

    polygon <- polygon_sf$NAME[polygon_idx]
    state <- polygon_sf$STATE[polygon_idx]
    fips <- polygon_sf$FIPS[polygon_idx]

    print(paste0("Process: ", polygon, " / ", state, " / ", fips))
    #print(paste0("Process: ", polygon))

    polygon_dem_df <- data.frame()

    if (polygon == "Alaska") {
        print("Alaska was skipped since it's not part of CONUS!")

    } else {

        ## Subset state from multipolygon
        aoi <- polygon_sf[polygon_sf$NAME == polygon, "geometry"][[1]][[1]]

        ## Convert aoi to a vector
        aoi <- vect(aoi)
        terra::crs(aoi) <- "EPSG:4326"

        ## Create a simple bounding box based on the input polygon
        boundingbox <- st_bbox(aoi)

        lat_north <- boundingbox$ymax
        lat_south <- boundingbox$ymin
        lon_east <- boundingbox$xmax
        lon_west <- boundingbox$xmin
        
        i = 1

        ## Check if DEM is in bounding box
        for (dem  in dem_l) {

            print(paste0("Process: ", polygon, " ", dem, " idx: ", i, "/", length(dem_l)))

            dem_name <- tail(str_split(dem, pattern = "/")[[1]], 1)
            dem_name <- gsub(".hgt", "", dem_name)
            dem_name <- gsub("n", "", dem_name)
            dem_name <- gsub("e", ", e", dem_name)
            dem_name <- gsub("e", "", dem_name)
            dem_name <- gsub("s", "-", dem_name)
            dem_name <- gsub("w", ", w", dem_name)
            dem_name <- gsub("w", "-", dem_name)

            #print(dem_name)

            lat <- as.numeric(str_split(dem_name, ",")[[1]][1])
            lon <- as.numeric(str_split(dem_name, ",")[[1]][2])

            if (all(lat <= lat_north+1 & lat >= lat_south-1 & lon >= lon_west-1 & lon <= lon_east+1)) {
                dem_aoi_row <- data.frame(
                    file = dem,
                    name = polygon,
                    state = state,
                    fips = fips,
                    lat = lat,
                    lat_north = lat_north,
                    lat_south = lat_south,
                    lon = lon,
                    lon_east = lon_east,
                    lon_west = lon_west
                )

                print(dem_aoi_row)
                polygon_dem_df <- rbind(polygon_dem_df, dem_aoi_row)
                dem_aoi_df <- rbind(dem_aoi_df, dem_aoi_row)

            } else {
                print(paste0(dem_name, " not in bounding box"))
            }
            i = i + 1
        }

        ## Create mosaic based on bounding box
        ## Get the list of .hgt files
        dem_files <- polygon_dem_df$file

        ## Read the DEM files into a list of spatial raster objects # nolint
        rasters <- lapply(dem_files, rast)

        ## Merge the rasters into a single spatial raster # nolint
        merged_raster <- do.call(mosaic, rasters)

        #terraOptions(tempdir = "/Volumes/MyBook2") # nolint

        ## Crop the raster to polygon
        merged_raster_crop <- terra::crop(merged_raster, aoi, snap = "near")

        ## Mask values outside the polygon
        merged_raster_crop_mask <- terra::mask(merged_raster_crop, aoi)

        ## Replace space with "_" in polygon name
        polygon_name <- gsub(" ", "_", polygon)

        ## Save merged raster
        writeRaster(merged_raster_crop_mask, paste0(nasa_dem_out, "/", state, "_merged_orig_dem.tif"), overwrite = TRUE, verbose = TRUE)
        print(paste0("Save: ", nasa_dem_out, "/", state, "_merged_orig_dem.tif"))
    }
}

## Reset the rownames
rownames(dem_aoi_df) <- NULL

## Save data frame as csv
write.csv(dem_aoi_df, paste0(nasa_dem_out, "/dem_aoi_df.csv"))

<<<<<<<< HEAD:01_Preprocessing/00_not_used/NASA_DEM_02_mosaic.R
## Create raster that combines all created tif files
tif_files <- list.files(paste0(nasa_dem_out, "/tif"), full.names = TRUE, recursive = TRUE)

## Read the DEM files into a list of spatial raster objects
raster_all <- lapply(tif_files, rast)

## Merge the rasters into a single spatial raster
merged_raster_all <- do.call(mosaic, raster_all)

## Note if merged_raster_all fails try to either group the mosiac as follows
## GR1: AZ, CA, ID, WA, UT, OR, NV
## GR2: CO, KS, MT, ND, NE, NM, OK, SD, TX, WY
## GR3: AL, AR, IA, IL, IN, KY, LA, MI, MN, MO, MS, OH, TN, WI
## GR4: FL, GA, SC, NC, VA, WV, MD, DE, PA, NJ, NY, CT, RI, MA, NH, VT, ME, DC

## Not necessary for CONUS
## GR5: Alaska, HI, VI, PW, PR, MP, MH, GU, FM, AS

## 01/09/25: Files were merged manually in QGIS (using GR1-4)

## Save merged raster
writeRaster(merged_raster_all, paste0(nasa_dem_out, "/CONUS_merged_all_dem.tif"), overwrite = TRUE, verbose = TRUE)
print(paste0("Save: ", nasa_dem_out, "/CONUS_merged_all_dem.tif"))
========
print("Complete!")
>>>>>>>> b16c90554cdf44630a91eee6ff11a373b9abc05d:01_Preprocessing/DEM/NASA_DEM_02_mosaic_states.R
