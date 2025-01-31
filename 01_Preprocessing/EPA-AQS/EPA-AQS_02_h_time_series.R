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
path_inp <- "/proj/ie/proj/Wellcome-ZEAS/RemoteSensing/Results/EPA-AQS/CA/aoi_CSV"
path_out <- "/proj/ie/proj/Wellcome-ZEAS/RemoteSensing/Results/EPA-AQS/CA/aoi_PLOTS"

pollutant <- "42602"

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

df_path <- list.files(path=path_inp, pattern=paste0("EPA-AQS_h_\\d{4}-\\d{2}-\\d{2}-\\d{4}-\\d{2}-\\d{2}_", pollutant, "_xminlon_-119_xmaxlon_-117_yminlat_33_ymaxlat_34.csv"), recursive=FALSE, full.names=TRUE, include.dirs=TRUE)
aqs_df <- read.csv(df_path)

## Get measurement site number
site_l <- unique(aqs_df$site_number)

for (site in site_l) {
  print(paste0("Process site: ", site))

  ## Subset data frame based on site and sample frequency
  ## Prefered sample frequency is a measurement for every hour "DAILY: 24"
  sub_df <- subset(aqs_df, subset=aqs_df$site_number==site & grepl("DAILY: 24", aqs_df$sample_frequency))
  
  ## Check if the data frame is empty; If so, try to use the "HOURLY" frequency which should provide measurements every 4h
  if (dim(sub_df)[1] == 0) {
    sub_df <- subset(aqs_df, subset=aqs_df$site_number==site & grepl("HOURLY", aqs_df$sample_frequency))
    print(dim(sub_df))
  } else {
    print(dim(sub_df))
  }

  ## Get filename from input file
  path_split <- strsplit(df_path, split="/")
  filename <- paste0(str_sub(path_split[[1]][length(path_split[[1]])], end=-5), '_', site)

  ## Write csv for time series
  write.csv(sub_df, paste0(path_inp, "/", filename, ".csv"))

  ## Create ggplot of each time series for each site
  plot <- ggplot()+

  geom_line(sub_df, mapping=aes(x=as.POSIXct(datetime_local, format="%Y-%m-%d %H:%M"), y=sample_measurement, color=method_type), linewidth=.2)+
  geom_point(sub_df, mapping=aes(x=as.POSIXct(datetime_local, format="%Y-%m-%d %H:%M"), y=sample_measurement, color=method_type), size=.1)+

  spline_trend +
  xlab("Local")+ ylab(unique(sub_df$units_of_measure))+
  ggtitle(filename)+
  theme2

  ggsave(paste0(path_out, '/time_series/', filename,'.png', sep=""), width=2500, height=950, units="px")
  #saveWidget(ggplotly(plot), paste0(path_out, '/time_series/', filename,'.html', sep=""), selfcontained = F, libdir = "lib")
}