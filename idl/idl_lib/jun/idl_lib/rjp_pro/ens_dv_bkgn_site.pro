;=========================================================================

pro plot_site, obs, pos=pos

  @define_plot_size
  ;=========================
  ; Distribution of mean
  ;========================
  limit = [25., -130., 50., -60.]
  LatRange = [ Limit[0], Limit[2] ]
  LonRange = [ Limit[1], Limit[3] ]


  ;---- observation----
  map_set, 0, 0, color=1, /contine, limit=limit, /usa,$
    position=pos[*,0]

  Map_Labels, LatLabel, LonLabel,              $
         Lats=Lats,         LatRange=LatRange,     $
         Lons=Lons,         LonRange=LonRange,     $
         NormLats=NormLats, NormLons=NormLons,     $
         /MapGrid,          _EXTRA=e

  XYOutS, NormLats[0,*], NormLats[1,*], LatLabel, $
          Align=1.0, Color=1, /Normal, charsize=csfac, charthick=charthick

  XYOutS, NormLons[0,*], NormLons[1,*], LonLabel, $
          Align=0.5, Color=1, /Normal, charsize=csfac, charthick=charthick


  plots, obs.lon, obs.Lat, color=1, psym=8, symsize=symsize

 end

;=====================================================================

 pro plot_histo, obs=obs, sim=sim, bkg=bkg, nat=nat, asi=asi, cumulative=cumulative, $
     deciview=deciview, position=position, label=label,  $
     plotbkg=plotbkg

  COMMON SHARE, SPEC, MAXD, MAXP

  @define_plot_size
  @calc_bext

  Nbins = 100.

  p    = [0.1,0.9]

  Xtitle = 'B!dext!n (Mm!u-1!n)'

  obs_d = obs_bext
  sim_d = sim_bext
  bkg_d = bkg_bext
  nat_d = nat_bext
  asi_d = asi_bext

  if keyword_set(deciview) then begin
     Xtitle = '(dv)'
     obs_d = obs_vis
     sim_d = sim_vis
     bkg_d = bkg_vis
     nat_d = nat_vis
     asi_d = asi_vis
  endif

 yrange = [0., MaxD]
 xrange = [0., 100.]

 qqnorm, sim_d, position=position, yrange=yrange, xrange=[-3,3], psym=1
 qqnorm, sim_d-(bkg_d-nat_d), color=4, /over, psym=4
 qqnorm, sim_d-(asi_d-nat_d), color=2, /over, psym=8
; qqnorm, sim_d-(asi_d-nat_d), color=5, /over, psym=8

 check, sim_d

 return

 end

;============================================================================
  @ctl

  NAME    = ['ALL4','SO4', 'NO3', 'OMC', 'EC']
;  NAME    = ['ALL4','+SO4','+NO3','+IOA','+OMC']
  SPEC    = 'ALL4'
  figfile = 'good_west.ps'

  Maxd   = 30.

;=====================
; eastern sites
;=====================
  ; good
;  mapid = [1,3,11,22,28,43,46,51,53,59,60,63,64,67,68,72,77,86,93,103,108,109,121,124]
  ; too high
  mapid = [10,15] ; due to nitrate
  mapid = [88] ; too much sulfate in Ohio
  mapid = [0,17,18,20,41,84,89,123]
  ; too low
;  mapid = [13,21,25,35,34,99,105,106,114]

;=====================
; western sites
;=====================
   ; good sites
   mapid = [  4,  5,  6, 14, 16, 19, 23, 26, 27, 36, $
             37, 39, 40, 42, 52, 56, 62, 65, 66, 69, $
             71, 74, 75, 81, 83, 85, 92,100,102,116, $
            119,120,125,127,129,130,132]
   goodid = [  4,  6, 14, 16, 19, 23, 24, 26, 31, 36, $
              37, 42, 45, 47, 48, 52, 56, 57, 62, 65, $
              74, 75, 79, 85,102,116,119,120,125,127, $
             128,129,130,132]
   okid   = [  5,  8, 27, 39, 40, 49, 58, 66, 69, 71, $
              80, 81, 83, 90, 92, 94,100,113,118]

   ; too high
   mapid = [73, 76, 117]

   mapid = [2,7,8,9,12,30,32,33,38,44]
   mapid = [50,54,55,61,82,87,91,95,97,98]
   mapid = [101,104,107,110,111,112,115,131,133,134]

   ; too low due to nitrate in CA
   mapid = [2,33,54,55,91,97,104]
   ; too high
   mapid = [73, 76, 117]

  ; north western sites for reduction estimate
;   mapid = [4, 14, 16, 19, 27, 30, 32, 36, 38, 45, 52, 56, $
;            58, 61, 62, 65, 71, 74, 75, 79, 80, $
;            94,102,110,111,112,113,116,119,120,127,130,132]


  ; too low due to omc
;   mapid = [12,50,82,115,132,133]

;   mapid = [goodid,okid]

;   mapid = [7,44,131]  ; 7 is selected (bibe)
;   mapid = [6,26,37]


  ; north western sites for reduction estimate
   mapid = [4, 14, 16, 19, 27, 36, 38, 52, 56, $
            58, 62, 65, 71, 74, 75, 79, 80, $
            94,102,113,116,119,120,127,130]


  !P.multi=[0,3,2,0,0]
  Pos = cposition(3,2,xoffset=[0.05,0.05],yoffset=[0.15,0.15], $
        xgap=0.05,ygap=0.1,order=0)

  if !D.name eq 'PS' then $
    open_device, file=figfile, /color, /ps, /landscape

  erase

     position = pos[*,0]
     plot_site, newobs(mapid), pos=position
     xp = (position[0]+position[2])*0.5
     yp = position[3]+0.01

     xyouts, xp, yp, 'SITES', color=1, alignment=0.5, /normal

  For N = 0, N_elements(Name)-1 do begin
     SPEC = NAME[N]
     deciview=1
     position = pos[*,N+1]
     plot_histo, obs=newobs(mapid), sim=newsim(mapid), bkg=newbkg(mapid), $
       nat=newnat(mapid), asi=newasi(mapid), deciview=deciview, position=position, $
       /cumulative

     xp = (position[0]+position[2])*0.5
     yp = position[3]+0.02
     xyouts, xp, yp, spec, color=1, alignment=0.5, /normal
  END

  print, '==========Mean altitude============'
  for D = 0, N_elements(mapid)-1 do begin
  print, mapid[D], ' ['+newobs[mapid[D]].siteid+', '+newobs[mapid[D]].state+']', newobs[mapid[D]].elev
  print, mean(newobs[mapid[D]].elev), ptz(mean(newsim[mapid[D]].pres))
  end


 if !D.name eq 'PS' then close_device

End
