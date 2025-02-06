## ------------------------------------------------------------------------------------
## Libraries
## ------------------------------------------------------------------------------------

# source /opt/anaconda3/bin/activate
# conda activate harp-env

# conda install conda-forge::r-credentials
# conda install conda-forge::fixie-creds
# pip install creds

#from math import prod
import pandas as pd
import requests
import json
#import creds
import datetime
import os

#cwd = os.getcwd()
#path = cwd + '/surface-emissions/00_Download'
#os.chdir(path)

from access_token_credentials import Token
token = Token()

## ------------------------------------------------------------------------------------
## Variables
## ------------------------------------------------------------------------------------

## YYYY-mm-dd
startdate = '2019-02-01'
enddate = '2024-02-28'

data_collection = "SENTINEL-5P"
product_variable = "L2__NO2___"
product_type = "NRTI"

#aoi = 'POLYGON ((-180 90, -180 -90, 180 -90, 180 90, -180 90))'
#aoi = 'POLYGON%20((-180%2090,%20-180%20-90,%20180%20-90,%20180%2090,%20-180%2090))%27)))'

#aoi = 'POLYGON ((-124 49, -124 25, -66 25, -66 49, -124 49))'
aoi = 'POLYGON%20((-124%2049,%20-124%2025,%20-66%2025,%20-66%2049,%20-124%2049))%27)))'

outpath = f"/proj/ie/proj/Wellcome-ZEAS/RemoteSensing/DATA/Sentinel-5P/L2/NRTI/zip/"

## ------------------------------------------------------------------------------------
## Main
## ------------------------------------------------------------------------------------

## Add one day to the end date
enddate1 = str(datetime.datetime.strptime(enddate, "%Y-%m-%d") + pd.Timedelta(days=1))
date_l = pd.date_range(start=startdate, end=enddate1)
print(date_l)

for d in date_l:

    print("Process day: ", str(d))

    download_date = d.strftime('%Y-%m-%d')

    #url_req = f"https://catalogue.dataspace.copernicus.eu/odata/v1/Products?$filter=Collection/Name eq '{data_collection}' and OData.CSC.Intersects(area=geography'SRID=4326;{aoi}') and ContentDate/Start gt {start_date}T00:00:00.000Z and ContentDate/Start lt {end_date}T00:00:00.000Z&$count=True&$top=1000"
    url_req = f"https://catalogue.dataspace.copernicus.eu/odata/v1/Products?&$filter=((Collection/Name%20eq%20%27{data_collection}%27%20and%20(Attributes/OData.CSC.StringAttribute/any(att:att/Name%20eq%20%27instrumentShortName%27%20and%20att/OData.CSC.StringAttribute/Value%20eq%20%27TROPOMI%27)%20and%20(contains(Name,%27{product_variable}%27)%20and%20OData.CSC.Intersects(area=geography%27SRID=4326;{aoi}%20and%20Attributes/OData.CSC.StringAttribute/any(att:att/Name%20eq%20%27processingMode%27%20and%20att/OData.CSC.StringAttribute/Value%20eq%20%27{product_type}%27)%20and%20Online%20eq%20true)%20and%20ContentDate/Start%20ge%20{download_date}T00:00:00.000Z%20and%20ContentDate/Start%20lt%20{download_date}T23:59:59.999Z)&$orderby=ContentDate/Start%20desc&$expand=Attributes&$count=True&$top=1000&$expand=Assets&$skip=0"

    json = requests.get(url_req).json()
    df = pd.DataFrame.from_dict(json['value'])

    ## Print only specific columns
    columns_to_print = ['Id', 'Name','S3Path','GeoFootprint']  
    df[columns_to_print].head(3)
    #print(df)

    subset_df = df[df['Name'].str.contains("NO2")]
    subset_df = subset_df[subset_df['Name'].str.contains(product_type)]
    print(subset_df)

    for i in range(0, len(subset_df), 1):

        column_id_index = subset_df.columns.get_loc('Id')
        column_name_index = subset_df.columns.get_loc('Name')

        url_id = subset_df.iloc[i, column_id_index]
        url_name = subset_df.iloc[i, column_name_index][:-3]

        print("Process: ", i, "/", len(subset_df), " ", url_name)

        url = f"https://download.dataspace.copernicus.eu/odata/v1/Products({url_id})/$value".format(url_id=url_id)
        #print(url)

        access_token = token.get_user_pw()
        print("Reloded the access token function!")
        ## Access_token needs to be renewed frequently (˜10min)!!
        ## See: https://forum.dataspace.copernicus.eu/t/odata-download-repeated-failures/285/3 

        headers = {"Authorization": f"Bearer {access_token}"}

        ## Create a session and update headers
        session = requests.Session()
        session.headers.update(headers)

        ## Perform the GET request
        response = session.get(url, stream=True)

        ## Get current date and time
        now = datetime.datetime.now()
        cdatetime = now.strftime("%Y%m%d_%H%M%S")

        ## Check if the request was successful
        if response.status_code == 200:
            with open(outpath+"{url_name}.zip".format(url_name=url_name), "wb") as file:
                for chunk in response.iter_content(chunk_size=8192):
                    if chunk:  # filter out keep-alive new chunks
                        file.write(chunk)
        else:
            print(f"Failed to download file. Status code: {response.status_code}")
            print(response.text)

#os.chdir(cwd)
print("Complete!")