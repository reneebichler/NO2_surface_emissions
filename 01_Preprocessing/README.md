<a id="readme-top"></a>


<!-- PROJECT LOGO -->
<br />
<div align="center">
  <h3 align="center">Preprocessing - Prepare the input data</h3>
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

xxx

1. 01_extract_grid_TROPOMI.R
2. EPA-AQS
    * EPA-AQS_01_create_shp_points.R
    * EPA-AQS_02_d_time_series.R
    * EPA-AQS_02_h_time_series.R
    * EPA-AQS_02_m_time_series.R
3. TROPOMI
    * TROPOMI_01_create_csv.R
    * TROPOMI_02_time_series.R
    * TROPOMI_03_map_ts_animation.R
4. DEM
    * NASA_DEM_01_unzip.R
    * NASA_DEM_02_mosaic_conus.R
    * NASA_DEM_02_mosaic_states.R
    * NASA_DEM_03_regrid_v3.R
5. LCZ
    * LCZ_01_regrid_v3.R
6. OSM
    * OSM_01_retrieve_osm.R
    * OSM_02_merge_grid_osm.R
7. 03_generate_figures.R

<p align="right">(<a href="#readme-top">back to top</a>)</p>


<!-- File Description -->
## File Description

The following table gives an insight on the data products downloaded and further processed in the 00_Download folder.

Grid filenames:
* 01_CONUS_S5P_TROPOMI_L3_1km_grid.shp


Sentinel-5P filenames:
* CONUS_S5P_L3_NO2_mm_2019-01-01_2019-01-31.tif



<!-- GETTING STARTED -->
## Getting Started

coming soon ...


The following R code generates the plots that were used in the paper:
    ```
    01_extract_grid_TROPOMI.R
    ```

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- Download Files -->
## Download Files

In the following table we provide the certain output files, so you don't have to reprocess them.

| Input     | Format    | Resolution     | AOI           | Download         |
| ---       | ---       | ---            | ---           | ---              |
| Grid      | SHP       | 1kmx1km        | CONUS         | coming soon...   |
| TROPOMI   | GeoTIFF   | 1kmx1km        | CONUS         | coming soon...   |
| EPA-AQS   | CSV       | 1kmx1km        | CONUS         | coming soon...   |
| EPA-AQS   | SHP       | 1kmx1km        | CONUS         | coming soon...   |
| OSM       | GeoTIFF   | 1kmx1km        | CONUS         | coming soon...   |
| LCZ       | GeoTIFF   | 1kmx1km        | CONUS         | coming soon...   |
| LCZ       | SHP       | 1kmx1km        | CONUS         | coming soon...   |
| DEM       | GeoTIFF   | 1kmx1km        | CONUS         | coming soon...   |
| DEM       | SHP       | 1kmx1km        | CONUS         | coming soon...   |

<p align="right">(<a href="#readme-top">back to top</a>)</p>
