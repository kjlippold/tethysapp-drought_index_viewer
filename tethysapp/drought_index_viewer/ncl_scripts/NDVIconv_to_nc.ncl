load "/usr/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "/usr/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "/usr/lib/ncarg/nclscripts/csm/contributed.ncl"
load "/usr/lib/ncarg/nclscripts/csm/shea_util.ncl"



  syr = 2000
  eyr = 2017
  nyr = eyr - syr +1

 diri = "/mnt/sahara/data2/DROUGHT/MODIS_NDVI/"
 diro = "/mnt/sahara/data2/DROUGHT/MODIS_NDVI_NetCDF/"

   ; make lat/long arrays for MODIS

 ny = 3600
 nx = 7200

 lat = fspan(-89.975,89.975,ny)
 lat@units = "degrees_north"
 lon = fspan(-179.975,179.975,nx)
 lon@units = "degrees_east"

 nlat = dimsizes(lat)
 nlon = dimsizes(lon)

 sdays = (/"001","017","033","049","065","081","097","113","129","145","161","177","193","209","225","241","257","273","289","305","321","337","353"/)
 leapsdays = (/"001","017","033","049","065","081","097","113","129","145","161","177","193","209","225","241","257","273","289","305","321","337","353"/)
 month = (/"01","01","02","02","03","03","04","04","05","05","06","06","07","07","08","08","09","09","10","11","11","12","12"/)
 day = (/"01","01","01","01","01","01","01","01","01","01","01","01","01","01","01","01","01","01","01","01","01","01","01"/)


 do y = 0, nyr-1

     yr = syr+y

        do m = 0, 22

     if(isleapyear(yr)) then
       fname = systemfunc("ls "+diri+"MOD13C1.A"+yr+leapsdays(m)+"*hdf")
       f=addfile(fname,"r")
	
	ndviout = new((/ny,nx/),"float")
    ;   ndviout!0 = "lat"
    ;   ndviout&lat = lats
    ;   ndviout!1 = "lon"
    ;   ndviout&lon = lons
       ndviout@_FillValue = (/-9999./)
       ndviout@standard_name = "MODIS NDVI"

       ndviout1 = f->CMG_0_05_Deg_16_days_NDVI
       ndviout = ndviout1(::-1,:)
       fout = addfile(diro+"MOD13C1.A"+yr+leapsdays(m)+".nc","c")
       
       setfileoption(fout,"DefineMode",True)
       dimNames = (/"lat","lon"/)
       dimSizes = (/nlat, nlon/)
       dimUnlim = (/False, False/)
       filedimdef(fout,dimNames,dimSizes,dimUnlim)
       filevardef(fout, "lat", typeof(lat), "lat")
       filevardef(fout, "lon", typeof(lon), "lon")
;      time = str_concat("MODIS:"+yr+"-"+month(m)+"-"+day(m)+"_00:00:00")
;      filevardef(fout, "time", typeof(time), "time")
       filevardef(fout, "ndvi", typeof(ndviout),(/"lat", "lon"/))
       filevarattdef(fout, "lat", lat)
       filevarattdef(fout, "lon", lon)
;       filevarattdef(fout, "time", time)

       fout->ndvi =(/ndviout/)
       fout->lat = (/lat/)
       fout->lon = (/lon/)
;      fout->time = (/time/)

     else
       fname = systemfunc("ls "+diri+"MOD13C1.A"+yr+sdays(m)+"*hdf")
       f=addfile(fname,"r")

       ndviout = new((/ny,nx/),"float")
    ;   ndviout!0 = "lat"
    ;    ndviout&lat = lats
    ;   ndviout!1 = "lon"
    ;   ndviout&lon = lons
       ndviout@_FillValue = (/-9999./)
       ndviout@standard_name = "MODIS NDVI"

	ndviout1 = f->CMG_0_05_Deg_16_days_NDVI
       ndviout = ndviout1(::-1,:)
       fout = addfile(diro+"MOD13C1.A"+yr+sdays(m)+".nc","c")

       setfileoption(fout,"DefineMode",True)
       dimNames = (/"lat","lon"/)
       dimSizes = (/nlat, nlon/)
       dimUnlim = (/False, False/)
       filedimdef(fout,dimNames,dimSizes,dimUnlim)
       filevardef(fout, "lat", typeof(lat), "lat")
       filevardef(fout, "lon", typeof(lon), "lon")
;      time = str_concat("MODIS:"+yr+"-"+month(m)+"-"+day(m)+"_00:00:00")
;      filevardef(fout, "time", typeof(time), "time")
       filevardef(fout, "ndvi", typeof(ndviout),(/"lat", "lon"/))
       filevarattdef(fout, "lat", lat)
       filevarattdef(fout, "lon", lon)
;      filevarattdef(fout, "time", time)

       fout->ndvi =(/ndviout/)
       fout->lat = (/lat/)
       fout->lon = (/lon/)
;      fout->time = (/time/)


     end if

        end do


 end do
