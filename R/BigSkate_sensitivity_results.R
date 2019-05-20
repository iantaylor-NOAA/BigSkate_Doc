### notes on getting sensitivity results
### which were run using code in /R/BigSkate_sensitivities.R
### for 2019 Big Skate assessment

# define directory on a specific computer
if(Sys.info()["user"] == "Ian.Taylor"){
  dir.outer <- c('c:/SS/skates/models')
}
dir.sensitivities <- file.path(dir.outer, "sensitivity.bigskate82")


################
### functions required for table cleanup below

# create a new column of labels for each quantity
clean.labels <- function(tab){
  newlabel <- tab$Label
  newlabel <- gsub("like", "likelihood", newlabel)
  newlabel <- gsub("Ret", "Retained", newlabel)
  newlabel <- gsub("p_1_", "", newlabel)
  newlabel <- gsub("GP_1", "", newlabel)
  newlabel <- gsub("SR_LN", "log", newlabel)
  newlabel <- gsub("_", " ", newlabel)
  newlabel <- gsub("LnQ base WCGBTS(5)", "Q WCGBTS", newlabel, fixed=TRUE)
  newlabel <- gsub("Fem", "Female", newlabel)
  newlabel <- gsub("Mal", "Male", newlabel)
  tab$Label <- newlabel
  return(tab)
}

# function to convert log Q to standard space
convert.LnQ <- function(tab){
  tab[grep("LnQ", tab$Label), -1] <-
    exp(tab[grep("LnQ", tab$Label), -1])
  return(tab)
}  
# function to convert offsets to standard space
convert.offsets <- function(tab){
  # male M offset
  tab[grep("NatM_p_1_Mal", tab$Label), -1] <-
    tab[grep("NatM_p_1_Fem", tab$Label), -1] *
      exp(tab[grep("NatM_p_1_Mal", tab$Label), -1])
  # male Linf offset
  # subset models for those that use male offset
  mods <- which(tab[grep("Linf_Mal", tab$Label), -1] < 0)
  tab[grep("Linf_Mal", tab$Label), 1 + mods] <-
    tab[grep("Linf_Fem", tab$Label), 1 + mods] *
      exp(tab[grep("Linf_Mal", tab$Label), 1 + mods])
  return(tab)
}  

#####################
## which things to read from the model output

thingnames <- c("Recr_Virgin", "R0", "NatM", "Linf",
    "LnQ_base_WCGBTS",
    "SSB_Virg", "SSB_2019",
                "Bratio_2019", "SPRratio_2018", "Ret_Catch_MSY", "Dead_Catch_MSY",
                "Totbio_unfished", "OFLCatch_2021")
likenames = c("TOTAL", "Survey", "Length_comp", "Age_comp",
    "Discard", "Mean_body_wt", "priors")

#####################

if(FALSE){

# getbs function from /BigSkate_Doc/R/BigSkate_functions.R
#getbs(82, sensname="sel1")
getbs(82, sensname="sel2")
getbs(82, sensname="sel3")
getbs(82, sensname="Q1")
getbs(82, sensname="Q2")

sens.sum_sel_and_Q <- SSsummarize(list(bs82, #bs82sel1,
                                       bs82sel2, bs82sel3,
                                       bs82Q1, bs82Q2))
sens.names_sel_and_Q <- c("Base model",
                          #"Sel all asymptotic",
                          "Sel all domed",
                          "Sel no sex offset",
                          "Q no prior on WCGBTS",
                          "Q no offset on triennial")
# make table of model results
sens.table_sel_and_Q <-
    SStableComparisons(sens.sum_sel_and_Q,
                       modelnames = sens.names_sel_and_Q,
                       names = thingnames,
                       likenames = likenames,
                       csv = TRUE,
                       csvdir = dir.sensitivities,
                       csvfile = "comparison_table_sens.82.csv"
                       )

# convert some things to new units (non-log or non-offset)
sens.table_sel_and_Q <- convert.LnQ(sens.table_sel_and_Q)
sens.table_sel_and_Q <- convert.offsets(sens.table_sel_and_Q)
# clean up labels
sens.table_sel_and_Q <- clean.labels(sens.table_sel_and_Q)

# write to file
write.csv(sens.table_sel_and_Q,
          file = file.path(dir.sensitivities, 'Sensitivities_sel_and_Q.csv'),
          row.names = FALSE)
# copy file to document repository
file.copy(file.path(dir.sensitivities, "Sensitivities_sel_and_Q.csv"),
          file.path(dir.sensitivities, "../../BigSkate_Doc/txt_files/",
                    "Sensitivities_sel_and_Q.csv"),
          overwrite=TRUE)
# make time series plots
SSplotComparisons(sens.sum_sel_and_Q,
                  print = TRUE,
                  filenameprefix = "sens.sel_and_Q_",
                  legendlabels = sens.names_sel_and_Q,
                  legendloc = 'right',
                  plotdir = dir.sensitivities)
# copy spawn bio plot to model repository
file.copy(file.path(dir.sensitivities, "sens.sel_and_Q_compare1_spawnbio.png"),
          file.path(dir.sensitivities, "../../BigSkate_Doc/Figures/",
                    "sens.sel_and_Q_compare1_spawnbio.png"),
          overwrite=TRUE)


############# sensitivities to miscellaneous things

getbs(82, sensname="misc1")
getbs(82, sensname="misc2")
getbs(82, sensname="misc4")
getbs(82, sensname="rec2")

sens.sum_misc <- SSsummarize(list(bs82,
                                  bs82misc1, bs82misc2, bs82misc4,
                                  bs82rec2))
sens.names_misc <- c("Base model",
                     "McAllister-Ianelli tuning",
                     "Dirichlet-Multinomial tuning",
                     "No extra index std. dev.",
                     "Recruitment deviations")

# make table of model results
sens.table_misc <-
  SStableComparisons(sens.sum_misc,
                     modelnames=sens.names_misc,
                     names=thingnames,
                     likenames = likenames,
                     csv=TRUE,
                     csvdir = dir.sensitivities,
                     csvfile = "comparison_table_sens.82.csv"
                     )

# convert some things to new units (non-log or non-offset)
sens.table_misc <- convert.LnQ(sens.table_misc)
sens.table_misc <- convert.offsets(sens.table_misc)
# clean up labels
sens.table_misc <- clean.labels(sens.table_misc)

# write to CSV file
write.csv(sens.table_misc,
          file = file.path(dir.sensitivities, 'Sensitivities_misc.csv'),
          row.names = FALSE)
# copy to document repository
file.copy(file.path(dir.sensitivities, "Sensitivities_misc.csv"),
          file.path(dir.sensitivities, "../../BigSkate_Doc/txt_files/",
                    "Sensitivities_misc.csv"),
          overwrite=TRUE)
# make comparison plot
SSplotComparisons(sens.sum_misc,
                  print = TRUE,
                  filenameprefix = "sens.misc_",
                  legendlabels = sens.names_misc,
                  plotdir = dir.sensitivities)
file.copy(file.path(dir.sensitivities, "sens.misc_compare1_spawnbio.png"),
          file.path(dir.sensitivities, "../../BigSkate_Doc/Figures/",
                    "sens.misc_compare1_spawnbio.png"),
          overwrite=TRUE)


############# sensitivities to biology things
getbs(82, sensname="bio1")
getbs(82, sensname="bio2")
getbs(82, sensname="bio3")
getbs(82, sensname="bio4")


sens.sum_bio <- SSsummarize(list(bs82, bs82bio1,
                                 bs82bio2, bs82bio3,
                                 bs82bio4))
sens.names_bio <- c("Base model",
                    "Separate M by sex",
                    "No M prior",
                    "von Bertalanffy growth",
                    "Richards growth")

# make table of model results
sens.table_bio <-
    SStableComparisons(sens.sum_bio,
                       modelnames=sens.names_bio,
                       names=thingnames,
                       likenames = likenames,
                       csv=TRUE,
                       csvdir = dir.sensitivities,
                       csvfile = "comparison_table_sens.82.csv"
                       )

# add in Richards and vonB growth values
sens.table_bio[grep("Linf", sens.table_bio$Label),
                        1 + grep("Richards", sens.names_bio)] <- 
                          bs82bio4$Growth_Parameters$Linf
sens.table_bio[grep("Linf", sens.table_bio$Label),
                        1 + grep("von", sens.names_bio)] <- 
                          bs82bio3$Growth_Parameters$Linf


# convert some things to new units (non-log or non-offset)
sens.table_bio <- convert.LnQ(sens.table_bio)
sens.table_bio <- convert.offsets(sens.table_bio)
# clean up labels
sens.table_bio <- clean.labels(sens.table_bio)

# write to CSV file
write.csv(sens.table_bio,
          file = file.path(dir.sensitivities, 'Sensitivities_bio.csv'),
          row.names = FALSE)
# copy to document repository
file.copy(file.path(dir.sensitivities, "Sensitivities_bio.csv"),
          file.path(dir.sensitivities, "../../BigSkate_Doc/txt_files/",
                    "Sensitivities_bio.csv"),
          overwrite=TRUE)

# Richards growth didn't converge, so replacing timeseries to get plot
sens.sum_bio$SpawnBio$model5 <- bs82bio4$timeseries$SpawnBio

SSplotComparisons(sens.sum_bio,
                  print = TRUE,
                  filenameprefix = "sens.bio_",
                  legendlabels = sens.names_bio,
                  plotdir = dir.sensitivities)
file.copy(file.path(dir.sensitivities, "sens.bio_compare1_spawnbio.png"),
          file.path(dir.sensitivities, "../../BigSkate_Doc/Figures/",
                    "sens.bio_compare1_spawnbio.png"),
          overwrite=TRUE)


plot_growth_curve_comparison <- function(){
  png(file.path(dir.sensitivities, "../../BigSkate_Doc/Figures/",
                'growth_curve_comparison.png'),
      res=300, units='in', width=8, height=5, pointsize=10)

  par(mfrow=c(1,3), mar=c(0,0,0,1), oma=c(4,4,1,2), las=1)
  par(cex=1)
  # make empty plot for Growth Pattern 1 (to ensure consistent dimensions)
  plot(0, type='n', xlim=c(0,20), ylim=c(0,277.75), xaxs='i', yaxs='i')
  mtext(side=1, line=2.5, outer=TRUE, text="Age (yr)")
  mtext(side=2, line=2.5, outer=TRUE, text="Length (cm)", las=0)
  # add growth curves
  SSplotBiology(bs82, subplot=1, add=TRUE, legendloc=FALSE)
  # add legend, grid, and outer box
  axis(1)
  grid()
  legend('topleft', title="Growth cessation", legend=NA, bty="n", text.font=2, cex=1.5)
  legend(x=0, y=250, lwd=3, lty=c(1,2), legend=c("Females","Males"), col=c(2,4), bty='n')
  box()

  # make empty plot for Growth Pattern 2 (to ensure consistent dimensions)
  plot(0, type='n', xlim=c(0,20), ylim=c(0,277.75), xaxs='i', yaxs='i', axes=FALSE)
  # add growth curves 
  SSplotBiology(bs82bio3, subplot=1, add=TRUE, legendloc=FALSE)
  # add legend, grid, and outer box
  axis(1)
  grid()
  legend('topleft', title="von Bertalanffy growth", legend=NA, bty="n", text.font=2, cex=1.5)
  box()

  # make empty plot for Growth Pattern 3 (to ensure consistent dimensions)
  plot(0, type='n', xlim=c(0,20), ylim=c(0,277.75), xaxs='i', yaxs='i', axes=FALSE)
  # add growth curves 
  SSplotBiology(bs82bio4, subplot=1, add=TRUE, legendloc=FALSE)
  # add legend, grid, and outer box
  axis(1)
  grid()
  legend('topleft', title="Richards growth", legend=NA, bty="n", text.font=2, cex=1.5)
  box()
  axis(4)

  dev.off()
}
plot_growth_curve_comparison()

#### catch sensitivities

getbs(82, sensname="catch1")
getbs(82, sensname="catch2")
getbs(82, sensname="catch3")
getbs(82, sensname="catch4")
getbs(82, sensname="catch5")

sens.sum_catch <- SSsummarize(list(bs82, bs82catch1, bs82catch2,
                                   bs82catch3, bs82catch4, bs82catch5))
sens.names_catch <- c("Base model",
                      "Discards based on 3yr averages",
                      "Discard mortality = 0.4",
                      "Discard mortality = 0.6",
                      "Multipliers on historical discards",
                      "Trend in F from Petrale Sole")

# make table of model results
sens.table_catch <-
    SStableComparisons(sens.sum_catch,
                       modelnames=sens.names_catch,
                       names=thingnames,
                       likenames = likenames,
                       csv=TRUE,
                       csvdir = dir.sensitivities,
                       csvfile = "comparison_table_sens.82.csv"
                       )

# convert some things to new units (non-log or non-offset)
sens.table_catch <- convert.LnQ(sens.table_catch)
sens.table_catch <- convert.offsets(sens.table_catch)
# clean up labels
sens.table_catch <- clean.labels(sens.table_catch)

# write to file
write.csv(sens.table_catch,
          file = file.path(dir.sensitivities, 'Sensitivities_catch.csv'),
          row.names = FALSE)
# copy to document repository
file.copy(file.path(dir.sensitivities, "Sensitivities_catch.csv"),
          file.path(dir.sensitivities, "../../BigSkate_Doc/txt_files/",
                    "Sensitivities_catch.csv"),
          overwrite=TRUE)

# comparison plot
SSplotComparisons(sens.sum_catch,
                  print = TRUE,
                  filenameprefix = "sens.catch_",
                  legendlabels = sens.names_catch,
                  plotdir = dir.sensitivities)

SSplotComparisons(sens.sum_catch, subplot=11,
                  legendloc = 'topleft',
                  print = TRUE,
                  indexfleets = 5,
                  indexUncertainty = TRUE,
                  filenameprefix = "sens.catch_",
                  legendlabels = sens.names_catch,
                  plotdir = dir.sensitivities)

# copy to document repository
file.copy(file.path(dir.sensitivities, "sens.catch_compare1_spawnbio.png"),
          file.path(dir.sensitivities, "../../BigSkate_Doc/Figures/",
                    "sens.catch_compare1_spawnbio.png"),
          overwrite=TRUE)
file.copy(file.path(dir.sensitivities, "sens.catch_compare11_indices_flt5.png"),
          file.path(dir.sensitivities, "../../BigSkate_Doc/Figures/",
                    "sens.catch_compare11_indices_flt5.png"),
          overwrite=TRUE)


# make catch plot
fleetnames_catch <- c("Fishery (current)",
                      "Discard (historical)",
                      "Fishery (historical)",
                      "Fishery (tribal)",
                      "WCGBTS",
                      "Triennial")
SS_plots(bs82catch4, plot=7,
         fleetnames = fleetnames_catch)
file.copy(file.path(bs82catch4$inputs$dir,
                    "plots/catch3 observed and expected landings (if different).png"),
          file.path(dir.sensitivities, "../../BigSkate_Doc/Figures/",
                    "catch_multiplier_catch_comparison.png"))
file.copy(file.path(bs82catch4$inputs$dir,
                    "plots/catch5 total catch (including discards) stacked.png"),
          file.path(dir.sensitivities, "../../BigSkate_Doc/Figures/",
                    "catch_multiplier_total_catch.png"))
file.copy(file.path(bs82catch4$inputs$dir,
                    "plots/catch5 total catch (including discards) stacked.png"),
          file.path(dir.sensitivities, "../../BigSkate_Doc/Figures/",
                    "catch_multiplier_total_catch.png"))


fleetnames_catch <- c("Fishery (current)",
                      "Fishery + Discards (historical)",
                      "",
                      "Fishery (tribal)",
                      "WCGBTS",
                      "Triennial")
SS_plots(bs82catch5, plot=7,
         fleetnames = fleetnames_catch)
file.copy(file.path(bs82catch5$inputs$dir,
                    "plots/catch3 observed and expected landings (if different).png"),
          file.path(dir.sensitivities, "../../BigSkate_Doc/Figures/",
                    "catch_petraleF_catch_comparison.png"))
file.copy(file.path(bs82catch5$inputs$dir,
                    "plots/catch5 total catch (including discards) stacked.png"),
          file.path(dir.sensitivities, "../../BigSkate_Doc/Figures/",
                    "catch_petraleF_total_catch.png"))

catch0 <- SSplotCatch(bs82, print=FALSE, plot=FALSE)
yrs <- catch0$totcatchmat$Yr
totcatch0 <- apply(catch0$totcatchmat[,1:4], MARGIN = 1, FUN = sum)
catch1 <- SSplotCatch(bs82catch1, print=FALSE, plot=FALSE)
totcatch1 <- apply(catch1$totcatchmat[,1:4], MARGIN = 1, FUN = sum)
catch2 <- SSplotCatch(bs82catch2, print=FALSE, plot=FALSE)
totcatch2 <- apply(catch2$totcatchmat[,1:4], MARGIN = 1, FUN = sum)
catch3 <- SSplotCatch(bs82catch3, print=FALSE, plot=FALSE)
totcatch3 <- apply(catch3$totcatchmat[,1:4], MARGIN = 1, FUN = sum)
catch4 <- SSplotCatch(bs82catch4, print=FALSE, plot=FALSE)
totcatch4 <- apply(catch4$totcatchmat[,1:4], MARGIN = 1, FUN = sum)
catch5 <- SSplotCatch(bs82catch5, print=FALSE, plot=FALSE)
totcatch5 <- apply(catch5$totcatchmat[,1:4], MARGIN = 1, FUN = sum)

cols <- rich.colors.short(7)[-1]

png(file.path(dir.sensitivities, "../../BigSkate_Doc/Figures/",
              'adjusted_historic_catch_comparison.png'),
    res=300, units='in', width=6.5, height=5, pointsize=10)
#par(mar=c(4,4,1,1))
plot(0, lwd=3, type='n',
     xlab="Year", ylab="Total mortality (mt)",
     xlim = c(1916, 2018), ylim = c(0,1090), yaxs='i')
lines(yrs[-1], totcatch5[-1], col=cols[5+1], lwd=3)
lines(yrs[-1], totcatch4[-1], col=cols[4+1], lwd=3)
#lines(yrs[-1], totcatch3[-1], col=cols[3+1], lwd=3)
#lines(yrs[-1], totcatch2[-1], col=cols[2+1], lwd=3)
#lines(yrs[-1], totcatch1[-1], col=cols[1+1], lwd=3)
lines(yrs[-1], totcatch0[-1], col=cols[1], lwd=3)
legend('topleft', lty=1, lwd=3, col=cols[c(1,5,6)],
       legend=sens.names_catch[c(1,5,6)],
       bty='n')
dev.off()


png(file.path(dir.sensitivities, "../../BigSkate_Doc/Figures/",
              'F_comparison.png'),
    res=300, units='in', width=6.5, height=5, pointsize=10)
#par(mar=c(4,4,1,1))
F_index2 <- read.csv('C:/ss/skates/models/sensitivity.bigskate82/petrale_F_index2.csv')
F_est_agg0 <- aggregate(bs82$catch$F, by=list(bs82$catch$Yr), FUN=sum)
F_est_agg4 <- aggregate(bs82catch4$catch$F, by=list(bs82catch4$catch$Yr), FUN=sum)
F_est_agg5 <- aggregate(bs82catch5$catch$F, by=list(bs82catch5$catch$Yr), FUN=sum)
## plot(bs82catch5$catch$Yr[bs82catch5$catch$Fleet==2],
##      bs82catch5$catch$F[bs82catch5$catch$Fleet==2], type='l')
plot(F_est_agg0, type='l', lwd=2,
     xlab="Year", ylab="Instantaneous fishing mortality (F)",
     xlim = c(1916, 2018), ylim = c(0,0.085), yaxs='i', col=cols[1])
lines(F_est_agg4, type='l', lwd=2, col=cols[5])
lines(F_est_agg5, type='l', lwd=2, col=cols[6])
lines(F_index$F_table.Yr, F_index$obs/bs82catch5$cpue$Calc_Q[1], col='purple', lty=3, lwd=2)
rect(1950,0,1994,1, col=gray(0,0.1), border=NA)
legend('topleft', lty=c(1,1,1,3), lwd=3, col=c(cols[c(1,5,6)],'purple'),
       legend=c(sens.names_catch[c(1,5,6)], 'Petrale Sole time series (scaled by q)'),
       bty='n')
dev.off()
          ## mortality M vs F
## Alternative catch or discard assumptions
## Data weighting (Francis, vs. M-I vs. Dirichlet-Multinomial)
## Prior on Q: on, wider, off
## Turn off the prior on M
## Turn on recruitment devs
## Jasons 3-parameter stock-recruit function (if Vlada figures out how to use this and it makes any difference for Longnose)
## Exponential logistic selectivity




# getbs function from /BigSkate_Doc/R/BigSkate_functions.R
#getbs(82, sensname="sel1")
getbs(82, sensname="sel2")
getbs(82, sensname="sel3")
getbs(82, sensname="Q1")
getbs(82, sensname="Q2")

getbs(82, sensname="catch1")
getbs(82, sensname="catch2")
getbs(82, sensname="catch3")
getbs(82, sensname="catch4")

getbs(82, sensname="bio1")
getbs(82, sensname="bio2")
getbs(82, sensname="bio3")
getbs(82, sensname="bio4")

getbs(82, sensname="misc1")
getbs(82, sensname="misc2")
getbs(82, sensname="misc4")
getbs(82, sensname="rec2")

sens.names_all <- c("Base model",

                    #"Sel all asymptotic",
                    "Sel all domed",
                    "Sel no sex offset",
                    "Q no prior on WCGBTS",
                    "Q no offset on triennial",
    
                    "Discards based on 3yr averages",
                    "Discard mortality = 0.4",
                    "Discard mortality = 0.6",
                    "Multipliers on historical discards",

                    "Bio separate M by sex",
                    "Bio no M prior",
                    "Bio von Bertalanffy growth",
                    "Bio Richards growth",
                    "Misc: McAllister-Ianelli tuning")

model.summaries <- SSsummarize(list(bs82,
                                    bs82sel2, bs82sel3, bs82Q1, bs82Q2,
                                    bs82catch1, bs82catch2, bs82catch3, bs82catch4,
                                    bs82bio1, bs82bio2, bs82bio3, bs82bio4, bs82misc1))
                                    
source('c:/SS/skates/R/SS_Sensi_plot.R')

#Run the sensitivity plot function
SS_Sensi_plot(model.summaries = model.summaries,
              Dir = dir.sensitivities,
              current.year = 2019,
              mod.names = sens.names_all, #List the names of the sensitivity runs
              likelihood.out = c(1,1,0),
              Sensi.RE.out = "Sensi_RE_out.DMP", #Saved file of relative errors
              CI = 0.95, #Confidence interval box based on the reference model
              TRP.in = 0.4, #Target relative abundance value
              LRP.in = 0.25, #Limit relative abundance value
              sensi_xlab = "Sensitivity scenarios", #X-axis label
              ylims.in = c(-1,1,-1,1,-1,1,-1,1,-1,1,-1,1), #Y-axis label
              plot.figs = c(1,1,1,1,1,1) , #Which plots to make/save? 
              sensi.type.breaks = c(5.5,9.5), #vertical breaks that can separate out types of sensitivities
              anno.x = c(3,7.5,12.5), # Vertical positioning of the sensitivity types labels
              anno.y = c(1,1,1), # Horizontal positioning of the sensitivity types labels
              anno.lab = c("Selectivity &\n Catchability",
                  "Catch history",
                  "Biology &\n data-weighting") #Sensitivity types labels
)

} # end if(FALSE) which allows sourcing the file to get the stuff at the top
