### notes on getting sensitivity results
### which were run using code in /R/BigSkate_sensitivities.R
### for 2019 Big Skate assessment

# define directory on a specific computer
if(Sys.info()["user"] == "Ian.Taylor"){
  dir.outer <- c('c:/SS/skates/models')
}
dir.sensitivities <- file.path(dir.outer, "sensitivity.bigskate99")


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
  newlabel <- gsub("NatM", "M", newlabel)
  newlabel <- gsub("LnQ base WCGBTS(5)", "WCGBTS catchability",
                   newlabel, fixed=TRUE)
  newlabel <- gsub("Fem", "Female", newlabel)
  newlabel <- gsub("Mal", "Male", newlabel)
  newlabel <- gsub("Bratio", "Fraction unfished", newlabel)
  newlabel <- gsub("OFLCatch", "OFL mt", newlabel)
  newlabel <- gsub("SmryBio unfished", "Virgin age 2+ bio 1000 mt", newlabel)
  newlabel <- gsub("thousand", "1000", newlabel)
  newlabel <- gsub("MSY", "MSY mt", newlabel)
  newlabel <- gsub("SPRratio", "Fishing intensity", newlabel)
  tab$Label <- newlabel
  return(tab)
}

# function to convert log Q to standard space
convert.vals <- function(tab){
  tab[grep("LnQ", tab$Label), -1] <-
    exp(tab[grep("LnQ", tab$Label), -1])
  tab[grep("SmryBio_unfished", tab$Label), -1] <-
    tab[grep("SmryBio_unfished", tab$Label), -1]/1e3
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
                "SmryBio_unfished", "OFLCatch_2021")
likenames = c("TOTAL", "Survey", "Length_comp", "Age_comp",
    "Discard", "Mean_body_wt", "priors")

#####################

if(FALSE){

  # getbs function from /BigSkate_Doc/R/BigSkate_functions.R
  if(!exists("getbs")){
    source('c:/SS/skates/BigSkate_Doc/R/BigSkate_functions.R')
  }
  getbs(99)

  #getbs(99, sensname="sel1")
  getbs(99, sensname="sel2") # all domed
  getbs(99, sensname="sel3") # no fem offset
  getbs(99, sensname="sel4") # annual blocks
  getbs(99, sensname="Q1") # no prior
  getbs(99, sensname="Q2") # no triennial offset
  getbs(99, sensname="Q6") # half prior
  getbs(99, sensname="Q7") # old longnose prior
  # sel4 is annual blocks instead of grouping 2002-2004, with higher discards in 1995-2002
  sum(bs99sel4$catch$kill_bio)
  #[1] 36270.45
  sum(bs99$catch$kill_bio)
  #[1] 34818.48
  # change in total dead biomass as a result of annual blocks
  sum(bs99sel4$catch$kill_bio)/sum(bs99$catch$kill_bio)
  #[1] 1.041701


  SS_plots(bs99sel4,
           fleetnames=c("Fishery",
               "Discard (historical)",
               "Fishery (historical)",
               "Fishery (tribal)",
               "WCGBT Survey",
               "Triennial Survey"),
           pwidth = 5.2,
           pheight = 4,
           plot = 9:10)
  sum(bs99sel4$catch$kill_bio[bs99sel4$catch$Yr%in% 1995:2002])/
    sum(bs99$catch$kill_bio[bs99$catch$Yr%in% 1995:2002])
  ## [1] 1.597286

  sens.sum_sel_and_Q <- SSsummarize(list(bs99,
                                         bs99sel2, bs99sel3,
                                         bs99Q7, bs99Q1, bs99Q2))
  sens.names_sel_and_Q <- c("Base model",
                            "Sel. all domed",
                            "Sel. no sex offset",
                            "Longnose Skate q prior",
                            "No q prior on WCGBTS",
                            "No q offset on triennial")

  # make table of model results
  sens.table_sel_and_Q <-
    SStableComparisons(sens.sum_sel_and_Q,
                       modelnames = sens.names_sel_and_Q,
                       names = thingnames,
                       likenames = likenames,
                       csv = TRUE,
                       csvdir = dir.sensitivities,
                       csvfile = "comparison_table_sens.99.csv"
                       )

  # convert some things to new units (non-log or non-offset)
  sens.table_sel_and_Q <- convert.vals(sens.table_sel_and_Q)
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
                    indexfleets = 6,
                    indexUncertainty = TRUE,
                    filenameprefix = "sens.sel_and_Q_",
                    ylimAdj = 1.05, yaxs = 'i', 
                    endyrvec = 2019, legendlabels = sens.names_sel_and_Q,
                    legendloc = 'right',
                    plotdir = dir.sensitivities)
  # copy spawn bio plot to model repository
  file.copy(file.path(dir.sensitivities, "sens.sel_and_Q_compare1_spawnbio.png"),
            file.path(dir.sensitivities, "../../BigSkate_Doc/Figures/",
                      "sens.sel_and_Q_compare1_spawnbio.png"),
            overwrite=TRUE)

  SSplotComparisons(sens.sum_sel_and_Q,
                    plot = FALSE,
                    print = TRUE,
                    subplot = c(1,11),
                    indexfleets = 5,
                    pwidth = 5.2,
                    pheight = 4,
                    legendloc = 'right',
                    filenameprefix = "sens.sel_and_Q_4x5_",
                    ylimAdj = 1.05, yaxs = 'i', 
                    endyrvec = 2019, legendlabels = sens.names_sel_and_Q,
                    plotdir = dir.sensitivities)
  file.copy(file.path(dir.sensitivities, "sens.sel_and_Q_4x5_compare1_spawnbio.png"),
            file.path(dir.sensitivities, "../../BigSkate_Doc/Figures/",
                      "sens.sel_and_Q_4x5_compare1_spawnbio.png"),
            overwrite=TRUE)

  ############# sensitivities to miscellaneous things

  getbs(99, sensname="misc1")
  getbs(99, sensname="misc2")
  getbs(99, sensname="misc4")
  getbs(99, sensname="rec2") # recdevs
  getbs(99, sensname="rec5") # recdevs tuned
  getbs(99, sensname="rec4") # recdevs with no Q prior

  sens.sum_misc <- SSsummarize(list(bs99,
                                    bs99misc1, bs99misc2, bs99misc4, #bs99misc5,
                                    bs99rec2, bs99rec4))
  #bs99misc7, bs99misc9,
  #bs99))
  sens.names_misc <- c("Base model",
                       "McAllister-Ianelli tuning",
                       "Dirichlet-Multinomial tuning",
                       "No extra index SD",
                       "Estimated recruitment deviations",
                       "Estimated rec. devs. with no q prior")
  #"No extra index SD on WCGBTS",
  #"D-M tuning + No extra SD on WCGBTS",
  #"New prior but assume 1% and 99% quantiles")

  # make table of model results
  sens.table_misc <-
    SStableComparisons(sens.sum_misc,
                       modelnames=sens.names_misc,
                       names=thingnames,
                       likenames = likenames,
                       csv=TRUE,
                       csvdir = dir.sensitivities,
                       csvfile = "comparison_table_sens.99.csv"
                       )

  # convert some things to new units (non-log or non-offset)
  sens.table_misc <- convert.vals(sens.table_misc)
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
                    ylimAdj = 1.05, yaxs = 'i', 
                    endyrvec = 2019, legendlabels = sens.names_misc,
                    legendloc = 'bottomleft',
                    indexfleets = 5,
                    indexUncertainty = TRUE,
                    plotdir = dir.sensitivities)
  file.copy(file.path(dir.sensitivities, "sens.misc_compare1_spawnbio.png"),
            file.path(dir.sensitivities, "../../BigSkate_Doc/Figures/",
                      "sens.misc_compare1_spawnbio.png"),
            overwrite=TRUE)

  # index plot with different legend location
  SSplotComparisons(sens.sum_misc,
                    subplot = 11,
                    print = TRUE,
                    filenameprefix = "sens.misc_",
                    ylimAdj = 1.05, yaxs = 'i', 
                    endyrvec = 2019, legendlabels = sens.names_misc,
                    legendloc = 'top',
                    indexfleets = 5,
                    indexUncertainty = TRUE,
                    plotdir = dir.sensitivities)
  file.copy(file.path(dir.sensitivities, "sens.misc_compare11_indices_flt5.png"),
            file.path(dir.sensitivities, "../../BigSkate_Doc/Figures/",
                      "sens.misc_compare11_indices_flt5.png"),
            overwrite=TRUE)

  SSplotComparisons(sens.sum_misc,
                    plot = FALSE,
                    print = TRUE,
                    subplot = c(1,11),
                    pwidth = 5.2,
                    pheight = 4,
                    indexfleets = 5,
                    legendloc = 'bottomleft',
                    filenameprefix = "sens.misc_4x5_",
                    ylimAdj = 1.05, yaxs = 'i', 
                    endyrvec = 2019, legendlabels = sens.names_misc,
                    plotdir = dir.sensitivities)
  file.copy(file.path(dir.sensitivities, "sens.misc_4x5_compare1_spawnbio.png"),
            file.path(dir.sensitivities, "../../BigSkate_Doc/Figures/",
                      "sens.misc_4x5_compare1_spawnbio.png"),
            overwrite=TRUE)

  ## ############# extra plots for review
  ## sens.sum_misc2 <- SSsummarize(list(bs99,
  ##                                   bs99rec2, bs99rec4))
  ## sens.names_misc2 <- c("Base model",
  ##                       "Recruitment deviations",
  ##                       "Recruitment deviations & no Q prior")
  ## SSplotComparisons(sens.sum_misc2,
  ##                   plot = FALSE,
  ##                   print = TRUE,
  ##                   indexfleets = 5,
  ##                   indexUncertainty = TRUE,
  ##                   pwidth = 5.2,
  ##                   pheight = 4,
  ##                   legendloc = 'bottomleft',
  ##                   filenameprefix = "sens.misc2_4x5_",
  ##                   endyrvec = 2019, legendlabels = sens.names_misc2,
  ##                   plotdir = dir.sensitivities)
  ## file.copy(file.path(dir.sensitivities, "sens.misc2_4x5_compare1_spawnbio.png"),
  ##           file.path(dir.sensitivities, "../../BigSkate_Doc/Figures/",
  ##                     "sens.misc2_4x5_compare1_spawnbio.png"),
  ##           overwrite=TRUE)


  ############# sensitivities to biology things
  getbs(99, sensname="bio1_")
  bs99bio1 <- bs99bio1_
  getbs(99, sensname="bio2")
  getbs(99, sensname="bio3")
  getbs(99, sensname="bio4")
  getbs(99, sensname="bio12")


  sens.sum_bio <- SSsummarize(list(bs99, 
                                   bs99bio1,
                                   bs99bio2, bs99bio3,
                                   bs99bio12))
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
                       csvfile = "comparison_table_sens.99.csv"
                       )

  # add in Richards and vonB growth values
  sens.table_bio[grep("Linf", sens.table_bio$Label),
                 1 + grep("Richards", sens.names_bio)] <- 
                   bs99bio12$Growth_Parameters$Linf
  sens.table_bio[grep("Linf", sens.table_bio$Label),
                 1 + grep("von", sens.names_bio)] <- 
                   bs99bio3$Growth_Parameters$Linf


  # convert some things to new units (non-log or non-offset)
  sens.table_bio <- convert.vals(sens.table_bio)
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
  sens.sum_bio$SpawnBio$model5 <- bs99bio12$timeseries$SpawnBio

  SSplotComparisons(sens.sum_bio,
                    print = TRUE,
                    filenameprefix = "sens.bio_",
                    ylimAdj = 1.05, yaxs = 'i', 
                    endyrvec = 2019, legendlabels = sens.names_bio,
                    legendloc = 'bottomleft',
                    indexfleets = 5,
                    plotdir = dir.sensitivities)
  file.copy(file.path(dir.sensitivities, "sens.bio_compare1_spawnbio.png"),
            file.path(dir.sensitivities, "../../BigSkate_Doc/Figures/",
                      "sens.bio_compare1_spawnbio.png"),
            overwrite=TRUE)

  SSplotComparisons(sens.sum_bio,
                    plot = FALSE,
                    print = TRUE,
                    subplot = c(1,11),
                    legendloc = 'bottomleft',
                    pwidth = 5.2,
                    pheight = 4,
                    filenameprefix = "sens.bio_4x5_",
                    ylimAdj = 1.05, yaxs = 'i', 
                    endyrvec = 2019, legendlabels = sens.names_bio,
                    plotdir = dir.sensitivities)
  file.copy(file.path(dir.sensitivities, "sens.bio_4x5_compare1_spawnbio.png"),
            file.path(dir.sensitivities, "../../BigSkate_Doc/Figures/",
                      "sens.bio_4x5_compare1_spawnbio.png"),
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
    SSplotBiology(bs99, subplot=1, add=TRUE, legendloc=FALSE)
    # add legend, grid, and outer box
    axis(1)
    grid()
    legend('topleft', title="Growth cessation", legend=NA, bty="n", text.font=2, cex=1.5)
    legend(x=0, y=250, lwd=3, lty=c(1,2), legend=c("Females","Males"), col=c(2,4), bty='n')
    box()

    # make empty plot for Growth Pattern 2 (to ensure consistent dimensions)
    plot(0, type='n', xlim=c(0,20), ylim=c(0,277.75), xaxs='i', yaxs='i', axes=FALSE)
    # add growth curves 
    SSplotBiology(bs99bio3, subplot=1, add=TRUE, legendloc=FALSE)
    # add legend, grid, and outer box
    axis(1)
    grid()
    legend('topleft', title="von Bertalanffy growth", legend=NA, bty="n", text.font=2, cex=1.5)
    box()

    # make empty plot for Growth Pattern 3 (to ensure consistent dimensions)
    plot(0, type='n', xlim=c(0,20), ylim=c(0,277.75), xaxs='i', yaxs='i', axes=FALSE)
    # add growth curves 
    SSplotBiology(bs99bio12, subplot=1, add=TRUE, legendloc=FALSE)
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

  getbs(99, sensname="catch1")
  getbs(99, sensname="catch2")
  getbs(99, sensname="catch3")
  getbs(99, sensname="catch4")
  getbs(99, sensname="catch5")
  getbs(99, sensname="catch6")

  sens.sum_catch <- SSsummarize(list(bs99, bs99catch1, bs99catch2,
                                     bs99catch3, bs99catch4, bs99catch5))
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
                       csvfile = "comparison_table_sens.99.csv"
                       )

  # convert some things to new units (non-log or non-offset)
  sens.table_catch <- convert.vals(sens.table_catch)
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
                    legendloc = 'bottomleft',
                    ylimAdj = 1.05, yaxs = 'i', 
                    endyrvec = 2019, legendlabels = sens.names_catch,
                    plotdir = dir.sensitivities)

  SSplotComparisons(sens.sum_catch, subplot=11,
                    legendloc = 'topleft',
                    print = TRUE,
                    indexfleets = 5,
                    indexUncertainty = TRUE,
                    filenameprefix = "sens.catch_",
                    ylimAdj = 1.05, yaxs = 'i', 
                    endyrvec = 2019, legendlabels = sens.names_catch,
                    plotdir = dir.sensitivities)

  sens.sum_catchB <- SSsummarize(list(bs99, bs99catch4, bs99catch5))
  SSplotComparisons(sens.sum_catchB,
                    col = rich.colors.short(7)[1+c(1,5,6)],
                    subplot = c(2,4),
                    print = TRUE,
                    filenameprefix = "sens.catchB_",
                    ylimAdj = 1.05, yaxs = 'i', 
                    endyrvec = 2019, legendlabels = sens.names_catch[c(1,5,6)],
                    plotdir = dir.sensitivities)
  SSplotComparisons(sens.sum_catchB,
                    col = rich.colors.short(7)[1+c(1,5,6)],
                    subplot = c(2,4),
                    pwidth=5.2,
                    pheight=4,
                    print = TRUE,
                    filenameprefix = "sens.catchB_4x5",
                    ylimAdj = 1.05, yaxs = 'i', 
                    endyrvec = 2019, legendlabels = sens.names_catch[c(1,5,6)],
                    plotdir = dir.sensitivities)
  sens.sum_catchC <- SSsummarize(list(bs99, bs99catch4, bs99catch5, bs99catch6))
  SSplotComparisons(sens.sum_catchC,
                    col = c(rich.colors.short(7)[1+c(1,5,6)],'purple'),
                    subplot = c(2,4),
                    pwidth=5.2,
                    pheight=4,
                    print = TRUE,
                    filenameprefix = "sens.catchC_4x5",
                    ylimAdj = 1.05, yaxs = 'i', 
                    endyrvec = 2019, legendlabels = c(sens.names_catch[c(1,5,6)],
                                         "Trend in F from Petrale Sole (no Q prior)"),
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

  # plot for presentations
  SSplotComparisons(sens.sum_catch,
                    plot = FALSE,
                    print = TRUE,
                    subplot = c(1,11),
                    pwidth = 5.2,
                    pheight = 4,
                    indexfleets = 5,
                    legendloc = 'bottomleft',
                    filenameprefix = "sens.catch_4x5_",
                    ylimAdj = 1.05, yaxs = 'i', 
                    endyrvec = 2019, legendlabels = sens.names_catch,
                    plotdir = dir.sensitivities)
  file.copy(file.path(dir.sensitivities, "sens.catch_4x5_compare1_spawnbio.png"),
            file.path(dir.sensitivities, "../../BigSkate_Doc/Figures/",
                      "sens.catch_4x5_compare1_spawnbio.png"),
            overwrite=TRUE)




  # make catch plot
  fleetnames_catch <- c("Fishery (current)",
                        "Discard (historical)",
                        "Fishery (historical)",
                        "Fishery (tribal)",
                        "WCGBTS",
                        "Triennial")
  SS_plots(bs99catch4, plot=7,
           fleetnames = fleetnames_catch)
  file.copy(file.path(bs99catch4$inputs$dir,
                      "plots/catch3 observed and expected landings (if different).png"),
            file.path(dir.sensitivities, "../../BigSkate_Doc/Figures/",
                      "catch_multiplier_catch_comparison.png"),
            overwrite = TRUE)
  file.copy(file.path(bs99catch4$inputs$dir,
                      "plots/catch5 total catch (including discards) stacked.png"),
            file.path(dir.sensitivities, "../../BigSkate_Doc/Figures/",
                      "catch_multiplier_total_catch.png"),
            overwrite = TRUE)
  file.copy(file.path(bs99catch4$inputs$dir,
                      "plots/catch5 total catch (including discards) stacked.png"),
            file.path(dir.sensitivities, "../../BigSkate_Doc/Figures/",
                      "catch_multiplier_total_catch.png"),
            overwrite = TRUE)



  fleetnames_catch <- c("Fishery (current)",
                        "Fishery + Discards (historical)",
                        "",
                        "Fishery (tribal)",
                        "WCGBTS",
                        "Triennial")
  SS_plots(bs99catch5, plot=7,
           fleetnames = fleetnames_catch)
  file.copy(file.path(bs99catch5$inputs$dir,
                      "plots/catch3 observed and expected landings (if different).png"),
            file.path(dir.sensitivities, "../../BigSkate_Doc/Figures/",
                      "catch_petraleF_catch_comparison.png"),
            overwrite = TRUE)
  file.copy(file.path(bs99catch5$inputs$dir,
                      "plots/catch5 total catch (including discards) stacked.png"),
            file.path(dir.sensitivities, "../../BigSkate_Doc/Figures/",
                      "catch_petraleF_total_catch.png"),
            overwrite = TRUE)

  catch0 <- SSplotCatch(bs99, print=FALSE, plot=FALSE)
  yrs <- catch0$totcatchmat$Yr
  totcatch0 <- apply(catch0$totcatchmat[,1:4], MARGIN = 1, FUN = sum)
  catch1 <- SSplotCatch(bs99catch1, print=FALSE, plot=FALSE)
  totcatch1 <- apply(catch1$totcatchmat[,1:4], MARGIN = 1, FUN = sum)
  catch2 <- SSplotCatch(bs99catch2, print=FALSE, plot=FALSE)
  totcatch2 <- apply(catch2$totcatchmat[,1:4], MARGIN = 1, FUN = sum)
  catch3 <- SSplotCatch(bs99catch3, print=FALSE, plot=FALSE)
  totcatch3 <- apply(catch3$totcatchmat[,1:4], MARGIN = 1, FUN = sum)
  catch4 <- SSplotCatch(bs99catch4, print=FALSE, plot=FALSE)
  totcatch4 <- apply(catch4$totcatchmat[,1:4], MARGIN = 1, FUN = sum)
  catch5 <- SSplotCatch(bs99catch5, print=FALSE, plot=FALSE)
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
  F_est_agg0 <- aggregate(bs99$catch$F, by=list(bs99$catch$Yr), FUN=sum)
  F_est_agg4 <- aggregate(bs99catch4$catch$F, by=list(bs99catch4$catch$Yr), FUN=sum)
  F_est_agg5 <- aggregate(bs99catch5$catch$F, by=list(bs99catch5$catch$Yr), FUN=sum)
  ## plot(bs99catch5$catch$Yr[bs99catch5$catch$Fleet==2],
  ##      bs99catch5$catch$F[bs99catch5$catch$Fleet==2], type='l')
  plot(F_est_agg0, type='l', lwd=2,
       xlab="Year", ylab="Instantaneous fishing mortality (F)",
       xlim = c(1916, 2018), ylim = c(0,0.085), yaxs='i', col=cols[1])
  lines(F_est_agg4, type='l', lwd=2, col=cols[5])
  lines(F_est_agg5, type='l', lwd=2, col=cols[6])
  lines(F_index2$F_table.Yr, F_index2$obs/bs99catch5$cpue$Calc_Q[1], col='purple', lty=3, lwd=2)
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



  #### review panel results for time-varying M and 1980 start
  getbs(82)
  getbs(82, sensname="bio6")
  getbs(82, sensname="bio7")
  getbs(82, sensname="bio8")
  getbs(82, sensname="bio9")
  getbs(82, sensname="misc5")
  getbs(82, sensname="bio10")
  getbs(82, sensname="misc6")

  ### 
  png(file.path(dir.sensitivities, "../../BigSkate_Doc/Figures/",
                'sens.1980start_comparisons_new_prior.png'),
      res=300, units='in', width=6.5, height=5, pointsize=10)

  SSplotComparisons(SSsummarize(list(bs82misc5, bs82misc6)),
                    ylimAdj = 1.05, yaxs = 'i', 
                    endyrvec = 2019, legendlabels=c(#"Pre-STAR Base",
                                         "Start in 1980 at fished equilibrium age structure",
                                         "Start in 1980 with flexible initial age structure"),
                    plotdir = dir.sensitivities,
                    plot = TRUE,
                    print = FALSE,
                    col = 2:3,
                    subplot = 1,
                    new = FALSE,
                    legendloc = c(2.5e3, 1995),
                    filenameprefix = "sens.1980start_")

  SSplotComparisons(SSsummarize(list(bs82)), #bs82misc5, bs82misc6)),
                    ylimAdj = 1.05, yaxs = 'i', 
                    endyrvec = 2019, legendlabels=c("Pre-STAR Base"),
                    #"Start in 1980 at fished equilibrium age structure",
                    #"Start in 1980 with flexible initial age structure"),
                    col = 4,
                    plotdir = dir.sensitivities,
                    plot = TRUE,
                    print = FALSE,
                    subplot = 1,
                    add = TRUE,
                    new = FALSE,
                    filenameprefix = "sens.1980start_")

  legend(legend = c("Start in 1980 at fished equilibrium age structure",
             "Start in 1980 with flexible initial age structure"),
         x = 2000, y = 2800,
         col = 2:3,
         bty='n',
         lwd=2)

  dev.off()


  ####


  ## ### new prior
  ## SSplotComparisons(SSsummarize(list(bs82, bs82Q5)),
  ##                   ylimAdj = 1.05, yaxs = 'i', 
  ##                   endyrvec = 2019, legendlabels=c("Base","New prior on catchability"),
  ##                   densitynames=c("OFLCatch_2021","ForeCatch_2021"),
  ##                   plotdir = dir.sensitivities,
  ##                   plot = FALSE,
  ##                   print = TRUE,
  ##                   filenameprefix = "sens.Q_new_prior_")


  #### comparing estimates of natural mortality
  png(file.path(dir.sensitivities, "../../BigSkate_Doc/Figures/",
                'sens.tv_M_time_series_of_M.png'),
      res=300, units='in', width=6.5, height=5, pointsize=10)
  colvec <- rich.colors.short(7)[-1]
  plot(1916:2018, bs82bio6$MGparmAdj$NatM_p_1_Fem_GP_1[bs82bio6$MGparmAdj$Yr %in% 1916:2018],
       ylim = c(0,0.7), yaxs='i', xlim=c(1916, 2018), #ylim=c(0, 0.6),
       xlab="Year", ylab="Natural mortality",
       type='l', lwd=2, col=colvec[2], las=1)
  lines(1916:2018, bs82bio7$MGparmAdj$NatM_p_1_Fem_GP_1[bs82bio7$MGparmAdj$Yr %in% 1916:2018],
        type='l', lwd=2, col=colvec[3])
  lines(1916:2018, bs82bio8$MGparmAdj$NatM_p_1_Fem_GP_1[bs82bio8$MGparmAdj$Yr %in% 1916:2018],
        type='l', lwd=2, col=colvec[4])
  lines(1916:2018, bs82bio9$MGparmAdj$NatM_p_1_Fem_GP_1[bs82bio9$MGparmAdj$Yr %in% 1916:2018],
        type='l', lwd=2, col=colvec[5])
  lines(1916:2018, bs82bio10$MGparmAdj$NatM_p_1_Fem_GP_1[bs82bio10$MGparmAdj$Yr %in% 1916:2018],
        type='l', lwd=2, col=colvec[6])
  lines(1916:2018, bs82$MGparmAdj$NatM_p_1_Fem_GP_1[bs82$MGparmAdj$Yr %in% 1916:2018],
        type='l', lwd=2, col=colvec[1])
  legend('bottomleft',
         col = colvec,
         lwd=2,
         bty = 'n',
         legend = c("Base",paste0("Time-varying M option ", 1:5)))
  dev.off()

  SSplotComparisons(SSsummarize(list(bs82, bs82bio6, bs82bio7, bs82bio8, bs82bio9, bs82bio10)),
                    #legendlabels=c("Base","New prior on catchability"),
                    ylimAdj = 1.05, yaxs = 'i', 
                    endyrvec = 2019, legendlabels = c("Base",paste0("Time-varying M option ", 1:5)),
                    densitynames=c("OFLCatch_2021","ForeCatch_2021"),
                    plotdir = dir.sensitivities,
                    plot = FALSE,
                    print = TRUE,
                    legendloc = 'bottomright',
                    indexfleets = 5,
                    indexUncertainty = TRUE,
                    filenameprefix = "sens.tv_M_")

  SSplotComparisons(SSsummarize(list(bs82, bs82bio6, bs82bio7, bs82bio8, bs82bio9, bs82bio10)),
                    #legendlabels=c("Base","New prior on catchability"),
                    ylimAdj = 1.05, yaxs = 'i', 
                    endyrvec = 2019, legendlabels = c("Base",paste0("Time-varying M option ", 1:5)),
                    densitynames=c("OFLCatch_2021","ForeCatch_2021"),
                    plotdir = dir.sensitivities,
                    plot = FALSE,
                    print = TRUE,
                    legendloc = 'topleft',
                    indexfleets = 6,
                    subplot = 11,
                    indexUncertainty = TRUE,
                    filenameprefix = "sens.tv_M_")
  file.copy(file.path(dir.sensitivities, "sens.tv_M_compare1_spawnbio.png"),
            file.path(dir.sensitivities, "../../BigSkate_Doc/Figures/",
                      "sens.tv_M_compare1_spawnbio.png"),
            overwrite=TRUE)
  file.copy(file.path(dir.sensitivities, "sens.tv_M_compare7_recruits.png"),
            file.path(dir.sensitivities, "../../BigSkate_Doc/Figures/",
                      "sens.tv_M_compare7_recruits.png"),
            overwrite=TRUE)
  file.copy(file.path(dir.sensitivities, "sens.tv_M_compare11_indices_flt5.png"),
            file.path(dir.sensitivities, "../../BigSkate_Doc/Figures/",
                      "sens.tv_M_compare11_indices_flt5.png"),
            overwrite=TRUE)
  file.copy(file.path(dir.sensitivities, "sens.tv_M_compare11_indices_flt6.png"),
            file.path(dir.sensitivities, "../../BigSkate_Doc/Figures/",
                      "sens.tv_M_compare11_indices_flt6.png"),
            overwrite=TRUE)

  
  SS_plots(bs82bio6)
  SS_plots(bs82bio7)
  SS_plots(bs82bio8)
  SS_plots(bs82bio9)
  SS_plots(bs82misc5)
  SS_plots(bs82bio10)
  SS_plots(bs82misc6)


  ## ### new prior
  ## SSplotComparisons(SSsummarize(list(bs99, bs99Q5)),
  ##                   ylimAdj = 1.05, yaxs = 'i', 
  ##                   endyrvec = 2019, legendlabels=c("Base","New prior on catchability"),
  ##                   densitynames=c("OFLCatch_2021","ForeCatch_2021"),
  ##                   plotdir = dir.sensitivities,
  ##                   plot = FALSE,
  ##                   print = TRUE,
  ##                   filenameprefix = "sens.Q_new_prior_")


  ### request #6
  # new prior value in non-log space
  exp(-0.355)
  ## [1] 0.7011734
  # half that value
  exp(-0.355)*.5
  ## [1] 0.3505867
  # half of q in log space
  log(exp(-0.355)*.5)
  ## [1] -1.048147

  png(file.path(dir.sensitivities, "../../BigSkate_Doc/Figures/",
                'request6_prior_comparisons.png'),
      res=300, units='in', width=6.5, height=6.5, pointsize=10)
  par(mfrow=c(3,1), mar=c(2,1,1,1), oma=c(3,0,0,0), cex=1);
  SSplotPars(bs99, string="LnQ_base_W", new=FALSE, newheaders = "New base model (prior q = 0.701)",
             xlab = "Log-scale catchability of the WCGBT Survey: log(q)")
  SSplotPars(bs99Q6, string="LnQ_base_W", new=FALSE, newheaders = "Prior q = 0.3505 (half of new base value)")
  SSplotPars(bs99Q1, string="LnQ_base_W", new=FALSE, newheaders = "No prior")
  dev.off()


  # prior comparisons
  png(file.path('C:/ss/skates/BigSkate_Doc/Figures/',
                'GFSC_prior_comparisons.png'),
      res=300, units='in', width=5.2, height=4, pointsize=10)
  SSplotPars(bs82, strings="LnQ_base_WCGBTS(5)", showpost=FALSE,
             nrow=1, ncol=1, new=FALSE, add=FALSE, showmle=TRUE,
             showinit=FALSE, showlegend=FALSE, ltyvec=rep(3,4))
  SSplotPars(bs99, strings="LnQ_base_WCGBTS(5)", showpost=FALSE,
             nrow=1, ncol=1, new=FALSE, add=TRUE, showmle=TRUE,
             showinit=FALSE, showlegend=FALSE)
  legend('topright', lty=c(1,1,3,3), lwd=c(2,1,2,1),
         legend=c("Big Skate prior","MLE","Longnose Skate prior","fit to LSKT prior"),
         bty='n', col=c(1,4,1,4))
  mtext(side=1, line=3, outer=FALSE, "log(q)")
  mtext(side=2, line=3, outer=FALSE, "Density")
  dev.off()


  

  # getbs function from /BigSkate_Doc/R/BigSkate_functions.R
  source('c:/SS/skates/BigSkate_Doc/R/BigSkate_functions.R')
  getbs(99) 
  #getbs(99, sensname="sel1")
  getbs(99, sensname="sel2")
  getbs(99, sensname="sel3")
  getbs(99, sensname="Q1")
  getbs(99, sensname="Q2")

  getbs(99, sensname="bio1")
  getbs(99, sensname="bio2")
  getbs(99, sensname="bio3")
  getbs(99, sensname="bio12")
  getbs(99, sensname="bio5") # nohess version

  getbs(99, sensname="misc1")
  getbs(99, sensname="misc2")
  getbs(99, sensname="misc4")
  getbs(99, sensname="rec2")
  getbs(99, sensname="rec4") # no Q prior

  getbs(99, sensname="catch1")
  getbs(99, sensname="catch2")
  getbs(99, sensname="catch3")
  getbs(99, sensname="catch4")
  getbs(99, sensname="catch5")



  sens.names_all <- c("Base model",

                      #"Sel all asymptotic",
                      "Sel all domed",
                      "Sel no sex offset",
                      "Q no prior on WCGBTS",
                      "Q no offset on triennial",
                      
                      "Bio separate M by sex",
                      "Bio no M prior",
                      "Bio von Bertalanffy growth",
                      "Bio Richards growth",

                      "McAllister-Ianelli tuning",
                      "Dirichlet-Multinomial tuning",
                      "No extra index std. dev.",
                      "Recruitment deviations",
                      
                      "Discards based on 3yr averages",
                      "Discard mortality = 0.4",
                      "Discard mortality = 0.6",
                      "Multipliers on historical discards",
                      "Trend in F from Petrale Sole")

  model.summaries <- SSsummarize(list(bs99,
                                      bs99sel2, bs99sel3, bs99Q1, bs99Q2,
                                      bs99bio1, bs99bio2, bs99bio3, bs99bio5,
                                      bs99misc1, bs99misc2, bs99misc4, bs99rec2, 
                                      bs99catch1, bs99catch2, bs99catch3, bs99catch4, bs99catch5))

  SSplotComparisons(model.summaries, ylimAdj = 1.05, yaxs = 'i', 
                    endyrvec = 2019, legendlabels = sens.names_all,
                    plot=FALSE,
                    print=TRUE,
                    subplot=1:4,
                    plotdir = file.path(dir.sensitivities,'plots'))

  source('c:/SS/skates/R/SS_Sensi_plot.R')

  #Run the sensitivity plot function
  SS_Sensi_plot(model.summaries = model.summaries,
                Dir = file.path(dir.sensitivities,'plots'),
                current.year = 2019,
                mod.names = sens.names_all, #List the names of the sensitivity runs
                likelihood.out = c(0,0,0),
                Sensi.RE.out = "Sensi_RE_out.DMP", #Saved file of relative errors
                CI = 0.95, #Confidence interval box based on the reference model
                TRP.in = 0.4, #Target relative abundance value
                LRP.in = 0.25, #Limit relative abundance value
                sensi_xlab = "Sensitivity scenarios", #X-axis label
                ylims.in = c(-1,1, -1,1, -1,1, -1,1, -1,1, -1,1), #Y-axis label
                plot.figs = c(1,1,1,1,1,1) , #Which plots to make/save? 
                sensi.type.breaks = c(5.5,9.5,13.5), #vertical breaks that can separate out types of sensitivities
                anno.x = c(3,7.5,11.5,16.0), # Vertical positioning of the sensitivity types labels
                anno.y = c(1,1,1,1), # Horizontal positioning of the sensitivity types labels
                anno.lab = c("Selectivity &\n Catchability",
                    "Biology",
                    "Data-\nweighting",
                    "Catch history") #Sensitivity types labels
                )

} # end if(FALSE) which allows sourcing the file to get the stuff at the top

