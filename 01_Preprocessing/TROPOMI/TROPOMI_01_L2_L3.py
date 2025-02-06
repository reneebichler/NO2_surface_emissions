## ------------------------------------------------------------------------------------
## Libraries
## ------------------------------------------------------------------------------------

## Source Codes
## UVAI: https://atmospherictoolbox.org/media/usecases/Usecase_2_S5P_AAI_Siberia_Smoke.html
## NO2: https://atmospherictoolbox.org/media/usecases/Usecase_4_S5P_NO2_LosAngeles_port.html
## NO2: https://creodias.docs.cloudferro.com/en/latest/cuttingedge/Processing-Sentinel-5P-data-on-air-pollution-using-Jupyter-Notebook-on-Creodias.html 

import harp
import numpy as np
#import matplotlib.pyplot as plt
#import cartopy.crs as ccrs
#import cartopy.io.img_tiles as cimgt
#from cmcrameri import cm
import os
import glob
import re
import pandas as pd
import geopandas as gpd


## ------------------------------------------------------------------------------------
## Variables
## ------------------------------------------------------------------------------------

## Set directory to NetCDF files
#directory_path = "/proj/ie/proj/Wellcome-ZEAS/RemoteSensing/DATA/Sentinel-5P/L2/OFFL/*/"
directory_path = "/Volumes/MyBook2/DATA/Sentinel-5P/NO2/L2/OFFL"

## Output
output_path_l3 = "/Volumes/MyBook2/DATA/Sentinel-5P/NO2/L3/OFFL"

## Find NetCDF files
nc_files = glob.glob(os.path.join(directory_path, '/*/*.nc'))
#print(nc_files)

startdate = '2024-01-01'
enddate = '2024-12-31'

N = 89.00
S = -89.00
W = -179.00
E = 179.00

SR = 0.01

## ------------------------------------------------------------------------------------
## Main
## ------------------------------------------------------------------------------------

date_l = pd.date_range(start = startdate, end = enddate)
#print(date_l)

for d in date_l:

    time_stamp = d.strftime('%Y%m%d')
    print("Process day: ", str(time_stamp))

    ## Pattern for file matching
    pattern = rf"^{directory_path}/S5P_OFFL_L2__NO2____{time_stamp}T\d{{6}}_\d{{8}}T\d{{6}}_\d+_\d{{2}}_\d{{6}}_\d{{8}}T\d{{6}}/S5P_OFFL_L2__NO2____\d{{8}}T\d{{6}}_\d{{8}}T\d{{6}}_\d+_\d{{2}}_\d{{6}}_\d{{8}}T\d{{6}}\.nc$"
    print(pattern)
    
    files_in = [file for file in nc_files if re.match(pattern, file)]
    number_of_files = len(files_in)
    print("Number of files: ", number_of_files)

    ## Set HARP bin_spatial()
    ## “bin_spatial(A,S,SR,B,W,SR)”
    ## A - is the number of latitude edge points, calculates as follows: (N latitude of AoI (55) - S latitude of AOI (49) / C (0.01)) + 1
    ## S - is the latitude offset at which to start the grid (S)
    ## SR - is the spatial resolution expressed in degrees
    ## B - is the number of longitude edge points, calculates as follows: (E longitude of AoI (25) - W longitude of AOI (14) / C (0.01)) + 1
    ## W - is the longitude offset at which to start the grid (W)
    ## SR - is the spatial resolution expressed in degrees

    A = (N-S)/SR + 1
    B = (E-W)/SR + 1

    SR_txt = str(SR)
    SR_string = SR_txt.replace(".", "P")

    print("Result A: " + str(A))
    print("Result B: " + str(B))

    ##  HARP operations for TROPOMI NO2
    operations = ";".join([
        "tropospheric_NO2_column_number_density_validity>75",
        "derive(surface_wind_speed {time} [m/s])",
        "surface_wind_speed<5",
        "keep(latitude_bounds, longitude_bounds, datetime_start,datetime_length, tropospheric_NO2_column_number_density, surface_wind_speed)",
        "derive(datetime_start {time} [days since 2000-01-01])",
        "derive(datetime_stop {time} [days since 2000-01-01])", 
        "exclude(datetime_length)",
        f"bin_spatial({int(A)},{int(S)},{float(SR)},{int(B)},{int(W)},{float(SR)})",  
        "derive(tropospheric_NO2_column_number_density [Pmolec/cm2])",
        "derive(latitude {latitude})",
        "derive(longitude {longitude})",
        "count>0"
    ])

    ## Reduced operations for combining multiple orbits
    reduce_operations = ";".join([
        "squash(time, (latitude, longitude, latitude_bounds, longitude_bounds))",
        "bin()"
    ])

    ## Create L3 product
    merged_no2 = harp.import_product(files_in, operations, reduce_operations = reduce_operations)
    print(merged_no2)

    out = f"{output_path_l3}/S5P_TROPOMI_NO2_L3_{time_stamp}_SPR_{SR_string}DEG_NOF_{number_of_files}.nc"

    harp.export_product(merged_no2, out, file_format="netcdf")

        
    

    """
    ## Extract data for plotting
    no2 = merged_no2.tropospheric_NO2_column_number_density.data
    no2_description = merged_no2.tropospheric_NO2_column_number_density.description
    no2_units = merged_no2.tropospheric_NO2_column_number_density.unit

    gridlat = np.append(merged_no2.latitude_bounds.data[:,0], merged_no2.latitude_bounds.data[-1,1])
    gridlon = np.append(merged_no2.longitude_bounds.data[:,0], merged_no2.longitude_bounds.data[-1,1])

    ## Colormap and scaling
    colortable = cm.romaO_r
    vmin = 0
    vmax = 10

    ## Map settings (W, E, S, N)
    boundaries=[W, E, S, N]

    fig = plt.figure(figsize=(10,10))

    ## Backgroundmap
    bmap = cimgt.OSM()
    #bmap = cimgt.Stamen(style='toner-lite')  

    ## Create GeoAxes with a projection
    #ax = plt.axes(projection = ccrs.PlateCarree())
    #ax.set_extent(boundaries, crs = ccrs.PlateCarree())
    ax = plt.axes(projection = bmap.crs)
    ax.set_extent(boundaries, crs = ccrs.PlateCarree())

    ## Add background map tiles
    zoom = 10
    ax.add_image(bmap, zoom)

    ## Add NO2 data with pcolormesh
    img = ax.pcolormesh(
        gridlon, gridlat,
        no2[0,:,:],
        vmin = vmin, vmax = vmax,
        cmap = colortable,
        transform = ccrs.PlateCarree(),
        alpha = 0.55
    )

    ## Add coastlines
    ax.coastlines()

    # Color bar
    cbar = fig.colorbar(img, ax=ax, orientation='horizontal', fraction=0.04, pad=0.1)
    cbar.set_label(f'{no2_description} [{no2_units}]')
    cbar.ax.tick_params(labelsize=14)

    #plt.show()
    """