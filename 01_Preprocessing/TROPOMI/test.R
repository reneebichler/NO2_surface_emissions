    # Read the NetCDF file as a raster brick
    nc <- nc_open(file)

    var <- ncvar_get(nc, "PRODUCT/nitrogendioxide_tropospheric_column")
    lat <- ncvar_get(nc, "PRODUCT/latitude")
    lon <- ncvar_get(nc, "PRODUCT/longitude")
    nlon <- dim(lon)

    # create netCDF file and put arrays
    ncout <- nc_create(ncfname,list(tmp_def,mtco.def,mtwa.def,mat.def),force_v4=TRUE)

    # put variables
    ncvar_put(ncout, tmp_def,tmp_array3)
    ncvar_put(ncout, mtwa.def,mtwa_array3)
    ncvar_put(ncout, mtco.def,mtco_array3)
    ncvar_put(ncout, mat.def,mat_array3)

    # put additional attributes into dimension and data variables
    ncatt_put(ncout,"lon","axis","X") #,verbose=FALSE) #,definemode=FALSE)
    ncatt_put(ncout,"lat","axis","Y")
    ncatt_put(ncout,"time","axis","T")


    var <- brick(file, varname = "PRODUCT/nitrogendioxide_tropospheric_column")
    lat <- brick(file, varname = "PRODUCT/latitude")
    lon <- brick(file, varname = "PRODUCT/longitude")
    qa_value <- brick(file, varname = "PRODUCT/qa_value")

    df <- data.frame(matrix(NA, ncol = lon, nrow = lat))