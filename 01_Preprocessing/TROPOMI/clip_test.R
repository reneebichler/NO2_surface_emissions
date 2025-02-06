## ------------------------------------------------------------------------------------
## Libraries
## ------------------------------------------------------------------------------------

# Load libraries for NetCDF, shapefile handling, and data manipulation
library(ncdf4)
library(sf)
library(dplyr)
library(raster)
library(tidyr)
library(terra)
library(ggplot2)

## ------------------------------------------------------------------------------------
## Variables
## ------------------------------------------------------------------------------------

# Define input and output paths
nc_file_path <- "/Volumes/MyBook2/DATA/Sentinel-5P/NO2/L2/OFFL"
shapefile_path <- "/Users/reneebichler/Downloads/s_18mr25/CONUS.shp"
output_dir <- "/Volumes/MyBook2/DATA/Sentinel-5P/NO2/L2/OFFL_CONUS"

# Ensure output directory exists
if (!dir.exists(output_dir)) {
  dir.create(output_dir, recursive = TRUE)
}

## ------------------------------------------------------------------------------------
## Load Shapefile
## ------------------------------------------------------------------------------------

polygon <- st_read(shapefile_path) %>% 
  st_transform(crs = "EPSG:4326")

bbox <- st_bbox(polygon)
bbox_geom <- st_as_sfc(bbox)

## ------------------------------------------------------------------------------------
## Process NetCDF Files
## ------------------------------------------------------------------------------------

netcdf_files <- list.files(path = nc_file_path, pattern = "\\.nc$", recursive = TRUE, full.names = TRUE)

for (file in netcdf_files) {
    message("Processing: ", file)

    # Generate output filenames
    base_name <- tools::file_path_sans_ext(basename(file))
    output_nc_file <- file.path(output_dir, paste0(base_name, "_cropped.nc"))
    output_png_file <- file.path(output_dir, paste0(base_name, "_plot.png"))

    # Open NetCDF file
    nc_data <- nc_open(file)

    # Read variables
    var <- ncvar_get(nc_data, "PRODUCT/nitrogendioxide_tropospheric_column")
    lat <- ncvar_get(nc_data, "PRODUCT/latitude")
    lon <- ncvar_get(nc_data, "PRODUCT/longitude")

    # Apply bounding box mask
    print("Create mask.")
    mask <- lat < bbox$ymax & lat > bbox$ymin & lon < bbox$xmax & lon > bbox$xmin

    var[!mask] <- NA
    print("Matrix with values outside mask set to NA")

    ## Convert values to mol cm-2
    var <- 6.02214e19 * var

    ## Make the value smaller by dividing them by 10e15
    var <- var / 10e15

    nc_close(nc_data)

    if (all(is.na(var))) {
        message("All values are NA for: ", file)
        next
    }

    # Define dimensions
    print("Define the lat/lon dimensions for the NetCDF.")
    lat_dim <- ncdim_def(name = "latitude", units = "degrees_north", vals = lat)
    lon_dim <- ncdim_def(name = "longitude", units = "degrees_east", vals = lon)

    # Define NO2 variable
    print("Define the NO2 variable for the NetCDF.")
    var_def <- ncvar_def(
        name = "nitrogendioxide_tropospheric_column",
        units = "mol cm-2",
        dim = list(lat_dim, lon_dim),
        missval = NA,
        longname = "Tropospheric vertical column of nitrogen dioxide",
        prec = "float"
    )
    browser()
    # Create and write to NetCDF
    nc_out <- nc_create(output_nc_file, vars = list(var_def))
    ncvar_put(nc_out, var_def, var)

    # Add global attributes
    ncatt_put(nc_out, 0, "title", "Georeferenced NetCDF")
    ncatt_put(nc_out, 0, "institution", "UNC Chapel Hill, IE-CEMPD")
    ncatt_put(nc_out, 0, "source", "Generated using R")

    nc_close(nc_out)
    message("NetCDF file created: ", output_nc_file)

    # Create dataframe for plotting
    df <- data.frame(
        lat = as.vector(lat),
        lon = as.vector(lon),
        no2 = as.vector(var)
    )

    # Convert to spatial object
    spdf <- st_as_sf(df, coords = c("lat", "lon"), crs = "EPSG:4326")

    # Plot
    plot <- ggplot() +
    geom_sf(data = spdf, aes(color = no2), size = 0.5) +
    geom_sf(data = polygon, color = "orange", fill = NA) +
    geom_sf(data = bbox_geom, color = "red", fill = NA) +
    scale_color_viridis_c(option = "magma", na.value = "grey90") +
    theme_minimal()

    ggsave(output_png_file, plot = plot)
    message("Plot saved: ", output_png_file)
}

message("Processing complete!")