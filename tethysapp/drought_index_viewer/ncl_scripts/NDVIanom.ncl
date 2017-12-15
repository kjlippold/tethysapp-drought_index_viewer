
ny = 3600
nx = 7200

; get NDVIs----5th percentile of baresoil NDVImax---a global constant
; NDVImax map is created based on the 2002-2015 global monthly NDVI data
; land cover classes are based on MODIS-NCEP-IGBP global data at 0.05 degree


NDVIs = 698

; get NDVIvi ----95th percentile of NDVImax for each class

;Value  Label
;0      Water
;1      Evergreen Needleleaf forest
;2      Evergreen Broadleaf forest
;3      Deciduous Needleleaf forest
;4      Deciduous Broadleaf forest
;5      Mixed forest
;6      Closed shrublands
;7      Open shrublands
;8      Woody savannas
;9      Savannas
;10     Grasslands
;11     Permanent wetlands
;12     Croplands
;13     Urban and built-up
;14     Cropland/Natural vegetation mosaic
;15     Snow and ice
;16     Barren or sparsely vegetated
;254    Unclassified
;255    Fill Value

; the following NDVIvi are for 0-16 classes

NDVIvi = (/9254,8659,9182,8595,9179,9044,7904,7843,8700,8468,7904,8278,8705,7802,8780,3184,2704/)


diriNDVI = "/mnt/sahara/data2/DROUGHT/MODIS_NDVI_NetCDF/"

cmd = systemfunc("ls "+diriNDVI+"*.nc")
fNDVIs = addfiles(cmd,"r")
ListSetType(fNDVIs, "join")
ndvi = fNDVIs[:]->ndvi


;create 16-day modis NDVI anom

begin

  syr = 2000
  eyr = 2017
  nyr = eyr - syr +1

  diri = "/mnt/sahara/data2/DROUGHT/MODIS_NDVI_NetCDF/"
  diro = "/mnt/sahara/data2/DROUGHT/NDVI_anom/"
  diro2 = "/mnt/sahara/data2/DROUGHT/NDVI_anom/format_1gd4r/"
  
  lat = fspan(-89.975,89.975,ny)
  lat@units = "degrees_north"
  lon = fspan(-179.975,179.975,nx)
  lon@units = "degrees_east"

  nlat = dimsizes(lat)
  nlon = dimsizes(lon)

;  sdays = (/"001","032","060","091","121","152","182","213","244","274","305","335"/)
;  leapsdays = (/"001","032","061","092","122","153","183","214","245","275","306","336"/)
;  mo = (/"jan","feb","mar","apr","may","jun","jul","aug","sep","oct","nov","dec"/)

sdays = (/"001","017","033","049","065","081","097","113","129","145","161","177","193","209","225","241","257","273","289","305","321","337","353"/)
leapsdays = (/"001","017","033","049","065","081","097","113","129","145","161","177","193","209","225","241","257","273","289","305","321","337","353"/)
mo = (/"jan","jan","feb","feb","mar","mar","apr","apr","may","may","jun","jun","jul","jul","aug","aug","sep","sep","oct","nov","nov","dec","dec"/)
day = (/"01","01","01","01","01","01","01","01","01","01","01","01","01","01","01","01","01","01","01","01","01","01","01"/)


  do y = 0, nyr -1

    yr = syr +y

    do m = 0, 22

      if(isleapyear(yr)) then
       fname = systemfunc("ls "+diri+"MOD13C1.A"+yr+leapsdays(m)+"*nc")
       f=addfile(fname,"r")

       fname2 = systemfunc("ls "+diri+"baseline.nc")
       f2=addfile(fname2,"r")

	ndvianom = new((/ny,nx/),"float")
       ndvianom@_FillValue =(/-9999./)
       ndvianom@standard_name = "MODIS NDVI Anomaly [2000-2017 Baseline]"

	ndviout = (f->ndvi)*0.0001
        baselineout = (f2->ndvi)*0.0001

       ndvianom = ndviout - baselineout
	
       fout = addfile(diro+"MODIS_ndvianom_"+yr+leapsdays(m)+".nc","c")
       ;print(ndvianom(1100:1105,1560:1565))

       setfileoption(fout,"DefineMode",True)
       dimNames = (/"lat","lon"/)
       dimSizes = (/nlat, nlon/)
       dimUnlim = (/False, False/)
       filedimdef(fout,dimNames,dimSizes,dimUnlim)
       filevardef(fout, "lat", typeof(lat), "lat")
       filevardef(fout, "lon", typeof(lon), "lon")
       filevardef(fout, "NDVIanomaly", typeof(ndvianom),(/"lat", "lon"/))
       filevarattdef(fout, "lat", lat)
       filevarattdef(fout, "lon", lon)

       fout->NDVIanomaly =(/ndvianom/)
       fout->lat = (/lat/)
       fout->lon = (/lon/)

       setfileoption("bin","WriteByteOrder","BigEndian")
       fbindirwrite(diro2+"MODIS_ndvianom."+yr+"."+leapsdays(m)+".1gd4r",ndvianom)

      else
       fname = systemfunc("ls "+diri+"MOD13C1.A"+yr+sdays(m)+"*nc")
       f=addfile(fname,"r")

       fname2 = systemfunc("ls "+diri+"baseline.nc")
       f2=addfile(fname2,"r")

        ndvianom = new((/ny,nx/),"float")
       ndvianom@_FillValue =(/-9999./)
       ndvianom@standard_name = "MODIS NDVI Anomaly [2000-2017 Baseline]"

        ndviout = (f->ndvi)*0.0001
        baselineout = (f2->ndvi)*0.0001

       ndvianom = ndviout - baselineout

       fout = addfile(diro+"MODIS_ndvianom_"+yr+sdays(m)+".nc","c")
       ;print(ndvianom(1100:1105,1560:1565))

       setfileoption(fout,"DefineMode",True)
       dimNames = (/"lat","lon"/)
       dimSizes = (/nlat, nlon/)
       dimUnlim = (/False, False/)
       filedimdef(fout,dimNames,dimSizes,dimUnlim)
       filevardef(fout, "lat", typeof(lat), "lat")
       filevardef(fout, "lon", typeof(lon), "lon")
       filevardef(fout, "NDVIanomaly", typeof(ndvianom),(/"lat", "lon"/))
       filevarattdef(fout, "lat", lat)
       filevarattdef(fout, "lon", lon)

       fout->NDVIanomaly =(/ndvianom/)
       fout->lat = (/lat/)
       fout->lon = (/lon/)

       setfileoption("bin","WriteByteOrder","BigEndian")
       fbindirwrite(diro2+"MODIS_ndvianom."+yr+"."+sdays(m)+".1gd4r",ndvianom)
    
      end if
    end do

  end do


end
