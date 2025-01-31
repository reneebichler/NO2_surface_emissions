## ------------------------------------------------------------------------------------
## Libraries
## ------------------------------------------------------------------------------------

library(osmdata)
library(osmextract)
library(sf)
library(tidyverse)
library(dplyr)
library(stars)
library(raster)
library(ggplot2)

## ------------------------------------------------------------------------------------
## Variables
## ------------------------------------------------------------------------------------

## variables
tag <- "highway"

#road_l1 <- "'motorway', 'trunk'"
road_l2 = c("motorway", "trunk")

cellsize <- 1

xmin <- -124
xmax <- -66
ymin <- 25
ymax <- 49

buffer <- 0

## Input
#polygon_path <- "C:/Users/rbichler/Documents/DATA/GEODATA/USA/cb_2022_us_nation_20m/cb_2022_us_nation_20m.shp"
state_path <- "/proj/ie/proj/Wellcome-ZEAS/RemoteSensing/DATA/GEODATA/s_18mr25/s_18mr25.shp"
conus_path <- "/proj/ie/proj/Wellcome-ZEAS/RemoteSensing/DATA/GEODATA/s_18mr25/CONUS.shp"
input_path <- "/proj/ie/proj/Wellcome-ZEAS/RemoteSensing/"

## Output
output_path <- "/proj/ie/proj/Wellcome-ZEAS/RemoteSensing/Results/OSM/USA/"

## ------------------------------------------------------------------------------------
## Main
## ------------------------------------------------------------------------------------

shp_path <- conus_path

## Check available features in osmdata
osm_avfeat <- available_features()

## Check available tags
## https://wiki.openstreetmap.org/wiki/Map_features#Highway
osm_tags <- available_tags(tag)

## Read polygon as spatial feature
polygon_sf <- sf::read_sf(shp_path)

## Change CRS for polygon
polygon_sf <- st_transform(polygon_sf, crs = "EPSG:4326")

## Retrieve name from polygon
aoi_l <- polygon_sf$NAME

cellsize_name <- as.character(cellsize)

j = 1

for (aoi in aoi_l) {

  ## Check if the following names are in the list
  if (aoi %in% c("Alaska", "American Samoa", "Guam", "Palau", "Marshall Islands", "Northern Mariana Islands", "Micronesia", "Fed States of Micronesia")) {
    print("OSM extract has an issue here! Skip aoi!")

  } else {

    print(paste0("Process: ", aoi, " ", j, "/", length(aoi_l)))

    ## Subset the aoi from the multipolygon
    polygon <- subset(polygon_sf, polygon_sf$NAME == aoi)

    ## Extract name
    polygon_name <- polygon$STATE

    ## Retrieve OSM data
    usa_osm <- oe_get(aoi, boundary = polygon, stringsAsFactors = FALSE, quiet = TRUE)
    
    ## Retrieve roads using osmextract
    usa_osm_tag <- usa_osm[usa_osm[[tag]] %in% road_l2, ]

    ## Set coordinate system
    usa_osm_tag <- st_transform(usa_osm_tag, crs = "EPSG:4326")

    ## Categories road data into 1 or 2
    usa_osm_tag <- usa_osm_tag %>% mutate(
      highway_val = case_when(
        (highway == "motorway") ~ 1,
        (highway == "trunk") ~ 2
      )
    )

    ## Create ggplot
    #osm_map <- ggplot() +
    #geom_sf(data = polygon, fill = "white", size = .3) +
    #geom_sf(data = usa_osm_tag, mapping = aes(color = tag))
    #ggtitle(aoi)

    ## Remove the space in the aoi name and replace with "_"
    #aoi_name <- gsub(" ", "_", aoi)
    aoi_name <- polygon_name

    ## Export tag as shapefile
    st_write(usa_osm_tag, paste0(output_path, "shp/", aoi_name, "_", tag, "_lines.shp"), append = TRUE)
    print(paste0("Save: ", output_path, "shp/", aoi_name, "_", tag, "_lines.shp"))
  }

  j = j + 1
}

## List all shp files and merge them
file_l <- list.files(paste0(output_path, "shp/"), pattern = "\\.shp$", full.names = TRUE, recursive = TRUE)

## Read the list of files
shp_l <- lapply(file_l, read_sf)

## rbind the files
df <- do.call(rbind, shp_l)

## Export tag as shapefile
st_write(df, paste0(output_path, "shp/CONUS_", tag, "_lines.shp"), append = TRUE)
print(paste0("Save: ", output_path, "shp/CONUS_", tag, "_lines.shp"))

print("Complete!")

## Nevada, Washington, and Georgia are missing!



## Create raster based on defined raster grid
#ext <- raster::extent(-180.0, 180, -90.0, 90.0)

## Create a grid cell with certain extent and coordinate system
#grid <- st_bbox(ext) %>% 
#  st_make_grid(cellsize = c(0.01, 0.01), crs = 4326, what = "polygons") %>%
#  st_set_crs(4326)

## xxx
#grid <- grid %>% st_sf() %>% mutate(id_cell = seq_len(nrow(.)))

## Load the grid file
#grid <- st_read(
#  paste0(
#    input_path,
#    "Results/Grid/00_grid_", cellsize_name, "x", cellsize_name, "_", xmin, "_", xmax, "_", ymin, "_", ymax, 
#    "/03_grid_", cellsize_name, "x", cellsize_name, "_", xmin, "_", xmax, "_", ymin, "_", ymax, "_intersect_buffer_", buffer, "m.shp"
#  )
#)

#grid <- st_transform(grid, crs = "EPSG:4326")
#grid_raster <- st_as_stars(st_bbox(grid))

## Use spatial join to merge grid and osm
#spatial_join <- usa_osm_tag %>% sf::st_join(grid, left = TRUE)

## Create a raster out of the spatial join feature
#spatial_join_raster <- st_rasterize(spatial_join %>% dplyr::select(highway_val, geometry), grid_raster)

## Export the raster file
#write_stars(spatial_join_raster, paste0(output_path, "tif/", aoi_name, "_", tag, "_raster.tif"))
#print(paste0("Save: ", output_path, "tif/", aoi_name, "_", tag, "_raster.tif"))