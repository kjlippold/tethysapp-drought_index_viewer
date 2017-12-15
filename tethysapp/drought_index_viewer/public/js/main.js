var lastFeature
var timeseries_data

var mousePositionControl = new ol.control.MousePosition({
    coordinateFormat: ol.coordinate.createStringXY(4),
    projection: 'EPSG:4326',
    className: 'custom-mouse-position',
    target: document.getElementById('mouse-position'),
    undefinedHTML: '&nbsp;'
});

init_map = function() {
    var projection = ol.proj.get('EPSG:3857');
    var baseLayer = new ol.layer.Tile({
        source: new ol.source.BingMaps({
            key: '5TC0yID7CYaqv3nVQLKe~xWVt4aXWMJq2Ed72cO4xsA~ApdeyQwHyH_btMjQS1NJ7OHKY8BK-W-EMQMrIavoQUMYXeZIQOUURnKGBOC7UCt4',
            imagerySet: 'AerialWithLabels'
        })
    });
    var view = new ol.View({
        center: ol.proj.transform([12,34], 'EPSG:4326','EPSG:3857'),
        projection: projection,
        zoom: 1.85
    });
    wms_source = new ol.source.ImageWMS();
    wms_layer = new ol.layer.Image({
        source: wms_source
    });
    var source = new ol.source.Vector({wrapX: false});
    var vector = new ol.layer.Vector({
        source: source
    });
    vector.setZIndex(1001);
    layers = [
                vector,
                baseLayer,
                wms_layer
            ];
    map = new ol.Map({
        controls: ol.control.defaults({
            attributionOptions: /** @type {olx.control.AttributionOptions} */ ({
                collapsible: false
            })
        }).extend([mousePositionControl]),
        target: document.getElementById("map"),
        layers: layers,
        view: view
    });
    map.crossOrigin = 'anonymous';
    map.on('pointermove', function(evt) {
        var clickCoord = evt.coordinate;
        var view = map.getView();
        var viewResolution = view.getResolution();
        var wms_url = wms_layer.getSource().getGetFeatureInfoUrl(evt.coordinate, viewResolution, view.getProjection(), {'INFO_FORMAT': 'application/json'}); //Get the wms url for the clicked point
        if (wms_url) {
            $.ajax({
                type: "GET",
                url: wms_url,
                dataType: 'json',
                success: function (result) {
                    var value = parseFloat(result["features"][0]["properties"]["GRAY_INDEX"]);
                    var di_name = $("#select2").find('option:selected').val()
                    if (di_name === "modis_ndvi_") {
                        value = value.toFixed(2) / 10000;
                    };
                    if (value === -0.3) {
                        value = "No Value"
                    };
                    if (value === -9999) {
                        value = "No Value"
                    };
                    document.getElementById('mousevalue').innerHTML = value
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    console.log(Error);
                }
            });
        }
    });
    var draw;
    function addInteraction() {
        var value = 'Point';
        draw = new ol.interaction.Draw({
            source: source,
            type: 'Point'
        });
        map.addInteraction(draw);  
    };
    addInteraction();
    source.on('addfeature', function(evt){
        var feature = evt.feature;
        feature.setId(1)
        var coords = feature.getGeometry().getCoordinates()
        var lat = String(coords).split(',')[1]
        var lon = String(coords).split(',')[0]
        var lat_trim = parseFloat(lat).toFixed(4)
        var lon_trim = parseFloat(lon).toFixed(4)
        var di_name = $("#select2").find('option:selected').val()
        console.log("LAT " + lat_trim + " : LON " + lon_trim)
        timeseries_data = [lat_trim,lon_trim,di_name]
        ajaxGetTimeseries(timeseries_data)
    });
    var removeLastFeature = function() {
        if (lastFeature)
          source.removeFeature(lastFeature);
    };
    draw.on('drawend', function (evt) {
        removeLastFeature();
        lastFeature = evt.feature;
    });
};

init_all = function(){
    init_map();
};

add_wms = function(){
    map.removeLayer(wms_layer);
    var di_name = $("#select2").find('option:selected').val()
    //var temp_di_name = 'hkh_di_index'
    var store_name = $("#select_layer").find('option:selected').val();
    //var layer_name = temp_di_name + ':' + store_name;
    //var date_str = '2017_07_13'
    //var layer_name = 'modis_ndvi_' + store_name;
    //var layer_name = 'modis_ndvi_anom_2000_02_18'


    if (di_name === 'modis_ndvi_') {
        // This is here due to a mistake in entering the dates on GeoServer.
        new_number = (Number(store_name.substr(store_name.length - 2)) + 1).toString()
        if (new_number.length === 1) {
            new_number = '0'.concat(new_number)
        };
        store_name = store_name.substring(0, store_name.length-2).concat(new_number);
        var layer_name = di_name + store_name;
        var sld_string = 
            '<StyledLayerDescriptor version="1.0.0">\
                <NamedLayer>\
                    <Name>'+'Ram:'+layer_name+'</Name>\
                    <UserStyle>\
                        <FeatureTypeStyle>\
                            <Rule>\
                                <RasterSymbolizer> \
                                    <Opacity>0.5</Opacity>\
                                    <ColorMap> \
                                        <ColorMapEntry color="#000000" quantity="-3000" label="nodata" opacity="0.0" />\
                                        <ColorMapEntry color="#8c510a" quantity="-2000" label="1" opacity="1" />\
                                        <ColorMapEntry color="#d8b365" quantity="0" label="1" opacity="1" />\
                                        <ColorMapEntry color="#f6e8c3" quantity="2000" label="1" opacity="1" />\
                                        <ColorMapEntry color="#c7eae5" quantity="4000" label="1" opacity="1" />\
                                        <ColorMapEntry color="#5ab4ac" quantity="6000" label="1" opacity="1" />\
                                        <ColorMapEntry color="#01665e" quantity="8000" label="1" opacity="1" />\
                                        <ColorMapEntry color="#1f3836" quantity="10000" label="1" opacity="1" />\
                                    </ColorMap>\
                                </RasterSymbolizer>\
                            </Rule>\
                        </FeatureTypeStyle>\
                    </UserStyle>\
                </NamedLayer>\
            </StyledLayerDescriptor>';
    };

    if (di_name === 'modis_ndvi_anom_') {
        var layer_name = 'modis_ndvi_anom_' + store_name;
        var sld_string =         
            '<StyledLayerDescriptor version="1.0.0">\
                <NamedLayer>\
                    <Name>'+'Ram:'+layer_name+'</Name>\
                    <UserStyle>\
                        <FeatureTypeStyle>\
                            <Rule>\
                                <RasterSymbolizer> \
                                    <Opacity>0.5</Opacity>\
                                    <ColorMap> \
                                        <ColorMapEntry color="#000000" quantity="-9999" label="nodata" opacity="0.0" />\
                                        <ColorMapEntry color="#8c510a" quantity="-0.6" label="1" opacity="1" />\
                                        <ColorMapEntry color="#d8b365" quantity="-0.4" label="1" opacity="1" />\
                                        <ColorMapEntry color="#f6e8c3" quantity="-0.2" label="1" opacity="1" />\
                                        <ColorMapEntry color="#c7eae5" quantity="0" label="1" opacity="1" />\
                                        <ColorMapEntry color="#5ab4ac" quantity="0.2" label="1" opacity="1" />\
                                        <ColorMapEntry color="#01665e" quantity="0.4" label="1" opacity="1" />\
                                        <ColorMapEntry color="#1f3836" quantity="0.6" label="1" opacity="1" />\
                                    </ColorMap>\
                                </RasterSymbolizer>\
                            </Rule>\
                        </FeatureTypeStyle>\
                    </UserStyle>\
                </NamedLayer>\
            </StyledLayerDescriptor>';
    };

    if (di_name === 'modis_lst_') {
        var layer_name = 'modis_lst_' + store_name;
        var sld_string =         
            '<StyledLayerDescriptor version="1.0.0">\
                <NamedLayer>\
                    <Name>'+'Ram:'+layer_name+'</Name>\
                    <UserStyle>\
                        <FeatureTypeStyle>\
                            <Rule>\
                                <RasterSymbolizer> \
                                    <Opacity>0.5</Opacity>\
                                    <ColorMap> \
                                        <ColorMapEntry color="#000000" quantity="-3000" label="nodata" opacity="0.0" />\
                                        <ColorMapEntry color="#476cff" quantity="-2000" label="1" opacity="1" />\
                                        <ColorMapEntry color="#615cda" quantity="0" label="1" opacity="1" />\
                                        <ColorMapEntry color="#953d91" quantity="2000" label="1" opacity="1" />\
                                        <ColorMapEntry color="#b02e6d" quantity="4000" label="1" opacity="1" />\
                                        <ColorMapEntry color="#ca1e48" quantity="6000" label="1" opacity="1" />\
                                        <ColorMapEntry color="#e40f24" quantity="8000" label="1" opacity="1" />\
                                        <ColorMapEntry color="#f00" quantity="10000" label="1" opacity="1" />\
                                    </ColorMap>\
                                </RasterSymbolizer>\
                            </Rule>\
                        </FeatureTypeStyle>\
                    </UserStyle>\
                </NamedLayer>\
            </StyledLayerDescriptor>';
    };

    if (di_name === 'modis_lst_anom_') {
        var layer_name = 'modis_lst_anom_' + store_name;
        var sld_string =         
            '<StyledLayerDescriptor version="1.0.0">\
                <NamedLayer>\
                    <Name>'+'Ram:'+layer_name+'</Name>\
                    <UserStyle>\
                        <FeatureTypeStyle>\
                            <Rule>\
                                <RasterSymbolizer> \
                                    <Opacity>0.5</Opacity>\
                                    <ColorMap> \
                                        <ColorMapEntry color="#000000" quantity="-3000" label="nodata" opacity="0.0" />\
                                        <ColorMapEntry color="#476cff" quantity="-2000" label="1" opacity="1" />\
                                        <ColorMapEntry color="#615cda" quantity="0" label="1" opacity="1" />\
                                        <ColorMapEntry color="#953d91" quantity="2000" label="1" opacity="1" />\
                                        <ColorMapEntry color="#b02e6d" quantity="4000" label="1" opacity="1" />\
                                        <ColorMapEntry color="#ca1e48" quantity="6000" label="1" opacity="1" />\
                                        <ColorMapEntry color="#e40f24" quantity="8000" label="1" opacity="1" />\
                                        <ColorMapEntry color="#f00" quantity="10000" label="1" opacity="1" />\
                                    </ColorMap>\
                                </RasterSymbolizer>\
                            </Rule>\
                        </FeatureTypeStyle>\
                    </UserStyle>\
                </NamedLayer>\
            </StyledLayerDescriptor>';
    };


    wms_source = new ol.source.ImageWMS({
        url: 'http://tethys.byu.edu:8181/geoserver/wms',
        params: {'LAYERS':layer_name,'SLD_BODY':sld_string},
        serverType: 'geoserver',
        crossOrigin: 'Anonymous'
    });
    wms_layer = new ol.layer.Image({
        source: wms_source
    });
    map.addLayer(wms_layer);
};


chart = Highcharts.chart('graph', {
    chart: {
        type: 'line',
        zoomType: 'x'
    },
    title: {
        text: 'MODIS Drought Index'
    },
    subtitle: {
        text: 'Source: MODIS'
    },
    xAxis: {
        title: {
            text: 'Date'
        },
        type: 'datetime',
        dateTimeLabelFormats: { 
            month: '%e. %b',
            year: '%Y'
        },
    },
    yAxis: {
        title: {
            text: 'NDVI'
        },
        max: 1,
        min: -0.2
    },
    plotOptions: {
        line: {
            lineWidth: 1,
            dataLabels: {
                enabled: false
            },
            enableMouseTracking: true
        }
    },
    series: [{
        name: $("#select2").find('option:selected').text(),
        data: []
    }],
    tooltip: {
        crosshairs: true,
        positioner: function () {
            return { x: 20, y: 350 };
        },
        shadow: false,
        borderWidth: 0,
        backgroundColor: 'rgba(255,255,255,0.8)'
    }
});

function transpose(a) {
    return Object.keys(a[0]).map(function(c) {
        return a.map(function(r) { return r[c]; });
    });
};

var ajaxGetTimeseries = function(data) {
    data = {"Lat":data[0],"Lon":data[1],"DI":data[2]}
    $.ajax({
        headers: {"X-CSRFToken": getCookie("csrftoken")},
        type: 'POST',
        url: '/apps/drought-index-viewer/ajax-point-timeseries/',
        dataType: 'json',
        data: data,
        public: false,
        error: function(XMLHttpRequest, textStatus, errorThrown) {
            console.log(errorThrown)
        },
        success: function(response) {
            values = response.data_values
            dates = response.date_list

            var result = dates.map(function (x) { 
                return Date.UTC(x.split("-")[0],x.split("-")[1],x.split("-")[2])
            });
            dates = result
            dataArray = transpose([dates,values])
            chart.series[0].setData(dataArray)
        }
    });
};

function getCookie(name) {
    var cookieValue = null;
    if (document.cookie && document.cookie !== '') {
        var cookies = document.cookie.split(';');
        for (var i = 0; i < cookies.length; i++) {
            var cookie = jQuery.trim(cookies[i]);
            if (cookie.substring(0, name.length + 1) === (name + '=')) {
                cookieValue = decodeURIComponent(cookie.substring(name.length + 1));
                break;
            }
        }
    }
    return cookieValue;
};

$(function() {
    init_all();
    $("#select2").change(function(){
        var selected_option = $(this).find('option:selected').text();
        $('#data-name').text(selected_option)
        chart.series[0].update({name:selected_option}, false);
        if (selected_option === "MODIS LST Drought Index") {
            $('#lst-legend').show()
            $('#lst-anom-legend').hide()
            $('#ndvi-legend').hide()
            $('#ndvi-anom-legend').hide()
        };
        if (selected_option === "MODIS LST Anomaly") {
            $('#lst-legend').hide()
            $('#lst-anom-legend').show()
            $('#ndvi-legend').hide()
            $('#ndvi-anom-legend').hide()
        };
        if (selected_option === "MODIS NDVI Drought Index") {
            $('#lst-legend').hide()
            $('#lst-anom-legend').hide()
            $('#ndvi-legend').show()
            $('#ndvi-anom-legend').hide()
        };
        if (selected_option === "MODIS NDVI Anomaly") {
            $('#lst-legend').hide()
            $('#lst-anom-legend').hide()
            $('#ndvi-legend').hide()
            $('#ndvi-anom-legend').show()
        };
        axis_data = {
            'MODIS NDVI Drought Index': {
                'max':1.0,
                'min':-0.2,
                'title':"NDVI"
            },
            'MODIS NDVI Anomaly': {
                'max':0.7,
                'min':-0.7,
                'title': "NDVI Anomaly"
            }
        };
        chart.yAxis[0].update({max:axis_data[selected_option]['max'],min:axis_data[selected_option]['min']}, false)
        chart.yAxis[0].setTitle({
            text: axis_data[selected_option]['title']
        });
        chart.redraw();
        if ( timeseries_data ) {
            timeseries_data[2] = $(this).find('option:selected').val();
            ajaxGetTimeseries(timeseries_data)
        };
        add_wms()
    }).change();
    $("#select_layer").change(function(){
        var selected_option = $(this).find('option:selected').index();
        add_wms();
        //$("#slider").slider("value", selected_option);
    }).change();
});





