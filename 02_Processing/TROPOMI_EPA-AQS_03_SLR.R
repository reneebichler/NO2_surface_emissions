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
library(hydroTSM)
library(ggpmisc)
library(cowplot)

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

theme_1 <- theme_bw() +
theme(
  panel.border = element_blank(),
  panel.spacing = unit(2, "lines"),
  plot.title = element_text(hjust = 0.5, size = 24, color = "grey25"),
  legend.position = "bottom",
  legend.box.spacing = unit(0.5, "cm"),
  legend.title = element_text(size = 20, color = "grey25"),
  legend.text = element_text(size = 18, color = "grey25"),
  axis.text = element_text(size =  18, color = "grey25"),
  axis.title = element_text(size = 18, color = "grey25"),
  axis.title.y = element_text(vjust = 2),
  axis.title.x = element_text(vjust = -1),
  strip.text = element_text(size = 18, color = "grey25"),
  strip.background = element_rect(fill = "grey95", color = "white"),
  aspect.ratio =  1
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
        
        ## Order data frame by date
        df_ts_trop <- df_ts_trop[order(as.Date(df_ts_trop$date, format="%Y-%m-%d")),]

        ## Order data frame by date
        df_ts_aqs <- df_ts_aqs[order(as.Date(df_ts_aqs$date_local, format="%Y-%m-%d")),]

        ## add a merge column based on the date
        df_ts_trop["merge"] <- df_ts_trop$date
        df_ts_aqs["merge"] <- df_ts_aqs$date_local

        ## merge the satellite observations and EPA-AQS
        df_reg_plot <- merge(df_ts_trop, df_ts_aqs, by="merge")
        df_reg_plot["season"] <- time2season(as.Date(df_reg_plot$merge), out.fmt="seasons", type="default")

        ## Replace "autumm" with "autumn" (wrong spelling in library)
        df_reg_plot$season <- gsub("autumm", "autumn", df_reg_plot$season)
        browser()
        ## Outlier detection EPA-AQS
        outliers_aqs <- boxplot.stats(df_reg_plot$sample_measurement)$out
        outliers_aqs_idx <- which(df_reg_plot$sample_measurement %in% c(outliers_aqs))
        df_reg_plot["sample_meas_woo"] <- df_reg_plot$sample_measurement
        test <- df_reg_plot[outliers_aqs_idx, ]

        ## Outlier detection satellite
        #https://statsandr.com/blog/outliers-detection-in-r/
        outliers_sat <- boxplot.stats(df_reg_plot$mean)$out
        outliers_sat_idx <- which(df_reg_plot$mean %in% c(outliers_sat))
        df_reg_plot["mean_woo"] <- df_reg_plot$mean
        ## Not working!!
        df_reg_plot["mean"][outliers_sat_idx,] <- NA

        ## Define x and y-axis limits
        sat_min <- min(df_reg_plot$mean)
        sat_max <- max(df_reg_plot$mean)
        aqs_min <- min(df_reg_plot$sample_measurement)
        aqs_max <- max(df_reg_plot$sample_measurement)

        ## List with correlation methods
        method_l <- c("pearson", "spearman", "kendall")

        for (m in method_l) {

            ## Single linear regression plot
            reg_p_wo <- ggplot(data=df_reg_plot, aes(x=sample_measurement, y=mean)) +
            geom_point(aes(color=factor(season)), size=2) +

            xlab("S5P tropospheric NO2 [Pmolecules/cm^2]") +
            ylab("EPA-AQS [ppb]") +

            ggtitle(paste("With Outliers")) +

            scale_color_manual(
                name="Seasons",
                limits=c(
                    "spring","summer","autumn","winter"
                ),
                labels=c(
                    "spring"="Spring (MAM)", 
                    "summer"="Summer (JJA)",
                    "autumn"="Autumn (SON)",
                    "winter"="Winter (DJF)"
                ),
                values=c(
                    "spring"="#ff0000",
                    "summer"="#a00000",
                    "autumn"="#0088ff",
                    "winter"="#003d73"
                )
            ) +

            coord_fixed() +

            geom_smooth(method="lm", se=TRUE, fullrange=FALSE, color="black", linetype="dashed") +
            stat_poly_eq(use_label(c("eq")), label.y=0.90, size=6) +
            stat_poly_eq(use_label(c("R2", "R2.confint")), label.y=0.85, size=6) +
            stat_correlation(method=m, label.y=0.80, size=6) +
            stat_poly_eq(use_label(c("n")), label.y=0.75, size=6) +
            theme_1
        
            boxplot_wo <- ggplot(data=df_reg_plot, aes(x=sample_measurement, y=mean)) +
            geom_boxplot(aes(color=factor(season)), alpha=0.3) +

            #xlim(temis_min, temis_max) +
            #ylim(cams_min, cams_max) +
            xlab("S5P tropospheric NO2 [Pmolecules/cm^2]") +
            ylab("EPA-AQS [ppb]") +

            ggtitle(paste("With Outliers")) +
            scale_color_manual(name="Seasons", values=c("#0088ff","#ff0000","#a00000","#003d73")) +
            theme_1

            pg <- plot_grid(reg_p_wo, boxplot_wo, labels="AUTO", ncol=2)
            browser()         

            ggsave(file=paste0(path_out_slr,"/TROPOMI_test_",site_number, "_", m,".png"), plot=pg, width=16, height=10, dpi=300)
        }
    }
}