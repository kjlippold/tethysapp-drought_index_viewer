from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.views.decorators.csrf import ensure_csrf_cookie
from django.utils.decorators import method_decorator
from django.contrib.auth.decorators import login_required
from netCDF4 import Dataset
from pyproj import Proj, transform
from datetime import date, timedelta
import numpy as np
import os
import json


@csrf_exempt
def ajax_point_timeseries(request):

    return_obj = {
        'success': False,
        'message': None,
        'results': {}
    }

    data = request.POST

    inProj = Proj(init='epsg:3857')
    outProj = Proj(init='epsg:4326')
    x1,y1 = data['Lon'],data['Lat']
    di_name = data['DI']
    in_lon,in_lat = transform(inProj,outProj,x1,y1)
    variables = {
        "modis_ndvi_":"ndvi",
        "modis_ndvi_anom_":"NDVIanomaly"
    }

    filename = di_name[:-1] + ".nc"

    nc_path = "/Users/kennethlippold/tethysdev/tethysapp-drought_index_viewer/tethysapp/drought_index_viewer/modis_nc/"

    print filename

    data_file = Dataset(nc_path + filename,"r")

    lats = data_file.variables['lat'][:]     
    lons = data_file.variables['lon'][:]     

    lat_idx = (np.abs(lats - in_lat)).argmin()
    lon_idx = (np.abs(lons - in_lon)).argmin()

    base_date = date(1600,1,1)

    date_list = [str(base_date + timedelta(days=int(i))) for i in list(data_file.variables['date'][:])]

    data_values = (data_file.variables[variables[di_name]][:,lat_idx,lon_idx]).tolist()

    if di_name == "modis_ndvi_":
        adj_ndvi_values = []
        for value in data_values:
            value = value / 10000
            adj_ndvi_values.append(value)
        data_values = adj_ndvi_values


    return_obj = {
        'success': True,
        'message': None,
        'data_values': data_values,
        'date_list': date_list
    }

    return JsonResponse(return_obj)
