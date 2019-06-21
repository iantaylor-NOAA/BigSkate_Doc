if(FALSE){
  ### load previously extracted survey values
  load('c:/SS/skates/data/BigSkate_survey_extractions_5-17-2019.Rdata')
  dir.figs <- 'c:/SS/skates/BigSkate_Doc/Figures'
}

max(catch.WCGBTS.BS$Depth_m[catch.WCGBTS.BS$total_catch_wt_kg > 0])
## [1] 459.2

table(catch.WCGBTS.BS$Depth_m < 500)
## FALSE  TRUE 
##  3243  7122 

catch2 <- catch.WCGBTS.BS[catch.WCGBTS.BS$Depth_m < 425,]

# create new depth variable binned to 10m 
catch2$Depth_m_bin10 <- 10*floor(catch2$Depth_m/10)
catch2$Depth_m_bin25 <- 25*floor(catch2$Depth_m/25)

#plot(table(catch2$Depth_m_bin10, catch2$cpue_kg_km2 > 0))

tab <- table(catch2$Depth_m_bin25, catch2$cpue_kg_km2 > 0)
#dimnames(tab)[[1]] <- c("Absent","Present")
dimnames(tab)[[2]] <- c("Absent","Present")


png(file.path(dir.figs, 'WCGBTS_presence_absence_by_depth_bin.png'),
    width=7, height=5, units='in', res=300, pointsize=10)
par(mar=c(1,1,1,.1))
plot(tab, col=c(gray(.7), 'blue3'), main="", cex=1)
dev.off()

nrow(catch2)
## [1] 0.3852819



catch3 <- catch.WCGBTS.Petrale[catch.WCGBTS.Petrale$Depth_m < 425,]

# create new depth variable binned to 10m 
catch3$Depth_m_bin25 <- 25*floor(catch3$Depth_m/25)

tab <- table(catch3$Depth_m_bin25, catch3$cpue_kg_km2 > 0)
dimnames(tab)[[2]] <- c("Absent","Present")

png(file.path(dir.figs, 'WCGBTS_Petrale_presence_absence_by_depth_bin.png'),
    width=7, height=5, units='in', res=300, pointsize=10)
par(mar=c(1,1,1,.1))
plot(tab, col=c(gray(.7), 'blue3'), main="", cex=1)
dev.off()

nrow(catch3)
