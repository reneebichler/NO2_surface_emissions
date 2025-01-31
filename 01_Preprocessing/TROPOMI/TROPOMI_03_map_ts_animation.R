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

## ------------------------------------------------------------------------------------
## Variables
## ------------------------------------------------------------------------------------

home_wd <- getwd()

storage <- "/Volumes/MyBook"
#storage <- "/Users/reneebichler/surface"

home_wd <- getwd()
source("/Users/reneebichler/GitHub/NO2_ML_analysis/01_Preprocessing/process_cams_era5_d.R")

var_name_list <- c("Sentinel-5P")
aoi_l <- c("AOI_LA_City")
time_resolution <- "D"
instrument <- "TROPOMI"
var <- "tropospheric_NO2_column_number_density"

## ------------------------------------------------------------------------------------
## Functions
## ------------------------------------------------------------------------------------

theme2 <- theme_bw() +
theme(
    legend.position="bottom", 
    legend.title=element_text(size=6), 
    legend.text=element_text(size=6), 
    legend.key.width=unit(1, "cm"),
    legend.key.height=unit(.4, "cm"),
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
    path_inp <- path_inp <- paste0(storage, "/RESULTS/TROPOMI/", aoi, "/aoi_CSV")
    path_out <- paste0(storage, "/RESULTS/TROPOMI/", aoi, "/aoi_PLOTS/")
    
    aoi_keys <- c(
        'AOI_LA_City'=paste0(storage, '/DATA/GEODATA/AOI_ML/AOI_LA_City_ML_Pixel_Single.geojson')
        #'AOI_LA_City'=paste0(storage, '/DATA/GEODATA/map.geojson')
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

        df_path <- list.files(paste0(nc_path, "/", var_name, "/NO2/L3/OFFL"), sprintf(paste0(".nc")), recursive=TRUE, full.names=TRUE, include.dirs=TRUE)
        print(df_path)
        
        df_ts_path <- list.files(path=path_inp, pattern=paste0('^', instrument, '_\\D{1}_TVC_\\d{4}-\\d{2}-\\d{2}-\\d{4}-\\d{2}-\\d{2}_d_crop_mean_\\D{3}_\\D{+}.csv$'), recursive=FALSE, full.names=TRUE, include.dirs=TRUE)
        df_ts <- read.csv(df_ts_path)

         ## Check for missing dates in time series
        date_range <- seq.Date(from=as.Date(df_ts$date[1]), to=as.Date(df_ts$date[length(df_ts$date)]), by="day") 
        missing_date_l <- as.character(date_range[!date_range %in% df_ts$date])

        for (md in missing_date_l) {
            print(paste0("Process missing date (daily df): ", md))
            missing_df <- data.frame(X=NA, date=as.character(md), variable="missing", level=NA, aoi=NA, n=NA, mean=NA)
            df_ts <- rbind(df_ts, missing_df)
        }

        ## Order data frame by date
        df_ts <- df_ts[order(as.Date(df_ts$date, format="%Y-%m-%d")),]

        ## Interpolate time series
        df_ts["interpl"] <- na.approx(df_ts$mean, na.rm=FALSE)

        ## Subset missind date to show in the plot
        subset_md <- subset(df_ts, df_ts$variable == "missing")

        filename_ts <- str_sub(str_split(df_ts_path, "/")[[1]][length(str_split(df_ts_path, "/")[[1]])], end=-5)

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

            #subset_point <- df_ts[(df_ts$date == timeinfo2),]
            subset_point <- df_ts %>% filter(str_detect(date, timeinfo2))
            print(subset_point)

            ## Set NA value for map plot
            na.value.forplot <- "green"

            ## ggplot for map
            p_map <- ggplot() +

            ## Raster
            geom_spatraster(data=raster1) +
            scale_fill_scico(palette="vik", alpha=0.8, limits=c(min(df_ts$interpl), max(df_ts$interpl)), oob=squish, na.value=na.value.forplot) +
            #scale_fill_scico(palette="vik", alpha=0.8, oob=squish, na.value=na.value.forplot) +
            scale_color_manual(values=NA) + 

            ## Lat lon raster
            geom_sf(data=st_graticule(polygon), color="grey65", fill=NA, linetype="dashed", linewidth=.2) +

            ## AOI
            geom_sf(data=polygon, color="white", fill=NA, linewidth=1) +
            
            ## Define x and y axis limits
            scale_x_continuous(limits=c(-119, -116.75)) +
            scale_y_continuous(limits=c(33.2, 34.7)) +

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
            p_ts <- ggplot()+

            ## Highlight
            geom_point(subset_md, mapping=aes(x=as.POSIXct(date), y=interpl), color="orange", size=1.8)+

            ## Highlight
            geom_point(subset_point, mapping=aes(x=as.POSIXct(date), y=interpl), color="red", size=1.8)+

            ## Interpolated data
            geom_line(df_ts, mapping=aes(x=as.POSIXct(date), y=interpl), color="grey85", size=.2)+
            geom_point(df_ts, mapping=aes(x=as.POSIXct(date), y=interpl), color="grey85", size=.1)+

            ## Actual observations
            geom_line(df_ts, mapping=aes(x=as.POSIXct(date), y=mean), size=.2)+
            geom_point(df_ts, mapping=aes(x=as.POSIXct(date), y=mean), size=.1)+

            xlab(NULL)+ ylab(NULL)+
            ggtitle(paste0(filename_ts, " Time: ", timeinfo2))+
            theme2

            library(cowplot)
            pg <- plot_grid(p_map, p_ts, labels="AUTO", nrow=2)

            plot_l[[i]] <- pg
            
            i = i + 1

            ggsave(paste0(path_out, '/maps/TROPOMI_NO2_L3_', timeinfo1,'.png', sep=""), plot=pg, width=1500, height=1900, units="px")
            print(paste0('Save: ', path_out, '/maps/TROPOMI_NO2_L3_', timeinfo1, '.png'))
        }

        ## ToDo: Create animation
    }
}