## ------------------------------------------------------------------------------------
## Libraries
## ------------------------------------------------------------------------------------

if (Sys.getenv("R_CONFIG_ACTIVE") == "rsconnect") {
  library("tools")

} else {
  repository <- "http://cran.us.r-project.org"
  if (!require(tools)) install.packages("tools", repos = repository)
}

if (!requireNamespace("utils", quietly = TRUE)) {
  stop("The 'utils' package is required but not installed.")
}

## ------------------------------------------------------------------------------------
## Variables
## ------------------------------------------------------------------------------------

## Define the folder containing the zip files
zip_folder <- "/Volumes/MyBook2/DATA/NASADEM/NASADEM_HGT_001-20241217_150848"
output_folder <- "/Volumes/MyBook2/DATA/NASADEM"

## ------------------------------------------------------------------------------------
## Main
## ------------------------------------------------------------------------------------

## Get a list of all zip files in the folder
zip_file_l <- list.files(zip_folder, pattern = "\\.zip$", full.names = TRUE)

# Loop through each zip file
for (zip in zip_file_l) {

  ## Extract the base name of the zip file (without extension)
  zip_name <- file_path_sans_ext(basename(zip))

  ## Create a subdirectory under the output folder with the name of the zip file
  unzip_dir <- file.path(output_folder, zip_name)

  ## Create directory in case it does not exist
  if (!dir.exists(unzip_dir)) {
    dir.create(unzip_dir)
  }

  ## Unzip the file into the subdirectory
  unzip(zip, exdir = unzip_dir)

  message(paste("Unzipped", zip, "to", unzip_dir))
}