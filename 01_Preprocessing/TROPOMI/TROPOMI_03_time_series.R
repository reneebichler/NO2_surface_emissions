## ------------------------------------------------------------------------------------
## Main
## ------------------------------------------------------------------------------------

library(stringr)
library(ggplot2)
library(zoo)
library(plotly)
library(htmlwidgets)

## ------------------------------------------------------------------------------------
## Variables
## ------------------------------------------------------------------------------------

## TEMPO Plots
aoi_l <- c("AOI_LA_City")
instrument <- "TROPOMI"
time_res_l <- c("d", "m")

storage <- "/Volumes/MyBook"
#storage <- "/Users/reneebichler/surface"

## ------------------------------------------------------------------------------------
## Functions
## ------------------------------------------------------------------------------------

spline_trend <- stat_smooth(
  method="gam", 
  formula=y~s(x), 
  color="steelblue3", 
  fill="steelblue1", 
  alpha=0.2, 
  size=0.8
)

theme2 <- theme_bw() +
theme(
legend.position = "top", 
legend.title=element_text(size=10), 
legend.text=element_text(size=10), 
plot.title=element_text(hjust=0, size=10), 
panel.border=element_blank(), 
axis.text.y=element_text(size=10), 
axis.text=element_text(size=10), 
axis.ticks=element_blank(), 
axis.title.y=element_text(color="grey45", size=12)
)

## ------------------------------------------------------------------------------------
## Main
## ------------------------------------------------------------------------------------

for (aoi in aoi_l) {

    path_inp <- paste0(storage, "/RESULTS/TROPOMI/", aoi, "/aoi_CSV")
    path_out <- paste0(storage, "/RESULTS/TROPOMI/", aoi, "/aoi_PLOTS/")

    for (time_res in time_res_l) {
        print(paste0("Process: ", aoi, "; Time resolution: ", time_res))
        
        df_path <- list.files(path=path_inp, pattern=paste0('^', instrument, '_\\D{1}_TVC_\\d{4}-\\d{2}-\\d{2}-\\d{4}-\\d{2}-\\d{2}_', time_res, '_crop_mean_\\D{3}_\\D{+}_\\D{+}.csv$'), recursive=FALSE, full.names=TRUE, include.dirs=TRUE)
        df <- read.csv(df_path)

        ## Check for missing dates in time series
        if (time_res %in% c("d")) {
          date_range <- seq.Date(from=as.Date(df$date[1]), to=as.Date(df$date[length(df$date)]), by="day") 
          missing_date_l <- as.character(date_range[!date_range %in% df$date])

          for (md in missing_date_l) {
            print(paste0("Process missing date (daily df): ", md))
            missing_df <- data.frame(X=NA, date=as.character(md), variable="missing", level=NA, aoi=NA, n=NA, mean=NA)
            df <- rbind(df, missing_df)
          }
        } else if (time_res %in% c("m")) {
          date_range <- seq.Date(from=as.Date(df$date[1]), to=as.Date(df$date[length(df$date)]), by="month") 
          missing_date_l <- date_range[!date_range %in% df$date]

          for (md in missing_date_l) {
            print(paste0("Process missing date (monthly df): ", md))
            missing_df <- data.frame(X=NA, date=as.character(md), variable="missing", level=NA, aoi=NA, n=NA, mean=NA)
            df <- rbind(df, missing_df)
          }
        }

        ## Order data frame by date
        df <- df[order(as.Date(df$date, format="%Y-%m-%d")),]

        ## Interpolate missing dates
        df["interpl"] <- na.approx(df$mean, na.rm=FALSE)

        ## Subset missind date to show in the plot
        subset_md <- subset(df, df$variable == "missing")

        ## Extract filename
        filename <- str_sub(str_split(df_path, "/")[[1]][length(str_split(df_path, "/")[[1]])], end=-5)

        plot <- ggplot()+

        ## Highlight
        geom_point(subset_md, mapping=aes(x=as.POSIXct(date), y=interpl), color="orange", size=1.8)+

        ## Plot the interpolated values
        geom_line(df, mapping=aes(x=as.POSIXct(date), y=interpl), color="grey85", size=.2)+
        geom_point(df, mapping=aes(x=as.POSIXct(date), y=interpl), color="grey85", size=.1)+

        ## Plot the actual values
        geom_line(df, mapping=aes(x=as.POSIXct(date), y=mean), size=.2)+
        geom_point(df, mapping=aes(x=as.POSIXct(date), y=mean), size=.1)+

        spline_trend +
        xlab(NULL)+ ylab(NULL)+
        ggtitle(filename)+
        theme2

        ggsave(paste0(path_out, '/time_series/', filename,'.png', sep=""), width=2500, height=950, units="px")
        saveWidget(ggplotly(plot), paste0(path_out, '/time_series/', filename,'.html', sep=""), selfcontained = F, libdir = "lib")
    }
}