## ------------------------------------------------------------------------------------
## Libraries
## ------------------------------------------------------------------------------------

library(ggplot2)
library(stringr)
library(plotly)
library(htmlwidgets)

## ------------------------------------------------------------------------------------
## Variables
## ------------------------------------------------------------------------------------

## Variables
path_inp <- "/proj/ie/proj/Wellcome-ZEAS/RemoteSensing/DATA/EPA-AQS/USA"
path_out <- "/proj/ie/proj/Wellcome-ZEAS/RemoteSensing/Results/EPA-AQS/USA/aoi_PLOTS"

pollutant <- "42602"

xmin <- -125
xmax <- -67
ymin <- 25
ymax <- 49

## ------------------------------------------------------------------------------------
## Functions
## ------------------------------------------------------------------------------------

spline_trend <- stat_smooth(
    method = "gam", 
    formula = y~s(x), 
    color = "steelblue3", 
    fill = "steelblue1", 
    alpha = 0.2, 
    linewidth = 0.8
)

theme2 <- theme_bw() +
theme(
    legend.position  =  "top", 
    legend.title = element_text(size = 10), 
    legend.text = element_text(size = 10), 
    plot.title = element_text(hjust = 0, size = 10), 
    panel.border = element_blank(), 
    axis.text.y = element_text(size = 10), 
    axis.text = element_text(size = 10), 
    axis.ticks = element_blank(), 
    axis.title.y = element_text(color = "grey45", size = 12)
)

## ------------------------------------------------------------------------------------
## Main
## ------------------------------------------------------------------------------------
browser()
df_path <- list.files(path = path_inp, pattern = paste0("EPA-AQS_h_\\d{4}-\\d{2}-\\d{2}-\\d{4}-\\d{2}-\\d{2}_", pollutant, "_xminlon_", xmin, "_xmaxlon_", xmax, "_yminlat_", ymin, "_ymaxlat_", ymax, ".csv"), recursive = FALSE, full.names = TRUE, include.dirs = TRUE)

## ToDo

aqs_df <- read.csv(df_path)

## Get measurement site number
site_l <- unique(aqs_df$site_number)

for (site in site_l) {
    print(paste0("Process site: ", site))

    #if (site  =  =  "1004") {
    #    View(aqs_df)
    #    browser()
    #}

    ## Subset data frame based on site and sample frequency
    ## Prefered sample frequency is a measurement for every hour "DAILY: 24"
    sub_df <- subset(aqs_df, subset = aqs_df$site_number == site & grepl("DAILY: 24", aqs_df$sample_frequency))
    
    ## Check if the data frame is empty; If so, try to use the "HOURLY" frequency which should provide measurements every 4h
    if (dim(sub_df)[1]  ==  0) {
        sub_df <- subset(aqs_df, subset = aqs_df$site_number == site & grepl("HOURLY", aqs_df$sample_frequency))
        print(dim(sub_df))
    } else {
        print(dim(sub_df))
    }

    ## Get filename from input file
    path_split <- strsplit(df_path, split = "/")
    filename <- paste0(str_sub(path_split[[1]][length(path_split[[1]])], end = -5), '_', site)
    filename <- gsub("_h_", "_d_", filename)

    ## Get date list from subset
    daily_date_l <- unique(sub_df$date_local)

    ## Calculate the daily mean
    daily_mean_df <- data.frame()

    for (ddate in daily_date_l) {
        print(paste0("Process date: ", ddate))

        daily_df <- subset(sub_df, subset = sub_df$date_local == ddate)

        method_type_l <- unique(daily_df$method_type)

        for (m in method_type_l) {
            print(paste0("Process method type: ", m, " of ", method_type_l))

            daily_method_df <- subset(daily_df, subset = daily_df$method_type == m)

            new_df <- data.frame(
                state_code = unique(daily_method_df$state_code),
                county_code = unique(daily_method_df$county_code),
                site_number = unique(daily_method_df$site_number),
                parameter_code = unique(daily_method_df$parameter_code),
                poc = unique(daily_method_df$poc),
                latitude = unique(daily_method_df$latitude),
                longitude = unique(daily_method_df$longitude),
                datum = unique(daily_method_df$datum),
                parameter = unique(daily_method_df$parameter),
                date_local = unique(daily_method_df$date_local),
                #date_gmt = unique(daily_method_df$date_gmt),
                sample_measurement = mean(daily_method_df$sample_measurement, na.rm = TRUE),
                units_of_measure = unique(daily_method_df$units_of_measure),
                units_of_measure_codes = unique(daily_method_df$units_of_measure_code),
                sample_duration = unique(daily_method_df$sample_duration),
                sample_duration_code = unique(daily_method_df$sample_duration_code),
                sample_frequency = unique(daily_method_df$sample_frequency),
                #detection_limit = unique(daily_method_df$detection_limit),
                uncertainty = unique(daily_method_df$uncertainty),
                #qualifier = unique(daily_method_df$qualifier),
                method_type = unique(daily_method_df$method_type),
                #method = unique(daily_method_df$method),
                #methode_code = unique(daily_method_df$method_code),
                state = unique(daily_method_df$state),
                county = unique(daily_method_df$county),
                #date_of_last_change = unique(daily_method_df$date_of_last_change),
                cbsa_code = unique(daily_method_df$cbsa_code)
            )
            print(new_df)

            daily_mean_df <- rbind(daily_mean_df, new_df)

            if (dim(new_df)[1] >=  2) {
                View(daily_df)
                View(new_df)
                browser()
            }
        }
    }
    ## Write csv for time series
    write.csv(daily_mean_df, paste0(path_inp, "/", filename, ".csv"))
    print(paste0(path_inp, "/", filename, ".csv"))

    ## Create ggplot of each time series for each site
    plot <- ggplot() +

    geom_line(daily_mean_df, mapping = aes(x = as.POSIXct(date_local, format = "%Y-%m-%d"), y = sample_measurement, color = method_type), linewidth = .2) +
    geom_point(daily_mean_df, mapping = aes(x = as.POSIXct(date_local, format = "%Y-%m-%d"), y = sample_measurement, color = method_type), size = .1) +

    spline_trend +
    xlab("Local") + ylab(unique(daily_mean_df$units_of_measure)) +
    ggtitle(filename) +
    theme2
    
    ggsave(paste0(path_out, '/time_series/', filename,'.png', sep = ""), width = 2500, height = 950, units = "px")
    #saveWidget(ggplotly(plot), paste0(path_out, '/time_series/', filename,'.html', sep = ""), selfcontained = F, libdir = "lib")
}