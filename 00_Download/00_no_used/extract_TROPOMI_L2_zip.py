## ------------------------------------------------------------------------------------
## Libraries
## ------------------------------------------------------------------------------------

import zipfile
import os
import glob
import shutil

## ------------------------------------------------------------------------------------
## Variables
## ------------------------------------------------------------------------------------

## Define zip input folder and output folder
path_zip = "/proj/ie/proj/Wellcome-ZEAS/RemoteSensing/DATA/Sentinel-5P/L2/NRTI/zip/"
path_out = "/proj/ie/proj/Wellcome-ZEAS/RemoteSensing/DATA/Sentinel-5P/L2/NRTI"
path_badzip = "/proj/ie/proj/Wellcome-ZEAS/RemoteSensing/DATA/Sentinel-5P/L2/badzipfile"
path_archive = "/proj/ie/proj/Wellcome-ZEAS/RemoteSensing/DATA/Sentinel-5P/L2/zip_archive"

## Create folders if they don't exist
os.makedirs(path_badzip, exist_ok=True)
os.makedirs(path_archive, exist_ok=True)

## ------------------------------------------------------------------------------------
## Main
## ------------------------------------------------------------------------------------

## Set current working directory to zip folder
cwd = os.getcwd()
os.chdir(path_zip)

## Search for zip files
extension = 'zip'
zip_files = glob.glob(f'*.{extension}')

## Extract zip files
for z in zip_files:
    print(f"Processing: {z}")
    try:
        with zipfile.ZipFile(z, 'r') as zObject:
            zObject.extractall(path=path_out)
        print(f"Successfully extracted: {z}")
        
        ## Move the processed zip file to the archive folder
        shutil.move(z, os.path.join(path_archive, z))
    except zipfile.BadZipFile:
        print(f"Error: {z} is not a valid zip file. Moving to badzipfile folder.")
        
        ## Move problematic zip file to the badzipfile folder
        shutil.move(z, os.path.join(path_badzip, z))

## Set current working directory back to original path
os.chdir(cwd)

print("Processing complete.")