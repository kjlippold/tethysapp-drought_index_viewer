from django.shortcuts import render
from django.contrib.auth.decorators import login_required
from tethys_sdk.gizmos import Button
from datetime import datetime, timedelta
from netCDF4 import Dataset
import datetime
from tethys_sdk.gizmos import SelectInput
from datetime import date, timedelta


@login_required()
def home(request):
    """
    Controller for the app home page.
    """

    
    #drought_index_list = [['MODIS LST Drought Index','modis_lst_'],['MODIS NDVI Drought Index','modis_ndvi_'],['MODIS LST Anomaly', 'modis_lst_anom_'],['MODIS NDVI Anomaly', 'modis_ndvi_anom_']]
    drought_index_list = [['MODIS NDVI Drought Index','modis_ndvi_'],['MODIS NDVI Anomaly', 'modis_ndvi_anom_']]
    base_date = datetime.date(1600,1,1)
    date_list = [str(base_date + timedelta(days=int(i))) for i in list(Dataset("/Users/kennethlippold/tethysdev/tethysapp-drought_index_viewer/tethysapp/drought_index_viewer/modis_nc/modis_ndvi.nc", "r").variables["date"][:])]
    di_date_list = []

    for date in date_list:
        date = date.split("-")
        date_object = datetime.date(int(date[0]),int(date[1]),int(date[2]))
        di_date_list.append([date_object.strftime("%Y %B %d"),date_object.strftime("%Y_%m_%d")])

    layers_length = len(di_date_list)

    index_selection = SelectInput(display_text='Select a Drought Index',
                                  name='select2',
                                  multiple=False,
                                  options=drought_index_list)

    date_selection = SelectInput(display_text='Select a Date',
                                 name='select_layer',
                                 multiple=False,
                                 options=di_date_list)

    context = {
        "index_selection":index_selection,
        "date_selection":date_selection,
        "slider_max":layers_length
    }

    return render(request, 'drought_index_viewer/home.html', context)
