### notes on running profiles and making associated plots
### for 2019 Big Skate assessment

#stop("\n  This file should not be sourced!") # note to stop Ian from accidental sourcing

# define directory on a specific computer
if(Sys.info()["user"] == "Ian.Taylor"){
  dir.outer <- c('c:/SS/skates/models')
}

require(r4ss)
require(SSutils) # package with functions for copying SS input files
#devtools::install_github('r4ss/SSutils')

# alternative approach to sensitivities where the change is easy to make,
# in which case the files from a previous set of sensitivities are all copied
# for a new model

## outerdir.old <- file.path(dir.outer, 
## old.bigskate74_spawnbio_3.30.13.02

populate_multiple_folders(outerdir.old = file.path(dir.outer, "sensitivity.bigskate72"),
                          outerdir.new = file.path(dir.outer, "sensitivity.bigskate74"),
                          create.dir = TRUE,
                          overwrite = FALSE,
                          use_ss_new = FALSE,
                          exe.dir = file.path(dir.outer, "bigskate74_spawnbio_3.30.13.02"),
                          exe.file = "ss.exe",
                          exe.only = FALSE,
                          verbose = TRUE) 
##                     dir results.files results.exe
## 1    bio1_male_M_offset          TRUE        TRUE
## 2         bio2_noMprior          TRUE        TRUE
## 3         bio3_VBgrowth          TRUE        TRUE
## 4  bio4_Richards_growth          TRUE        TRUE
## 5   catch1_alt_discards          TRUE        TRUE
## 6  catch2_disc_mort_0.4          TRUE        TRUE
## 7  catch3_disc_mort_0.6          TRUE        TRUE
## 8        misc1_MItuning          TRUE        TRUE
## 9           Q1_no_prior          TRUE        TRUE
## 10     Q2_no_tri_offset          TRUE        TRUE
## 11  sel1_all_asymptotic          TRUE        TRUE
## 12        sel2_all_dome          TRUE        TRUE
## 13   sel3_no_fem_offset          TRUE        TRUE

dir.sensitivities <- file.path(dir.outer, "sensitivity.bigskate74")
dir.sensitivities.old <- file.path(dir.outer, "sensitivity.bigskate72")
sens.list     <- dir(dir.sensitivities)

# base model on May 8
#mod <- 'bigskate74_share_dome'
# new base May 11 (new exe to fix forecast uncertainty and fix fecundity = 0.5) 
mod <- 'bigskate74_spawnbio_3.30.13.02' 

# load model output into R
dir.mod <- file.path(dir.outer, mod)

# replace all forecast files with updated version
for(imod in 1:length(sens.list)){
  dir.sens <- file.path(dir.sensitivities, sens.list[imod])
  # get forecast file with time-varying sigma, fixed catches, and benchmark year = 1916
  file.copy(from = file.path(dir.mod, "forecast.ss"),
            to   = file.path(dir.sens, "forecast.ss"),
            overwrite = TRUE)
  SS_changepars(dir = dir.sens,
                ctlfile = "BSKT2019_control.ss",
                newctlfile = "BSKT2019_control.ss",
                strings = "Eggs/kg_inter_Fem_GP_1",
                newvals = 1)
}

dirvec <- file.path(dir.sensitivities, sens.list)
run_SS_models(dirvec=dirvec)
  


# read model without printing stuff (assuming it's already been looked at)
out <- SS_output(dir.mod, verbose=FALSE, printstats=FALSE)

dir.sensitivities <- file.path(dir.outer, "sensitivity.bigskate72")
dir.create(dir.sensitivities)

dir.sens <- file.path(dir.sensitivities, "bigskate72.sens.sel1_all_asymptotic")
copy_SS_inputs(dir.old = dir.mod,
               dir.new = dir.sens,
               use_ss_new = TRUE,
               copy_exe = TRUE,
               copy_par = TRUE)
SS_changepars(dir = dir.sens,
              ctlfile = "BSKT2019_control.ss",
              newctlfile = "BSKT2019_control.ss",
              strings = "Descend",
              newvals = rep(5, 3),
              estimate = TRUE)
run_SS_models(dir.sens)

dir.sens <- file.path(dir.sensitivities, "bigskate72.sens.sel2_all_dome")
copy_SS_inputs(dir.old = dir.mod,
               dir.new = dir.sens,
               use_ss_new = TRUE,
               copy_exe = TRUE,
               copy_par = TRUE)
SS_changepars(dir = dir.sens,
              ctlfile = "BSKT2019_control.ss",
              newctlfile = "BSKT2019_control.ss",
              strings = "Descend",
              newvals = rep(20, 3),
              estimate = FALSE)
SS_changepars(dir = dir.sens,
              ctlfile = "BSKT2019_control.ss",
              newctlfile = "BSKT2019_control.ss",
              strings = "Fem_Descend",
              newvals = rep(0, 3),
              estimate = FALSE)

# note: had to change init for LN(R0) to be 10 and phase to be 5 to avoid nan values
dir.sens <- file.path(dir.sensitivities, "bigskate72.sens.sel3_no_fem_offset")
copy_SS_inputs(dir.old = dir.mod,
               dir.new = dir.sens,
               use_ss_new = TRUE,
               copy_exe = TRUE,
               copy_par = TRUE)
SS_changepars(dir = dir.sens,
              ctlfile = "BSKT2019_control.ss",
              newctlfile = "BSKT2019_control.ss",
              strings = "SzSel_Fem",
              estimate = FALSE)

dir.sens <- file.path(dir.sensitivities, "bio1_male_M_offset")
copy_SS_inputs(dir.old = dir.mod,
               dir.new = dir.sens,
               use_ss_new = TRUE,
               copy_exe = TRUE,
               copy_par = TRUE)
SS_changepars(dir = dir.sens,
              ctlfile = "BSKT2019_control.ss",
              newctlfile = "BSKT2019_control.ss",
              strings = "NatM_p_1_Mal",
              estimate = TRUE)


dir.sens <- file.path(dir.sensitivities, "bio2_noMprior")
copy_SS_inputs(dir.old = dir.mod,
               dir.new = dir.sens,
               use_ss_new = FALSE,
               copy_exe = TRUE,
               copy_par = TRUE)


dir.sens <- file.path(dir.sensitivities, "bio3_VBgrowth")
copy_SS_inputs(dir.old = dir.mod,
               dir.new = dir.sens,
               use_ss_new = FALSE,
               copy_exe = TRUE,
               copy_par = TRUE)


dir.sens <- file.path(dir.sensitivities, "bio4_Richards_growth")
copy_SS_inputs(dir.old = dir.mod,
               dir.new = dir.sens,
               use_ss_new = FALSE,
               copy_exe = TRUE,
               copy_par = TRUE)


# edit manually
dir.sens <- file.path(dir.sensitivities, "Q1_no_prior")
copy_SS_inputs(dir.old = dir.mod,
               dir.new = dir.sens,
               use_ss_new = FALSE,
               copy_exe = TRUE,
               copy_par = TRUE)

dir.sens <- file.path(dir.sensitivities, "Q2_no_tri_offset")
copy_SS_inputs(dir.old = dir.mod,
               dir.new = dir.sens,
               use_ss_new = FALSE,
               copy_exe = TRUE,
               copy_par = TRUE)

dir.sens <- file.path(dir.sensitivities, "catch1_alt_discards")
copy_SS_inputs(dir.old = dir.mod,
               dir.new = dir.sens,
               use_ss_new = FALSE,
               copy_exe = TRUE,
               copy_par = TRUE)

dir.sens <- file.path(dir.sensitivities, "catch2_disc_mort_0.4")
copy_SS_inputs(dir.old = dir.mod,
               dir.new = dir.sens,
               use_ss_new = FALSE,
               copy_exe = TRUE,
               copy_par = TRUE)

dir.sens <- file.path(dir.sensitivities, "catch3_disc_mort_0.6")
copy_SS_inputs(dir.old = dir.mod,
               dir.new = dir.sens,
               use_ss_new = FALSE,
               copy_exe = TRUE,
               copy_par = TRUE)

dir.sens <- file.path(dir.sensitivities, "misc1_MItuning")
copy_SS_inputs(dir.old = dir.mod,
               dir.new = dir.sens,
               use_ss_new = TRUE,
               copy_exe = TRUE,
               copy_par = TRUE)
mod <- SS_output(dir.mod, verbose=FALSE, printstats=FALSE)
MItuning <- SS_tune_comps(mod, option="MI")
file.rename(file.path(dir.mod, "suggested_tuning.ss"),
            file.path(dir.mod, "suggested_tuning_MI.ss"))
ctl.lines <- readLines(file.path(dir.mod, "control.ss_new"))
start <- grep("Input variance adjustments factors", ctl.lines)
end <- grep("-9999", ctl.lines)
end <- end[end > start][1]
new.ctl.lines <- c(ctl.lines[1:start],
                   apply(MItuning, 1, FUN = paste, collapse = " "),
                   ctl.lines[end:length(ctl.lines)])
writeLines(new.ctl.lines, con = file.path(dir.sens, "BSKT2019_control.ss"))



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
getbs(74, sensname="sel1")
getbs(74, sensname="sel2")
getbs(74, sensname="sel3")
getbs(74, sensname="Q1")
getbs(74, sensname="Q2")
getbs(74, sensname="catch1")
getbs(74, sensname="catch2")
getbs(74, sensname="catch3")

sens.sum_sel_and_Q <- SSsummarize(list(bs74, bs74sel1, bs74sel2, bs74sel3,
                                       bs74Q1, bs74Q2))
sens.names_sel_and_Q <- c("Base model",
                          "Sel all asymptotic",
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
                       csvfile = "comparison_table_sens.74.csv"
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
                  plotdir = dir.sensitivities)
# copy spawn bio plot to model repository
file.copy(file.path(dir.sensitivities, "sens.sel_and_Q_compare1_spawnbio.png"),
          file.path(dir.sensitivities, "../../BigSkate_Doc/Figures/",
                    "sens.sel_and_Q_compare1_spawnbio.png"),
          overwrite=TRUE)



############# sensitivities to biology and miscellaneous things
getbs(74, sensname="bio1")
getbs(74, sensname="bio2")
getbs(74, sensname="bio3")
getbs(74, sensname="bio4")
getbs(74, sensname="misc1")

sens.sum_bio_and_misc <- SSsummarize(list(bs74, bs74bio1, bs74bio2, bs74bio3,
                                          bs74bio4, bs74misc1))
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
                       csv=TRUE,
                       csvdir = dir.sensitivities,
                       csvfile = "comparison_table_sens.74.csv"
                       )

# add in Richards and vonB growth values
sens.table_bio_and_misc[grep("Linf", sens.table_bio_and_misc$Label),
                        1 + grep("Richards", sens.names_bio_and_misc)] <- 
                          bs74bio4$Growth_Parameters$Linf
sens.table_bio_and_misc[grep("Linf", sens.table_bio_and_misc$Label),
                        1 + grep("von", sens.names_bio_and_misc)] <- 
                          bs74bio3$Growth_Parameters$Linf


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
#sens.sum_bio_and_misc$SpawnBio$model5 <- bs74bio4$timeseries$SpawnBio

SSplotComparisons(sens.sum_bio_and_misc,
                  print = TRUE,
                  filenameprefix = "sens.bio_and_misc_",
                  legendlabels = sens.names_bio_and_misc,
                  plotdir = dir.sensitivities)
file.copy(file.path(dir.sensitivities, "sens.bio_and_misc_compare1_spawnbio.png"),
          file.path(dir.sensitivities, "../../BigSkate_Doc/Figures/",
                    "sens.bio_and_misc_compare1_spawnbio.png"),
          overwrite=TRUE)

#### catch sensitivities

getbs(74, sensname="catch1")
getbs(74, sensname="catch2")
getbs(74, sensname="catch3")

sens.sum_catch <- SSsummarize(list(bs74, bs74catch1, bs74catch2, bs74catch3))
sens.names_catch <- c("Base model",
                          "Discards based on 3yr averages",
                          "Discard mortality = 0.4",
                          "Discard mortality = 0.6")
thingnames = c("Recr_Virgin", "R0", "NatM", "Linf",
    "LnQ_base_WCGBTS",
    "SSB_Virg", "SSB_2019",
    "Bratio_2019", "SPRratio_2018", "Ret_Catch_MSY", "Dead_Catch_MSY")

# make table of model results
sens.table_catch <-
    SStableComparisons(sens.sum_catch,
                       modelnames=sens.names_catch,
                       names=thingnames,
                       csv=TRUE,
                       csvdir = dir.sensitivities,
                       csvfile = "comparison_table_sens.74.csv"
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

# copy to document repository
file.copy(file.path(dir.sensitivities, "sens.catch_compare1_spawnbio.png"),
          file.path(dir.sensitivities, "../../BigSkate_Doc/Figures/",
                    "sens.catch_compare1_spawnbio.png"),
          overwrite=TRUE)



## mortality M vs F
## Alternative catch or discard assumptions
## Data weighting (Francis, vs. M-I vs. Dirichlet-Multinomial)
## Prior on Q: on, wider, off
## Turn off the prior on M
## Turn on recruitment devs
## Jasons 3-parameter stock-recruit function (if Vlada figures out how to use this and it makes any difference for Longnose)
## Exponential logistic selectivity
