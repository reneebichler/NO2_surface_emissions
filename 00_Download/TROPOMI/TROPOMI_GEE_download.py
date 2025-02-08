## ------------------------------------------------------------------------------------
## Description
## ------------------------------------------------------------------------------------

"""
Download monthly mean Sentinel-5P NO2 data from Google Earth Engine, clipped to a shapefile region and exported as GeoTIFF.

Date format: YYYY-MM-DD
"""

## ------------------------------------------------------------------------------------
## Libraries
## ------------------------------------------------------------------------------------

import ee
import pandas as pd
import geopandas as gpd
from datetime import date
from calendar import monthrange

## ------------------------------------------------------------------------------------
## Variables
## ------------------------------------------------------------------------------------

sy = 2019
ey = 2022

aoi = "CONUS"
project_id = 'ee-rbichler'
data_product = 'OFFL'
google_drive_folder = 'S5P_OFFL_L3_NO2'

## Input
shapefile_path = '/Volumes/MyBook2/DATA/GEODATA/s_18mr25/CONUS.shp'

## ------------------------------------------------------------------------------------
## Functions
## ------------------------------------------------------------------------------------

## Function to download NO2 data from Sentinel-5P
def download_s5p_no2_with_shapefile(start_date, end_date, shapefile_path, output_file):
    
    ## Load the shapefile using GeoPandas
    gdf = gpd.read_file(shapefile_path)

    ## Convert the shapefile to GeoJSON format
    #geojson = gdf.to_json()

    ## Convert the GeoJSON to an Earth Engine geometry
    region = ee.Geometry.Polygon(gdf.unary_union.convex_hull.exterior.coords[:])

    ## Load the Sentinel-5P NRTI NO2 dataset
    collection = 'COPERNICUS/S5P/' + data_product + '/L3_NO2'
    no2_collection = ee.ImageCollection(collection)\
        .filterDate(start_date, end_date)\
        .filterBounds(region)

    ## Select the NO2 column density variable
    no2_image = no2_collection.select('tropospheric_NO2_column_number_density').mean()

    ## Export the image to Google Drive as GeoTIFF
    task = ee.batch.Export.image.toDrive(
        image = no2_image.clip(region),
        description = 'NO2_Export',
        folder = google_drive_folder,
        fileNamePrefix = output_file,
        region = region.bounds().getInfo()['coordinates'],
        scale = 1000,  # Set the scale to 1km resolution
        crs = 'EPSG:4326',
        fileFormat = 'GeoTIFF'
    )

    task.start()
    print(f"Export started for {output_file}; Check your Google Drive for the GeoTIFF file.")

## ------------------------------------------------------------------------------------
## Main
## ------------------------------------------------------------------------------------

if __name__ == "__main__":

    ## Trigger the authentication flow.
    ee.Authenticate()

    ## Initialize the library.
    ee.Initialize(project = project_id)

    ## Create a yearly list
    year_l = list(range(sy, ey + 1))

    for YEAR in year_l:

        start_date1 = YEAR + '-01-01'
        end_date1 = YEAR + '-12-31'

        ## Create the output filename
        output_file1 = aoi + '_S5P_' + data_product + '_L3_NO2_ym_' + start_date1 + '_' + end_date1
        print(output_file1)

        ## Call the function
        download_s5p_no2_with_shapefile(start_date1, end_date1, shapefile_path, output_file1)

        df = pd.DataFrame()

        ## Get the first date of a month "2024-01-01" and the last day of a month "2024-01-31"
        ## and store the information with concat() to the empty data frame
        for month in range(1, 13):
            start = date(YEAR, month, 1)
            end = date(YEAR, month, monthrange(YEAR, month)[1])
            df1 = pd.DataFrame({"start":[start], "end":[end]})
            df = pd.concat([df, df1], ignore_index=True)
            print(df1)

        ## Create an index list based on the length of the data frame
        idx_l = list(range(len(df)))

        for idx in idx_l:

            ## Retrieve the start date and end date based on the index (idx)
            start_date2 = str(df.loc[idx, 'start'])
            end_date2 = str(df.loc[idx, 'end'])
            print('Start date:', start_date2, '| End date:', end_date2, sep=" ")

            ## Create the output filename
            output_file2 = aoi + '_S5P_' + data_product + '_L3_NO2_mm_' + start_date2 + '_' + end_date2
            print(output_file2)

            ## Call the function
            download_s5p_no2_with_shapefile(start_date2, end_date2, shapefile_path, output_file2)

print("Complete!")

## Note: To export the data to Google Drive can take a moment.
## Check status: https://code.earthengine.google.com/tasks