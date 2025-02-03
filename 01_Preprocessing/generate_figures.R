## ------------------------------------------------------------------------------------
## Libraries
## ------------------------------------------------------------------------------------

library(terra)
library(tidyterra)
library(sf)
library(ggplot2)
library(ggthemes)
library(scico)
library(ggspatial)

## ------------------------------------------------------------------------------------
## Variables
## ------------------------------------------------------------------------------------

## Create raster list
tif_l <- c("lcz")

cellsize <- 1

xmin <- -124    # -180
xmax <- -66     # 180
ymin <- 25      # -90
ymax <- 49      # 90

epsg_code <- 4326

## Input
input_path <- "/proj/ie/proj/Wellcome-ZEAS/RemoteSensing/"
polygon_path <- "DATA/GEODATA/s_18mr25/s_18mr25.shp"

## Output
outpath <- "/proj/ie/proj/Wellcome-ZEAS/RemoteSensing/Results/Plots/"

## ------------------------------------------------------------------------------------
## Functions and dictionaries
## ------------------------------------------------------------------------------------

tif_dic <- c(
  "lcz" = paste0(input_path, "Results/LCZ/01_lcz_grid_0.01x0.01_-124_-66_25_49.tif"),
  "osm" = paste0(input_path, "Results/OSM/USA/tif/CONUS_OSM_roads_all_states_v2.tif")
)

title_dic <- c(
  "lcz" = "Local Climate Zones",
  "osm" = "OpenStreetMap",
  "dem" = "Digital Elevation Model"
)

source_dic <- c(
  "lcz" = "LCZ from Demuzere et al. (2020)",
  "osm" = "OpenStreetMap",
  "dem" = "USGS SRTM"
)

## ------------------------------------------------------------------------------------
## Main
## ------------------------------------------------------------------------------------

for (t in tif_l) {

  ## Load tif file
  tif <- terra::rast(tif_dic[t])

  ## Reproject raster file
  plate_carree_crs <- paste0("EPSG:", epsg_code)

  if (crs(tif) != plate_carree_crs) {
  	tif <- terra::project(tif, plate_carree_crs)
  }

  ## Get names from tif
  tif_name <- names(tif)
  cellsize_name <- as.character(cellsize)

  ## Load polygon
  polygon <- read_sf(paste0(input_path, polygon_path))

  ## Reproject polygon
  if (st_crs(polygon)$epsg != epsg_code) {
  	polygon <- st_transform(polygon, epsg_code)
  }

  ## Filter only for CONUS and exclude the following
  exclude <- c(
    "Alaska", "American Samoa", "Hawaii", "Puerto Rico", "Marshall Islands",
    "Fed States of Micronesia", "Rhode Island", "Virgin Islands", "Guam", "Palau",
    "Northern Mariana Islands"
  )

  ## Remove all areas in exclude from polygon
  polygon <- polygon %>% filter(!polygon$NAME %in% exclude)

  ## Convert the raster to a data frame
  raster_df <- as.data.frame(tif, xy = TRUE)
  colnames(raster_df) <- c("x", "y", "value")

  ## Define the color scheme
  color_scheme <- c(
    "0" = "#fb00ff",    # NULL
    "1" = "#8c0000",    # Compact Highrise
    "2" = "#d10000",    # Compact Midrise
    "3" = "#ff0000",    # Compact Lowrise
    "4" = "#bf4d00",    # Open Highrise
    "5" = "#ff6600",    # Open Midrise
    "6" = "#ff9955",    # Open Lowrise
    "7" = "#faee05",    # Lightweight lowrise
    "8" = "#bcbcbc",    # Large lowrise
    "9" = "#ffccaa",    # Sparsely built
    "10" = "#555555",   # Heavy industry
    "11" = "#006a00",   # Dense trees
    "12" = "#00aa00",   # Scattered trees
    "13" = "#648525",   # Bush or scrub
    "14" = "#b9db79",   # Low plants
    "15" = "#000000",   # Bare rock or paved
    "16" = "#fbf7ae",   # Bare soil or sand
    "17" = "#6a6aff"    # Water
  )

  ## Create a named legend mapping
  legend_labels <- c(
    "0" = "NULL",
    "1" = "1 - Compact Highrise",
    "2" = "2 - Compact Midrise",
    "3" = "3 - Compact Lowrise",
    "4" = "4 - Open Highrise",
    "5" = "5 - Open Midrise",
    "6" = "6 - Open Lowrise",
    "7" = "7 - Lightweight Lowrise",
    "8" = "8 - Large Lowrise",
    "9" = "9 - Sparsely Built",
    "10" = "10 - Heavy Industry",
    "11" = "A - Dense Trees",
    "12" = "B - Scattered Trees",
    "13" = "C - Bush or Scrub",
    "14" = "D - Low Plants",
    "15" = "E - Bare Rock or Paved",
    "16" = "F - Bare Soil or Sand",
    "17" = "G - Water"
  )

  ## Convert the value column to a factor with defined levels
  raster_df["category"] <- factor(raster_df$value, levels = names(color_scheme))

  ## Create the map
  map <- ggplot() +

    geom_tile(data = raster_df, mapping = aes(x = x, y = y, fill = category)) +
    scale_fill_manual(
      name = title_dic[t],
      values = color_scheme,
      labels = legend_labels,
      na.value = "transparent"
    ) +
    geom_sf(data = polygon, fill = "transparent", color = "black") +

    labs(
      x = NULL, 
      y = NULL 
      #caption = paste0("Data: U.S. States and Territories (NOAA), version 18 March 2025; ", source_dic[t], "; EPSG:", epsg_code")
    ) + 

    annotation_scale(
      location = "bl",
      bar_cols = c("grey60", "white"),
      text_col = "grey60",
      line_col = "grey60", 
      text_family = "serif"
    ) +

    theme_bw() +
    theme(
      legend.position = "bottom",
      legend.text = element_text(size = 10),
      legend.key.size = unit(0.2, 'cm'),
      legend.key.height = unit(0.2, 'cm'),
      legend.key.width = unit(0.2, 'cm'),
      text = element_text(family = "serif"),
      panel.grid.major = element_line(linetype = "dashed", color = "gray", linewidth = 0.1),
      panel.grid.minor = element_blank()
      #panel.background = element_rect(fill = "aliceblue")
    ) +
    guides(
      ## Change polistion of the legend title
      fill = guide_legend(title.position = "top",),
    )

  ## Create filename
  filename <- paste0(outpath, tif_name, ".png")

  ## Save plot
  ggsave(filename, plot = map, width = 8, height = 5)
}

print("Complete")