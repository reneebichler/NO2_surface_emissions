<a id="readme-top"></a>


<!-- PROJECT LOGO -->
<br />
<div align="center">
  <h3 align="center">00_Download - Download the input data</h3>
  <p align="center">
    project_description coming soon ...
    <br />
    <a href="https://github.com/reneebichler/surface-emissions/issues/new?labels=bug&template=bug-report---.md">Report Bug</a>
    <a href="https://github.com/reneebichler/surface-emissions/issues/new?labels=enhancement&template=feature-request---.md">Request Feature</a>
  </p>
</div>



<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li><a href="#code-structure">Code Structure</a></li>
    <li><a href="#file-description">File Description</a></li>
    <li><a href="#getting-started">Getting Started</a></li>
    <li><a href="#output-files">Output Files</a></li>
  </ol>
</details>



<!-- Code Structure -->
## Code Structure

00_Download provides codes to download EPA-AQS data in R for an input ploygon, in this case CONUS, as well as two Python codes for the automatic download of Sentinel-5P TROPOMI data.

* EPA-AQS
  * download_EPA-AQS.R
 
    What do you need to run this code?
      * Polygon (shp or gpkg)

* TROPOMI
  * access_token_credentials.py
  * download_TROPOMI_L2.py
  * extract_TROPOMI_L2_zip.py
 
    What do you need to run this code?
      * [Access token](https://documentation.dataspace.copernicus.eu/APIs/SentinelHub/Overview/Authentication.html) for the Copernicus Dataspace

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- File Description -->
## File Description

The following table gives an insight on the data products downloaded and further processed in the 00_Download folder.

EPA-AQS file name:
* EPA-AQS_h_2019-01-01-2019-01-31_42602_xminlon_-125_xmaxlon_-67_yminlat_25_ymaxlat_49.csv
  * EPA-AQS ... Environmental Protection Agency - Air Quality Service
  * h ... hourly time resolution
  * 2019-01-01 ... start period
  * 2019-01-31 ... end period
  * 42602 ... Nitrogen dioxide identifier
  * xminlon_-125 ... bounding box west (left) coordinate
  * xmaxlon_-67 ... bounding box east (right) coordinate
  * yminlat_25 ... bounding box south (bottom) coordinate
  * ymaxlat_49 ... bounding box north (top) coordinate

Sentinel-5P original file name:
* S5P_OFFL_L2__NO2____20240101T110759_20240101T124929_32221_03_020600_20240103T033227
  * S5P ... Sentinel-5P
  * OFFL ... Offline data
  * L2 ... Level 2 data product
  * NO2 ... Nitrogend dioxide



<!-- GETTING STARTED -->
## Getting Started

coming soon ...

### Requirements

1. Open terminal in VSC.
2. For EPA-AQS data:
   1. Run
        ```sh
        Rscript download_EPA-AQS.R
        ```
4. For TROPOMI data:
   1. Install anaconda
        ```sh
        pip3 install anaconda
        ```
   2. Navigate to anaconda
        ```sh
        source /opt/anaconda3/bin/activate 
        ```
   3. Create Virtual Environment
        ```sh
        conda create --name surface-emissions python=3.9
        ```
   4. Activate the environment
        ```sh
        conda activate surface-emissions
        ```
   5. Install Python package dependencies
        ```sh
        pip3 install -r requirements.txt
        ```
   6. Run
        ```sh
        python3 download_TROPOMI_L2.py
        python3 extract_TROPOMI_zip.py
        ```

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- Output Files -->
## Output Files

The following table presents the files processed in 00_Download as well as the download link.

| Input         | Format         | Resolution      | Period      | Download              |
| ---           | ---            | ---             | ---         | ---                   |
| EPA-AQS       | CSV            | hourly CONUS    | 2019-2024   | Link coming soon ...  |
| TROPOMI OFFL  | zip to NetCDF  | daily L2 global | 2024        | Link coming soon ...  |

<p align="right">(<a href="#readme-top">back to top</a>)</p>
