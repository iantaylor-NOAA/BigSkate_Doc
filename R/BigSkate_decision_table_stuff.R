# states of nature for Big Skate

if(FALSE){
  source('c:/SS/skates/BigSkate_Doc/R/BigSkate_functions.R')
  getbs(99)
}

#########################################################################
## getting states of nature
#########################################################################

info <- bs99$estimated_non_dev_parameters["LnQ_base_WCGBTS(5)",c("Value","Parm_StDev")]
q_mean <- info[1]
q_sd <- info[2]

(q_low <- q_mean - q_sd*1.15)
(q_high <- q_mean + q_sd*1.15)
##                         Value
## LnQ_base_WCGBTS(5) -0.7660238
##                          Value
## LnQ_base_WCGBTS(5) -0.04059225


round(q_low, 3)
round(q_high, 3)
##                     Value
## LnQ_base_WCGBTS(5) -0.766
##                     Value
## LnQ_base_WCGBTS(5) -0.041


dir <- 'C:/SS/skates/models/bigskate99_new_prior_98percent_priorSD/forecasts'
#bs.low <- SS_output(file.path(dir, 'low_state'))
#bs.high <- SS_output(file.path(dir, 'high_state'))
## dir.profile.Q <- file.path(dir.mod, "profile.Q")
## profilemodels <- SSgetoutput(dirvec=dir.profile.Q,
##                              keyvec=1:length(Q.vec), getcovar=FALSE)
#bs.low <- profilemodels[[5]]


bs.high <- SS_output(file.path(dir, 'high_state_default'))
bs.low <- SS_output(file.path(dir, 'low_state_default'))


# exact calculations
model <- bs99
(mean <- model$derived_quants["SSB_2019", "Value"])
# [1] 1999.35
(sd <- model$derived_quants["SSB_2019", "StdDev"])
# [1] 731.452
mean - 1.15 * sd
# [1] 1158.18
qnorm(p = .125, mean = mean, sd = sd)
# [1] 1157.925


#########################################################################
## comparing states of nature
#########################################################################

state.sum <- SSsummarize(list(bs99, bs.low, bs.high))

for(size in 1:2){
  if(size == 1){
    w <- 5.2
    h <- 4
    pref <- "4x5_"
  }
  if(size == 2){
    w <- 6.5
    h <- 5
    pref <- ""
  }
  SSplotComparisons(state.sum,
                    plot = FALSE,
                    print = TRUE,
                    #subplot = c(1,11),
                    pwidth = w,
                    pheight = h,
                    indexfleets = 5,
                    indexUncertainty = TRUE,
                    legendloc = 'topright',
                    filenameprefix = paste0("state_", pref),
                    densitynames = c("SSB_Virgin", "SSB_2019", "R0",
                        #"ForeCatch_2021",
                        "OFL_2019", "NatM"),
                    ylimAdj = 1.05, yaxs = 'i',
                    legendlabels = c("New base model (q = 0.668)",
                        "Low state (q = 1.250)",
                        "High state (q = 0.464)"),
                    plotdir = dir)

  SSplotComparisons(state.sum,
                    plot = FALSE,
                    print = TRUE,
                    endyrvec = 2030,
                    subplot = c(1,2),
                    pwidth = w,
                    pheight = h,
                    indexfleets = 5,
                    indexUncertainty = TRUE,
                    ylimAdj = 1.05, yaxs = 'i',
                    legendloc = 'topright',
                    filenameprefix = paste0("state_forecast", pref),
                    densitynames = c("SSB_2019"),
                    legendlabels = c("New base model (q = 0.668)","Low state (q = 1.250)","High state (q = 0.464)"),
                    plotdir = dir)
}
file.copy(file.path(dir, "state_compare2_spawnbio_uncertainty.png"),
          file.path(dir, "../../../BigSkate_Doc/Figures/",
                    "state_compare2_spawnbio_uncertainty.png"),
          overwrite=TRUE)
file.copy(file.path(dir, "state_compare14_densities_SSB_2019.png"),
          file.path(dir, "../../../BigSkate_Doc/Figures/",
                    "state_compare14_densities_SSB_2019.png"),
          overwrite=TRUE)


#########################################################################
## get three catch streams
#########################################################################

### calculate first 2 forecast years based on average of 2017:2018
SS_ForeCatch(bs99, yrs=2019:2020, average = TRUE,
             avg.yrs = 2017:2018, dead=TRUE, digits=1)

##   #Year Seas Fleet dead(B)              comment
## 1  2019    1     1   195.9 #sum_for_2019: 241.3
## 4  2019    1     4    45.4                     
## 5  2020    1     1   195.9 #sum_for_2020: 241.3
## 8  2020    1     4    45.4                     

SS_ForeCatch(bs99, yrs=2019:2030, average = TRUE,
             avg.yrs = 2017:2018, dead=TRUE, digits=1,
             total = c(rep(241.3, 2), rep(250, 10)))
##    #Year Seas Fleet dead(B)              comment
## 1   2019    1     1   195.9 #sum_for_2019: 241.3
## 4   2019    1     4    45.4                     
## 5   2020    1     1   195.9 #sum_for_2020: 241.3
## 8   2020    1     4    45.4                     
## 9   2021    1     1   203.0   #sum_for_2021: 250
## 12  2021    1     4    47.0                     
## 13  2022    1     1   203.0   #sum_for_2022: 250
## 16  2022    1     4    47.0                     
## 17  2023    1     1   203.0   #sum_for_2023: 250
## 20  2023    1     4    47.0                     
## 21  2024    1     1   203.0   #sum_for_2024: 250
## 24  2024    1     4    47.0                     
## 25  2025    1     1   203.0   #sum_for_2025: 250
## 28  2025    1     4    47.0                     
## 29  2026    1     1   203.0   #sum_for_2026: 250
## 32  2026    1     4    47.0                     
## 33  2027    1     1   203.0   #sum_for_2027: 250
## 36  2027    1     4    47.0                     
## 37  2028    1     1   203.0   #sum_for_2028: 250
## 40  2028    1     4    47.0                     
## 41  2029    1     1   203.0   #sum_for_2029: 250
## 44  2029    1     4    47.0                     
## 45  2030    1     1   203.0   #sum_for_2030: 250
## 48  2030    1     4    47.0

SS_ForeCatch(bs99, yrs=2019:2030, average = TRUE,
             avg.yrs = 2017:2018, dead=TRUE, digits=1,
             total = c(rep(241.3, 2), rep(494, 10)))
##    #Year Seas Fleet dead(B)              comment
## 1   2019    1     1   195.9 #sum_for_2019: 241.3
## 4   2019    1     4    45.4                     
## 5   2020    1     1   195.9 #sum_for_2020: 241.3
## 8   2020    1     4    45.4                     
## 9   2021    1     1   401.0   #sum_for_2021: 494
## 12  2021    1     4    93.0                     
## 13  2022    1     1   401.0   #sum_for_2022: 494
## 16  2022    1     4    93.0                     
## 17  2023    1     1   401.0   #sum_for_2023: 494
## 20  2023    1     4    93.0                     
## 21  2024    1     1   401.0   #sum_for_2024: 494
## 24  2024    1     4    93.0                     
## 25  2025    1     1   401.0   #sum_for_2025: 494
## 28  2025    1     4    93.0                     
## 29  2026    1     1   401.0   #sum_for_2026: 494
## 32  2026    1     4    93.0                     
## 33  2027    1     1   401.0   #sum_for_2027: 494
## 36  2027    1     4    93.0                     
## 37  2028    1     1   401.0   #sum_for_2028: 494
## 40  2028    1     4    93.0                     
## 41  2029    1     1   401.0   #sum_for_2029: 494
## 44  2029    1     4    93.0                     
## 45  2030    1     1   401.0   #sum_for_2030: 494
## 48  2030    1     4    93.0                     


fore.dir <- file.path(bs99$inputs$dir, "forecasts")
base_state_default <- SS_output(file.path(fore.dir, "base_state_default"),
                                verbose=FALSE)

# 
SS_ForeCatch(base_state_default, yrs=2019:2030, average = FALSE,
             dead=TRUE, digits=1)
##    #Year Seas Fleet dead(B)               comment
## 1   2019    1     1   195.9  #sum_for_2019: 241.3
## 4   2019    1     4    45.4                      
## 5   2020    1     1   195.9  #sum_for_2020: 241.3
## 8   2020    1     4    45.4                      
## 9   2021    1     1  1232.9 #sum_for_2021: 1476.8
## 12  2021    1     4   243.9                      
## 13  2022    1     1  1159.2   #sum_for_2022: 1389
## 16  2022    1     4   229.8                      
## 17  2023    1     1  1101.7 #sum_for_2023: 1320.5
## 20  2023    1     4   218.8                      
## 21  2024    1     1  1057.0 #sum_for_2024: 1267.1
## 24  2024    1     4   210.1                      
## 25  2025    1     1  1021.4 #sum_for_2025: 1224.5
## 28  2025    1     4   203.1                      
## 29  2026    1     1   990.7 #sum_for_2026: 1187.7
## 32  2026    1     4   197.0                      
## 33  2027    1     1   963.5   #sum_for_2027: 1155
## 36  2027    1     4   191.5                      
## 37  2028    1     1   936.0   #sum_for_2028: 1122
## 40  2028    1     4   186.0                      
## 41  2029    1     1   909.0 #sum_for_2029: 1089.6
## 44  2029    1     4   180.6                      
## 45  2030    1     1   883.7 #sum_for_2030: 1059.3
## 48  2030    1     4   175.6

### re-run models with revised forecast files
forecast.dirs <- dir(fore.dir, full.names = TRUE)[file.info(dir(fore.dir, full.names = TRUE))$isdir]
forecast.dirs <- forecast.dirs[grep("state", forecast.dirs)]
SSutils::run_SS_models(dirvec = forecast.dirs, skipfinished = FALSE)
          

# read output for decision table
base_state_250t    <- SS_output(file.path(fore.dir, "base_state_250t"),
                                verbose=FALSE, printstats=FALSE)
base_state_494t    <- SS_output(file.path(fore.dir, "base_state_494t"),
                                verbose=FALSE, printstats=FALSE)
base_state_default <- SS_output(file.path(fore.dir, "base_state_default"),
                                verbose=FALSE, printstats=FALSE)

low_state_250t    <- SS_output(file.path(fore.dir, "low_state_250t"),
                                verbose=FALSE, printstats=FALSE)
low_state_494t    <- SS_output(file.path(fore.dir, "low_state_494t"),
                                verbose=FALSE, printstats=FALSE)
low_state_default <- SS_output(file.path(fore.dir, "low_state_default"),
                                verbose=FALSE, printstats=FALSE)

high_state_250t    <- SS_output(file.path(fore.dir, "high_state_250t"),
                                verbose=FALSE, printstats=FALSE)
high_state_494t    <- SS_output(file.path(fore.dir, "high_state_494t"),
                                verbose=FALSE, printstats=FALSE)
high_state_default <- SS_output(file.path(fore.dir, "high_state_default"),
                                verbose=FALSE, printstats=FALSE)

### extract values from time-series
# note that SS_decision_table_stuff isn't exported to NAMESPACE so requires the
# trip colon ":::" to call even if r4ss package is loaded.
vals.base_state_default <- r4ss:::SS_decision_table_stuff(base_state_default, yrs=2019:2030)
vals.base_state_250t    <- r4ss:::SS_decision_table_stuff(base_state_250t,    yrs=2019:2030)
vals.base_state_494t    <- r4ss:::SS_decision_table_stuff(base_state_494t, yrs=2019:2030)

vals.low_state_default <- r4ss:::SS_decision_table_stuff(low_state_default, yrs=2019:2030)
vals.low_state_250t    <- r4ss:::SS_decision_table_stuff(low_state_250t,    yrs=2019:2030)
vals.low_state_494t    <- r4ss:::SS_decision_table_stuff(low_state_494t, yrs=2019:2030)

vals.high_state_default <- r4ss:::SS_decision_table_stuff(high_state_default, yrs=2019:2030)
vals.high_state_250t    <- r4ss:::SS_decision_table_stuff(high_state_250t,    yrs=2019:2030)
vals.high_state_494t    <- r4ss:::SS_decision_table_stuff(high_state_494t, yrs=2019:2030)


decision1 <- read.csv('c:/SS/skates/BigSkate_Doc/txt_files/DecisionTable_blank.csv',
                      check.names = FALSE, stringsAsFactors = FALSE)
names(decision1) <- gsub(pattern = "Depletion",
                         replacement = "Fraction unfished",
                         names(decision1))

newtab <- rbind(cbind(vals.low_state_250t,    vals.base_state_250t,    vals.high_state_250t),
                cbind(vals.low_state_494t,    vals.base_state_494t,    vals.high_state_494t),
                cbind(vals.low_state_default, vals.base_state_default, vals.high_state_default))

# confirming that fixed catches came our right
newtab[newtab$yr == 2021,]
##         yr  catch SpawnBio   dep   yr    catch SpawnBio   dep   yr  catch
## 2087  2021  250.0   1144.9 0.638 2021  250.000     2012 0.797 2021  250.0
## 20871 2021  494.0   1144.9 0.638 2021  494.000     2012 0.797 2021  494.0
## 20872 2021 1476.8   1144.9 0.638 2021 1476.753     2012 0.797 2021 1476.8
##       SpawnBio   dep
## 2087    2840.4 0.857
## 20871   2840.4 0.857
## 20872   2840.4 0.857

newtab2 <- newtab[,c(2, which(names(newtab) %in% c("SpawnBio","dep")))]
names(newtab2) <- names(decision1)[-c(1:2)]
decision2 <- cbind(decision1[,1:2], newtab2)

write.csv(decision2,
          file = 'c:/SS/skates/BigSkate_Doc/txt_files/DecisionTable_mod1.csv',
          row.names = FALSE)

####
# adding new rows for SPR = 60%
####

fore.dir <- file.path(bs99$inputs$dir, "forecasts")
base_state_SPR60 <- SS_output(file.path(fore.dir, "base_state_SPR60"),
                                verbose=FALSE, printstats=FALSE)
SS_ForeCatch(base_state_SPR60, yrs=2019:2030, average = FALSE,
             dead=TRUE, digits=1)
### values below pasted into low and high state forecast files for SPR60

 ## #Year Seas Fleet dead(B)               comment
 ##  2019    1     1   195.9  #sum_for_2019: 241.3
 ##  2019    1     4    45.4                      
 ##  2020    1     1   195.9  #sum_for_2020: 241.3
 ##  2020    1     4    45.4                      
 ##  2021    1     1   911.7   #sum_for_2021: 1092
 ##  2021    1     4   180.3                      
 ##  2022    1     1   872.0 #sum_for_2022: 1044.7
 ##  2022    1     4   172.7                      
 ##  2023    1     1   840.2 #sum_for_2023: 1006.8
 ##  2023    1     4   166.6                      
 ##  2024    1     1   814.6  #sum_for_2024: 976.2
 ##  2024    1     4   161.6                      
 ##  2025    1     1   793.7  #sum_for_2025: 951.2
 ##  2025    1     4   157.5                      
 ##  2026    1     1   775.3  #sum_for_2026: 929.2
 ##  2026    1     4   153.9                      
 ##  2027    1     1   759.2  #sum_for_2027: 909.8
 ##  2027    1     4   150.6                      
 ##  2028    1     1   742.7    #sum_for_2028: 890
 ##  2028    1     4   147.3                      
 ##  2029    1     1   726.5  #sum_for_2029: 870.6
 ##  2029    1     4   144.1                      
 ##  2030    1     1   711.4  #sum_for_2030: 852.5
 ##  2030    1     4   141.1
low_state_SPR60  <- SS_output(file.path(fore.dir, "low_state_SPR60"),
                                verbose=FALSE, printstats=FALSE)
high_state_SPR60 <- SS_output(file.path(fore.dir, "high_state_SPR60"),
                                verbose=FALSE, printstats=FALSE)

vals.base_state_SPR60 <- r4ss:::SS_decision_table_stuff(base_state_SPR60, yrs=2019:2030)
vals.low_state_SPR60  <- r4ss:::SS_decision_table_stuff(low_state_SPR60, yrs=2019:2030)
vals.high_state_SPR60 <- r4ss:::SS_decision_table_stuff(high_state_SPR60, yrs=2019:2030)

newtab3 <- cbind(vals.low_state_SPR60, vals.base_state_SPR60, vals.high_state_SPR60)
newtab4 <- newtab3[,c(1,2, which(names(newtab3) %in% c("SpawnBio","dep")))]

decision3 <- read.csv(file = 'c:/SS/skates/BigSkate_Doc/txt_files/DecisionTable_mod1.csv')
newtab5 <- data.frame(xx="", newtab4)
names(newtab5) <- names(decision3)
decision3 <- rbind(decision3, newtab5)

write.csv(decision3,
          file = 'c:/SS/skates/BigSkate_Doc/txt_files/DecisionTable_expanded_Aug20.csv',
          row.names = FALSE)


### alternative forecast table
yrs.forecast <- 2019:2030
Landings <- (base_state_SPR60$timeseries$"retain(B):_1" +
               base_state_SPR60$timeseries$"retain(B):_4")[base_state_SPR60$timeseries$Yr %in% yrs.forecast]
EstCatch <- (base_state_SPR60$timeseries$"dead(B):_1" +
               base_state_SPR60$timeseries$"dead(B):_4")[base_state_SPR60$timeseries$Yr %in% yrs.forecast]
OFL <- base_state_SPR60$derived_quants[paste0("OFLCatch_", yrs.forecast), "Value"]
ACL <- base_state_SPR60$derived_quants[paste0("ForeCatch_", yrs.forecast), "Value"]
OFL[1:2] <- 541
ACL[1:2] <- 494

#Stock,Landings,EstCatch,OFL,ACL
Exec_basemodel_summary <- data.frame(Stock = yrs.forecast,
                                     Landings = Landings,
                                     EstCatch = EstCatch,
                                     OFL = OFL,
                                     ACL = ACL)
write.csv(Exec_basemodel_summary, "./txt_files/Exec_basemodel_summary_SPR60.csv",
          row.names=FALSE)





