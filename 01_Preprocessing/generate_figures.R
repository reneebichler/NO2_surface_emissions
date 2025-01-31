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
tif_l <- c("lcz", "osm")

cellsize <- 1

xmin <- -124    # -180
xmax <- -66     # 180
ymin <- 25      # -90
ymax <- 49      # 90

## Input
lcz_path <- "/proj/ie/proj/Wellcome-ZEAS/RemoteSensing/Demuzere_2020/"
osm_path <- "/proj/ie/proj/Wellcome-ZEAS/RemoteSensing/DATA/OSM/"
dem_path <- ""

polygon_path <- "/proj/ie/proj/Wellcome-ZEAS/RemoteSensing/GEODATA/s_18mr25/s_18mr25/s_18mr25.shp"

## Output
outpath <- "/proj/ie/proj/Wellcome-ZEAS/RemoteSensing/Results/Plots/"

## ------------------------------------------------------------------------------------
## Functions and dictionaries
## ------------------------------------------------------------------------------------

tif_dic <- c(
  "lcz" = paste0(lcz_path, "CONUS_LCZ_map_NLCD_v1.0.tif"),
  "osm" = paste0(osm_path, "tif/Texas_highway_raster.tif"),
  "dem" = paste0(dem_path, "")
)

title_dic <- c(
  "lcz" = "Local Climate Zones",
  "osm" = "OpenStreetMap",
  "dem" = "Digital Elevation Model"
)

## ------------------------------------------------------------------------------------
## Main
## ------------------------------------------------------------------------------------

for (t in tif_l) {

  ## Load tif file
  tif <- terra::rast(tif_dic[t])

  ## Load polygon
  polygon <- read_sf(polygon_path)

  ## Filter only for CONUS and exclude the following
  exclude <- c(
    "Alaska", "American Samoa", "Hawaii", "Puerto Rico", "Marshall Islands",
    "Fed States of Micronesia", "Rhode Island", "Virgin Islands", "Guam", "Palau",
    "Northern Mariana Islands"
  )

  ## Remove all areas in exclude from polygon
  polygon <- polygon %>% filter(!polygon$NAME %in% exclude)

  ## Create the map
  map <- ggplot() +
    geom_sf(data = polygon) +
    geom_spatraster(data = tif, aes(fill = names(tif))) +

    coord_sf(crs = 5070, expand = TRUE) +

    labs(
      x = NULL, 
      y = NULL, 
      #title = "Title1", 
      #subtitle = "Title2", 
      caption = "Data: U.S. States and Territories (NOAA), 18 March 2025"
    ) + 

    scale_fill_manual(
      values = rev(scico(8, palette = "davos")[2:7]),
      #breaks = rev(brks_scale),
      name = title_dic[t],
      drop = FALSE,
      #labels = labels_scale,
      guide = guide_legend(
        direction = "horizontal",
        keyheight = unit(2, units = "mm"), 
        keywidth = unit(70/length(labels), units = "mm"),
        title.position = 'top',
        title.hjust = 0.5,
        label.hjust = 1,
        nrow = 1,
        byrow = TRUE,
        reverse = TRUE,
        label.position = "bottom"
      )
    ) +

    annotation_scale(
      location = "bl",
      bar_cols = c("grey60", "white")
    ) +

    annotation_north_arrow(
      location = "bl",
      which_north = "true",
      pad_x = unit(0.6, "in"),
      pad_y = unit(0.4, "in"),
      style = north_arrow_nautical(
        fill = c("grey40", "white"),
        line_col = "grey20"
      )
    ) +

    theme_bw() +
    theme(
      legend.position = "bottom",
      plot.title = element_text(hjust = 0.5),
      plot.subtitle = element_text(hjust = 0.5),
      panel.background = element_rect(fill = "aliceblue")
    )

  ## Create filename
  filename <- paste0(outpath, t, "_", cellsize_name, "x", cellsize_name, ".png")

  ## Save plot
  ggsave(filename, plot = map, width = 20, height = 20, units = "cm")
}

print("Complete")