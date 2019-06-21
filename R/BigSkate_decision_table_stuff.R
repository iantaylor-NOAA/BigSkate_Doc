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
bs.high <- SS_output(file.path(dir, 'high_state'))
## dir.profile.Q <- file.path(dir.mod, "profile.Q")
## profilemodels <- SSgetoutput(dirvec=dir.profile.Q,
##                              keyvec=1:length(Q.vec), getcovar=FALSE)
bs.low <- profilemodels[[5]]



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

SSplotComparisons(state.sum,
                  plot = FALSE,
                  print = TRUE,
                  #subplot = c(1,11),
                  pwidth = 5.2,
                  pheight = 4,
                  indexfleets = 5,
                  indexUncertainty = TRUE,
                  legendloc = 'topright',
                  filenameprefix = "state_4x5_",
                  densitynames = c("SSB_Virgin", "SSB_2019", "R0",
                      "ForeCatch_2021","OFL_2019", "NatM"),
                  legendlabels = c("New base model (q = 0.668)","Low state (q = 1.250)","High state (q = 0.464)"),
                  plotdir = dir)



SSplotComparisons(state.sum,
                  plot = FALSE,
                  print = TRUE,
                  #subplot = c(1,11),
                  pwidth = 5.2,
                  pheight = 4,
                  indexfleets = 5,
                  indexUncertainty = TRUE,
                  legendloc = 'topright',
                  filenameprefix = "state_4x5_",
                  densitynames = c("SSB_Virgin", "SSB_2019", "R0",
                      "ForeCatch_2021","OFL_2019", "NatM"),
                  legendlabels = c("New base model (q = 0.668)","Low state (q = 1.250)","High state (q = 0.464)"),
                  plotdir = dir)

SSplotComparisons(state.sum,
                  plot = FALSE,
                  print = TRUE,
                  endyrvec = 2030,
                  subplot = c(1,2),
                  pwidth = 5.2,
                  pheight = 4,
                  indexfleets = 5,
                  indexUncertainty = TRUE,
                  legendloc = 'topright',
                  filenameprefix = "state_forecast_4x5_",
                  densitynames = c("SSB_2019"),
                  legendlabels = c("New base model (q = 0.668)","Low state (q = 1.250)","High state (q = 0.464)"),
                  plotdir = dir)

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
                         replacement = "%Unfished",
                         names(decision1))

newtab <- rbind(cbind(vals.low_state_250t,    vals.base_state_250t,    vals.high_state_250t),
                cbind(vals.low_state_494t,    vals.base_state_494t,    vals.high_state_494t),
                cbind(vals.low_state_default, vals.base_state_default, vals.high_state_default))

newtab2 <- newtab[,c(2, which(names(newtab) %in% c("SpawnBio","dep")))]
names(newtab2) <- names(decision1)[-c(1:2)]
decision2 <- cbind(decision1[,1:2], newtab2)

write.csv(decision2,
          file = 'c:/SS/skates/BigSkate_Doc/txt_files/DecisionTable_mod1.csv',
          row.names = FALSE)
