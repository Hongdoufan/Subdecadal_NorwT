;************************************
; trans_1.ncl
;************************************
;
; Concepts illustrated:
;   - Calculating and plotting a transect
;   - Using gc_latlon to calculate a great circle path
;   - Using linint2_points to interpolate rectilinear grid values to set of lat/lon points
;   - Attaching polylines to a map plot
;   - Explicitly setting tickmarks and labels on the bottom X axis
;************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;************************************
begin
  in = addfile("/work/uo1075/u241321/data/Boot_section.nc","r")
  coe  = in->coe
  sig  = in->sig

;********************************
; create plot
;********************************
  nyear = 6
  wks = gsn_open_wks("pdf","/work/uo1075/u241321/results/Temp_section_boot")       ; send graphics to PNG file
  plot = new(nyear,graphic) 
  plotA = new(nyear,graphic) 
  plotB = new(nyear,graphic) 
  res                     = True          ; plot mods desired
  res@gsnDraw             = False            ; don't draw
  res@gsnFrame            = False            ; don't advance frame
  res@tmXBMode            = "Explicit"    ; explicitly label x-axis
;  res@tmXBValues          = (/points(0),points(1),points(npts-1)/) ; points to label
; label values
  res@tmXBLabels          = (/"a","3","4"/)
;  (/leftlat +", "+leftlon, rightlat+", "+rightlon/)

  res@cnFillOn            = True         ; turn on color
  res@cnFillPalette       = "cmocean_balance"  ; set color map
  res@cnLinesOn           = False        ; turn off countour lines
  res@lbLabelBarOn        = False
  res@cnLineLabelsOn    =False
;  res@lbOrientation       = "vertical"   ; vertical label bar
;  res@pmLabelBarOrthogonalPosF = -0.05        ; move label bar closer to plot
  res@cnLevelSelectionMode = "ManualLevels"
  res@cnMinLevelValF       = -1.4             ; set min contour level
  res@cnMaxLevelValF       =  1.4             ; set max contour level
  res@cnLevelSpacingF      =  0.2              ; set contour spacing
  res@gsnRightStringOrthogonalPosF = 1

  res@tiMainString        = " "   ; add title
  res@tiXAxisString       = " "
;  res@tiXAxisFontHeightF = 2
;  res@trXReverse          = True         ; reverse x axis (neg longitudes)
;  res@cnLevelSpacingF     = 1.0          ; set contour spacing

  res@vpHeightF            = 4      ; Set height and width
  res@vpWidthF             = 25
  res@tmXBLabelFontHeightF  =  0.5
  res@tmYLLabelFontHeightF  =  0.5
  res@cnInfoLabelOn = False
  
;************************************
; Converts the irregular z-axis to linear. 

;  res@gsnYAxisIrregular2Linear = True   
  res@trYReverse          = True         ; reverse y axis

;============================================================
; stip the difference in correlation at 95% significant level
;============================================================

 opt = True
 opt@gsnShadeFillType = "pattern"       
 opt@gsnShadeHigh= 17          ;
sres                 = True
sres@gsnDraw         = False
sres@gsnFrame        = False
sres@cnLineLabelsOn  = False
sres@cnLinesOn       = False
sres@cnInfoLabelOn   = False
sres@cnFillOn        = True
sres@lbLabelBarOn= False
sres@cnLevelSelectionMode = "ExplicitLevels"
sres@cnFillDrawOrder="postDraw"
sres@cnLevels = (/0.949, 0.951/) 
sres@cnMonoFillPattern    = False            ; want multiple patterns
sres@cnFillPatterns       = (/-1,17,17/)     ; the patterns
sres@cnMonoFillScale      = False            ; want different densities
sres@cnFillScales         = (/1,1/)    ; change densities
sres@cnMonoFillColor      =True
sres@cnFillColor      = (/"gold3"/)
sres@cnFillDotSizeF       = 0.00007
;============================================================
; panel plot only resources
resP                     = True         ; modify the panel plot
resP@gsnFrame           = False                ; don't advance panel plot
resP@gsnMaximize         = True         ; large format
resP@gsnPanelLabelBar    = True         ; add common colorbar
resP@tiMainString             = "Temperature anomaly" ; title
resP@lbLabelFontHeightF = 0.01
resP@pmLabelBarOrthogonalPosF = 0       ; 0.05

  
do n=0,nyear-1

res@gsnLeftString  = coe&mode(n)+" year" 
res@gsnRightString = " "
plotA(n)=gsn_csm_contour(wks,coe(n,:,:),res)
plotB(n)=gsn_csm_contour(wks,sig(n,:,:),sres)
overlay(plotA(n),plotB(n))
plot(n)=plotA(n)

end do

gsn_panel(wks,plot,(/nyear,1/),resP)     ; now draw as one plot
frame(wks)


end





