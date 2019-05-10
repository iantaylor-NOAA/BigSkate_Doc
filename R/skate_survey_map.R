############################################################################
# map showing hauls in WCGBT Survey with Big Skate
# for some reason this needs to be run in an older version of R (like 3.3.1)
# to avoid the plot not getting clipped to the plotting region

graphics.off()
dir <- 'c:/SS/skates/BigSkate_Doc/'

species <- "BS"
if(species == "BS"){
  load(file = file.path(dir, '../data/BigSkate_survey_extractions_4-22-2019.Rdata'))
  Surv.Hauls <- catch.WCGBTS.BS
}
if(species == "LN"){
  load(file = file.path(dir, '../data/LSKT_survey_catch_5-09-2019.Rdata'))
  Surv.Hauls <- catch.WCGBTS.LN
}

# CSV file with EEZ created by Ian from KML file available from
# http://www.nauticalcharts.noaa.gov/csdl/mbound.htm#data
eez <- read.csv(file.path(dir, 'txt_files/EEZ_polygon_lat_lon.csv'))


# load packages
require(maps)
require(mapdata)

doPNG <- TRUE
# open PNGfile
if(doPNG){
  if(species == "BS"){
    png(file.path(dir, 'Figures/survey_hauls_map.png'),
        width=8, height=6.5, res=350, units='in')
  }
  if(species == "LN"){
    png(file.path(dir, 'Figures/survey_hauls_map_LSKT.png'),
        width=8, height=6.5, res=350, units='in')
  }
}
layout(mat=t(c(1,2)), widths=c(1,1.9))
for(iarea in 1:2){
  par(mar=c(3,5,.1,.1), xpd=FALSE)
  if(iarea==1){
    xlim <- c(-126, -122)
    ylim <- c(40, 49)
  }else{
    xlim <- c(-125.5, -117)
    ylim <- c(31.7, 40.7)
  }    
  # map of Northern area only
  map('worldHires', regions=c("Canada","Mexico"),
      xlim=xlim, ylim=ylim, xaxs='i', yaxs='i',
      col='grey', fill=TRUE, interior=TRUE, lwd=1)
  lines(eez$lon, eez$lat, lty=3)
  # horizontal line at 40-10
  #abline(h=c(40+10/60), lty=3)
  text(-127, 40, "40°10'", pos=3)
  # map with US states
  map('state', regions=c("Wash","Oreg","Calif","Idaho",
                   "Montana","Nevada","Arizona","Utah"),
      add=TRUE,
      col='grey', fill=TRUE, interior=TRUE, lwd=1)
  axis(2, at=seq(30,50,2), lab=paste0(seq(30,50,2), "°N"), las=3)
  axis(1, at=seq(-130,-114,2), lab=paste0(abs(seq(-130,-114,2)), "°W"))
  #map.axes()

  text(-123, 46.8, "WA")
  text(-123, 44, "OR")
  text(-123, 41, "CA")
  text(-120, 37, "CA")
  # empty hauls
  points(Surv.Hauls$Longitude_dd, Surv.Hauls$Latitude_dd, pch=".", col=rgb(1,0,0,.4))
  # positive hauls
  scale <- .3
  points(Surv.Hauls$Longitude_dd, Surv.Hauls$Latitude_dd, pch=16,
         cex=scale*sqrt(Surv.Hauls$total_catch_wt_kg/Surv.Hauls$Area_Swept_ha),
         col=rgb(0,0,1,.2))
  ## # Hook & Line catch
  if(iarea==2){
    # legend
    legend('topright', pch=c(16,16,16),
           col=c(rep(rgb(0,0,1,.3), 2),
               rgb(1,0,0,.8)),
           pt.cex=c(scale*sqrt(100), scale*sqrt(10), .3),
           legend=c("100 kg/ha","10 kg/ha", "no catch"))
               
  }
    
  box()
} # end loop over area = 1 or 2
if(doPNG){
  dev.off()
}

