<a id="readme-top"></a>


<!-- PROJECT LOGO -->
<br/>
<div align="center">
  <h3 align="center">Preprocessing the Local Climate Zones (LCZ)</h3>
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
    <li><a href="#literature">Literature</a></li>
  </ol>
</details>



<!-- GETTING STARTED -->
## Getting Started

coming soon ...

### Requirements

This is an example of how to list things you need to use the software and how to install them.

* npm
    ```sh
    pip3 install -r requirements.txt
    ```

### Installation

1. Create a virtual environment
    ```sh
    pip3 install virtualenv 
    python3 -m venv venv
    ```
2. Activate the virtual environment
    ```sh
    source venv/bin/activate
    ```
3. Install Python package dependencies
    ```sh
    pip3 install -r requirements.txt
    ```
4. Run  (coming soon...)
    ```sh
    python3 xxx.py
    python3 xxx.py
    python3 xxx.py
    ```

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- Code Explained -->
## Code Explained

1. If not already created, run the following file to create a shapefile grid. The grid will be needed to downscale the resolution of the LCZ to 0.01° x 0.01°.

  ```sh
  create_shp_grid.R
  ```

2. Regrid the LCZ

  ```sh
  LCZ_01_regrid.R
  ```

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- ACKNOWLEDGMENTS -->
## Acknowledgments

LCZ data from:
* [Demuzere, M., Hankey, S., Mills, G., Zhang, W., Lu, T., & Bechtel, B. (2020). Combining expert and crowd-sourced training data to map urban form and functions for the continental US. Scientific Data, 7:264](https://doi.org/10.1038/s41597-020-00605-z)



<!-- LITERATURE -->
## Literature

* [Stewart, I. D., & Oke, T. R. (2012). Local Climate Zones for Urban Temperature Studies. Bulletin of the American Meteorological Society, 93(12), 1879-1900.](https://doi.org/10.1175/BAMS-D-11-00019.1)

* [Qi, M.,Xu, C., Zhang, W., Demuzere, M., Hystad, P., Lu, T., James, P., Bechtel, B., & Hankey, S. (2024). Mapping urban form into local climate zones for the continental US from 1986-2020. Scientific Data, 11:195.](https://doi.org/10.1038/s41597-024-03042-4)

<p align="right">(<a href="#readme-top">back to top</a>)</p>