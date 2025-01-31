## ------------------------------------------------------------------------------------
## Libraries
## ------------------------------------------------------------------------------------

#library(raster)
library(terra)
library(sf)
library(stars)
library(dplyr)
library(ggplot2)

## ------------------------------------------------------------------------------------
## Variables
## ------------------------------------------------------------------------------------

cellsize <- 0.01

xmin <- -124    # -180
xmax <- -66     # 180
ymin <- 25      # -90
ymax <- 49      # 90

buffer <- 0

## Input
input_path <- "/proj/ie/proj/Wellcome-ZEAS/RemoteSensing/DATA/"
grid_path <- "/proj/ie/proj/Wellcome-ZEAS/RemoteSensing/Results/Grid/"

## Output
output_path <- "/proj/ie/proj/Wellcome-ZEAS/RemoteSensing/Results/LCZ/"

## ------------------------------------------------------------------------------------
## Functions and dictionaries
## ------------------------------------------------------------------------------------

## See Fig 1. Demuzere et al. (2020)
## https://doi.org/10.1038/s41597-020-00605-z

categories_class_name <- c(
    "1" = "1",
    "2" = "2",
    "3" = "3",
    "4" = "4",
    "5" = "5",
    "6" = "6",
    "7" = "7",
    "8" = "8",
    "9" = "9",
    "10" = "10",
    "11" = "A",
    "12" = "B",
    "13" = "C",
    "14" = "D",
    "15" = "E",
    "16" = "F",
    "17" = "G"
)

categories_full_name <- c(
    "1" = "1 - Compact highrise",
    "2" = "2 - Compact midrise",
    "3" = "3 - Compact lowrise",
    "4" = "4 - Open highrise",
    "5" = "5 - Open midrise",
    "6" = "6 - Open lowrise",
    "7" = "7 - Lightweight lowrise",
    "8" = "8 - Large lowrise",
    "9" = "9 - Sparsely built",
    "10" = "10 - Heavy Industry",
    "11" = "A - Dense trees",
    "12" = "B - Scattered trees",
    "13" = "C - Bush, scrub",
    "14" = "D - Low plants",
    "15" = "E - Bare rock or paved",
    "16" = "F - Bare soil or sand",
    "17" = "G - Water"
)

categories_name <- c(
    "1" = "Compact highrise",
    "2" = "Compact midrise",
    "3" = "Compact lowrise",
    "4" = "Open highrise",
    "5" = "Open midrise",
    "6" = "Open lowrise",
    "7" = "Lightweight lowrise",
    "8" = "Large lowrise",
    "9" = "Sparsely built",
    "10" = "Heavy Industry",
    "11" = "Dense trees",
    "12" = "Scattered trees",
    "13" = "Bush, scrub",
    "14" = "Low plants",
    "15" = "Bare rock or paved",
    "16" = "Bare soil or sand",
    "17" = "Water"
)

## ------------------------------------------------------------------------------------
## Main
## ------------------------------------------------------------------------------------

## Load local climate zones (tif)
#tif <- raster::raster(paste0(input_path, "Demuzere_2020/CONUS_LCZ_map_NLCD_v1.0_epsg4326.tif"))
tif <- terra::rast(paste0(input_path, "Demuzere_2020/CONUS_LCZ_map_NLCD_v1.0_epsg4326.tif"))

## Remove the point in case cellsize is smaller than 1 degree
cellsize_name <- as.character(cellsize)

## Load grid file (shp)
grid <- read_sf(paste0(grid_path, "00_grid_", cellsize_name, "x", cellsize_name, "_", xmin, "_", xmax, "_", ymin, "_", ymax, "/03_grid_", cellsize_name, "x", cellsize_name, "_", xmin, "_", xmax, "_", ymin, "_", ymax, "_intersect_buffer_", buffer, "m.shp"))

## Create an empty data frame to store the new rows with the new class column
df_lcz <- data.frame()

## calculate mean value for each new grid cell using DEM
for (i in seq(1, nrow(grid))) {

    print(paste0("Process grid cell: ", i, "/", as.character(nrow(grid))))

    ## Used for testing: Show which grid cell is getting processed
    #ggplot() +
    #geom_sf(data = grid) +
    #geom_sf(data = grid[i,], fill = "red")

    ## Retrieve grid cell
    cell <- grid[i,]

    ## Crop and mask tif file
    aoi1 <- crop(tif, cell)
    aoi1 <- mask(aoi1, cell)

    ## Remove class 0 from counting in table (t)
    #t <- data.frame(rbind(table(getValues(aoi1))))
    t <- data.frame(rbind(table(terra::values(aoi1))))
    t <- t(t)

    ## Create a new data frame and store the rownames and counts from table (t)
    df <- data.frame(
        class = rownames(t),
        count = t[,1]
    )

    ## Remove X0 rows from the data frame (df)
    df <- df[!(df$class == "X0"),]
    rownames(df) <- NULL

    ## Add a new column called "new_class" to grid (sf)
    grid["class"] <- NA
    grid["cname"] <- NA
    grid["fname"] <- NA
    grid["oname"] <- NA

    if (!is.null(dim(df))) {
        if (dim(df)[1] != 0) {

            ## Get the class with the highest frequenzy
            new_class <- df[df$count == max(df$count),]
            new_class <- gsub("X", "", new_class$class)
            print(paste0("Detected class: ", new_class))

            ## Add new class to grid
            grid$class[i] <- new_class

            ## Add name to class
            grid$cname[i] <- categories_class_name[new_class]
            grid$fname[i] <- categories_full_name[new_class]
            grid$oname[i] <- categories_name[new_class]

        } else {
            print("No class detected!")
        }
    } else {
        print("Skip!")
    }

    df_lcz <- rbind(df_lcz, grid[i,])
    print(tail(df_lcz))
}

## Create folder path
folder_name <- paste0("00_lcz_", cellsize_name, "x", cellsize_name, "_", xmin, "_", xmax, "_", ymin, "_", ymax)
folder_path <- paste0(output_path, folder_name)

## Check if the folder path exists. If not, create folder!
if (!file.exists(folder_path)) {
    dir.create(folder_path, recursive = TRUE)
    cat("Folder created at:", folder_path, "\n")
} else {
    cat("Folder already exists at:", folder_path, "\n")
}

## Export the new data frame as shapefile
st_write(
    obj = df_lcz,
    dsn = paste0(folder_path, "/01_lcz_grid_", cellsize_name, "x", cellsize_name, "_", xmin, "_", xmax, "_", ymin, "_", ymax, ".shp"),
    layer = paste0("01_lcz_grid_", cellsize_name, "x", cellsize_name, "_", xmin, "_", xmax, "_", ymin, "_", ymax, ".shp")
)
print(paste0("Save: ", folder_path, "/01_lcz_grid_", cellsize_name, "x", cellsize_name, "_", xmin, "_", xmax, "_", ymin, "_", ymax, ".shp"))

## Rasterize the data frame with the geometry object
sf_raster <- st_rasterize(df_lcz %>% dplyr::select(class, cname, fname, oname, geometry))

## Export the raster file
write_stars(sf_raster, paste0(folder_path, "/02_lcz_raster_", cellsize_name, "x", cellsize_name, "_", xmin, "_", xmax, "_", ymin, "_", ymax, ".tif"))
print(paste0("Save: ", folder_path, "/02_lcz_raster_", cellsize_name, "x", cellsize_name, "_", xmin, "_", xmax, "_", ymin, "_", ymax, ".tif"))