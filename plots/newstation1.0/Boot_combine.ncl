begin
; ==============================================================
; User defined parameters that specify region of globe and
; ==============================================================

 
   varname = "t_ver"                                                         
   var1 = "corr"
   var2 = "sig"
    ; set plot name 
   nyear= 6     ; Names for nc files have been changed, e.g.,"boot_reg_t_ver_ly5_block2" is changed to  "boot_reg_t_ver_ly0_block2", so in fact the first file is ly5
   ndepth= 21
   lynumber=ispan(0,nyear-1,1)
   nstation = 9
   npoint = nstation*100
   output  =  "/work/uo1075/u241321/data/"                            ; directory for plot output
  outName = "boot_reg_" + varname + "_block2_dt.nc"                       ; set plot 


all_files = "/work/uo1075/u241321/mistral_home/paper2.1/newstation1.0/boot_reg_" + varname + "_ly"+lynumber + "_block2.nc"
ff = addfiles (all_files, "r")
;---Read "pottmp" in "join" mode and print a summary of the variable
; Read variable(s) multiple data file. Here from CLM 
;===========================================================================
;---Read "pottmp" in "join" mode 
ListSetType (ff, "join")


vv = ff[:]->$var1$
vv!0 = "ly"
vv&ly    = ispan(-5,0,1) 

ss = ff[:]->$var2$
ss!0 = "ly"
ss&ly    = ispan(-5,0,1) 

 system("rm -f $output$+$outName$.nc")
 fout=addfile(output+outName, "c")
 fout->coe=vv
 fout->sig=ss
exit()
;********************************
; create plot
;********************************
  nyear = 6
  wks = gsn_open_wks("pdf","/work/uo1075/u241321/results/test")       ; send graphics to PNG file
  plot = new(nyear,graphic)  
  res                     = True          ; plot mods desired
  res@gsnDraw             = False            ; don't draw
  res@gsnFrame            = False            ; don't advance frame
  res@tmXBMode            = "Explicit"    ; explicitly label x-axis
;  res@tmXBValues          = (/points(0),points(1),points(npts-1)/) ; points to label
; label values
  res@tmXBLabels          = (/"a","3","4"/)
;  (/leftlat +", "+leftlon, rightlat+", "+rightlon/)

  res@cnFillOn            = True         ; turn on color
  res@cnFillPalette       = "BlAqGrYeOrReVi200"  ; set color map
  res@cnLinesOn           = False        ; turn off countour lines
  res@lbLabelBarOn        = False
;  res@lbOrientation       = "vertical"   ; vertical label bar
;  res@pmLabelBarOrthogonalPosF = -0.05        ; move label bar closer to plot
  res@cnLevelSelectionMode = "ManualLevels"
  res@cnMinLevelValF       = -0.1             ; set min contour level
  res@cnMaxLevelValF       =  1.2           ; set max contour level
  res@cnLevelSpacingF      =  0.1              ; set contour spacing

  res@tiMainString        = "Transect"   ; add title
  res@tiXAxisString       = "lat/lon along transect"
;  res@trXReverse          = True         ; reverse x axis (neg longitudes)
;  res@cnLevelSpacingF     = 1.0          ; set contour spacing

;************************************
; Converts the irregular z-axis to linear. 

;  res@gsnYAxisIrregular2Linear = True   
  res@trYReverse          = True         ; reverse y axis

; panel plot only resources
resP                     = True         ; modify the panel plot
resP@gsnFrame           = False                ; don't advance panel plot
;resP@gsnMaximize         = True         ; large format
resP@gsnPanelLabelBar    = True         ; add common colorbar
resP@tiMainString             = "Temperature anomaly" ; title

  
do n=0,nyear-1

res@gsnLeftString  = " "
res@gsnRightString = trans&mode(n)
plot(n)=gsn_csm_contour(wks,tran(n,:,:,0),res)

end do

gsn_panel(wks,plot,(/2,3/),resP)     ; now draw as one plot
frame(wks)

end


