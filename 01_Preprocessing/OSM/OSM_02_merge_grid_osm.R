## ------------------------------------------------------------------------------------
## Libraries
## ------------------------------------------------------------------------------------

library(sf)


## ------------------------------------------------------------------------------------
## Variables
## ------------------------------------------------------------------------------------

tag <- "highway"

cellsize <- 1

xmin <- -124
xmax <- -66
ymin <- 25
ymax <- 49

buffer <- 0

## Input
conus_path <- "/proj/ie/proj/Wellcome-ZEAS/RemoteSensing/DATA/GEODATA/s_18mr25/CONUS.shp"
input_path <- "/proj/ie/proj/Wellcome-ZEAS/RemoteSensing/"

## Output
output_path <- "/proj/ie/proj/Wellcome-ZEAS/RemoteSensing/Results/OSM/USA/"

## ------------------------------------------------------------------------------------
## Main
## ------------------------------------------------------------------------------------

cellsize_name <- as.character(cellsize)

## Load grid and manually merged OSM data
print("Read grid shapefile")
grid <- read_sf(
    paste0(
        input_path,
        "Results/Grid/00_grid_", cellsize_name, "x", cellsize_name, "_", xmin, "_", xmax, "_", ymin, "_", ymax,
        "/03_grid_", cellsize_name, "x", cellsize_name, "_", xmin, "_", xmax, "_", ymin, "_", ymax, "_intersect_buffer_", buffer, "m.shp"
    )
)

## Load CONUS shapefile that includes all states
print("Read CONUS OSM roads")
osm_roads <- read_sf(paste0(input_path, "Results/OSM/USA/shp/CONUS_OSM_roads_all_states.shp"))

## Rename column "name" in osm_roads
names(osm_roads)[names(osm_roads) == "name"] <- "osm_name"

#names(grid)[names(grid) == "ID"] <- "g_id"
#names(grid)[names(grid) == "AFFGEOID"] <- "g_affgeoid"
#names(grid)[names(grid) == "GEOID"] <- "g_geoid"
#names(grid)[names(grid) == "NAME"] <- "g_name"

#grid <- grid[ , -which(names(grid) %in% c("ID", "AFFGEOID", "GEOID", "NAME"))]

## Make sure both spatial feature share the same CRS
print("Transform the data to EPSG 4326")
grid <- st_transform(grid, crs = "EPSG:4326")
osm_roads <- st_transform(osm_roads, crs = "EPSG:4326")

## Carry out spatial join
print("Intersect the two shapefiles")
shp <- st_intersection(grid, osm_roads)

## Export tag as shapefile
st_write(
    st_as_sf(shp),
    dsn = paste0(output_path, "shp/CONUS_OSM_roads_all_states_grid.shp"),
    layer = "CONUS_OSM_roads_all_states_grid.shp",
    driver = "ESRI Shapefile",
    delete_layer = TRUE
)
print(paste0("Save: ", output_path, "shp/CONUS_OSM_roads_all_states_grid.shp"))