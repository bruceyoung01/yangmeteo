
 ; plot pm2.5 vs. radiances
   PRO plot_dnb_radiance, filename, dir, position, pequation

 readcol, dir + filename + '_1.txt', yy, mm, dd, hr, lat, lon, vza, SatAZM, $
         moonphase, LZA, LAZM, PMA, PMB, F= 'I, I, I, I,  F, F, F, F, F, F, F, F, F', $
         skipline = 1, DELIMITER = ','

 readcol, dir + filename + '_2.txt', rad1, rad2, rad3, rad4, rad5, rad6, rad7, $
         rad8, rad9, rad10, rad11, rad12, rad13, rad14, rad15, rad16, $
         F = 'F, F, F, F, F, F, F, F, F, F, F, F, F, F, F, F', skipline = 1, $
         DELIMITER = ','
 
 readcol, dir + filename + '_3.txt', rad17, rad18, rad19, rad20, rad21, rad22, rad23, $
         rad24, rad25, $
         F = 'F, F, F, F, F, F, F, F, F ', skipline = 1, DELIMITER = ','
 
 readcol, dir + '/visualized_couldmask_selected1.txt', cld1, skipline = 1
 readcol, dir + '/visualized_couldmask_selected2.txt', cld2, skipline = 1
 readcol, dir + '/visualized_couldmask_excellent.txt', cld3, skipline = 1

 ; computer mean of radiances
 NL = n_elements (yy)
 rad = fltarr(NL)
 tmprad = fltarr(25)
 for i = 0, NL-1 do begin
 tmprad (0:24) = [rad1(i), rad2(i) , rad3(i) , rad4(i) , rad5(i) ,  $
              rad6(i) , rad7(i) , rad8(i) , rad9(i) , rad10(i) , $
              rad11(i) , rad12(i) , rad13(i) , rad14(i) , rad15(i) , $
              rad16(i) , rad17(i) , rad18(i) , rad19(i) , rad20(i) , $
              rad21(i) , rad22(i) , rad23(i) , rad24(i) , rad25(i) ] 

 rad(i) = mean(tmprad)
 rad(i) = max(tmprad)
 
 if (min(tmprad) gt 0 ) then begin
 ; tmprad = alog(tmprad)
;  result = where (tmprad le max(tmprad) and tmprad gt median(tmprad))
;  rad(i) = median(alog(tmprad(result)))

 result = percentiles (tmprad)
 rad(i) = alog( (tmprad(result(1)) + tmprad(result(2)))*0.5 )
 rad(i) = alog(tmprad(result(1)))
 endif
 
; result = where (max(tmprad) eq tmprad)
; print, result(0)
; ctrnl = result(0)/5
; ctrnp = result(0) - result(0)/5*5
; print, ctrnl, ctrnp 
 endfor             

 ; plot linear and scatter plot
 yy = rad
 xx = 0.5 * (PMA+PMB)/cos(vza*!pi/180.)
 result = where ( xx gt 0 and rad gt -4.0 and moonphase gt 120 and $
                  rad lt 2.0 and vza lt 60 and mm lt  10)
 best_fit, yy(result),  xx(result) , ifplot=1, xrange = [0, 40], $
          yrange = [-4, 2], $
          xtitle = 'PM2.5/(cos(VZA))', $
          ytitle = ' alog(rad) ', position = position, $
          pequation = pequation
 end  


; Main Code Starts Here
 ; set plot ps
 ps_color, filename = 'PM_DNB.ps'
 
 ; set plot for 5 panels
 multipanel, row=3, col=2 
 multipanel, position = position

;                   A           B           C            D           E
;              N. Atlanta    SW            SE           CTR         CTR      
 FileNames = ['131350002', '130770002', '131510002', '131210055', '130890002'] 


; dir = './data_w_background/'
 dir = './data_ctr/'
 
 for i = 0, 4 do begin
 pequation = [ position(0)+0.1* (position(2)-position(0)), position(1)+0.9*(position(3)-position(1)) ] 
 plot_dnb_radiance, filenames(i)+'ctr', dir, position, pequation
 multipanel, position = position, /advance
 endfor

 device, /close
 end
