begin
; ==============================================================
; User defined parameters that specify region of globe and
; ==============================================================

   var1 = "coe"
   var2 = "sig" 
   varname = "anom"                                                          ; create a plot [?]
   output  =  "/work/uo1075/u241321/data/"                            ; directory for plot output
   outName = "Boot_section.nc"                       ; set plot name 
   nyear= 6
   ndepth= 21
   nstation = 9
   snumber=ispan(0,nstation-1,1)
   npoint = nstation*100




all_files = "/work/uo1075/u241321/data/boot_section" + snumber + "_block2.nc"
ff = addfiles (all_files, "r")
;---Read "pottmp" in "join" mode and print a summary of the variable
; Read variable(s) multiple data file. Here from CLM 
;===========================================================================
;---Read "pottmp" in "join" mode 
ListSetType (ff, "join")


vv = ff[:]->$var1$
vv!0 = "section"

ss= ff[:]->$var2$
ss!0 = "section"

tran= vv(section|:,point|:,mode|:,depth|:) 
trans = reshape(tran,(/npoint,nyear,ndepth/))

tra_s= ss(section|:,point|:,mode|:,depth|:) 
tran_s = reshape(tra_s,(/npoint,nyear,ndepth/))

    
  trans!1      = "mode"           ; create named dimension and assign
  trans&mode    = ispan(-5,0,1)           ; coordinate variable for 0th dimension only
  
  trans!2      = "depth"           ; create named dimension and assign
  trans&depth    = vv&depth           ; coordinate variable for 0th dimension only
 
  trans!0      = "point"           ; create named dimension and assign
  trans&point    = ispan(1,npoint,1)           ; coordinate variable for 0th dimension only

  copy_VarCoords(trans, tran_s)
  trans_new = trans(mode|:,depth|:,point|:)   
  trans_s_new = tran_s(mode|:,depth|:,point|:) 

 system("rm -f $output$+$outName$.nc")
 fout=addfile(output+outName, "c")
 fout->coe=trans_new
 fout->sig=trans_s_new
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


