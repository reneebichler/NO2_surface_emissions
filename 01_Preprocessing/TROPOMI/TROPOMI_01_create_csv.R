## ------------------------------------------------------------------------------------
## Libraries
## ------------------------------------------------------------------------------------

library(sf)
library(stringi)

## ------------------------------------------------------------------------------------
## Variables
## ------------------------------------------------------------------------------------

storage <- "/Volumes/MyBook"
#storage <- "/Users/reneebichler/surface"

home_wd <- getwd()
source("/Users/reneebichler/GitHub/NO2_ML_analysis/01_Preprocessing/process_cams_era5_d.R")

var_name_list <- c("Sentinel-5P")
aoi_l <- c("AOI_LA_City")
time_resolution <- "D"
var_nc <- "tropospheric_NO2_column_number_density"

## ------------------------------------------------------------------------------------
## Main
## ------------------------------------------------------------------------------------

for (aoi in aoi_l) {

    print(paste0("Process AOI: ", aoi))

    nc_path <- paste0(storage, "/DATA")
    path_out <- paste0(storage, "/RESULTS/TROPOMI/", aoi, "/aoi_CSV/")
    
    aoi_keys <- c(
        'AOI_LA_City' = paste0(storage, '/DATA/GEODATA/AOI_ML/AOI_LA_City_ML_Pixel_Single.geojson')
        #'AOI_LA_City' = paste0(storage, '/DATA/GEODATA/map.geojson')
    )

    polygon_file <- aoi_keys[[aoi]]

    print(paste0("Polygon for ", aoi))
    
    ## get layername from file and remove ".geojson"
    layer_name <- gsub("\\..*","",strsplit(polygon_file, "/")[[1]][7])
    polygon <- read_sf(dsn=polygon_file)

    for (var_name in var_name_list) {

        satellite_keys <- c(
            "Sentinel-5P"="TROPOMI"
        )

        satellite <- satellite_keys[[var_name]]

        print(paste0("Process: ", var_name))

        DB <- paste0(nc_path, "/", var_name, "/NO2/L3/OFFL")
        u <- paste0(".nc")

        file_l <- list.files(DB, sprintf(u), recursive=TRUE, full.names=TRUE, include.dirs=TRUE)
        print(file_l)

        df_crop_aoi <- crop_tropomi_nc(polygon, file_l, var_nc)

        ## get start and end date
        sd <- stri_sub(names(df_crop_aoi)[3], 2, 11)
        ed <- stri_sub(tail(names(df_crop_aoi),1), 2, 11)
        
        #print(paste0("UTC time: ", utc, " Start date: ", sd,  " and end date: ", ed))
        write.csv(df_crop_aoi, file=paste0(path_out, "/", satellite, "_", time_resolution, "_TVC_", sd, "-", ed, "_crop_", aoi, ".csv"))
        print(paste0("Saving: ", satellite, "_", time_resolution, "_TVC_", sd, "-", ed, "_crop_", aoi, ".csv"))

        ml_level <- 1

        ## calculate daily mean based on daily data for each utc zone
        df_d_mean_aoi <- generate_d_mean_df(df_crop_aoi, var_nc, aoi, ml_level)
        write.csv(df_d_mean_aoi, file=paste0(path_out, "/", satellite, "_", time_resolution, "_TVC_", sd, "-", ed, "_d_crop_mean_", aoi, ".csv"))
        print(paste0(satellite, "_", time_resolution, "_TVC_", sd, "-", ed, "_d_crop_mean_", aoi, ".csv"))
   
        ## calculate monthly mean based on daily data for each utc zone
        df_m_mean_aoi <- generate_m_mean_df(df_crop_aoi, var_nc, aoi, ml_level)
        write.csv(df_m_mean_aoi, file=paste0(path_out, "/", satellite, "_", time_resolution, "_TVC_", sd, "-", ed, "_m_crop_mean_", aoi, ".csv"))
        print(paste0(satellite, "_", time_resolution, "_TVC_", sd, "-", ed, "_m_crop_mean_", aoi, ".csv"))
    }
}