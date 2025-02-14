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


strata <- CreateStrataDF.fn(
    names=c("shallow_s", "deep_s","shallow_n", "deep_n"), 
    depths.shallow = c( 0, 2555, 183,  55, 183),
    depths.deep    = c(183, 549, 183, 549),
    lats.south     = c( 32,  32,  42,  42),
    lats.north     = c( 42,  42,  49,  49))


  

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



###########


subset <- VAST_output_gamma$Fleet=="Coastwide"
vast.bio <- VAST_output_gamma[subset, "Estimate_metric_tons"]
round(mean(vast.bio))
## [1] 12184
round(mean(biomass.WCGBTS$Bio$Value)/1e3)
## [1] 12143


############
#### script to make table of input values and uncertainty for each index
#### formerly in /R/table_of_index_inputs.R

# this could point to any model prior to bigskate67 when IPHC index was removed
bs66dir <- "C:/SS/skates/models//bigskate66_tri_init_fish_asymptotic"
# read data file
dat <- SS_readdat_3.30(file = file.path(bs66dir, "BSKT2019_data.ss"))
# grab CPUE inputs
cpue <- dat$CPUE

Surv.vals.WCGBTS <- biomass.WCGBTS$Bio[,c("Year","Value","seLogB")]
Surv.vals.WCGBTS$Value <- Surv.vals.WCGBTS$Value/1000

Surv.vals.Tri <- biomass.Tri$Bio[,c("Year","Value","seLogB")]
Surv.vals.Tri$Year <- as.numeric(as.character(Surv.vals.Tri$Year))
# chop of 1977
Surv.vals.Tri <- Surv.vals.Tri[Surv.vals.Tri$Year > 1977,]
# why is dividing by 1000 necessary to get them to match,
# perhaps the estimates are in kg?
Surv.vals.Tri$Value <- Surv.vals.Tri$Value/1000

# make table
tab <- data.frame(year = sort(as.numeric(unique(cpue$year))),
                  stringsAsFactors = FALSE)
# loop over fleets with index
for(f in sort(unique(as.numeric(cpue$index)))){
  fleetname <- dat$fleetnames[f]
  col1name <- paste0(dat$fleetname[f], ".obs")
  col2name <- paste0(dat$fleetname[f], ".se_log")
  tab[[col1name]] <- NA
  tab[[col2name]] <- NA
  # subset cpue for this fleet
  cpue.f <- cpue[cpue$index == f,]
  # loop over values within this fleet
  for(irow in 1:nrow(cpue.f)){
    y <- cpue.f$year[irow]
    scale <- 1
    if(f == 7){
      scale <- 1000
    }
    tab[tab$year == y, col1name] <- scale*as.numeric(cpue.f$obs[irow])
    tab[tab$year == y, col2name] <- round(as.numeric(cpue.f$se_log[irow]), 4)
  }
}

### update on 5/18/2019
# remove IPHC and add design-based values
tab <- data.frame(tab[,c(1,4,5)], Tri.design=NA, Tri.design.se_log=NA,
                  tab[,2:3], WCGBTS.design=NA, WCGBTS.design.se_log=NA)
for(y in seq(1980, 2004, 3)){
  tab$Tri.design[tab$year == y] <- Surv.vals.Tri$Value[Surv.vals.Tri$Year == y]
  tab$Tri.design.se_log[tab$year == y] <- Surv.vals.Tri$seLogB[Surv.vals.Tri$Year == y]
}
for(y in 2003:2018){
  tab$WCGBTS.design[tab$year == y] <- Surv.vals.WCGBTS$Value[Surv.vals.WCGBTS$Year == y]
  tab$WCGBTS.design.se_log[tab$year == y] <- Surv.vals.WCGBTS$seLogB[Surv.vals.WCGBTS$Year == y]
}

names(tab) <- gsub("Triennial", "Tri.VAST", names(tab))
names(tab)[6:7] <- gsub("WCGBTS", "WCGBTS.VAST", names(tab)[6:7])
for(icol in c(2,4,6,8)){
  tab[,icol] <- round(tab[,icol])
}
for(icol in 1+c(2,4,6,8)){
  tab[,icol] <- round(tab[,icol], 3)
}
write.csv(tab,
          file="C:/SS/skates/BigSkate_Doc/txt_files/data_summaries/table_of_index_inputs_May18.csv",
          row.names=FALSE)
