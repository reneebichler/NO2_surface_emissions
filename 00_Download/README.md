<a id="readme-top"></a>


<!-- PROJECT LOGO -->
<br />
<div align="center">
  <h3 align="center">Download - Download the input data</h3>
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

00_Download provides codes to download EPA-AQS data (R) for an input ploygon, in this case CONUS, as well as two Python codes for the automatic download of Sentinel-5P TROPOMI data.

* EPA-AQS
  * EPA-AQS_download_.R

* TROPOMI
  * TROPOMI_GEE_download.py

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- File Description -->
## File Description

The following table gives an insight on the data products downloaded and further processed in the 00_Download folder.

EPA-AQS file name:
* EPA-AQS_h_2019-01-01-2019-01-31_42602_xminlon_-125_xmaxlon_-67_yminlat_25_ymaxlat_49.csv

EPA-AQS ... Environmental Protection Agency - Air Quality Service
h ... hourly time resolution
2019-01-01 ... start period
2019-01-31 ... end period
42602 ... Nitrogen dioxide identifier
xminlon_-125 ... bounding box west (left) coordinate
xmaxlon_-67 ... bounding box east (right) coordinate
yminlat_25 ... bounding box south (bottom) coordinate
ymaxlat_49 ... bounding box north (top) coordinate

Sentinel-5P file name:
* CONUS_S5P_L3_NO2_mm_2019-01-01_2019-01-31.tif

CONUS ... Continental United States (Shapefile)
S5P ... Sentinel-5P
OFFL ... Offline data
L3 ... Level 3 data product
NO2 ... Nitrogend dioxide
mm ... Monthly mean
yyyy-mm-dd ... start and end date


<!-- GETTING STARTED -->
## Getting Started

coming soon ...

### Requirements

1. Open terminal in VSC.

2. For EPA-AQS data:
  1. 
    ```sh
    Rscript download_EPA-AQS.R
    ```

3. For TROPOMI data:
  1. Google Earth Engine
    Create a Google cloud project. If you use the cloud for research it will be free of charge.
    However, make sure that your accound or project belongs to the "Academia & Research" oranization.
  2. Navigate to anaconda or activate the anaconda module (for example UNC Longleaf)
    ```sh
    source /opt/anaconda3/bin/activate
    ```
    ```sh
    module load anaconda
    ```
  3. Navigate to anaconda
      ```sh
      source /opt/anaconda3/bin/activate 
      ```
  4. Create Virtual Environment
      ```sh
      conda create --name surface-emissions python=3.9
      ```
  5. Activate the environment
      ```sh
      conda activate surface-emissions
      ```
  6. Install Python package dependencies
      ```sh
      pip3 install -r requirements.txt
      ```
  7. Run
      ```sh
      python3 TROPOMI_GEE_download.py
      ```

<p align="right">(<a href="#readme-top">back to top</a>)</p>


<!-- Output Files -->
## Output Files

The following table presents the files processed in 00_Download as well as the download link.

| Input         | Format         | Resolution      | AOI        | Period      | Download              |
| ---           | ---            | ---             | ---        | ---         | ---                   |
| EPA-AQS       | CSV            | hourly          | CONUS      | 2019-2024   | Link coming soon ...  |
| TROPOMI OFFL  | GeoTIFF        | monthly L3      | CONUS      | 2019-2024   | Link coming soon ...  |

<p align="right">(<a href="#readme-top">back to top</a>)</p>