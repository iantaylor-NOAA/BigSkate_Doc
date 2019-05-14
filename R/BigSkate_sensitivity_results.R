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



############# sensitivities to biology and miscellaneous things
getbs(82, sensname="bio1")
getbs(82, sensname="bio2")
getbs(82, sensname="bio3")
getbs(82, sensname="bio4")
getbs(82, sensname="misc1")

sens.sum_bio_and_misc <- SSsummarize(list(bs82, bs82bio1, bs82bio2, bs82bio3,
                                          bs82bio4, bs82misc1))
sens.names_bio_and_misc <- c("Base model",
                          "Bio separate M by sex",
                          "Bio no M prior",
                          "Bio von Bertalanffy growth",
                          "Bio Richards growth",
                          "Misc: McAllister-Ianelli tuning")

# make table of model results
sens.table_bio_and_misc <-
    SStableComparisons(sens.sum_bio_and_misc,
                       modelnames=sens.names_bio_and_misc,
                       names=thingnames,
                       likenames = likenames,
                       csv=TRUE,
                       csvdir = dir.sensitivities,
                       csvfile = "comparison_table_sens.82.csv"
                       )

# add in Richards and vonB growth values
sens.table_bio_and_misc[grep("Linf", sens.table_bio_and_misc$Label),
                        1 + grep("Richards", sens.names_bio_and_misc)] <- 
                          bs82bio4$Growth_Parameters$Linf
sens.table_bio_and_misc[grep("Linf", sens.table_bio_and_misc$Label),
                        1 + grep("von", sens.names_bio_and_misc)] <- 
                          bs82bio3$Growth_Parameters$Linf


# convert some things to new units (non-log or non-offset)
sens.table_bio_and_misc <- convert.LnQ(sens.table_bio_and_misc)
sens.table_bio_and_misc <- convert.offsets(sens.table_bio_and_misc)
# clean up labels
sens.table_bio_and_misc <- clean.labels(sens.table_bio_and_misc)

# write to CSV file
write.csv(sens.table_bio_and_misc,
          file = file.path(dir.sensitivities, 'Sensitivities_bio_and_misc.csv'),
          row.names = FALSE)
# copy to document repository
file.copy(file.path(dir.sensitivities, "Sensitivities_bio_and_misc.csv"),
          file.path(dir.sensitivities, "../../BigSkate_Doc/txt_files/",
                    "Sensitivities_bio_and_misc.csv"),
          overwrite=TRUE)

# Richards growth didn't converge, so replacing timeseries to get plot
sens.sum_bio_and_misc$SpawnBio$model5 <- bs82bio4$timeseries$SpawnBio

SSplotComparisons(sens.sum_bio_and_misc,
                  print = TRUE,
                  filenameprefix = "sens.bio_and_misc_",
                  legendlabels = sens.names_bio_and_misc,
                  plotdir = dir.sensitivities)
file.copy(file.path(dir.sensitivities, "sens.bio_and_misc_compare1_spawnbio.png"),
          file.path(dir.sensitivities, "../../BigSkate_Doc/Figures/",
                    "sens.bio_and_misc_compare1_spawnbio.png"),
          overwrite=TRUE)



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


#### catch sensitivities

getbs(82, sensname="catch1")
getbs(82, sensname="catch2")
getbs(82, sensname="catch3")
getbs(82, sensname="catch4")

sens.sum_catch <- SSsummarize(list(bs82, bs82catch1, bs82catch2,
                                   bs82catch3, bs82catch4))
sens.names_catch <- c("Base model",
                      "Discards based on 3yr averages",
                      "Discard mortality = 0.4",
                      "Discard mortality = 0.6",
                      "Multipliers on historical discards")

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


          ## mortality M vs F
## Alternative catch or discard assumptions
## Data weighting (Francis, vs. M-I vs. Dirichlet-Multinomial)
## Prior on Q: on, wider, off
## Turn off the prior on M
## Turn on recruitment devs
## Jasons 3-parameter stock-recruit function (if Vlada figures out how to use this and it makes any difference for Longnose)
## Exponential logistic selectivity
