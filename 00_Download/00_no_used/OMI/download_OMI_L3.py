## ------------------------------------------------------------------------------------
## Libraries
## ------------------------------------------------------------------------------------

## source: https://stackoverflow.com/questions/40088745/how-to-download-nasa-satellite-opendap-data-using-python
## last access: 25/6/24

## Python download for Aura/OMI L3 daily data

import os
from urllib import request
import pandas as pd

## ------------------------------------------------------------------------------------
## Variables
## ------------------------------------------------------------------------------------

username = "allaroundeo1"
password = "NASAAuraNO2!"

#omi_file = '/Volumes/MyBook/DATA/Aura/subset_OMNO2d_003_20240625_104228_download.txt'
omi_file = '/Volumes/MyBook/DATA/Aura/subset_OMNO2d_003_20240625_124123_download.txt'

## ------------------------------------------------------------------------------------
## Main
## ------------------------------------------------------------------------------------

## read text file into pandas DataFrame
df = pd.read_csv(omi_file, sep='?', header=None)

## download L3 Arua OMI based on index number
#index_l = list(range(0, len(df.index)+1, 1))
index_l = list(range(7165, 7165, 1))
#7153 7162

for i in index_l:

    url = df.loc[i, 0]

    ## set filenmae and path
    filename = url.split("/")[9]
    year = url.split("/")[8]
    path = ('/Volumes/MyBook/DATA/Aura/OMI/{}').format(year)
    fullfilename = os.path.join(path, filename)

    print("Process file {0} at index {1} / {2}".format(filename, i, len(df.index)))

    redirectHandler = request.HTTPRedirectHandler()
    cookieProcessor = request.HTTPCookieProcessor()
    passwordManager = request.HTTPPasswordMgrWithDefaultRealm()
    passwordManager.add_password(None, "https://urs.earthdata.nasa.gov", username, password)
    authHandler = request.HTTPBasicAuthHandler(passwordManager)
    opener = request.build_opener(redirectHandler, cookieProcessor, authHandler)

    request.install_opener(opener)
    request.urlretrieve(url, fullfilename)
    opener.close()