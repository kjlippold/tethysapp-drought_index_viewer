
ny = 3600
nx = 7200

diriLST = "/mnt/sahara/data2/DROUGHT/MODIS_LST_NetCDF/"

cmd = systemfunc("ls "+diriLST+"*.nc")
fLSTs = addfiles(cmd,"r")
ListSetType(fLSTs, "join")
lst = fLSTs[:]->lst

;create 8-day modis LST anom

begin

  syr = 2000
  eyr = 2017
  nyr = eyr - syr +1

  diri = "/mnt/sahara/data2/DROUGHT/MODIS_LST_NetCDF/"
  diro = "/mnt/sahara/data2/DROUGHT/LST_anom/"
  diro2 = "/mnt/sahara/data2/DROUGHT/LST_anom/format_1gd4r/"
  
  lat = fspan(-89.975,89.975,ny)
  lat@units = "degrees_north"
  lon = fspan(-179.975,179.975,nx)
  lon@units = "degrees_east"

  nlat = dimsizes(lat)
  nlon = dimsizes(lon)


 sdays =(/"001","009","017","025","033","041","049","057","065","073","081","089","097","105","113","121","129","137","145","153","161","169","177","185","193","201","209","217","225","233","241","249","257","265","273","281","289","297","305","313","321","329","337","345","353","361"/)

leapsdays =(/"001","009","017","025","033","041","049","057","065","073","081","089","097","105","113","121","129","137","145","153","161","169","177","185","193","201","209","217","225","233","241","249","257","265","273","281","289","297","305","313","321","329","337","345","353","361"/)

month = (/"01","01","01","01","02","02","02","02","03","03","03","03","04","04","04","05","05","05","05","06","06","06","06","07","07","07","07","08","08","08","08","09","09","09","09","10","10","10","11","11","11","11","12","12","12","12"/)

day = (/"01","01","01","01","01","01","01","01","01","01","01","01","01","01","01","01","01","01","01","01","01","01","01","01","01","01","01","01","01","01","01","01","01","01","01","01","01","01","01","01","01","01","01","01","01","01"/)

  do y = 0, nyr -1

    yr = syr +y

    do m = 0, 45

      if(isleapyear(yr)) then
       fname = systemfunc("ls "+diri+"MOD11C2.A"+yr+leapsdays(m)+"*nc")
       f=addfile(fname,"r")

       fname2 = systemfunc("ls "+diri+"baseline.nc")
       f2=addfile(fname2,"r")

	lstanom = new((/ny,nx/),"float")
       lstanom@_FillValue =(/-9999./)
       lstanom@standard_name = "MODIS LST Anomaly [2000-2017 Baseline]"

	lstout = (f->lst)*0.02
        baselineout = (f2->lst)*0.02

       lstanom = lstout - baselineout
	
       fout = addfile(diro+"MODIS_lstanom_"+yr+leapsdays(m)+".nc","c")
       ;print(lstanom(1100:1105,1560:1565))

       setfileoption(fout,"DefineMode",True)
       dimNames = (/"lat","lon"/)
       dimSizes = (/nlat, nlon/)
       dimUnlim = (/False, False/)
       filedimdef(fout,dimNames,dimSizes,dimUnlim)
       filevardef(fout, "lat", typeof(lat), "lat")
       filevardef(fout, "lon", typeof(lon), "lon")
       filevardef(fout, "LSTanomaly", typeof(lstanom),(/"lat", "lon"/))
       filevarattdef(fout, "lat", lat)
       filevarattdef(fout, "lon", lon)

       fout->LSTanomaly =(/lstanom/)
       fout->lat = (/lat/)
       fout->lon = (/lon/)

       setfileoption("bin","WriteByteOrder","BigEndian")
       fbindirwrite(diro2+"MODIS_lstanom."+yr+"."+leapsdays(m)+".1gd4r",lstanom)

      else
       fname = systemfunc("ls "+diri+"MOD11C2.A"+yr+sdays(m)+"*nc")
       f=addfile(fname,"r")

       fname2 = systemfunc("ls "+diri+"baseline.nc")
       f2=addfile(fname2,"r")

        lstanom = new((/ny,nx/),"float")
       lstanom@_FillValue =(/-9999./)
       lstanom@standard_name = "MODIS LST Anomaly [2000-2017 Baseline]"

        lstout = (f->lst)*0.02
        baselineout = (f2->lst)*0.02

       lstanom = lstout - baselineout

       fout = addfile(diro+"MODIS_lstanom_"+yr+sdays(m)+".nc","c")
       ;print(lstanom(1100:1105,1560:1565))

       setfileoption(fout,"DefineMode",True)
       dimNames = (/"lat","lon"/)
       dimSizes = (/nlat, nlon/)
       dimUnlim = (/False, False/)
       filedimdef(fout,dimNames,dimSizes,dimUnlim)
       filevardef(fout, "lat", typeof(lat), "lat")
       filevardef(fout, "lon", typeof(lon), "lon")
       filevardef(fout, "LSTanomaly", typeof(lstanom),(/"lat", "lon"/))
       filevarattdef(fout, "lat", lat)
       filevarattdef(fout, "lon", lon)

       fout->LSTanomaly =(/lstanom/)
       fout->lat = (/lat/)
       fout->lon = (/lon/)

       setfileoption("bin","WriteByteOrder","BigEndian")
       fbindirwrite(diro2+"MODIS_lstanom."+yr+"."+sdays(m)+".1gd4r",lstanom)
    
      end if
    end do

  end do


end
