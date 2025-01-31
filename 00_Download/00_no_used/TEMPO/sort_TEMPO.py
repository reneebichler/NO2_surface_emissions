## ------------------------------------------------------------------------------------
## Libraries
## ------------------------------------------------------------------------------------

import os
import shutil
import re
from datetime import datetime

## ------------------------------------------------------------------------------------
## Variables
## ------------------------------------------------------------------------------------

## Directory containing the NetCDF files
source_dir = "/Volumes/MyBook/DATA/TEMPO/NO2/Download"

## Directory where you want to organize the files into daily folders
destination_dir = "/Volumes/MyBook/DATA/TEMPO/NO2"

## ------------------------------------------------------------------------------------
## Main
## ------------------------------------------------------------------------------------

## List nedcdf files
nc_l = os.listdir(source_dir)
print(nc_l)

# Loop through all files in the source directory
for filename in nc_l:

    print("Process: ", filename)

    if filename != ".DS_Store":

        file_path = source_dir + "/" + filename

        ## Search for date pattern in filename
        date_search = re.search('V03_(.+?)T\\d{6}Z_S\\d{3}', filename)

        ## Get the date pattern
        date_group = date_search.group(1)

        ## Convert date group into date object
        date_obj = datetime.strptime(date_group, "%Y%m%d")
        
        ## Create the foldername based on the date_obj
        date_folder = date_obj.strftime("%Y-%m-%d")

        # Create the date folder if it doesn't exist
        date_folder_path = os.path.join(destination_dir, date_folder)

        ## Check if the foldername already exists
        if not os.path.exists(date_folder_path):
            os.makedirs(date_folder_path)

        ## Move the file to the appropriate folder
        shutil.move(file_path, os.path.join(date_folder_path, filename))
        print(f"Moved {filename} to {date_folder_path}")

    else:
        print("Skip filename entry: ", filename)