# Drought Index Viewer *tethysapp-drought_index_viewer*

**This app is created to run in the Tethys Platform programming environment. See:**
**https://github.com/tethysplatform/tethys and http://docs.tethysplatform.org/en/latest/**

## Prerequisites:

    Tethys Platform (CKAN, PostgresQL, GeoServer)

### Install Tethys Platform See: http://docs.tethysplatform.org/en/latest/installation.html

## Installation: Clone the app into the directory you want:

```
$ git clone https://github.com/kjlippold/tethysapp-drought_index_viewer.git
$ cd tethysapp-drought_index_viewer
```

Then install the app into the Tethys Platform.

### Installation for App Development:

```
$ . /usr/lib/tethys/bin/activate
$ cd tethysapp-drought_index_viewer
$ python setup.py develop
```

### Installation for Production:

```
$ . /usr/lib/tethys/bin/activate
$ cd tethysapp-drought_index_viewer
$ python setup.py install
$ tethys manage collectstatic
```

Restart the Apache Server: See: http://docs.tethysplatform.org/en/latest/production/installation.html#enable-site-and-restart-apache

## Updating the App: Update the local repository and Tethys Platform instance.

```
$ . /usr/lib/tethys/bin/activate
$ cd tethysapp-drought_index_viewer
$ git pull
```

Restart the Apache Server: See: http://docs.tethysplatform.org/en/latest/production/installation.html#enable-site-and-restart-apache

## Using the App

This app was designed to visualize global 16-day MODIS Land Surface Temperature and MODIS Normalized Difference Vegetation Index data from 2000 to 2017.

To use the app, select either MODIS LST or MODIS NDVI from the dropdown menu, then select a date. The data you've chosen will be displayed on the map. Hover your cursor over a cell to see the value for that cell displayed ont he left hand side of the map.

Click anywhere on the map to display a timeseries plot below the map of the LST and NDVI values at that point from 2000 to 2017. The plot will also display anomaly data for both LST and NDVI datasets. You may also click and drag a portion of the plot to zoom into that section.

## Accessing the Data

Example using MOD11C2: MODIS/Terra Land Surface Temperature/Emissivity 8-day L3 Global 0.05Deg CMG V006 dataset


### Download the MODIS Data

1.  Go to: https://lpdaac.usgs.gov/dataset_discovery/modis/modis_products_table/mod11c2_v006#tools
2.  Scroll down the page to “Tools”, under which is “Data Access”. 
3.  Click “NASA Earthdata Search”.
4.  Login or create an account with Earthdata.
5.  Once logged in, type the name of the dataset (MOD11C2) into the search bar.
6.  Click on the result “MODIS/Terra Land Surface Temperature/Emissivity 8-day L3 Global 0.05Deg CMG V006”.
a.  This should bring up a collection of about 817 granules, dating from February 2000 through the present.
7.  Click the green, “Download Data” button on the right-hand side. This will direct you through a Review and Select process.
a.  Select “Direct Download”
b.  Click “Download Access Script”, wait for the page to load, and then click “Download Script File”. This script should list all granules for download.
8.  Log in to Monsoon.
9.  Navigate to the directory you plan to house your data.
a.  Can create this using: “mkdir directoryname”
10.  Copy your download script from your local computer to the server using: “scp username@origin:/path/to/file username@target:/path/to/file”
11. Run your download script to begin dataset download.

### Convert the HDF files to NetCDF format

1.  Copy the LSTconv_to_nc.ncl script into your directory with MODIS files.
2.  Edit the NCL script for the following:
a.  Change “syr” and “eyr” to the start and end years of your dataset.
b.  Change “diri” to your path to working directory (current location of .hdf files).
c.  Change “diro” to your path to output directory (destination location of output .nc files).
3.  Run the NCL script by typing at command line: “ncl LSTconv_to_nc.ncl”. 

### Calculate the baseline

1.  Navigate to directory with newly generated NetCDF LST files.
2.  Use CDO to calculate reference file: “cdo ensmean file1 file2 …  outputfile.nc”
a.  Note: CDO has a max limit on files it can open and read at one time. Depending on number of files, may need to process in batches.

### Calculate the anomaly

1.  Create/navigate to directory for processing anomaly files.
2.  Copy the LSTanom.ncl script into this directory.
3.  Edit the NCL script for the following:
a.  Change “diriLST” and “diri” to your path to data directory (current location of NetCDF files).
b.  Change “diro” to your path to current working directory (location for output files).
c.  OPTIONAL: change “diro2” to path to 1gd4r output directory. This script generates output in 1gd4r format as well. If this is not applicable, skip this step or change the 1gd4r format to another format of choice.
4.  Run the NCL script by typing at command line: “ncl LSTanom.ncl”. 

Repeat this process for MOD13C1: MODIS/Terra Vegetation Indices 16-day L3 Global 0.05Deg CMG V006 dataset using the associated NDVI NCL scripts.



