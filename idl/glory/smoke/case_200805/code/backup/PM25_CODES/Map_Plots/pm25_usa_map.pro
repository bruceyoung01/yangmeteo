;  $ID: us_map_plot.pro
; 
; 
   @./sym.pro
    @

; specify date
   yr = 2008
   dday = 25
   mmon = 4
   ttime = 1200  


;  open plot device

   SET_PLOT, 'PS' 
   DEVICE, file = 'For_Melissa/us_map_April25_2008pm25.ps', xsize = 6, ysize =4,$
              /inches, /color, BITS=8
   ;WINDOW, 1, xsize = 600, ysize =400
   loadct, 34, ncolors=80, bottom=20
   
   ; read all PM data
  filedir = '/home/npothier/Assistanceship/EPAAIRS/SimplifiedData/'
  filename = 'Simple_New_RD_501_88502_2008-0.txt'
  nmon = 12
  nday = 31
  readcol, filedir + filename, format='A', /debug

  ;for i = 0, filesnamecount-1 do begin
  readcol, filedir + filename, state_id, county_id, site_id, year, mon, day, $
           time, pm25, $
           format ='I, I, I, I, I, I, I, F', skipline = 1   
  ;skip header and 2008 01 01
   monthcount = n_elements(mon)

; read lat and lon for each site
  readcol, filedir + 'Simple_new_site_monitor.txt', class, $
    	    sitestatecode, sitecountycode, sitesiteid, sitelat, sitelon, $
           format = 'A, I, I, I, F,  F',  skipline = 1,/debug

; find index that matches the time of interest.
	location=where( mon eq mmon $
                    and day eq dday and time eq ttime, COUNT)

    	;if (COUNT eq 0) then begin
	;print, 'Date and Time Do Not Exist'
	;endif else begin
; PM data at the time of interest
      	PPM = PM25[location]
      	SSTATE = state_id[location]
      	Ccounty = county_id[location]
      	SSite = site_id[location]
	;endelse
      	LLAT = fltarr(COUNT) - 999
      	LLON = fltarr(COUNT) - 999

for i=0,COUNT-1 do begin 
	index=where(sitestatecode eq SSTATE[i] and $
                    sitecountycode eq Ccounty[i] and $
                     sitesiteid eq SSite[i], CCOUNT)
        
        if ccount eq 0 then begin
           print, 'no match found' 
           print,  SSTATE[i], Ccounty[i], SSite[i] 
        endif   
  
        if (CCOUNT eq 1 ) then begin
        LLAT[i] = sitelat[index[0]]
        LLON[i] = sitelon[index[0]]
        endif
	
	if (LLAT[i] eq -999.0 or LLON[i] eq -999) then begin
	    LLAT[i]=!values.F_NaN
	    LLON[i]=!values.F_NaN
	    PPM[i]=!values.F_NaN
	endif
endfor    	

   map_range = [25,-130,50,-70]

   MAP_SET, /CONTINENT, MLINETHICK = 1, LIMIT = map_range, $
            title = '!6PM!d2.5!n Map for April 25, 2008 at 1200', $
            color = 1, /usa, /horizon, position = [0.1,0.2,0.9,0.9]

   FOR i = 0, COUNT -1 DO BEGIN

    ; color index for the scatter is a function of PM values
    color_index     = ROUND( PPM[i] * (80./50.)+20. )
   ; bar_labelv      = fltarr(7)
    bar_labelv      = [0.0, 10.0, 20.0, 30.0, 40.0, 50.0]
    
    
    
    ;PPMlabel	    =ROUND(50./80.)-20.)

    print, 'color_indx:', color_index, '  PM:', PPM[i]

    	    oplot, [LLON[i]], [LLAT[i]], color = color_index,psym = sym(1), symsize=0.5;, $
    
    ENDFOR

;  plot the color bar
   COLORBAR, NCOLORS=80, BOTTOM=20, DIVISIONS=5, TICKNAMES=[bar_labelv],$
   POSITION=[0.1, 0.1, 0.9, 0.15]

   DEVICE, /close

   END
