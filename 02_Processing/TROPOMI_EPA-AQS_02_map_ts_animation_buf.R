## ------------------------------------------------------------------------------------
## Libraries
## ------------------------------------------------------------------------------------

library(gganimate)
library(ggplot2)
library(scico)
library(sf)
library(terra)
library(tidyterra)
library(zoo)
library(tidyverse)
library(stringr)
library(scales)
library(cowplot)
library(magrittr)

## ------------------------------------------------------------------------------------
## Variables
## ------------------------------------------------------------------------------------

home_wd <- getwd()

storage <- "/Volumes/MyBook"
#storage <- "/Users/reneebichler/surface"

home_wd <- getwd()
source("/Users/reneebichler/GitHub/NO2_ML_analysis/01_Preprocessing/process_cams_era5_d.R")

var_name_list <- c("Sentinel-5P")

time_resolution <- "D"
instrument <- "TROPOMI"
var <- "tropospheric_NO2_column_number_density"

pollutant <- "42602"
site_number <- "2002"
aoi_l <- c("site_2002")

## ------------------------------------------------------------------------------------
## Functions
## ------------------------------------------------------------------------------------

theme2 <- theme_bw() +
theme(
    legend.position="bottom", 
    legend.title=element_text(size=6), 
    legend.text=element_text(size=6), 
    legend.key.width=unit(1, "cm"),
    legend.key.height=unit(.1, "cm"),
    plot.title=element_text(hjust=0, size=6), 
    panel.border=element_blank(), 
    axis.text.y=element_text(size=6), 
    axis.text=element_text(size=6), 
    axis.ticks=element_blank(), 
    axis.title.y=element_text(color="grey45", size=8)
)

## ------------------------------------------------------------------------------------
## Main
## ------------------------------------------------------------------------------------

for (aoi in aoi_l) {

    print(paste0("Process AOI: ", aoi))

    nc_path <- paste0(storage, "/DATA")
    path_inp_trop <- paste0(storage, "/RESULTS/Surface/TROPOMI/sites/aoi_CSV")
    path_inp_aqs <- paste0(storage, "/RESULTS/EPA-AQS/CA/aoi_CSV")
    #path_out <- paste0(storage, "/RESULTS/Surface/TROPOMI/", aoi, "/aoi_PLOTS/")
    path_out_slr <- paste0(storage,"/RESULTS/Surface/TROPOMI/sites/aoi_PLOTS")
    
    aoi_keys <- c(
        'site_1004'=paste0(storage, '/RESULTS/EPA-AQS/CA/aoi_GEODATA/EPA-AQS_h_2024-01-01-2024-11-10_42602_xminlon_-119_xmaxlon_-117_yminlat_33_ymaxlat_34_1004_buf_3000.geojson'),
        'site_2002'=paste0(storage, '/RESULTS/EPA-AQS/CA/aoi_GEODATA/EPA-AQS_h_2024-01-01-2024-11-10_42602_xminlon_-119_xmaxlon_-117_yminlat_33_ymaxlat_34_2002_buf_3000.geojson')
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
        
        ## Path to original TROPOMI NetCDF
        df_path <- list.files(paste0(nc_path, "/", var_name, "/NO2/L3/OFFL"), sprintf(paste0(".nc")), recursive=TRUE, full.names=TRUE, include.dirs=TRUE)
        print(df_path)
        
        ## Read TROPOMI time series
        df_ts_trop_path <- list.files(path=path_inp_trop, pattern=paste0("^", instrument, "_\\D{1}_TVC_\\d{4}-\\d{2}-\\d{2}-\\d{4}-\\d{2}-\\d{2}_d_crop_mean_site_", site_number, ".csv$"), recursive=FALSE, full.names=TRUE, include.dirs=TRUE)
        print(df_ts_trop_path)
        df_ts_trop <- read.csv(df_ts_trop_path)
        
        ## Read EPA-AQS time series
        df_ts_aqs_path <- list.files(path=path_inp_aqs, pattern=paste0("^EPA-AQS_d_\\d{4}-\\d{2}-\\d{2}-\\d{4}-\\d{2}-\\d{2}_", pollutant, "_xminlon_-119_xmaxlon_-117_yminlat_33_ymaxlat_34_", site_number, ".csv"), recursive=FALSE, full.names=TRUE, include.dirs=TRUE)
        print(df_ts_aqs_path)
        df_ts_aqs <- read.csv(df_ts_aqs_path)
        
        ## Check for missing dates in time series
        date_range <- seq.Date(from=as.Date(df_ts_trop$date[1]), to=as.Date(df_ts_trop$date[length(df_ts_trop$date)]), by="day") 
        missing_date_l <- as.character(date_range[!date_range %in% df_ts_trop$date])

        for (md in missing_date_l) {
            print(paste0("Process missing date (daily df): ", md))
            missing_df <- data.frame(X=NA, date=as.character(md), variable="missing", level=NA, aoi=NA, n=NA, mean=NA)
            df_ts_trop <- rbind(df_ts_trop, missing_df)
        }
        
        ## Order data frame by date
        df_ts_trop <- df_ts_trop[order(as.Date(df_ts_trop$date, format="%Y-%m-%d")),]

        ## Interpolate time series
        df_ts_trop["interpl"] <- na.approx(df_ts_trop$mean, na.rm=FALSE)

        ## Subset missind date to show in the plot
        subset_md <- subset(df_ts_trop, df_ts_trop$variable == "missing")

        ## Extract the filename
        filename_ts <- str_sub(str_split(df_ts_trop_path, "/")[[1]][length(str_split(df_ts_trop_path, "/")[[1]])], end=-5)
        
        ## get raster list by cropping the polygon out of the NetCDF files
        raster_l <- get_tropomi_raster_list(polygon, df_path, var)

        plot_l <- list()
        i = 1

        for(r in raster_l) {
            raster1 <- as(r, "SpatRaster")
            print(paste0("Make plot: ", names(raster1)))

            timeinfo <- as.POSIXct(names(raster1), format="X%Y.%m.%d")
            timeinfo1 <- strftime(timeinfo, format="%Y-%m-%d")
            timeinfo2 <- strftime(timeinfo, format="%Y-%m-%d")
            print(paste0(timeinfo, " ", timeinfo1, " ", timeinfo2))
            print(paste0(names(raster1)))

            ## TROPOMI
            subset_trop_point <- df_ts_trop %>% filter(str_detect(date, timeinfo2))
            print(subset_trop_point)

            ## Subset EPA-AQS
            subset_aqs_point <- df_ts_aqs %>% filter(str_detect(date_local, timeinfo2))
            print(subset_aqs_point)

            ## Set NA value for map plot
            na.value.forplot <- "green"

            ## ggplot for map
            p_map <- ggplot() +

            ## Raster
            geom_spatraster(data=raster1) +
            scale_fill_scico(palette="vik", alpha=0.8, limits=c(min(df_ts_trop$interpl), max(df_ts_trop$interpl)), oob=squish, na.value=na.value.forplot) +
            #scale_fill_scico(palette="vik", alpha=0.8, oob=squish, na.value=na.value.forplot) +
            scale_color_manual(values=NA) + 

            ## Lat lon raster
            geom_sf(data=st_graticule(polygon), color="grey65", fill=NA, linetype="dashed", linewidth=.2) +

            ## EPA-AQS Buffer
            geom_sf(data=polygon, color="red", fill=NA, linewidth=1) +

            ## EPA-AQS Point
            geom_point(df_ts_aqs, mapping=aes(x=longitude[1], y=latitude[1]), size=2) +
            
            ## Define x and y axis limits
            #scale_x_continuous(limits=c(df_ts_aqs$longitude[1]-0.1, df_ts_aqs$longitude[1]+0.1)) +
            #scale_y_continuous(limits=c(df_ts_aqs$latitude[1]-0.1, df_ts_aqs$latitude[1]+0.1)) +
            xlab("") + ylab("") +

            ## Set coordinates
            coord_sf(crs='+proj=lonlat', expand=F) +

            guides(
                #color=guide_legend(
                #    title="NA", title.position="top",
                #    override.aes=list(fill=na.value.forplot, color=NA),
                #    order=2
                #),
                fill=guide_colorbar(
                    title="Daily NO2 Emissions [Pmolecules/cm^2]", title.position="top",
                    barwidth=12, barheight=1,
                    order=1
                )
            ) +

            ## Add title and plot theme
            ggtitle(paste0("TROPOMI observations for ", aoi, " Time: ", timeinfo1)) +
            theme2
    
            ## ggplot for time series
            p_trop_ts <- ggplot() +

            ## Highlight
            geom_point(subset_md, mapping=aes(x=as.POSIXct(date), y=interpl), color="orange", size=1.8) +

            ## Highlight
            geom_point(subset_trop_point, mapping=aes(x=as.POSIXct(date), y=interpl), color="red", size=1.8) +

            ## Interpolated data
            geom_line(df_ts_trop, mapping=aes(x=as.POSIXct(date), y=interpl), color="grey85", size=.2) +
            geom_point(df_ts_trop, mapping=aes(x=as.POSIXct(date), y=interpl), color="grey85", size=.1) +

            ## Actual observations
            geom_line(df_ts_trop, mapping=aes(x=as.POSIXct(date), y=mean), size=.2) +
            geom_point(df_ts_trop, mapping=aes(x=as.POSIXct(date), y=mean), size=.1) +

            xlab(NULL) + ylab("Pmolecules/cm^2") +
            ggtitle(paste0(filename_ts, " Time: ", timeinfo2)) +
            theme2

            ## EPA-AQS plot
            p_aqs_ts <- ggplot() +

            ## Highlight
            geom_point(subset_aqs_point, mapping=aes(x=as.POSIXct(date_local), y=sample_measurement), color="red", size=1.8) +
            
            ## Actual observations
            geom_line(df_ts_aqs, mapping=aes(x=as.POSIXct(date_local), y=sample_measurement), size=.2) +
            geom_point(df_ts_aqs, mapping=aes(x=as.POSIXct(date_local), y=sample_measurement), size=.1) +

            xlim(as.POSIXct("2024-01-01"), as.POSIXct("2024-01-31")) +

            xlab("Local") + ylab(df_ts_aqs$units_of_measure) +
            ggtitle("EPA-AQS") +
            theme2

            pg <- plot_grid(p_map, p_trop_ts, p_aqs_ts, labels="AUTO", nrow=3)

            plot_l[[i]] <- pg
            
            i = i + 1

            ggsave(paste0(path_out_slr, '/maps/TROPOMI_EPA-AQS_NO2_L3_', timeinfo1,'.png', sep=""), plot=pg, width=1500, height=1900, units="px")
            print(paste0('Save: ', path_out_slr, '/maps/TROPOMI_EPA-AQS_NO2_L3_', timeinfo1, '.png'))
        }

        ## ToDo: Create animation
    }
}