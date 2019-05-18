### plot comparisons of design-based vs. VAST index estimates

if(FALSE){
  devtools::install_github("nwfsc-assess/nwfscSurvey", build_vignettes=TRUE)

  ### load previously extracted values
  load('c:/SS/skates/data/BigSkate_survey_extractions_5-17-2019.Rdata')
  dir.figs <- 'c:/SS/skates/BigSkate_Doc/Figures'
}
require(nwfscSurvey)

strata <- CreateStrataDF.fn(
    names=c("shallow_s", "deep_s","shallow_n", "deep_n"), 
    depths.shallow = c( 55, 183,  55, 183),
    depths.deep    = c(183, 549, 183, 549),
    lats.south     = c( 32,  32,  42,  42),
    lats.north     = c( 42,  42,  49,  49))
##        name      area Depth_m.1 Depth_m.2 Latitude_dd.1 Latitude_dd.2
## 1 shallow_s 187251226        55       183            32            42
## 2    deep_s 182594511       183       549            32            42
## 3 shallow_n 208174619        55       183            42            49
## 4    deep_n 106872334       183       549            42            49

# design-based indices
biomass.WCGBTS <- Biomass.fn(dir = 'c:/SS/skates/indices/WCGBTS', 
                            dat = catch.WCGBTS.BS,  
                            strat.df = strata, 
                            printfolder = "",
                            outputMedian = TRUE)
biomass.Tri <- Biomass.fn(dir = 'c:/SS/skates/indices/Triennial',
                          dat = catch.Tri.BS,  
                          strat.df = strata, 
                          printfolder = "", 
                          outputMedian = TRUE)


  

index.fn <- function(dat, col=1, pch=16, x.adj=0, scale=1,
                     length=0.02, type='o', lty=2, ...){
  # function adding to a plot a series of index values with 95% intervals
  # input is a data.frame with 3 columns:
  #  1. year,
  #  2. biomass, and
  #  3. SD of biomass on a log scale
  yrs <- dat[,1] + x.adj
  bio <- dat[,2]
  sdlog <- dat[,3]
  arrows(x0 = yrs, y0 = scale*qlnorm(.025,meanlog=log(bio), sdlog=sdlog),
         x1 = yrs, y1 = scale*qlnorm(.975,meanlog=log(bio), sdlog=sdlog),
         length = length, angle = 90, code = 3, col = col)
  points(yrs, scale*bio, pch=pch, col=col, type=type, lty=lty, ...)
}

dir.indices <- 'C:/ss/skates/indices/'
VAST_output_gamma <- read.csv(file.path(dir.indices,
                                        'WCGBTS/VAST_output_2019-03-25_Big skate_nx=250_Gamma',
                                        'Table_for_SS3.csv'), stringsAsFactors=FALSE)
VAST_output_lognormal <- read.csv(file.path(dir.indices,
                                        'WCGBTS/VAST_output_2019-03-25_Big skate_nx=250_Lognormal',
                                        'Table_for_SS3.csv'), stringsAsFactors=FALSE)

VAST_output_Tri_gamma <- read.csv(file.path(dir.indices,
                                            "Triennial/Triennial full",
                                            "VAST_output_2019-04-13_Longnose-Triennial_nx=250_Domain=Triennial_gamma",
                                            'Table_for_SS3.csv'), stringsAsFactors=FALSE)
VAST_output_Tri_lognormal <- read.csv(file.path(dir.indices,
                                                "Triennial/Triennial full",
                                                "VAST_output_2019-04-14_Longnose-Triennial_nx=250_Domain=Triennial",
                                                'Table_for_SS3.csv'), stringsAsFactors=FALSE)

#####################################################################
#### comparison figure for WCGBTS
#####################################################################

png(file.path(dir.figs, 'WCGBTS_index_compare.png'),
    width=6.5, height=5, units='in', res=300)
par(mar=c(4,4,1,1))
# empty plot
Surv.vals <- biomass.WCGBTS$Bio[,c("Year","Value","seLogB")]
Surv.vals$Year <- as.numeric(as.character(Surv.vals$Year))
# why is dividing by 1000 necessary to get them to match,
# perhaps the estimates are in kg?
Surv.vals$Value <- Surv.vals$Value/1000 
col.vec <- c(1,4,2)
plot(0, xlab="Year", ylab="Biomass estimate ('000 t)",
     type='l', yaxs='i', xlim=range(Surv.vals$Year), ylim=c(0,35), axes=FALSE)
axis(1, at=2003:2018)
axis(2)
box()
# VAST lognormal
subset <- VAST_output_lognormal$Fleet=="Coastwide"
index.fn(VAST_output_lognormal[subset, c("Year", "Estimate_metric_tons", "SD_log")],
         scale=1e-3, col=col.vec[3], x.adj=.1)
# VAST gamma
subset <- VAST_output_gamma$Fleet=="Coastwide"
index.fn(VAST_output_gamma[subset, c("Year", "Estimate_metric_tons", "SD_log")],
         scale=1e-3, col=col.vec[2], x.adj=0)
# design-based survey
index.fn(Surv.vals,
         scale=1e-3, col=col.vec[1], x.adj=-.1)
# legend
legend('topleft', lwd=3, col=col.vec[c(1,2,3)],
       legend=c("Design-based estimate",
           "VAST estimate (gamma)",
           "VAST estimate (lognormal)"), bty='n')
dev.off()

#####################################################################
#### comparison figure for Triennial
#####################################################################
png(file.path(dir.figs, 'Triennial_index_compare.png'),
    width=6.5, height=5, units='in', res=300)
par(mar=c(4,4,1,1))
# empty plot
Surv.vals <- biomass.Tri$Bio[,c("Year","Value","seLogB")]
Surv.vals$Year <- as.numeric(as.character(Surv.vals$Year))
# chop of 1977
Surv.vals <- Surv.vals[Surv.vals$Year > 1977,]

# why is dividing by 1000 necessary to get them to match,
# perhaps the estimates are in kg?
Surv.vals$Value <- Surv.vals$Value/1000
col.vec <- c(1,4,2)
plot(0, xlab="Year", ylab="Biomass estimate ('000 t)",
     type='l', yaxs='i', xlim=range(Surv.vals$Year), ylim=c(0,10), axes=FALSE)
axis(1, at=Surv.vals$Year)
axis(2)
box()
# VAST lognormal
subset <- VAST_output_Tri_lognormal$Fleet=="Coastwide" &
  VAST_output_Tri_lognormal$Year %% 3 == 0
index.fn(VAST_output_Tri_lognormal[subset, c("Year", "Estimate_metric_tons", "SD_log")],
         scale=1e-3, col=col.vec[3], x.adj=.1*3)
# VAST gamma
subset <- VAST_output_Tri_gamma$Fleet=="Coastwide" &
  VAST_output_Tri_gamma$Year %% 3 == 0
index.fn(VAST_output_Tri_gamma[subset, c("Year", "Estimate_metric_tons", "SD_log")],
         scale=1e-3, col=col.vec[2], x.adj=0)
# design-based survey
index.fn(Surv.vals,
         scale=1e-3, col=col.vec[1], x.adj=-.1*3)
# legend
legend('topleft', lwd=3, col=col.vec[c(1,2,3)],
       legend=c("Design-based estimate",
           "VAST estimate (gamma)",
           "VAST estimate (lognormal)"), bty='n')
dev.off()
