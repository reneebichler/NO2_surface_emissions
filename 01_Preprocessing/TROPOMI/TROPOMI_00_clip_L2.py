## ------------------------------------------------------------------------------------
## Libraries
## ------------------------------------------------------------------------------------

# Load libraries for NetCDF and shapefile handling
%matplotlib inline
import os
import xarray as xr
import numpy as np
import netCDF4 as nc

import matplotlib.pyplot as plt
from matplotlib.colors import LogNorm
import cartopy.crs as ccrs
from cartopy.mpl.gridliner import LONGITUDE_FORMATTER, LATITUDE_FORMATTER

from matplotlib.axes import Axes
from cartopy.mpl.geoaxes import GeoAxes
GeoAxes._pcolormesh_patched = Axes.pcolormesh

import geopandas as gpd

import warnings
warnings.simplefilter(action = "ignore", category = RuntimeWarning)

## ------------------------------------------------------------------------------------
## Variables
## ------------------------------------------------------------------------------------

## Input
nc_file_path = "/Volumes/MyBook2/DATA/Sentinel-5P/NO2/L2/OFFL"
shapefile_path = "/Users/reneebichler/Downloads/s_18mr25/CONUS.shp"

## Output
output_nc_file = "/Volumes/MyBook2/DATA/Sentinel-5P/NO2/L2/crop"

## ------------------------------------------------------------------------------------
## Main
## ------------------------------------------------------------------------------------

# Automatically generate the output file name by appending '_cropped' before the extension
file_base_name <- tools::file_path_sans_ext(basename(nc_file_path))  # Extract file name without extension
output_nc_file <- file.path(dirname(output_nc_file), paste0(file_base_name, "_cropped.nc"))  # Create output path

netcdf_files <- list.files(path = directory_path, pattern = "\\.nc$", recursive = TRUE, full.names = TRUE)





var = s5p_file.groups['PRODUCT'].variables['carbonmonoxide_total_column']
lon = s5p_file.groups['PRODUCT'].variables['longitude'][:][0,:,:]
lat = s5p_file.groups['PRODUCT'].variables['latitude'][:][0,:,:]