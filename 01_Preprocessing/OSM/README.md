<a id="readme-top"></a>


<!-- PROJECT LOGO -->
<br />
<div align="center">
  <h3 align="center">Preprocessing Open Street Map data</h3>
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
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#requirements">Requirements</a></li>
        <li><a href="#installation">Installation</a></li>
      </ul>
    </li>
    <li><a href="#code-explained">Code Explained</a></li>
    <li><a href="#acknowledgments">Acknowledgments</a></li>
  </ol>
</details>



<!-- GETTING STARTED -->
## Getting Started

coming soon ...

### Requirements

The following libraries are required to successful deploy the OSM.R code.

* libraries
    ```sh
    install.packages(c("osmdata", "osmextract", "sf", "tidyverse", "dplyr", "stars"))
    ```

### Installation

1. Run the R code
    ```sh
    Rscript OSM.R
    ```
2. Clean the OSM dataset of the states Washington, Nevada, and Georgia (only keep "motorway" and "trunk")
3. Merge the states Washington, Nevada, and Georgia to the CONUS shapefile (OSM.R) in QGIS
    * Vector > Data Management Tools > Merge Vector Layers ...
    <img src=https://github.com/CEMPD/NO2_Surface_Estimation/blob/main/Images/QGIS/01_merge_shp.png alt="Merge01" width="400"/>
    
    * Select Layers that neet to be merged
    <img src=https://github.com/CEMPD/NO2_Surface_Estimation/blob/main/Images/QGIS/02_merge_shp_select_layer.png alt="Merge01" width="400"/>

    * Check the merge settings (CRS)
    <img src=https://github.com/CEMPD/NO2_Surface_Estimation/blob/main/Images/QGIS/03_merge_shp_settings.png alt="Merge01" width="400"/>

    * Start merging process
    <img src=https://github.com/CEMPD/NO2_Surface_Estimation/blob/main/Images/QGIS/04_merge_shp_run.png alt="Merge01" width="400"/>

4. Convert the vector data to a raster with 0.01°x0.01° in QGIS

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- Code Explained -->
## Code Explained

coming soon ...

  ```sh
  OSM.R
  ```

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- ACKNOWLEDGMENTS -->
## Acknowledgments

* [xxx](xxx)
* [xxx](xxx)
* [xxx](xxx)

<p align="right">(<a href="#readme-top">back to top</a>)</p>