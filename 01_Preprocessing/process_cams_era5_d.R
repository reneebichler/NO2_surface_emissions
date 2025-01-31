#-----------------------------------------------------------------------------
# Sources and Libraries
#-----------------------------------------------------------------------------

library(ncdf4)
library(raster)
library(sf)
library(viridis)
library(dplyr)
library(stringr)
library(lubridate)
library(data.table)

#-----------------------------------------------------------------------------
# (1) Crop the NetCDF file to the size of the polygon file
#-----------------------------------------------------------------------------

crop_nc <- function(polygon, file_l, var_nc, utc, ml_level) {
  
  aoi_full_df <- data.frame(NaN)
  
  for (nc_file in file_l) {
    
      print(paste0("Crop NetCDF file: ", nc_file))
    
      ## Load nc and polygon file
      print("Create nc.brick")
      nc.brick <- brick(x=nc_file, varname=var_nc, level=ml_level)

      ## Show the extent of the nc and polygon file
      extent(nc.brick)
      extent(polygon)
      
      ## Check the projections of the raster and polygon
      crs(nc.brick)
      crs(polygon)
      
      ## Crop raster to polygon
      print("Crop raster to polygon")
      re <- crop(nc.brick, extent(polygon))
      
      rm(nc.brick)
    
      print("Create aoi_df")
      aoi_df <- as.data.frame(re, xy=TRUE)
      l <- length(aoi_df)
      print(paste0("Dataset length: ", l-2))
      
      ## Full join based on x and y
      if (nc_file == file_l[1]) {
        aoi_full_df <- cbind(aoi_full_df, aoi_df)
        aoi_full_df <- aoi_full_df[,  ! names(aoi_full_df) == "NaN.",  drop = F]
        
      } else{
        aoi_full_df <- aoi_full_df %>% full_join(aoi_df, by=c("x", "y"))
      }
  }
  
  aoi_full_df["utc"] <- utc
  
  l0 <- length(aoi_full_df)
  print(paste0("Dataset length: ", l0))
  
  l1<- length(aoi_full_df)-1
  aoi_full_df <- aoi_full_df[, c(1:2,  l0, 3:l1)]
  
  rm(re, aoi_df, l0, l1, polygon, var_nc)
  
  return(aoi_full_df)
}

#-----------------------------------------------------------------------------
# (1A) Crop the NetCDF file to the size of the polygon file
#-----------------------------------------------------------------------------

crop_gome2_nc <- function(polygon, file_l) {
  
  aoi_full_df <- data.frame(NaN)
  
  for (nc_file in file_l) {
    
    print(paste0("Crop NetCDF file: ", nc_file))
    
    fname <- tail(strsplit(nc_file, "/")[[1]],n=1)
    var <- substr(fname[1], 10, 17)
    print(paste0("Use var_nc: ", var))

    date <- str_sub(fname[1], -11, -4)
    date <- paste0("X", substr(date, 1, 4), ".", substr(date, 5, 6), ".", substr(date, 7, 8))
    print(paste0("Process GOME-2: ", date))
    
    if (isTRUE(var == "TropNO2.")) {
      var_nc <- "TropNO2"
    } else {
      print("ERROR!")
    }
    
    # if (var == "NO2tropo") {
    #   var_nc <- "NO2tropo"
    #   }
    # else if (var == "NO2Tropo") {
    #   var_nc <- "NO2tropo"
    #   }
    # else if (var == "TropNO2.") {
    #   var_nc <- "TropNO2"
    #   }
    # else {
    #   print("var_nc ERROR")
    #   }
    
    ## Load nc and polygon file
    print("Create nc.brick")
    nc.brick <- brick(x=nc_file, varname=var_nc)
    
    # if (var_nc == "NO2tropo") {
    #   rotate(nc.brick)
    #   extent(nc.brick) <- c(-180, 180, -90, 90)
    #   }
    # else {
    #   print("No brick rotation needed")
    #   }
    
    ## Show the extent of the nc and polygon file
    extent(nc.brick)
    extent(polygon)
    
    ## Check the projections of the raster and polygon
    crs(nc.brick)
    crs(polygon)
    
    ## Crop raster to polygon
    print("Crop raster to polygon")
    re <- crop(nc.brick, extent(polygon))
    
    #rm(nc.brick)
    
    print("Create aoi_df")
    aoi_df <- as.data.frame(re, xy=TRUE)
    l <- length(aoi_df)
    print(paste0("Dataset length: ", l-2))
    
    names(aoi_df)[3] <- date
    
    ## Full join based on x and y
    if (isTRUE(nc_file == file_l[1])) {
      aoi_full_df <- cbind(aoi_full_df, aoi_df)
      aoi_full_df <- aoi_full_df[,  ! names(aoi_full_df) == "NaN.",  drop = F]
    }
    else{
      aoi_full_df <- aoi_full_df %>% full_join(aoi_df, by=c("x", "y"))
    }
  }
  
  l0 <- length(aoi_full_df)
  print(paste0("Dataset length: ", l0))
  
  l1<- length(aoi_full_df)-1
  aoi_full_df <- aoi_full_df[, c(1:2,  l0, 3:l1)]
  
  rm(re, aoi_df, l0, l1, polygon, var_nc)
  
  return(aoi_full_df)
}

#-----------------------------------------------------------------------------
# (1A) Crop the NetCDF file to the size of the polygon file
#-----------------------------------------------------------------------------

crop_omi_nc <- function(polygon, file_l) {
  
  aoi_full_df <- data.frame(NaN)
  
  for (nc_file in file_l) {
    
    print(paste0("Crop NetCDF file: ", nc_file))
    
    fname <- tail(strsplit(nc_file, "/")[[1]],n=1)
    var_nc <- "ColumnAmountNO2TropCloudScreened"
    print(paste0("Use var_nc: ", var_nc))

    ## split fname
    date <- as.Date(gsub("m", "", strsplit(fname, split="_")[[1]][3]), format="%Y%m%d")

    ## change column name for ML code
    date <- paste0("X", gsub("-", ".", date))

    print(paste0("Process OMI: ", date))
    
    ## Load nc and polygon file
    print("Create nc.brick")
    nc.brick <- brick(x=nc_file, varname=var_nc)
    
    ## Show the extent of the nc and polygon file
    extent(nc.brick)
    extent(polygon)
    
    ## Check the projections of the raster and polygon
    crs(nc.brick)
    crs(polygon)

    ## Crop raster to polygon
    print("Crop raster to polygon")
    re <- crop(nc.brick, polygon)
    
    #rm(nc.brick)
    
    print("Create aoi_df")
    aoi_df <- as.data.frame(re, xy=TRUE)
    l <- length(aoi_df)
    print(paste0("Dataset length: ", l-2))

    names(aoi_df)[3] <- date
    
    ## Full join based on x and y
    if (isTRUE(nc_file == file_l[1])) {
      aoi_full_df <- cbind(aoi_full_df, aoi_df)
      aoi_full_df <- aoi_full_df[, ! names(aoi_full_df) == "NaN.", drop = F]
    }
    else{
      aoi_full_df <- aoi_full_df %>% full_join(aoi_df, by=c("x", "y"))
    }
  }
  
  'l0 <- length(aoi_full_df)
  print(paste0("Dataset length: ", l0))
  
  l1 <- length(aoi_full_df)-1
  aoi_full_df <- aoi_full_df[, c(1:2,  l0, 3:l1)]'
  
  rm(re, aoi_df, polygon, var_nc)
  
  return(aoi_full_df)
}

#-----------------------------------------------------------------------------
# (2) Generate the daily mean from the cropped df for each utc time
#-----------------------------------------------------------------------------

generate_d_mean_df <- function(aoi_df, var_nc, aoi, ml_level) { 
  
  aoi_df <- aoi_df[, ! names(aoi_df) == "x", drop = F]
  aoi_df <- aoi_df[, ! names(aoi_df) == "y", drop = F]
  
  if ("utc" %in% names(aoi_df)) {
    utc_info <- "yes"
    utc <- aoi_df$utc[1]
    aoi_df <- aoi_df[, ! names(aoi_df) == "utc", drop = F]
  } else {
    utc_info <- "no"
    print("No utc information")
  }
  
  n <- names(aoi_df)
  
  date_l <- lapply(n, function(x) gsub("X", "", x))
  date_l <- lapply(date_l, function(x) gsub("-", ".", x))
  
  # EAC4 and ERA5 data include the UTC information in the column, therefore delete this information
  if (str_length(date_l[3]) > 19) {
    browser()
    date_l <- gsub('.{0, 9}$',  '',  date_l)
  }

  date_l <- as.Date(as.character(date_l), "%Y.%m.%d")
  
  if (isTRUE(length(colnames(aoi_df)) == length(date_l))) {
    colnames(aoi_df) <- date_l
  }
  else {
    print("ERROR: colnames has not the same lenght as date_l")
  }
  
  if (isTRUE(utc_info == "yes")) {
    aoi_d_mean_df <- data.frame(
      date=names(aoi_df),
      utc=utc, 
      variable=var_nc,
      level=ml_level,
      aoi=aoi, 
      mean=colMeans(as.matrix(aoi_df), na.rm=TRUE)
    )
  } else {
    aoi_d_mean_df <- data.frame(
      date=names(aoi_df), 
      variable=var_nc,
      level=ml_level,
      aoi=aoi, 
      mean=colMeans(as.matrix(aoi_df), na.rm=TRUE)
    )
  }

  aoi_d_mean_df$date <- as.Date(aoi_d_mean_df$date)
  rownames(aoi_d_mean_df) <- NULL
  
  return(aoi_d_mean_df)
}

#-----------------------------------------------------------------------------
# (3) Generate the monthly mean from the cropped df for each utc time
#-----------------------------------------------------------------------------

generate_m_mean_df <- function(aoi_df, var_nc, aoi, ml_level) { 
  
  aoi_df <- aoi_df[,  ! names(aoi_df) == "x",  drop = F]
  aoi_df <- aoi_df[,  ! names(aoi_df) == "y",  drop = F]

  if ("utc" %in% names(aoi_df)) {
    utc_info <- "yes"
    utc <- aoi_df$utc[1]
    aoi_df <- aoi_df[,  ! names(aoi_df) == "utc",  drop = F]
  } else {
    utc_info <- "no"
    print("No utc information")
  }

  n <- names(aoi_df)
  date_l <- lapply(n,  function(x) gsub("X", "", x))
  date_l <- lapply(date_l,  function(x) gsub("-", ".", x))
  
  # EAC4 and ERA5 data include the UTC information in the column, therefore delete this information
  if (str_length(date_l[3]) > 19) {
    browser()
    date_l <- gsub('.{0, 11}$',  '',  date_l)
  }

  ## if date has . replace them with -
  if (str_detect(date_l[[1]], ".")) {
    date_l <- format(as.Date(as.character(date_l), "%Y.%m.%d"), "%Y-%m-%d")
  } else if (str_detect(date_l[[1]], "-")) {
    date_l <- as.Date(as.character(date_l), "%Y-%m-%d")
  } else {
    date_l <- as.Date(as.character(date_l), "%Y%m%d")
  }
  
  colnames(aoi_df) <- date_l

  month_seq <- sprintf("%02d",  1:12)
  year_seq <- unique(year(date_l))
  
  aoi_mean_df <- data.frame()
  aoi_m_mean_df <- data.frame()
  
  for (y in year_seq){
    for (m in month_seq){
      
      sub_df <- aoi_df %>% dplyr::select(contains(paste0(y, "-", m)))
      
      if (isTRUE(utc_info == "yes")) {
        new_df <- data.frame(
          date=paste0(y, "-", m, "-01"), 
          utc=utc,  variable=var_nc, level=ml_level, aoi=aoi, 
          mean=mean(as.matrix(sub_df), na.rm=TRUE)
        )
      }
      else {
        new_df <- data.frame(
          date=paste0(y, "-", m, "-01"), 
          variable=var_nc, level=ml_level, aoi=aoi, 
          mean=mean(as.matrix(sub_df), na.rm=TRUE)
        )
      }
      print(new_df)
      aoi_mean_df <- rbind(aoi_mean_df,  new_df)
    }
  }
  aoi_m_mean_df <- rbind(aoi_m_mean_df, aoi_mean_df)
  return(aoi_m_mean_df)
}

#-----------------------------------------------------------------------------
# (3) Generate the monthly mean from the cropped df for each utc time
#-----------------------------------------------------------------------------

generate_m_mean_df_temis <- function(aoi_df, var_nc, aoi) { 

  aoi_df <- aoi_df[,  ! names(aoi_df) == "x",  drop = F]
  aoi_df <- aoi_df[,  ! names(aoi_df) == "y",  drop = F]

  if ("utc" %in% names(aoi_df)) {
    utc_info <- "yes"
    utc <- aoi_df$utc[1]
    aoi_df <- aoi_df[,  ! names(aoi_df) == "utc",  drop = F]
  } else {
    utc_info <- "no"
    print("No utc information")
  }
  
  date_l <- lapply(names(aoi_df),  function(x) gsub("X", "", x))
  date_l <- as.Date(as.character(date_l), "%Y%m.%d")
  date_l <- as.character(date_l)
 
  colnames(aoi_df) <- date_l

  month_seq <- sprintf("%02d",  1:12)
  year_seq <- unique(year(date_l))
  
  aoi_mean_df <- data.frame()
  aoi_m_mean_df <- data.frame()
  
  for (y in year_seq){
    for (m in month_seq){

      sub_df <- aoi_df %>% dplyr::select(contains(paste0(y, "-", m)))
      
      if (isTRUE(utc_info == "yes")) {
        new_df <- data.frame(
          date=paste0(y, "-", m, "-01"), 
          utc=utc,  variable=var_nc,  aoi=aoi, 
          mean=mean(as.matrix(sub_df), na.rm=TRUE)
        )
      }
      else {
        new_df <- data.frame(
          date=paste0(y, "-", m, "-01"), 
          variable=var_nc,  aoi=aoi, 
          mean=mean(as.matrix(sub_df), na.rm=TRUE)
        )
      }
      print(new_df)
      aoi_mean_df <- rbind(aoi_mean_df,  new_df)
    }
  }
  aoi_m_mean_df <- rbind(aoi_m_mean_df, aoi_mean_df)
  return(aoi_m_mean_df)
}

#-----------------------------------------------------------------------------
# (4) Generate the daily mean crop of multiple utc times based on _d_crop_AOI_*.csv's
#-----------------------------------------------------------------------------

generate_d_mean_crop <- function(file_l) {
  
  df <- data.frame(NaN)
  
  ## import utc files in one data frame
  for (csv in file_l) {
    df_csv <- read.csv(csv)
    df_csv <- df_csv[,  ! names(df_csv) == "X",  drop = F]
    df <- cbind(df, df_csv)
  }
  
  df <- df[,  ! names(df) == "NaN.",  drop = F]
  
  n <- names(df)
  s <- unlist(strsplit(gsub("X", "", head(n, 1)), "[.]"))
  e <- unlist(strsplit(gsub("X", "", tail(n, 1)), "[.]"))
  
  date_seq <- seq.Date(
    as.Date(paste0(s[1], "-", s[2], "-", s[3])), 
    as.Date(paste0(e[1], "-", e[2], "-", e[3])), "days"
  )
  
  unique_list <- unique(date_seq)
  
  names(df) <- gsub(x = names(df),  pattern = "\\.",  replacement = "-") 
  
  aoi_d_mean_crop_df <- data.frame()
  aoi_d_mean_utc_crop_df <- data.frame()
  
  for (u in as.character(unique_list)) {
    sub_df <- df %>% dplyr::select(contains(u))
    new_df <- data.frame(rowMeans(sub_df, na.rm=TRUE))
    print(new_df)
    aoi_d_mean_crop_df <- rbind(aoi_d_mean_crop_df,  new_df)
  }
  aoi_d_mean_utc_crop_df <- rbind(aoi_d_mean_utc_crop_df, aoi_d_mean_crop_df)
  
  return(aoi_d_mean_utc_crop_df)
}

#-----------------------------------------------------------------------------
# (5) Generate the daily mean of multiple utc times based on _d_crop_AOI_*.csv's
#-----------------------------------------------------------------------------

generate_d_mean_utc <- function(file_l, var_nc, aoi, utc_l, ml_level) {

  ## calculates mean of two columns, one for utc time 1 and one for utc time 2
  
  df <- data.frame(NaN)
  
  ## import utc files in one data frame
  for (csv in file_l) {
    df_csv <- read.csv(csv)
    df_csv <- df_csv[, ! names(df_csv) == "X", drop = F]
    df_csv <- df_csv[, ! names(df_csv) == "x", drop = F]
    df_csv <- df_csv[, ! names(df_csv) == "y", drop = F]
    df_csv <- df_csv[, ! names(df_csv) == "utc", drop = F]
    df <- cbind(df, df_csv)
  }
  
  df <- df[, ! names(df) == "NaN.", drop = F]
  
  n <- names(df)
  s <- unlist(strsplit(gsub("X", "", head(n, 1)), "[.]"))
  e <- unlist(strsplit(gsub("X", "", tail(n, 1)), "[.]"))
  
  date_seq <- seq.Date(
    as.Date(paste0(s[1], "-", s[2], "-", s[3])), 
    as.Date(paste0(e[1], "-", e[2], "-", e[3])), "days"
  )
  
  unique_list <- unique(date_seq)

  names(df) <- gsub(x = names(df), pattern = "\\.", replacement = "-") 
  
  aoi_d_mean_df <- data.frame()
  aoi_d_mean_utc_df <- data.frame()
  
  for (u in as.character(unique_list)) {
    sub_df <- df %>% dplyr::select(contains(u))
    new_df <- data.frame(
      date=paste0(u), 
      utc=utc_l,
      variable=var_nc,
      level=ml_level,
      aoi=aoi, 
      mean=mean(as.matrix(sub_df), na.rm=TRUE)
    )
    print(new_df)
    aoi_d_mean_df <- rbind(aoi_d_mean_df, new_df)
  }
  aoi_d_mean_utc_df <- rbind(aoi_d_mean_utc_df, aoi_d_mean_df)
  
  return(aoi_d_mean_utc_df)
}

#-----------------------------------------------------------------------------
# (6) Generate the monthly mean of multiple utc times based on the daily mean
#-----------------------------------------------------------------------------

generate_m_mean_utc <- function(file_l, var_nc, aoi, utc_l, ml_level) {
  
  df <- data.frame(NaN)
  
  for (csv in file_l) {
    df_csv <- read.csv(csv)
    df_csv <- df_csv[,  ! names(df_csv) == "X",  drop = F]
    df_csv <- df_csv[,  ! names(df_csv) == "x",  drop = F]
    df_csv <- df_csv[,  ! names(df_csv) == "y",  drop = F]
    df_csv <- df_csv[,  ! names(df_csv) == "utc",  drop = F]
    df <- cbind(df, df_csv)
  }
  
  df <- df[,  ! names(df) == "NaN.",  drop = F]
  
  n <- names(df)
  s <- unlist(strsplit(gsub("X", "", head(n, 1)), "[.]"))
  e <- unlist(strsplit(gsub("X", "", tail(n, 1)), "[.]"))
  
  date_seq <- seq.Date(
    as.Date(paste0(s[1], "-", s[2], "-", s[3])),
    as.Date(paste0(e[1], "-", e[2], "-", e[3])), "days"
  )
  
  month_seq <- sprintf("%02d",  1:12)

  year_seq <- year(seq.Date(
    as.Date(paste0(s[1], "-", s[2], "-", s[3])), 
    as.Date(paste0(e[1], "-", e[2], "-", e[3])), "years")
  )
  
  names(df) <- gsub(x = names(df),  pattern = "\\.",  replacement = "-") 
  
  aoi_m_mean_df <- data.frame()
  aoi_m_mean_utc_df <- data.frame()
  
  for (y in year_seq){
    for (m in month_seq){

      print(paste0("Process YYYY: ", y, " and month: ", m))

      sub_df <- df %>% dplyr::select(contains(paste0(y, "-", m)))
      new_df <- data.frame(
        date=paste0(y, "-", m, "-01"), 
        utc=utc_l, variable=var_nc, level=ml_level, aoi=aoi, 
        mean=mean(as.matrix(sub_df), na.rm=TRUE)
        #max=max(as.matrix(sub_df), na.rm=TRUE)
      )
      print(new_df)
      aoi_m_mean_df <- rbind(aoi_m_mean_df,  new_df)
    }
  }
  
  aoi_m_mean_utc_df <- rbind(aoi_m_mean_utc_df, aoi_m_mean_df)

  return(aoi_m_mean_utc_df)
}

#-----------------------------------------------------------------------------
# (7) Generate the daily mean of multiple utc times based on _d_crop_AOI_*.csv's
#-----------------------------------------------------------------------------

generate_d_pixel_mean_utc <- function(file_l) {

  ## the file_l inclueds a file for each utc time
  ## afterwards the mean value of each pixel is calculated
  
  df_l <- lapply(file_l, read.csv)
  df_l <- lapply(df_l, function(x) x[!(names(x) == "X")])

  col_names <- substr(names(df_l[[1]]), 2, 11)
  col_names[1] <- "x"
  col_names[2] <- "y"
  col_names[3] <- "utc"
  
  df_l <- lapply(df_l, setNames, col_names)
  
  dt <- rbindlist(df_l)[, lapply(.SD, mean), list(x,  y)]
  dt <- dt[, utc:=NULL]
  
  return(dt)
}

generate_d_pixel_mean_sat <- function(file_l) {
  
  df_l <- lapply(file_l,  read.csv)
  df_l <- lapply(df_l,  function(x) x[!(names(x) == "X")])
  
  col_names <- substr(names(df_l[[1]]), 2, 11)
  col_names[1] <- "x"
  col_names[2] <- "y"
  col_names[3] <- "utc"

  browser()
  
  df_l <- lapply(df_l,  setNames,  col_names)
  
  dt <- rbindlist(df_l)[, lapply(.SD, mean),  list(x,  y)]
  dt <- dt[, utc:=NULL]
  
  return(dt)
}

#-----------------------------------------------------------------------------
# (8) CAMS - ERA5 - Statistics (cloud cover)
#-----------------------------------------------------------------------------

generate_era5_stat <- function(era5_df){

  era5_df$date <- as.Date(era5_df$date)

  ym <- unique(format(era5_df$date,  "%Y-%m"))
  cc_df <- data.frame()

  for (x in seq_along(ym)) {
    print(paste("Process statistics for: ", ym[x], sep=""))
    # subset a month from era5 daily data and the cloud cover and the mean
    df2 <- subset(era5_df,  format(era5_df$date,  "%Y-%m") == ym[x])
    # get the amount of days below a certain factor of cloud coverage
    cc_90 <- factor(length(which(df2$mean <= 0.90)))
    cc_85 <- factor(length(which(df2$mean <= 0.85)))
    cc_80 <- factor(length(which(df2$mean <= 0.80)))
    cc_75 <- factor(length(which(df2$mean <= 0.75)))
    cc_70 <- factor(length(which(df2$mean <= 0.70)))
    cc_65 <- factor(length(which(df2$mean <= 0.65)))
    cc_60 <- factor(length(which(df2$mean <= 0.60)))
    cc_55 <- factor(length(which(df2$mean <= 0.55)))
    cc_50 <- factor(length(which(df2$mean <= 0.50)))
    cc_45 <- factor(length(which(df2$mean <= 0.45)))
    cc_40 <- factor(length(which(df2$mean <= 0.40)))
    cc_35 <- factor(length(which(df2$mean <= 0.35)))
    cc_30 <- factor(length(which(df2$mean <= 0.30)))
    cc_25 <- factor(length(which(df2$mean <= 0.25)))
    cc_20 <- factor(length(which(df2$mean <= 0.20)))
    cc_15 <- factor(length(which(df2$mean <= 0.15)))
    cc_10 <- factor(length(which(df2$mean <= 0.10)))
    # multiply by 100 to get %
    mean <- mean(df2$mean, na.rm=TRUE)*100
    #max <- max(df2$mean, na.rm=TRUE)*100
    new_df2 <- data.frame(
      cc_10=cc_10, cc_15=cc_15, 
      cc_20=cc_20, cc_25=cc_25, 
      cc_30=cc_30, cc_35=cc_35, 
      cc_40=cc_40, cc_45=cc_45, 
      cc_50=cc_50, cc_55=cc_55, 
      cc_60=cc_60, cc_65=cc_65, 
      cc_70=cc_70, cc_75=cc_75, 
      cc_80=cc_80, cc_85=cc_85, 
      cc_90=cc_90, 
      mean=mean, #max=max, 
      date=as.Date(paste(ym[x], "-01", sep=""))
    )
    cc_df <- rbind(cc_df,  new_df2)
  }

  cc_df <- cc_df[order(as.Date(cc_df$date,  format = "%Y-%m-%d")), ]
  cc_df$date <- as.Date(cc_df$date, "%Y-%m-%d")

  return(cc_df)
}