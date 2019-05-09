# calculations related to Big Skate catch inputs for 2019 assessment

catch.dir <- 'C:/SS/skates/catch'

landings <- read.csv(file.path(catch.dir, "Big skate catches for Ian landings.csv"))
discards <- read.csv(file.path(catch.dir, "Big skate catches for Ian LN discards.csv"))
totals <- read.csv(file.path(catch.dir, "Big skate catches for Ian totals.csv"))

# recalculate discard fraction for longnose
discards$discard.rate <- discards$Dicscard / discards$LSKT.total.catch.estimated.based.on.Dover

# plot longnose info
plot(discards$Year, discards$LSKT, type='h', lwd=10, lend=3, ylim=c(0,3000), yaxs='i')
points(discards$Year, discards$TOTAL.Land, type='h', lwd=10, lend=3, col=4)
lines(discards$Year, 2000*discards$discard.rate, col=2, lwd=4)
abline(h=2000, lty=3, col=2)

# aggregate big skate catches
landings.BS <- aggregate(landings$Landings..mt.,
                         by = list(landings$Year),
                         FUN = sum)
names(landings.BS) <- c("Year", "Landings_mt")

# aggregate again but separate the tribal fishery
landings.BS2 <- aggregate(landings$Landings..mt.,
                         by = list(landings$Year, landings$Fishery),
                         FUN = sum)
names(landings.BS2) <- c("Year", "Fishery", "Landings_mt")

# add discard rate from longnose
landings.BS$discard.rate.LN <- NA
landings.BS2$discard.rate.LN <- NA
for(y in discards$Year){
  landings.BS$discard.rate.LN[landings.BS$Year == y] <-
    discards$discard.rate[discards$Year == y]
  landings.BS2$discard.rate.LN[landings.BS2$Fishery == "Commercial" &
                                 landings.BS2$Year == y] <-
    discards$discard.rate[discards$Year == y]
}

landings.BS$discard.rate.LN[landings.BS$discard.rate.LN < 0] <- 0.001
landings.BS2$discard.rate.LN[landings.BS2$discard.rate.LN < 0] <- 0.001
abline(v=1995)

# linear model fit to pre-1995 landings has non-significant
# slope of -0.1 ton per year over 45 years
# (prediction 62.9 in 1950 to 58.1 in 1995 vs. mean across years of 62.4
yrs.sub <- landings.BS$Year %in% 1950:1995
yrs.sub2 <- landings.BS2$Year %in% 1950:1995 & landings.BS2$Fishery == "Commercial"

lm.landings <- lm(Landings_mt ~ Year,
                  data=landings.BS[yrs.sub,])
summary(lm.landings)
## Coefficients:
##              Estimate Std. Error t value Pr(>|t|)
## (Intercept)  15.38971  837.56897   0.018    0.985
## Year          0.02425    0.42461   0.057    0.955
lm.landings2 <- lm(Landings_mt ~ Year,
                   data=landings.BS2[yrs.sub2,])
summary(lm.landings2)
##              Estimate Std. Error t value Pr(>|t|)
## (Intercept)  28.35620  838.55811   0.034    0.973
## Year          0.01764    0.42511   0.041    0.967
abline(lm.landings, col=3)
abline(lm.landings2, col=5, lty=2)

lm.landings$coeff[1] + 1950*lm.landings$coeff[2]
## 62.67234 
lm.landings$coeff[1] + 1995*lm.landings$coeff[2]
## 63.76348 
lm.landings2$coeff[1] + 1950*lm.landings2$coeff[2]
## 62.75096 
lm.landings2$coeff[1] + 1995*lm.landings2$coeff[2]
## 63.54468 

(mean.landings <- mean(landings.BS$Landings_mt[yrs.sub],
                       na.rm = TRUE))
## [1] 63.21791
(mean.landings2 <- mean(landings.BS2$Landings_mt[yrs.sub2],
                        na.rm = TRUE))
## [1] 63.14782
yrs.sub2T <- landings.BS2$Year %in% 1950:1995 & landings.BS2$Fishery == "Tribal"
(mean.tribal.landings2 <- mean(landings.BS2$Landings_mt[yrs.sub2T],
                        na.rm = TRUE))
## [1] 0.3582336

### choosing to exclude tribal catch from all following calculations
(mean.landings <- mean(landings.BS2$Landings_mt[yrs.sub],
                       na.rm = TRUE))

# mean discard rate for LN (independent of tribal vs. non-tribal)
(mean.discard.rate.LN <-
  mean(landings.BS$discard.rate.LN[yrs.sub],
       na.rm=TRUE))
 ## [1] 0.924647

# linear regression (non-significant increase of 0.0003 per year)
lm.discard.rate <- lm(discard.rate.LN ~ Year,
                      data = landings.BS2[yrs.sub2,])
##               Estimate Std. Error t value Pr(>|t|)
## (Intercept)  1.2104983  1.0781381   1.123    0.268
## Year        -0.0001449  0.0005466  -0.265    0.792
lm.discard.rate$coeff[1] + 1950*lm.discard.rate$coeff[2]
## 0.9279077 
lm.discard.rate$coeff[1] + 1995*lm.discard.rate$coeff[2]
## 0.9213863 

# use non-tribal catch and subset to 
# exclude tribal catch from the following
landings.BS <- landings.BS2[landings.BS2$Fishery == "Commercial",
                            c("Year", "Landings_mt", "discard.rate.LN")]

# create new total catch estimates
# (note, mixing mean and annual values produced terrible results)
landings.BS$total_mean_catch_mean_rate_mt <- NA
landings.BS$total_annual_catch_annual_rate_mt <- NA

# create new average discard estimates
landings.BS$discard_mean_catch_mean_rate_mt <- NA
landings.BS$total_mean_catch_mean_rate_mt <- NA

landings.BS$total_mean_catch_mean_rate_mt[yrs.sub] <-
  mean.landings / (1 - mean.discard.rate.LN)
landings.BS$total_annual_catch_annual_rate_mt[yrs.sub] <-
  landings.BS$Landings_mt[yrs.sub] /
    (1 - landings.BS$discard.rate.LN[yrs.sub])

# mean discard amount
landings.BS$total_mean_catch_mean_rate_mt[yrs.sub] <-
  mean.landings / (1 - mean.discard.rate.LN)
summary(landings.BS$total_mean_catch_mean_rate_mt)
landings.BS$discard_mean_catch_mean_rate_mt[yrs.sub] <-
  mean.landings / (1 - mean.discard.rate.LN) - mean.landings
# get new total
landings.BS$total_mean_catch_mean_rate_mt[yrs.sub] <-
  landings.BS$discard_mean_catch_mean_rate_mt[yrs.sub] +
    landings.BS$Landings_mt[yrs.sub]

# 3-year moving averages
landings.BS$Landings_3yr_avg <- NA
landings.BS$discard.rate.LN_3yr_avg <- NA
landings.BS$total_3yr_catch_3yr_rate_mt <- NA
for(y in 1950:1995){
  row <- which(landings.BS$Year == y)
  yrs <- y + -1:1
  landings.BS$Landings_3yr_avg[row] <-
    mean(landings.BS$Landings_mt[landings.BS$Year %in% yrs], na.rm=TRUE)
  landings.BS$discard.rate.LN_3yr_avg[row] <-
    mean(landings.BS$discard.rate.LN[landings.BS$Year %in% yrs], na.rm=TRUE)
}
landings.BS$total_3yr_catch_3yr_rate_mt <- 
  landings.BS$Landings_3yr_avg /
    (1 - landings.BS$discard.rate.LN_3yr_avg)

# separate discards from total
landings.BS$discard_annual_catch_annual_rate_mt <-
  landings.BS$total_annual_catch_annual_rate_mt - landings.BS$Landings_mt
landings.BS$discard_3yr_catch_3yr_rate_mt <-
  landings.BS$total_3yr_catch_3yr_rate_mt - landings.BS$Landings_mt


## # linear ramp to 1950 (old method with discards only)
## landings.BS$discard_mean_catch_mean_rate_mt[landings.BS$Year < 1950] <- 
##   (landings.BS$Year[landings.BS$Year < 1950] - 1916) / (1950 - 1916) *
##     landings.BS$discard_mean_catch_mean_rate_mt[landings.BS$Year == 1950]
## # linear ramp to 1950 for 3yr avg
## landings.BS$discard_3yr_catch_3yr_rate_mt[landings.BS$Year < 1950] <- 
##   (landings.BS$Year[landings.BS$Year < 1950] - 1916) / (1950 - 1916) *
##     landings.BS$discard_3yr_catch_3yr_rate_mt[landings.BS$Year == 1950]


# linear ramp to 1950 (matching longnose, ramping total catch)
landings.BS$total_mean_catch_mean_rate_mt[landings.BS$Year < 1950] <- 
  (landings.BS$Year[landings.BS$Year < 1950] - 1916) / (1950 - 1916) *
    landings.BS$total_mean_catch_mean_rate_mt[landings.BS$Year == 1950]
# linear ramp to 1950 for 3yr avg
landings.BS$total_3yr_catch_3yr_rate_mt[landings.BS$Year < 1950] <- 
  (landings.BS$Year[landings.BS$Year < 1950] - 1916) / (1950 - 1916) *
    landings.BS$total_3yr_catch_3yr_rate_mt[landings.BS$Year == 1950]

# assume California catch before 1939 are no good so all earlier catch is discards
landings.BS$Landings_mt[landings.BS$Year < 1939] <- 0
sub <- landings.BS$Year < 1950
landings.BS$discard_3yr_catch_3yr_rate_mt[sub] <-
  landings.BS$total_3yr_catch_3yr_rate_mt[sub] - landings.BS$Landings_mt[sub]
landings.BS$discard_mean_catch_mean_rate_mt[sub] <- 
  landings.BS$total_mean_catch_mean_rate_mt[sub] - landings.BS$Landings_mt[sub]



# plot landings and rates
png(file.path(catch.dir, '../BigSkate_Doc/Figures/discard_calculations.png'),
    res=300, units='in', width=6.5, height=5, pointsize=9)
#
par(mar=c(3,5,1,5))
plot(landings.BS[,c("Year","Landings_mt")],
     ylab = "Landings, discards, or total catch (t)",
     type='h', lwd=5, lend=3, ylim=c(0,3200), yaxs='i', col='gray30')
#abline(lm.landings, col=3)
#abline(h = mean(landings.BS$Landings_mt[yrs.sub]), col=2)
#
scale <- 3200
#### linear fit to rates
## abline(a = scale*lm.discard.rate$coeff[1],
##        b = scale*lm.discard.rate$coeff[2], col=3)
lines(discards$Year, scale*discards$discard.rate, col='green3', lwd=2)
lines(x=c(1950,1995), y=rep(scale*mean.discard.rate.LN, 2),
      col='green3', lty=3)
axis(4, at=scale*seq(0,1,.2), lab=seq(0,1,.2), col.ticks=1, col=1)
axis(4, at=scale*mean.discard.rate.LN,
     lab=round(mean.discard.rate.LN, 3), col.ticks=1, col=1)
mtext(side=4, line=3, "Discard rate", col='green3')
#
lines(landings.BS$Year, landings.BS$total_annual_catch_annual_rate_mt,
      lwd=1, lty=1, col=2)
lines(landings.BS$Year, landings.BS$total_3yr_catch_3yr_rate_mt,
      lwd=2, col='purple')
lines(landings.BS$Year, landings.BS$discard_3yr_catch_3yr_rate_mt,
      lwd=1, lty=3, col='purple')
lines(landings.BS$Year, landings.BS$total_mean_catch_mean_rate_mt,
      lwd=3, col=4)
lines(landings.BS$Year, landings.BS$discard_mean_catch_mean_rate_mt,
      lwd=1, lty=2, col=4)
par(lend=2) # make the lines squarer
legend(x=1916,
       y=2750,
       bty='n',
       lty=c(1,1,3,1,1,1,2,3),
       lwd=c(5,2,1,3,2,1,1,1),
       col=c("grey30", "green3", "green3", "blue","purple","red","blue","purple"),
       legend=c("Reconstructed landings",
           "Annual Longnose Skate discard rate",
           "Mean Longnose Skate discard rate (1950-1995)",
           "Total catch (based on 1950-1995 means)",
           "Total catch (3-yr moving average)",
           "Total catch (annual values)",
           "Discards (based on 1950-1995 means)",
           "Discards (3-yr moving average)"))
par(lend=0)
dev.off()

## lines(landings.BS$Year, landings.BS$Landings_mt +
##         landings.BS$discard_3yr_catch_3yr_rate_mt,
##       lwd=2, col=2)
## lines(landings.BS$Year, landings.BS$discard_mean_catch_mean_rate_mt,
##       lwd=2, col=3)
## lines(landings.BS$Year, landings.BS$Landings_mt +
##         landings.BS$discard_mean_catch_mean_rate_mt,
##       lwd=2, col=6)
sum(landings.BS$total_mean_catch_mean_rate_mt[yrs.sub])
## [1] 38549.23
sum(landings.BS$total_annual_catch_annual_rate_mt[yrs.sub])
## [1] 43953.34
sum(landings.BS$total_3yr_catch_3yr_rate_mt[yrs.sub])
## [1] 42130.16

#yr, seas, fleet, catch, catch_se
landings.table <- data.frame(yr = landings.BS$Year,
                             seas = 1,
                             fleet = ifelse(landings.BS$Year < 1995, 3, 1),
                             catch = round(landings.BS$Landings_mt, 1),
                             catch_se = 0.01,
                             note = ifelse(landings.BS$Year < 1995,
                                 "#_historical_landings",
                                 "#_current_landings"))
sub <- landings.BS2$Fishery == "Tribal"
landings.table.tribal <- data.frame(yr = landings.BS2$Year[sub],
                                    seas = 1,
                                    fleet = 4,
                                    catch = round(landings.BS2$Landings_mt[sub], 1),
                                    catch_se = 0.01,
                                    note = "#_tribal_landings")

disc_mort <- 0.5
discards.table <- data.frame(yr = landings.BS$Year,
                             seas = 1,
                             fleet = 2,
                             catch = round(disc_mort *
                                             landings.BS$discard_mean_catch_mean_rate_mt, 1),
                             catch_se = 0.01,
                             note = "#_estimated_discards_from_mean_values")
discards.table2 <- data.frame(yr = landings.BS$Year,
                              seas = 1,
                              fleet = 2,
                              catch = round((1-disc_mort) *
                                              landings.BS$discard_3yr_catch_3yr_rate_mt, 1),
                              catch_se = 0.01,
                              note = "#_estimated_discards_from_3yr_moving_avg")

disc_mort <- 0.4
discards.table0.4 <- data.frame(yr = landings.BS$Year,
                             seas = 1,
                             fleet = 2,
                             catch = round((1-disc_mort) *
                                             landings.BS$discard_mean_catch_mean_rate_mt, 1),
                             catch_se = 0.01,
                             note = "#_estimated_discards_from_mean_values_with_mort=0.4")
disc_mort <- 0.6
discards.table0.6 <- data.frame(yr = landings.BS$Year,
                             seas = 1,
                             fleet = 2,
                             catch = round((1-disc_mort) *
                                             landings.BS$discard_mean_catch_mean_rate_mt, 1),
                             catch_se = 0.01,
                             note = "#_estimated_discards_from_mean_values_with_mort=0.6")

discards.table <- discards.table[discards.table$yr < 1995,]
discards.table2 <- discards.table2[discards.table2$yr < 1995,]
discards.table0.4 <- discards.table0.4[discards.table0.4$yr < 1995,]
discards.table0.6 <- discards.table0.6[discards.table0.6$yr < 1995,]
# write file
write.csv(rbind(landings.table, discards.table, discards.table2, discards.table0.4, discards.table0.6, landings.table.tribal),
          file = file.path(catch.dir, 'catch_for_SS_5-08-2019.csv'), row.names=FALSE)
# comment out alternative discard estimates
lines1 <- readLines(con = file.path(catch.dir, 'catch_for_SS_5-08-2019.csv'))
lines1[grep("3yr", lines1)] <- paste("#", lines1[grep("3yr", lines1)])
lines1[grep("with_mort", lines1)] <- paste("#", lines1[grep("with_mort", lines1)])
writeLines(lines1, con = file.path(catch.dir, 'catch_for_SS_commented_5-08-2019.csv'))



# landings table for document
catch.table.doc <- data.frame(Year = 1916:2018, CA = NA, OR = NA, WA = NA,
                              Tribal = NA, total=NA)
for(y in 1916:2018){
  catch.table.doc[catch.table.doc$Year == y, "CA"] <-
    round(sum(landings$Landings..mt.[landings$State=="CA" &
                                 landings$Year == y]), 1)
  catch.table.doc[catch.table.doc$Year == y, "CA"] <-
    round(sum(landings$Landings..mt.[landings$State=="CA" &
                                 landings$Year == y]), 1)
  catch.table.doc[catch.table.doc$Year == y, "OR"] <-
    round(sum(landings$Landings..mt.[landings$State=="OR" &
                                 landings$Year==y]), 1)
  catch.table.doc[catch.table.doc$Year == y, "WA"] <-
    round(sum(landings$Landings..mt.[landings$State=="WA" &
                                 landings$Year==y &
                                   landings$Fishery=="Commercial"]), 1)
  catch.table.doc[catch.table.doc$Year == y, "Tribal"] <-
    round(sum(landings$Landings..mt.[landings$State=="WA" &
                                 landings$Year==y &
                                   landings$Fishery!="Commercial"]), 1)
  catch.table.doc[catch.table.doc$Year == y, "total"] <-
    round(sum(landings$Landings..mt.[landings$Year==y]), 1)
}
write.csv(catch.table.doc,
          file=file.path(catch.dir, '../BigSkate_Doc/txt_files/data_summaries',
              'reconstructed_landings_by_state.csv'),
          row.names = FALSE)
### save table for use elsewhere
#save(landings.BS, file=file.path(catch.dir, "landings.BS.RData"))

### read saved table
#load(file=file.path(catch.dir, "landings.BS.RData"))

