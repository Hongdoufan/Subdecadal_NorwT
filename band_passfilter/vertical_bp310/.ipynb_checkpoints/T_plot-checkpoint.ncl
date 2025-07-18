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
  in = addfile("/work/uo1075/u241321/data/Boot_sectionbp310.nc","r")
  coe  = in->coe
  sig  = in->sig

;********************************
; create plot
;********************************
  nyear = 6
  wks = gsn_open_wks("pdf","/work/uo1075/u241321/results/bp310")       ; send graphics to PNG file
  plot = new(nyear,graphic) 
  plotA = new(nyear,graphic) 
  plotB = new(nyear,graphic) 
  res                     = True          ; plot mods desired
  res@gsnDraw             = False            ; don't draw
  res@gsnFrame            = False            ; don't advance frame

  res@cnFillOn            = True         ; turn on color
  res@cnFillPalette       = "cmocean_balance"  ; set color map
  res@cnLinesOn           = False        ; turn off countour lines
  res@lbLabelBarOn        = True
  res@lbBoxEndCapStyle = "TriangleBothEnds"

  res@cnLineLabelsOn    =False
  res@lbOrientation       = "horizontal"   ; vertical label bar
  res@pmLabelBarOrthogonalPosF = 0.11        ; move label bar closer to plot
  res@pmLabelBarParallelPosF = 0.5        ; move label bar closer to plot
  res@pmLabelBarWidthF =22
  res@pmLegendHeightF  =0.01
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
  res@tmXTOn = False
  res@tmYLOn = True
  res@tmYROn = True
  res@tmXBOn = True
  res@tmYLLabelsOn =False
  res@tmYRLabelsOn =True
  res@gsnLeftStringFontHeightF  = 0.5
  res@gsnLeftStringOrthogonalPosF = -0.2
  res@gsnLeftStringParallelPosF = -0.14
  res@tmXBMode            = "Explicit"    ; explicitly label x-axis
  res@tmXBLabelsOn =True
  res@tmXTLabelsOn =True
  res@tmXBValues              = (/"1","100","200","300","400","500","600","700","800","900"/)
  res@tmXBLabels              = (/"1","2","3","4","5","6","7","8","9","10"/)
  res@cnMissingValFillColor = "gray"

; ************************************
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
;sres@cnLevels    = (/0.94999999/)
sres@cnLevels = (/0.949, 0.951/) 
sres@cnMonoFillPattern    = False            ; want multiple patterns
sres@cnFillPatterns       = (/-1,17,17/)     ; the patterns
sres@cnMonoFillScale      = False            ; want different densities
sres@cnFillScales         = (/1,1/)    ; change densities
sres@cnMonoFillColor      =True
sres@cnFillColor      = (/"gold3"/)
sres@cnFillDotSizeF       = 0.00007
title = (/"(a)","(b)","(c)","(d)","(e)","(f)"/)

;plot
;============================================================


do n=0,nyear-1

res@gsnLeftString  = title(n)+" "+coe&mode(n)+" year" 
res@gsnRightString = " "
plotA(n)=gsn_csm_contour(wks,coe(n,:,:),res)
plotB(n)=gsn_csm_contour(wks,sig(n,:,:),sres)
overlay(plotA(n),plotB(n))
plot(n)=plotA(n)

end do

; Set up resource lists for attaching the plot.
; The res1 will apply to the base plot, and the
; res2 to the plots being attached.  These resources
; lists are *not* for changing things like line color,
; but for changing things like whether the plots
; are maximized, and which axis they are attached on.
;
  res1                     = True
  res2                     = True
  res1@gsnMaximize         = True
  res2@gsnAttachPlotsXAxis = True

; xy1 will be the base plot.
  amid = gsn_attach_plots(plot(0),(/plot(1),plot(2),plot(3),plot(4),plot(5)/),res1,res2)

  draw(plot(0))    ; All four plots will be drawn.
  frame(wks)



end





