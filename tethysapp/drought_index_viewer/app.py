from tethys_sdk.base import TethysAppBase, url_map_maker


class DroughtIndexViewer(TethysAppBase):
    """
    Tethys app class for Drought Index Viewer.
    """

    name = 'Drought Index Viewer'
    index = 'drought_index_viewer:home'
    icon = 'drought_index_viewer/images/Terrestrial_globe.svg.png'
    package = 'drought_index_viewer'
    root_url = 'drought-index-viewer'
    color = '#301891'
    description = 'View global MODIS NDVI and LST data collected by NASA\'s Terra and Aqua satellites.'
    tags = ''
    enable_feedback = False
    feedback_emails = []

    def url_maps(self):
        """
        Add controllers
        """
        UrlMap = url_map_maker(self.root_url)

        url_maps = (
            UrlMap(
                name='home',
                url='drought-index-viewer',
                controller='drought_index_viewer.controllers.home'
            ),
            UrlMap(
                name='ajax-point-timeseries',
                url='drought-index-viewer/ajax-point-timeseries',
                controller='drought_index_viewer.ajax_controllers.ajax_point_timeseries'
            ),
        )

        return url_maps
