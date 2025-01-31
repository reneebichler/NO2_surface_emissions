## ------------------------------------------------------------------------------------
## Libraries
## ------------------------------------------------------------------------------------

import zipfile39 as zipfile
import os
import glob

## ------------------------------------------------------------------------------------
## Variables
## ------------------------------------------------------------------------------------

## Define zip input folder and output folder
path_zip = f"/proj/ie/proj/Wellcome-ZEAS/RemoteSensing/DATA/Sentinel-5P/L2/zip/"
path_out = f"/proj/ie/proj/Wellcome-ZEAS/RemoteSensing/DATA/Sentinel-5P/L2/OFFL"

## ------------------------------------------------------------------------------------
## Main
## ------------------------------------------------------------------------------------

## Set current working directory to zip folder
cwd = os.getcwd()
os.chdir(path_zip)

## Search for zip files
extension = 'zip'
result_l = glob.glob('*.{}'.format(extension))

## ToDo!! In case there is a problematic zip file move it into an "error" folder

## ToDo!! Move processed zip file into a "completed" folder or delete the file

## Extract zip files
for z in result_l:
    print("Extract: ", z)
    with zipfile.ZipFile(z, 'r') as zObject: 
        zObject.extractall(path = path_out)

## Set current working directory back to original path
os.chdir(cwd)