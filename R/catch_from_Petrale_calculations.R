# get ratio of biomass N & S of 42-degrees
dir.indices <- 'C:/ss/skates/indices/'
VAST_output_gamma <- read.csv(file.path(dir.indices,
                                        'WCGBTS/VAST_output_2019-03-25_Big skate_nx=250_Gamma',
                                        'Table_for_SS3.csv'), stringsAsFactors=FALSE)
plot(2003:2018,
     VAST_output_gamma[VAST_output_gamma$Fleet=="CA", "Estimate_metric_tons"]/
       VAST_output_gamma[VAST_output_gamma$Fleet=="Coastwide", "Estimate_metric_tons"])

CA.ratio <- mean(VAST_output_gamma[VAST_output_gamma$Fleet=="CA", "Estimate_metric_tons"]/
                   VAST_output_gamma[VAST_output_gamma$Fleet=="Coastwide", "Estimate_metric_tons"])
CA.ratio
#[1] 0.4238106

CA.ratio2 <- sum(VAST_output_gamma[VAST_output_gamma$Fleet=="CA", "Estimate_metric_tons"])/
                   sum(VAST_output_gamma[VAST_output_gamma$Fleet=="Coastwide", "Estimate_metric_tons"])
## [1] 0.4170509

pet <- SS_output('c:/SS/Petrale/Petrale2015_REALbase')
dov <- SS_output('c:/SS/Dover/DoverSole2011_baseModelFiles/', forecast=FALSE)
SSplotComparisons(SSsummarize(list(pet, dov)),
                  subplot = c(4,18),
                  legendlabels = c("Petrale Sole (2015 assessment)",
                      "Dover Sole (2011 assessment)"),
                  legendloc = 'bottomleft',
                  plotdir='c:/SS/skates/BigSkate_Doc/Figures/',
                  plot = FALSE,
                  print = TRUE,
                  pwidth=5.2, pheight=4,
                  filenameprefix = "Dover_vs_Petrale_")


pet$FleetNames
## [1] "WinterN"  "SummerN"  "WinterS"  "SummerS"  "TriEarly" "TriLate"  "NWFSC"   

F_table <- pet$timeseries[pet$timeseries$Yr %in% 1916:2015, c("Yr", "F:_2", "F:_4")]
names(F_table) <- c("Yr", "F_SummerN", "F_SummerS")
F_table$F_total <- F_table$F_SummerN*(1 - 0.424) + F_table$F_SummerS*0.424


F_index <- data.frame(F_table$Yr, month=7, fleet=2, obs=round(F_table$F_total,5), stderr=0.01)
write.csv(F_index, file='C:/ss/skates/models/sensitivity.bigskate82/petrale_F_index2.csv')



### changes Big Skate catches to combine
# getbs from /R/BigSkate_functions.R
bs82dat <- SS_readdat_3.30("C:/SS/skates/models//bigskate82_base_May13/BSKT2019_data.ss")

newcatch <- bs82dat$catch
names(newcatch) <- c("yr","seas","fleet","catch","catch_se")
for(icol in 1:ncol(newcatch)){
  newcatch[,icol] <- as.numeric(newcatch[,icol])
}

# fleet 2 now combines both landings and discards
newcatch$catch[newcatch$fleet==2] <-
  as.numeric(newcatch$catch[newcatch$fleet==3]) +
    newcatch$catch[newcatch$fleet==2]

# fleet 3 is now empty
newcatch$catch[newcatch$fleet==3] <- 0
newcatch$catch_se[newcatch$fleet==2] <- 2.0

newcatch$note <- ""
newcatch$note[newcatch$fleet==3] <- "#_fleet3_not_used"
newcatch$note[newcatch$fleet==2] <- "#_fleet2_is_uncertain_discards_plus_landings"
newcatch$note[newcatch$fleet==1] <- "#_fleet1_is_current_fishery"
newcatch$note[newcatch$fleet==4] <- "#_fleet4_is_tribal_fishery"

write.csv(newcatch, file='C:/ss/skates/models/sensitivity.bigskate82/catch6_petraleF/newcatch.csv')

 
#### co-occurence of petrale and big skate
#load('c:/SS/skates/data/BigSkate_survey_extractions_5-17-2019.Rdata')
#load('c:/SS/skates/data/BigSkate_petrale_extraction_5-17-2019.Rdata')

table(catch.WCGBTS.Petrale$total_catch_wt_kg[catch.WCGBTS.BS$total_catch_wt_kg > 0] > 0)
## FALSE  TRUE 
##    80  1522 
mean(catch.WCGBTS.Petrale$total_catch_wt_kg[catch.WCGBTS.BS$total_catch_wt_kg > 0] > 0)
## [1] 0.9500624
