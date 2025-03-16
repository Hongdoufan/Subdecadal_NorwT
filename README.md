# Subdecadal_NorwT
Source python for the submitted paper to the Journal of Climate and the Phd project: chapter 2: See PhD publication (chrome-extension://efaidnbmnnnibpcajpcglclefindmkaj/https://pure.mpg.de/rest/items/item_3617726/component/file_3619069/content)

1.Preprocessing: All ASSIM and hindcasts data are linearly detrended. The yearly anomalies are calculated with respect to its
climatology, which is defined as the 50-yr (1970-2019) mean of the 16-member ensemble

mean in ASSIM and the 80-member ensemble mean in hindcasts.
2.The Ensemble Empirical Mode Decomposition method is applied to extract the subdecadal variability of the area-averaged
Norwegian Sea temperature, NAO index, SPG index, tendency of ocean heat content, turbulent heat flux, and temperature transport.
3.The second EEMD component c2 of the Norwegian Sea temperature is regressed onto fields. 
4.The block bootstrapping is used to do the significace test.
5.The code for plotting is included.
