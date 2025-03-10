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
  in = addfile("/work/uo1075/u241321/data/reg_t_ver_tC2.nc","r")
  t  = in->__xarray_dataarray_variable__

t@_FillValue = -999


if (any(isnan_ieee(t))) then
    if(.not.isatt(t,"_FillValue")) then
      t@_FillValue = default_fillvalue(typeof(t))
    end if
    replace_ieeenan (t, t@_FillValue, 0)
end if


;************************************
; calculate great circle along transect
;************************************
  leftlat  =  63.5
  rightlat =  68.5

  leftlon  =  3.5
  rightlon =  11.5

  npts     =   100                    ; number of points in resulting transect

  dist     = gc_latlon(leftlat,leftlon,rightlat,rightlon,npts,-2)
  points   = ispan(0,npts-1,1)*1.0 
;********************************
; interpolate data to great circle
;********************************
  trans   = linint2_points(t&lon,t&lat,t,False,dist@gclon,dist@gclat,2)
  

;  copy_VarAtts(t(:,:,0,0),trans(:,:,0))          ; copy attributes



  trans!0      = "mode"           ; create named dimension and assign
  trans&mode    = ispan(-4,1,1)           ; coordinate variable for 0th dimension only
  
  trans!1      = "depth"           ; create named dimension and assign
  trans&depth    = t&depth           ; coordinate variable for 0th dimension only
 
  trans!2      = "point"           ; create named dimension and assign
  trans&point    = ispan(1,100,1)           ; coordinate variable for 0th dimension only
 
system("rm -f /work/uo1075/u241321/data/Temp_7.nc")
fout=addfile("/work/uo1075/u241321/data/Temp_7.nc", "c")
fout->anom=trans
exit()

;********************************
; create plot
;********************************
  nyear = 6
  wks = gsn_open_wks("pdf","/work/uo1075/u241321/results/T_78")       ; send graphics to PNG file
  plot = new(nyear,graphic)  
  res                     = True          ; plot mods desired
  res@gsnDraw             = False            ; don't draw
  res@gsnFrame            = False            ; don't advance frame
  res@tmXBMode            = "Explicit"    ; explicitly label x-axis
  res@tmXBValues          = (/points(0),points(1),points(npts-1)/) ; points to label
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
  res@cnMinLevelValF       = -1.2             ; set min contour level
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

; plot = gsn_csm_contour(wks,trans(0,:,:),res)  ; create plot
  
do n=0,nyear-1

res@gsnLeftString  = " "
res@gsnRightString = trans&mode(n)
plot(n)=gsn_csm_contour(wks,trans(n,:,:),res)

end do

gsn_panel(wks,plot,(/2,3/),resP)     ; now draw as one plot
frame(wks)

;********************************
; show transect on a map
;********************************
  mres              = True                ; plot mods desired
  mres@gsnFrame     = False               ; don't turn page yet
  mres@gsnDraw      = False               ; don't draw yet
  mres@tiMainString = "Transect Location" ; title
  map = gsn_csm_map(wks,mres)         ; create map

; add polyline to map
  pres                  = True           ; polyline mods desired
  pres@gsLineColor      = "red"          ; color of lines
  pres@gsLineThicknessF = 2.0            ; line thickness   
  id = gsn_add_polyline(wks,map,(/leftlon,rightlon/),(/leftlat,rightlat/),pres)
  draw(map)    ; draws map and polyline
  frame(wks)
end





