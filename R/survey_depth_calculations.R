if(FALSE){
### investigations into catch rate by depth

if(FALSE){
  devtools::install_github("nwfsc-assess/nwfscSurvey", build_vignettes=TRUE)

  ### load previously extracted values
  load('c:/SS/skates/data/BigSkate_survey_extractions_5-17-2019.Rdata')
  dir.figs <- 'c:/SS/skates/BigSkate_Doc/Figures'
}
require(nwfscSurvey)

# get strata
strat1 <- expand.grid(c(32,36,42,46), c(seq(50,150,25),200))
names(strat1) <- c("lats.south","depths.shallow")
strat1$lats.north <- NA
strat1$depths.deep <- NA
strat1$lats.north[strat1$lats.south == 32] <- 36
strat1$lats.north[strat1$lats.south == 36] <- 42
strat1$lats.north[strat1$lats.south == 42] <- 46
strat1$lats.north[strat1$lats.south == 46] <- 49
strat1$depths.deep <- strat1$depths.shallow + 25
strat1$depths.deep[strat1$depths.deep == 225] <- 549
strat1$depths.shallow[strat1$depths.shallow == 50] <- 55
strat1$depths.shallow[strat1$depths.shallow == 150] <- 155
strat1$depths.deep[strat1$depths.deep == 150] <- 155
strat1$depths.deep[strat1$depths.deep == 175] <- 200
strat1$names = paste0(strat1$depths.shallow, "-",
    strat1$depths.deep, "m_",
    strat1$lats.south, "-",
    strat1$lats.north, "degN")
strata <- CreateStrataDF.fn(names=strat1$names, 
                            depths.shallow = strat1$depths.shallow,
                            depths.deep = strat1$depths.deep,
                            lats.south = strat1$lats.south,
                            lats.north = strat1$lats.north)

head(strata)
##                name     area Depth_m.1 Depth_m.2 Latitude_dd.1 Latitude_dd.2
## 1  55-75m_32-36degN 1512.609        55        75            32            36
## 2  55-75m_36-42degN 2481.987        55        75            36            42
## 3  55-75m_42-46degN 1745.556        55        75            42            46
## 4  55-75m_46-49degN 1438.966        55        75            46            49
## 5 75-100m_32-36degN 2429.700        75       100            32            36
## 6 75-100m_36-42degN 3362.454        75       100            36            42
 
biomass.WCGBTS <- Biomass.fn(dir = 'c:/SS/skates/indices/WCGBTS/depths', 
                            dat = catch.WCGBTS.BS,  
                            strat.df = strata, 
                            printfolder = "many_depth",
                            outputMedian = TRUE)




# get strata
strat1 <- expand.grid(c(32,36,42,46), c(seq(50,150,25),200))
names(strat1) <- c("lats.south","depths.shallow")
strat1$lats.north <- NA
strat1$depths.deep <- NA
strat1$lats.north[strat1$lats.south == 32] <- 36
strat1$lats.north[strat1$lats.south == 36] <- 42
strat1$lats.north[strat1$lats.south == 42] <- 46
strat1$lats.north[strat1$lats.south == 46] <- 49
strat1$depths.deep <- strat1$depths.shallow + 25
strat1$depths.deep[strat1$depths.deep == 225] <- 250
strat1$depths.shallow[strat1$depths.shallow == 50] <- 55
strat1$depths.shallow[strat1$depths.shallow == 150] <- 155
strat1$depths.deep[strat1$depths.deep == 150] <- 155
strat1$depths.deep[strat1$depths.deep == 175] <- 200
strat1$region <- NA
strat1$region[strat1$lats.south == 32] <- "CA.S"
strat1$region[strat1$lats.south == 36] <- "CA.N"
strat1$region[strat1$lats.south == 42] <- "OR"
strat1$region[strat1$lats.south == 46] <- "WA"

strat1$names = paste0(strat1$depths.shallow, "-",
    strat1$depths.deep, "m_",
    strat1$region)
strata1 <- CreateStrataDF.fn(names=strat1$names, 
                            depths.shallow = strat1$depths.shallow,
                            depths.deep = strat1$depths.deep,
                            lats.south = strat1$lats.south,
                            lats.north = strat1$lats.north)

head(strata1)
##           name     area Depth_m.1 Depth_m.2 Latitude_dd.1 Latitude_dd.2
## 1  55-75m_CA.S 1512.609        55        75            32            36
## 2  55-75m_CA.N 2481.987        55        75            36            42
## 3    55-75m_OR 1745.556        55        75            42            46
## 4    55-75m_WA 1438.966        55        75            46            49
## 5 75-100m_CA.S 2429.700        75       100            32            36
## 6 75-100m_CA.N 3362.454        75       100            36            42


biomass.WCGBTS1 <- Biomass.fn(dir = 'c:/SS/skates/indices/WCGBTS/depths', 
                              dat = catch.WCGBTS.BS,  
                              strat.df = strata1, 
                              printfolder = "many_depth",
                              outputMedian = TRUE)

catch.WCGBTS.BS.noyear <- catch.WCGBTS.BS
catch.WCGBTS.BS.noyear$Year <- 2020

biomass.WCGBTS2020 <- Biomass.fn(dir = 'c:/SS/skates/indices/WCGBTS/depths', 
                              dat = catch.WCGBTS.BS.noyear,  
                              strat.df = strata1, 
                              printfolder = "many_depth",
                              outputMedian = TRUE)
results <- biomass.WCGBTS2020$All$Strata$Year2020
results <- cbind(results, strata1)
results$region <- strat1$region

head(results)
##                      name     area ntows meanCatchRate varCatchRate       Bhat
## 55-75m_CA.S   55-75m_CA.S 1512.609   128      37.58632     47696.11   56853.41
## 55-75m_CA.N   55-75m_CA.N 2481.987   202     624.77471   1219833.90 1550682.99
## 55-75m_OR       55-75m_OR 1745.556   146     499.40076    676888.10  871731.78
## 55-75m_WA       55-75m_WA 1438.966   111     477.22553    654071.77  686711.08
## 75-100m_CA.S 75-100m_CA.S 2429.700   257      63.44589     97761.35  154154.47
## 75-100m_CA.N 75-100m_CA.N 3362.454   359     430.70473    662091.00 1448224.66
##                  varBhat      Nhat    varNhat         name     area Depth_m.1
## 55-75m_CA.S    852562838  1.680309  0.3947232  55-75m_CA.S 1512.609        55
## 55-75m_CA.N  37200476421 60.641913 70.2492335  55-75m_CA.N 2481.987        55
## 55-75m_OR    14126395876 37.546351 17.5266710    55-75m_OR 1745.556        55
## 55-75m_WA    12201218124 23.813572  9.9569013    55-75m_WA 1438.966        55
## 75-100m_CA.S  2245636195  3.242105  1.1532502 75-100m_CA.S 2429.700        75
## 75-100m_CA.N 20851428866 37.692719 23.8145856 75-100m_CA.N 3362.454        75
##              Depth_m.2 Latitude_dd.1 Latitude_dd.2 region
## 55-75m_CA.S         75            32            36   CA.S
## 55-75m_CA.N         75            36            42   CA.N
## 55-75m_OR           75            42            46     OR
## 55-75m_WA           75            46            49     WA
## 75-100m_CA.S       100            32            36   CA.S
## 75-100m_CA.N       100            36            42   CA.N

depth.vec <- c(55, 75, 100, 125, 155, 200, 250)
mean.depth <- rep(NA, 6)
depth.name <- rep(NA, 6)
for(ibin in 1:6){
  mean.depth[ibin] <- mean(depth.vec[ibin + 0:1])
  depth.name[ibin] <- paste(depth.vec[ibin + 0:1], collapse="-")
}
col.vec <- rich.colors.short(6)[c(6,5,3,2)]

# remove duplicate name and area columns
results <- results[,c("name", "area", "ntows","meanCatchRate","varCatchRate",
                      "Bhat","varBhat","Depth_m.1","Depth_m.2",
                      "Latitude_dd.1","Latitude_dd.2","region")]
shallow.dat <- read.csv('c:/SS/skates/data/StrataArea_forIan_20190605.csv')

results.new <- data.frame(
    name = NA,
    area = shallow.dat$SUM_Hectares/100,
    ntows = NA,
    meanCatchRate = NA,
    varCatchRate = NA,
    Bhat = NA,
    varBhat = NA,
    Depth_m.1 = shallow.dat$MinZ,
    Depth_m.2 = shallow.dat$MaxZ,
    Latitude_dd.1 = shallow.dat$MinLat,
    Latitude_dd.2 = shallow.dat$MaxLat,
    region = NA,
    stringsAsFactors = FALSE
)
results.new$region[round(results.new$Latitude_dd.1) %in%  32] <- "CA.S"
results.new$region[round(results.new$Latitude_dd.1) %in%  36] <- "CA.N"
results.new$region[round(results.new$Latitude_dd.1) %in%  42] <- "OR"
results.new$region[round(results.new$Latitude_dd.1) %in%  46] <- "WA"
results.new$name <- paste0(results.new$Depth_m.1,"-",
                           results.new$Depth_m.2,"_",
                           results.new$region)

rbind(results.new, results)

read.csv('C:/SS/skates/data/Average_WCGOP_BigSkate_Catch.csv')

results.new$meanCatchRate[results.new$name == "1-25_CA.S"] <-
  0.259 * results$meanCatchRate[results$name == "55-75m_CA.S"]
results.new$meanCatchRate[results.new$name == "1-25_CA.N"] <-
  0.259 * results$meanCatchRate[results$name == "55-75m_CA.N"]
results.new$meanCatchRate[results.new$name == "25-54_CA.S"] <-
  1.444 * results$meanCatchRate[results$name == "55-75m_CA.S"]
results.new$meanCatchRate[results.new$name == "25-54_CA.N"] <-
  1.444 * results$meanCatchRate[results$name == "55-75m_CA.N"]
results.new$meanCatchRate[results.new$name == "1-25_OR"] <-
  0.025 * results$meanCatchRate[results$name == "55-75m_OR"]
results.new$meanCatchRate[results.new$name == "1-25_WA"] <-
  0.025 * results$meanCatchRate[results$name == "55-75m_WA"]
results.new$meanCatchRate[results.new$name == "25-54_OR"] <-
  0.490 * results$meanCatchRate[results$name == "55-75m_OR"]
results.new$meanCatchRate[results.new$name == "25-54_WA"] <-
  0.490 * results$meanCatchRate[results$name == "55-75m_WA"]

results.new$Bhat <- results.new$area * results.new$meanCatchRate
  
results2 <- rbind(results, results.new)

demory <- read.csv('c:/SS/skates/data/Demory Catch Query.csv')
demory2 <- demory[demory$SP_CODE %in% 420,]

plot(demory$BOT_DEPTH, demory$START_LAT, xlim=c(0,200))
points(demory2$BOT_DEPTH, demory2$START_LAT, col=2, pch=16, cex=.3*sqrt(demory2$WEIGHT))

abline(v=55)
abline(v=55/1.8288)

}

depth.vec <- c(0, 25, 55, 75, 100, 125, 155, 200, 250)
mean.depth <- rep(NA, 8)
depth.name <- rep(NA, 8)
for(ibin in 1:8){
  mean.depth[ibin] <- mean(depth.vec[ibin + 0:1])
  depth.name[ibin] <- paste(depth.vec[ibin + 0:1], collapse="-")
}
col.vec <- rich.colors.short(6)[c(6,5,3,2)]

png('c:/SS/skates/BigSkate_Doc/Figures/survey_estimates_by_depth_with_shallow.png',
    res=300, units='in', width=6, height=6, pointsize=10)
par(mfrow=c(2,1), mar=c(1,4,1,1), oma=c(3,0,0,0))
plot(0, type='n', xlim=c(0, 250), ylim = c(0, 1000), yaxs='i', axes=FALSE,
     xlab="Depth bin (m)", ylab="Mean catch rate (kg / km2)")
axis(1, at=depth.vec, labels=rep(NA,7))
axis(1, at=mean.depth, labels=depth.name, tick=FALSE, cex=.8)
axis(2)
#
for(iregion in 1:4){
  region <- c("CA.S","CA.N","OR","WA")[iregion]
  col <- col.vec[iregion]
  res.i <- results2[results2$region == region,]
  lines(mean.depth, res.i$meanCatchRate[order(res.i$Depth_m.1)],
        col=col, pch=16, cex=2, lwd=3)
}
legend("topright", lwd=5, col=rev(col.vec),
       bty='n',
       legend=rev(c("California S (32-36°N)",
           "California N (36-42°N)",
           "Oregon (42-46°N)",
           "Washington (46-49°N)")))
rect(0,0,55,5000, col=gray(0, alpha=.1), border=NA)
#
plot(0, type='n', xlim=c(0, 250), ylim = c(0, 3000), yaxs='i', axes=FALSE,
     xlab="Depth bin (m)", ylab="Total biomass (mt)")
axis(1, at=depth.vec, labels=rep(NA,7))
axis(1, at=mean.depth, labels=depth.name, tick=FALSE, cex=.8)
axis(2)
#
for(iregion in 1:4){
  region <- c("CA.S","CA.N","OR","WA")[iregion]
  col <- col.vec[iregion]
  res.i <- results2[results2$region == region,] 
  lines(mean.depth, res.i$Bhat[order(res.i$Depth_m.1)]/1000,
        col=col, pch=16, cex=2, lwd=3)
}
rect(0,0,55,5000, col=gray(0, alpha=.1), border=NA)
#
mtext(side=1, line=2, outer=TRUE, text="Depth bin (m)")
dev.off()

sum(results2$Bhat[results2$Depth_m.1 < 55])
sum(results2$Bhat[results2$Depth_m.1 >= 55])
sum(results2$Bhat[results2$Depth_m.1 < 55]) / sum(results2$Bhat)






##### displaying new prior
x <- rlnorm(1e6, meanlog = log(0.701), sd = 0.592)
hist(rlnorm(1e6, meanlog = log(0.701), sd = 0.592), breaks=200, col='grey', xlim=c(0,4), freq=FALSE, main="", xlab="Catchability of the WCGBT Survey")
abline(v=1, col=4, lwd=3)
abline(v = c(0.338,	0.701,	1.539), col=2, lwd=c(1,3,1), lty=c(1,1,1))

round(plnorm(1, meanlog=log(0.701), sd = 0.592), 2)
## [1] 0.73
sd(x)
## [1] 0.5404064
sd(log(x))
## [1] 0.5917953








### old before new rates
png('c:/SS/skates/BigSkate_Doc/Figures/survey_estimates_by_depth.png',
    res=300, units='in', width=6, height=6, pointsize=10)
par(mfrow=c(2,1), mar=c(1,4,1,1), oma=c(3,0,0,0))
plot(0, type='n', xlim=c(55, 250), ylim = c(0, 700), yaxs='i', axes=FALSE,
     xlab="Depth bin (m)", ylab="Mean catch rate (kg / km2)")
axis(1, at=depth.vec, labels=rep(NA,7))
axis(1, at=mean.depth, labels=depth.name, tick=FALSE, cex=.8)
axis(2)

for(iregion in 1:4){
  region <- c("CA.S","CA.N","OR","WA")[iregion]
  col <- col.vec[iregion]
  res.i <- results[results$region == region,] 
  lines(mean.depth, res.i$meanCatchRate, col=col, pch=16, cex=2, lwd=3)
}
legend("topright", lwd=5, col=rev(col.vec),
       bty='n',
       legend=rev(c("California S (32-36°N)",
           "California N (36-42°N)",
           "Oregon (42-46°N)",
           "Washington (46-49°N)")))

plot(0, type='n', xlim=c(55, 250), ylim = c(0, 1700), yaxs='i', axes=FALSE,
     xlab="Depth bin (m)", ylab="Total biomass (mt)")
axis(1, at=depth.vec, labels=rep(NA,7))
axis(1, at=mean.depth, labels=depth.name, tick=FALSE, cex=.8)
axis(2)

for(iregion in 1:4){
  region <- c("CA.S","CA.N","OR","WA")[iregion]
  col <- col.vec[iregion]
  res.i <- results[results$region == region,] 
  lines(mean.depth, res.i$Bhat/1000, col=col, pch=16, cex=2, lwd=3)
}

mtext(side=1, line=2, outer=TRUE, text="Depth bin (m)")
dev.off()
