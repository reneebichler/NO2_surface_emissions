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

EPA-AQS filename:
* EPA-AQS_h_2019-01-01-2019-01-31_42602_xminlon_-125_xmaxlon_-67_yminlat_25_ymaxlat_49.csv

EPA-AQS ... Environmental Protection Agency - Air Quality Service <br/>
h ... hourly time resolution <br/>
2019-01-01 ... start period <br/>
2019-01-31 ... end period <br/>
42602 ... Nitrogen dioxide identifier <br/>
xminlon_-125 ... bounding box west (left) coordinate <br/>
xmaxlon_-67 ... bounding box east (right) coordinate <br/>
yminlat_25 ... bounding box south (bottom) coordinate <br/>
ymaxlat_49 ... bounding box north (top) coordinate <br/>

Sentinel-5P filename:
* CONUS_S5P_L3_NO2_mm_2019-01-01_2019-01-31.tif

CONUS ... Continental United States (Shapefile) <br/>
S5P ... Sentinel-5P <br/>
OFFL ... Offline data <br/>
L3 ... Level 3 data product <br/>
NO2 ... Nitrogend dioxide <br/>
mm ... Monthly mean <br/>
yyyy-mm-dd ... start and end date <br/>


<!-- GETTING STARTED -->
## Getting Started

coming soon ...

### EPA-AQS

1. Open terminal in VSC.

2. For EPA-AQS data:
      ```sh
      Rscript download_EPA-AQS.R
      ```

### Tropomi

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

| Input         | Format      | Resolution           | AOI        | Period      | Download              |
| ---           | ---         | ---                  | ---        | ---         | ---                   |
| EPA-AQS       | CSV         | hourly               | CONUS      | 2019-2024   | Link coming soon ...  |
| TROPOMI OFFL  | GeoTIFF     | monthly mean L3      | CONUS      | 2019-2024   | Link coming soon ...  |

<p align="right">(<a href="#readme-top">back to top</a>)</p>