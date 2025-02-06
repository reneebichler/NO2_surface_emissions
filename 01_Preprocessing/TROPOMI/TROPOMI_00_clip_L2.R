## ------------------------------------------------------------------------------------
## Libraries
## ------------------------------------------------------------------------------------

# Load libraries for NetCDF and shapefile handling
library(ncdf4)
library(sf)
library(dplyr)
library(raster)
library(tidyr)

library(terra)



## ------------------------------------------------------------------------------------
## Variables
## ------------------------------------------------------------------------------------

## Input
nc_file_path <- "/Volumes/MyBook2/DATA/Sentinel-5P/NO2/L2/OFFL"
shapefile_path <- "/Users/reneebichler/Downloads/s_18mr25/CONUS.shp"

## Output
output_nc_file <- "/Volumes/MyBook2/DATA/Sentinel-5P/NO2/L2/crop"

## ------------------------------------------------------------------------------------
## Main
## ------------------------------------------------------------------------------------

# Automatically generate the output file name by appending '_cropped' before the extension
file_base_name <- tools::file_path_sans_ext(basename(nc_file_path))  # Extract file name without extension
output_nc_file <- file.path(dirname(output_nc_file), paste0(file_base_name, "_cropped.nc"))  # Create output path

netcdf_files <- list.files(path = nc_file_path, pattern = "\\.nc$", recursive = TRUE, full.names = TRUE)
netcdf_files

polygon <- read_sf(shapefile_path)
polygon <- st_transform(polygon, crs = "EPSG:4326")

# Automatically create the output file name by adding '_cropped' to the original file name
output_nc_file <- sub("\\.nc$", "_cropped.nc", netcdf_files)

for (file in netcdf_files) {
    print(paste0("Process: ", file))

    #file <- netcdf_files[36]

    filename <- paste0("CONUS_", strsplit(file, split = "/")[[1]][length(strsplit(file, split = "/")[[1]])])
    filename_png <- gsub("nc", "png", filename)
    filename_nc <- filename

    # Load the shapefile (assumes the shapefile's CRS matches the NetCDF file's CRS)
    polygon <- read_sf(shapefile_path)
    polygon <- st_transform(polygon, crs = "EPSG:4326")

    bbox <- st_bbox(polygon)
    bbox1 <- st_as_sfc(st_bbox(polygon))
    bbox_buf <- st_buffer(bbox1, dist = 1000000)

    # Open the NetCDF file
    nc_data <- nc_open(file)

    # Read and plot the data
    var <- ncvar_get(nc_data, "PRODUCT/nitrogendioxide_tropospheric_column")
    lat <- ncvar_get(nc_data, "PRODUCT/latitude")
    lon <- ncvar_get(nc_data, "PRODUCT/longitude")

    nc_close(nc_data)

    lat_mask <- lat < bbox$ymax & lat > bbox$ymin
    lon_mask <- lon < bbox$xmax & lon > bbox$xmin
    latlon_mask <- lat < bbox$ymax & lat > bbox$ymin & lon < bbox$xmax & lon > bbox$xmin

    var[!latlon_mask] <- NA
    print("Matrix with values outside mask set to NA")
    print(paste0("Max value: ", max(var, na.rm=TRUE)))

    if (all(is.na(var)) ) {
        print("Variable only includes NA values.")
    
    } else {
        print("Create NetCDF")

        # Define dimensions
        lat_dim <- ncdim_def(name = "latitude", units = "degrees_north", vals = lat)
        lon_dim <- ncdim_def(name = "longitude", units = "degrees_east", vals = lon)
        
        # Define the variable (for 2D data)
        var_def <- ncvar_def(
            name = "nitrogendioxide_tropospheric_column",
            units = "mol m-2", 
            dim = list(lon_dim, lat_dim),
            missval = NA, 
            longname = "Tropospheric vertical column of nitrogen dioxide",
            prec = "float",
            compression = 6
        )

        ## Convert values in var to mol cm-2


        # Create NetCDF file
        nc_filename <- paste0("/Volumes/MyBook2/DATA/Sentinel-5P/NO2/L2/OFFL_CONUS/", filename_nc)
        nc_out <- nc_create(nc_filename, vars = list(var_def))
        
        # Write data to NetCDF
        ncvar_put(nc_out, var_def, var)

        # Add global attributes (optional)
        ncatt_put(nc_out, 0, "title", "Georeferenced NetCDF")
        ncatt_put(nc_out, 0, "institution", "UNC Chapel Hill, IE-CEMPD")
        ncatt_put(nc_out, 0, "source", "Generated using R")

        # Close the file
        nc_close(nc_out)

        cat("NetCDF file created successfully:", nc_filename)

        df <- data.frame(
            "var" = as.vector(var),
            "lat" = as.vector(lat),
            "lon" = as.vector(lon)
        )

        xy <- df[, c("lon", "lat")]

        spdf <- SpatialPointsDataFrame(
            coords = xy,
            data = df,
            proj4string = CRS("EPSG:4326")
        )
        spdf <- sf::st_as_sf(spdf)

        ref_plot <- ggplot() +
        geom_sf(data = spdf, aes(fill = var)) +
        geom_sf(data = polygon, color = "orange", fill = "transparent") +
        geom_sf(data = bbox1, color = "red", fill = "transparent") 
        #geom_sf(data = bbox_buf, color = "blue", fill = "transparent") +
        scale_fill_viridis_c(option = "magma", begin = 0.1, na.value = "grey90")

        ggsave(paste0("/Volumes/MyBook2/DATA/Sentinel-5P/NO2/L2/ref_plot_", filename_png), plot = ref_plot)
    }
}
print("Complete!")