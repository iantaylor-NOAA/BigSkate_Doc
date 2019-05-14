############################################################################
# map showing EEZ for 2019 Big Skate stock assessment
bsdir <- './'

# define names and colors for each area
col <- rgb(0,0,1,.5)

# load packages
require(maps)
require(mapdata)

# CSV file with EEZ created by Ian from KML file available from
# http://www.nauticalcharts.noaa.gov/csdl/mbound.htm#data
eez <- read.csv(file.path(bsdir, 'txt_files/EEZ_polygon_lat_lon.csv'))

# open PNGfile
png(file.path(bsdir, 'Figures/assess_region_map.png'),
    width=4.875, height=6, res=350, units='in')
par(mar=c(3,3,.1,.1))
# map with Canada and Mexico (not sure how to add states on this one)
map('worldHires', regions=c("Canada","Mexico"),
    xlim=c(-130, -114), ylim=c(30, 51),
    col='grey', fill=TRUE, interior=TRUE, lwd=1)
polygon(eez$lon, eez$lat, col=col, border=FALSE)

# map with US states
map('state', regions=c("Wash","Oreg","Calif","Idaho",
                 "Montana","Nevada","Arizona","Utah"),
    add=TRUE,
    col='grey', fill=TRUE, interior=TRUE, lwd=1)
axis(2, at=seq(30,50,2), lab=paste0(seq(30,50,2), "?N"), las=1)
axis(1, at=seq(-130,-114,4), lab=paste0(abs(seq(-130,-114,4)), "?W"))
#map.axes()


#### add vertical lines indicating range for each stock
## latrange <- c(40+10/60, 48.5) + c(.2, -.2)
## lines(rep(-126,2), latrange, lwd=10, col=mod.cols[1])
## text(-126-.8, mean(latrange), mod.names[1], srt=90)
## latrange <- c(32.5, 40+10/60) + c(.2, -.2)
## lines(rep(-126,2), latrange, lwd=10, col=mod.cols[2])
## text(-126-.8, mean(latrange), mod.names[2], srt=90)
#
text(-122, 50, "Canada")
text(-120, 47.75, "Washington")
text(-121, 44, "Oregon")
text(-120, 37, "California")
text(-115.5, 32.1, "Mexico")
#
box()
dev.off()
