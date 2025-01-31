## ------------------------------------------------------------------------------------
## Libraries
## ------------------------------------------------------------------------------------

library(sf)
library(sp)
library(wk)
library(s2)

## ------------------------------------------------------------------------------------
## Variables
## ------------------------------------------------------------------------------------

cellsize <- 0.01

## First grid
xmin <- -124    # -180
xmax <- -66     # 180
ymin <- 25      # -90
ymax <- 49      # 90

## Second Grid (CONUS)
#xmin <- -124    # -180
#xmax <- -66     # 180
#ymin <- 25      # -90
#ymax <- 49      # 90

## Test grid (Los Angeles)
#xmin <- -119    # -180
#xmax <- -117    # 180
#ymin <- 33      # -90
#ymax <- 34      # 90

buffer <- 0

## Input
#polygon_file <- "/proj/ie/proj/Wellcome-ZEAS/RemoteSensing/DATA/GEODATA/s_18mr25/s_18mr25.shp"
polygon_file <- "/proj/ie/proj/Wellcome-ZEAS/RemoteSensing/DATA/GEODATA/cb_2022_us_nation_20m/cb_2022_us_nation_20m.shp"

## Output
path_out <- "/proj/ie/proj/Wellcome-ZEAS/RemoteSensing/Results/Grid/"


## ------------------------------------------------------------------------------------
## Functions
## ------------------------------------------------------------------------------------

## Create shp grid
create_shp_grid <- function(cellsize, extension) {
    print(paste0("Create shp grid with cellsize: ", cellsize[1], " x ", cellsize[2], " degree"))

    globe_bb <- matrix(
        extension,
        byrow = TRUE,  ncol = 2) %>%
            list() %>% 
            st_polygon() %>% 
            st_sfc(., crs = 4326)

    # Generate grid of ... x ... tiles
    globe_grid <- st_make_grid(
        globe_bb, 
        cellsize = cellsize, 
        crs = 4326, 
        what = "polygons"
    )  %>% st_sf("geometry" = ., data.frame("ID" = 1:length(.)))

    return(globe_grid)
}

## Calculate the centerpoint of a polygon and add the information to the shapefile
get_lat_lon_coords <- function(shp) {
    print("Add lat/lon information to grid")
    #require(sp)

    shp <- as(shp, "Spatial")
    df <- data.frame()

    idx_l <- c(seq(1, length(shp)))

    for (i in idx_l) {

        id <- shp@data$ID[[i]]
        lat <- round(as.numeric(shp@polygons[[i]]@labpt[2]), 3)
        lon <- round(as.numeric(shp@polygons[[i]]@labpt[1]), 3)
        
        df1 <- data.frame("ID" = id, "lat" = lat, "lon" = lon)
        df <- rbind(df, df1)
    }

    shp@data = data.frame(shp@data, df[match(shp@data[, "ID"], df[, "ID"]), ])
    
    return(shp)
}

## ------------------------------------------------------------------------------------
## Main
## ------------------------------------------------------------------------------------

## Define extinsion for grid file
extension <- c(xmin, ymax, xmax, ymax, xmax, ymin, xmin, ymin, xmin, ymax)
print(paste0("Grid extension: ", xmin, " ", xmax, " and ", ymin, " ", ymax))

## Create shp grid with 1x1 degree resolution
shp_grid1 <- create_shp_grid(cellsize = c(cellsize, cellsize), extension = extension)
shp_grid <- as(shp_grid1, "Spatial")

## Remove the point in case cellsize is smaller than 1 degree
cellsize_name <- as.character(cellsize)

## Create folder
folder_name <- paste0("00_grid_", cellsize_name, "x", cellsize_name, "_", xmin, "_", xmax, "_", ymin, "_", ymax)
folder_path <- paste0(path_out, folder_name)

## Check if the folder path exists. If not, create folder!
if (!file.exists(folder_path)) {
  dir.create(folder_path, recursive = TRUE)
  cat("Folder created at:", folder_path, "\n")
} else {
  cat("Folder already exists at:", folder_path, "\n")
}

## Export the shapefile with lat/lon centerpoint information
print(paste0("Process: ", folder_path, "/01_grid_", cellsize_name, "x", cellsize_name, "_", xmin, "_", xmax, "_", ymin, "_", ymax, ".shp"))
st_write(
    st_as_sf(shp_grid),
    dsn = paste0(folder_path, "/01_grid_", cellsize_name, "x", cellsize_name, "_", xmin, "_", xmax, "_", ymin, "_", ymax, ".shp"),
    layer = "01_grid_", cellsize_name, "x", cellsize_name, "_", xmin, "_", xmax, "_", ymin, "_", ymax, ".shp",
    driver = "ESRI Shapefile",
    delete_layer = TRUE
)

## Read second shapefile for intersect with grid
polygon <- read_sf(polygon_file)

## Filter only for CONUS and exclude the following
#exclude <- c(
#  "Alaska", "American Samoa", "Hawaii", "Puerto Rico", "Marshall Islands",
#  "Fed States of Micronesia", "Rhode Island", "Virgin Islands", "Guam", "Palau",
#  "Northern Mariana Islands"
#)

## Remove all areas in exclude from polygon
#polygon <- polygon %>% filter(!polygon$NAME %in% exclude)

## Set CRS for polygon
polygon_4326 <- st_transform(polygon, 4326)

## ToDo: add buffer to polygon
#polygon_4326_buf <- st_buffer(polygon_4326, dist = units::set_units(buffer, m))
polygon_4326_buf <- polygon_4326

## Export polygon output of shapefile file
print(paste0("Process: ", folder_path, "/02_polygon_buffer_", buffer, "m_4326.shp"))
st_write(
    st_as_sf(polygon_4326_buf),
    dsn = paste0(folder_path, "/02_polygon_buffer_", buffer, "m_4326.shp"),
    layer = "02_polygon_buffer_", buffer, "m_4326.shp",
    driver = "ESRI Shapefile",
    delete_layer = TRUE
)
 
## Clip grid to polygon_buf
shp_grid_intersect <- st_intersection(st_as_sf(shp_grid), polygon_4326_buf)

## Export intersect output of shapefile file
print(paste0("Process: ", folder_path, "/03_grid_", cellsize, "x", cellsize, "_", xmin, "_", xmax, "_", ymin, "_", ymax, "_intersect_buffer_", buffer, "m.shp"))
st_write(
    st_as_sf(shp_grid_intersect),
    dsn = paste0(folder_path, "/03_grid_", cellsize, "x", cellsize, "_", xmin, "_", xmax, "_", ymin, "_", ymax, "_intersect_buffer_", buffer, "m.shp"),
    layer = "03_grid_", cellsize, "x", cellsize, "_", xmin, "_", xmax, "_", ymin, "_", ymax, "_intersect_buffer_", buffer, "m.shp",
    driver = "ESRI Shapefile",
    delete_layer = TRUE
)

print("Done!")