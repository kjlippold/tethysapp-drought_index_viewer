from netCDF4 import Dataset
from datetime import datetime
from datetime import timedelta
from datetime import date
from ftplib import FTP
from itertools import groupby
import datetime
import os
import shutil
import sys
import numpy as np
import time
import sys
import tempfile
import calendar
import gdal
import osr
import ogr
import requests


def concatenate_netcdf_data(dir_path, file_path, var_name):

    #new_netcdf = Dataset('modis_ndvi_anom.nc','a')
    input_file = Dataset(file_path,'r')
    print(input_file.variables)
    """
    new_netcdf.createDimension('lat',len(test_file.variables['lat'][:]))
    new_netcdf.createDimension('lon',len(test_file.variables['lon'][:]))
    new_netcdf.createDimension('date',None)
    new_netcdf.createVariable('lat','f4','lat')
    new_netcdf.createVariable('lon','f4','lon')
    new_netcdf.createVariable('date','i4','date')
    new_netcdf.createVariable(var_name,'f4',('date','lat','lon'))

    new_netcdf.variables['lat'][:] = input_file.variables['lat'][:]
    new_netcdf.variables['lon'][:] = input_file.variables['lon'][:]

    date_list = []
    base_date = date(1600,1,1)
    for nc_file in os.listdir(dir_path):
        year = nc_file.split('.')[1][1:5]
        day = nc_file.split('.')[1][5:8]
        init_date = date(int(year),1,1)
        nc_date = init_date + timedelta(days=(int(day) - 1))
        date_delta = nc_date - base_date
        date_list.append(date_delta.days)

    date_list = sorted(date_list)
    new_netcdf.variables['date'][:] = date_list

    for n, i in enumerate(date_list):
        year_ = (base_date + timedelta(days = i)).year
        year_start = date(year_,1,1)
        date_ = (base_date + timedelta(days = i + 1))
        filename = "MODIS_ndvianom_" + str((base_date + timedelta(days=i)).year) + str((date_ - year_start).days).zfill(3) + ".nc"
        nc_file = Dataset(dir_path + filename)
        new_netcdf.variables[var_name][n,:,:] = nc_file.variables[var_name][:,:]

    modis_ndvi.close()
    """

def extractRasters(input_dir, output_dir):
    for file in sorted(os.listdir(input_dir)):
        year = os.path.basename(file).split('.')[1][1:5]
        day = os.path.basename(file).split('.')[1][5:8]
        data_date = datetime.datetime(int(year),1,1) + timedelta(days=int(day))
        in_loc = os.path.join(input_dir,file)
        output_dir = os.path.join(output_dir,"")
        lis_fid = Dataset(in_loc, 'r')  # Reading the netcdf file
        lis_var = lis_fid.variables  # Get the netCDF variables
        var = "ndvi"  # Specifying the variable key. This parameter will be used to retrieve information about the netCDF file
        xsize, ysize, GeoT, Projection, NDV = get_netcdf_info(in_loc, var)

        ts_file_name = 'modis_ndvi_' + data_date.strftime('%Y_%m_%d')
        data = lis_var['ndvi'][:,:][::-1,:]
        #data = lis_var[var][timestep, :, :]
        #data = data[::-1, :]
        driver = gdal.GetDriverByName('GTiff')
        DataSet = driver.Create(output_dir + ts_file_name + '.tif', xsize, ysize, 1, gdal.GDT_Float32)
        DataSet.SetGeoTransform(GeoT)
        srs = osr.SpatialReference()
        srs.ImportFromEPSG(4326)
        DataSet.SetProjection(srs.ExportToWkt())
        DataSet.GetRasterBand(1).WriteArray(data)
        DataSet.GetRasterBand(1).SetNoDataValue(NDV)
        DataSet.FlushCache()
        DataSet = None

    return date_str


def get_netcdf_info(filename,var_name):

    nc_file = gdal.Open(filename)

    if nc_file is None:
        sys.exit()

    #There are more than two variables, so specifying the lwe_thickness variable

    if nc_file.GetSubDatasets() > 1:
        subdataset = 'NETCDF:"'+filename+'":'+var_name #Specifying the subset name
        src_ds_sd = gdal.Open(subdataset) #Reading the subset
        NDV = src_ds_sd.GetRasterBand(1).GetNoDataValue() #Get the nodatavalues
        xsize = src_ds_sd.RasterXSize #Get the X size
        ysize = src_ds_sd.RasterYSize #Get the Y size
        GeoT = src_ds_sd.GetGeoTransform() #Get the GeoTransform
        Projection = osr.SpatialReference() #Get the SpatialReference
        Projection.ImportFromWkt(src_ds_sd.GetProjectionRef()) #Setting the Spatial Reference
        src_ds_sd = None #Closing the file
        nc_file = None #Closing the file

        return xsize,ysize,GeoT,Projection,NDV #Return data that will be used to convert the shapefile


def upload_tiff(dir, region, geoserver_rest_url, workspace, uname, pwd):

    headers = {
        'Content-type': 'image/tiff',
    }

    dir = os.path.join(dir,"")

    for file in sorted(os.listdir(dir)):  # Looping through all the files in the given directory
        if file is None:
            sys.exit()
        data = open(dir + file, 'rb').read()  # Read the file
        store_name = file.split('.')[0] # Creating the store name dynamically

        request_url = '{0}workspaces/{1}/coveragestores/{2}/file.geotiff'.format(geoserver_rest_url, workspace,
                                                                                 store_name)  # Creating the rest url
        print("Starting " + str(store_name))
        requests.put(request_url, headers=headers, data=data,
                     auth=(uname, pwd))  # Creating the resource on the geoserver
        print(str(store_name) + ' added to GeoServer.')

print("TEST")
dir_path = "/Users/kennethlippold/Desktop/NDVI_Anom/NDVI_anom/"
file_path = "/Users/kennethlippold/Desktop/NDVI_Anom/NDVI_anom/MODIS_ndvianom_2000049.nc"
var_name = ""
concatenate_netcdf_data(dir_path,file_path,var_name)
#extractRasters(input_dir,output_dir)
#upload_tiff(output_dir,'global','http://tethys.byu.edu:8181/geoserver/rest/','modis_ndvi_di','admin','geoserver')
