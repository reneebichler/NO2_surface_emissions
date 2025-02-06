import ee
import geopandas as gpd
import datetime

# Trigger the authentication flow.
ee.Authenticate()

# Initialize the library.
ee.Initialize(project='ee-rbichler')

# Function to download NO2 data from Sentinel-5P
def download_s5p_no2_with_shapefile(start_date, end_date, shapefile_path, output_file):
    """
    Download daily Sentinel-5P NO2 data from Google Earth Engine, clipped to a shapefile region and exported as GeoTIFF.

    Parameters:
    start_date (str): Start date in 'YYYY-MM-DD' format.
    end_date (str): End date in 'YYYY-MM-DD' format.
    shapefile_path (str): Path to the shapefile defining the region of interest.
    output_file (str): Path to save the downloaded file.
    """
    
    # Load the shapefile using GeoPandas
    gdf = gpd.read_file(shapefile_path)

    # Convert the shapefile to GeoJSON format
    geojson = gdf.to_json()

    # Convert the GeoJSON to an Earth Engine geometry
    region = ee.Geometry.Polygon(gdf.unary_union.convex_hull.exterior.coords[:])

    # Load the Sentinel-5P NRTI NO2 dataset
    no2_collection = ee.ImageCollection('COPERNICUS/S5P/NRTI/L3_NO2')\
        .filterDate(start_date, end_date)\
        .filterBounds(region)

    # Select the NO2 column density variable
    no2_image = no2_collection.select('NO2_column_number_density').mean()

    # Export the image to Google Drive as GeoTIFF
    task = ee.batch.Export.image.toDrive(
        image=no2_image.clip(region),
        description='NO2_Export',
        folder='EarthEngineExports',
        fileNamePrefix=output_file,
        region=region.bounds().getInfo()['coordinates'],
        scale=1000,  # Set the scale to 1km resolution
        crs='EPSG:4326',
        fileFormat='GeoTIFF'  # Export as GeoTIFF
    )

    task.start()
    print(f"Export started for {output_file}. Check your Google Drive for the GeoTIFF file.")


# Example usage
if __name__ == "__main__":
    # Define date range
    start_date = '2023-12-01'
    end_date = '2023-12-01'  # Single day for daily data

    # Path to the shapefile
    shapefile_path = '/proj/ie/proj/Wellcome-ZEAS/RemoteSensing/DATA/GEODATA/s_18mr25/CONUS.shp'  # Replace with your shapefile path

    # Define output filename
    output_file = 'NO2_Dec01_2023_Clipped'

    # Call the function
    download_s5p_no2_with_shapefile(start_date, end_date, shapefile_path, output_file)

# Note:
# The exported GeoTIFF file will appear in your Google Drive under the 'EarthEngineExports' folder.
# Make sure to have sufficient storage in Google Drive and appropriate permissions for Earth Engine exports.
