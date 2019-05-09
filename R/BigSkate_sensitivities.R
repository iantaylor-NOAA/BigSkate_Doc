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

# load model output into R
# read base model from each area
mod <- 'bigskate72_share_dome'
dir.mod <- file.path(dir.outer, mod)
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


# getbs function from /BigSkate_Doc/R/BigSkate_functions.R
getbs(72, sensname="sel1")
getbs(72, sensname="sel2")
getbs(72, sensname="sel3")
getbs(72, sensname="Q1")
getbs(72, sensname="Q2")
getbs(72, sensname="catch1")
getbs(72, sensname="catch2")
getbs(72, sensname="catch3")

sens.sum_sel_and_Q <- SSsummarize(list(bs72, bs72sel1, bs72sel2, bs72sel3,
                                       bs72Q1, bs72Q2))
sens.names_sel_and_Q <- c("Base model",
                          "Sel all asymptotic",
                          "Sel all domed",
                          "Sel no sex offset",
                          "Q no prior on WCGBTS",
                          "Q no offset on triennial")
thingnames = c("Recr_Virgin", "R0", "NatM", "Linf",
    "LnQ_base_WCGBTS",
    "SSB_Virg", "SSB_2019",
    "Bratio_2019", "SPRratio_2018", "Ret_Catch_MSY", "Dead_Catch_MSY")

sens.table_sel_and_Q <-
    SStableComparisons(sens.sum_sel_and_Q,
                       modelnames=sens.names_sel_and_Q,
                       names=thingnames,
                       csv=TRUE,
                       csvdir = dir.sensitivities,
                       csvfile = "comparison_table_sens.72.csv"
                       )
# create a new column of labels for each quantity
newlabel <- sens.table_sel_and_Q$Label
newlabel <- gsub("p_1_", "", newlabel)
newlabel <- gsub("GP_1", "", newlabel)
newlabel <- gsub("SR_LN", "log", newlabel)
newlabel <- gsub("_", " ", newlabel)
newlabel <- gsub("LnQ base WCGBTS(5)", "Q WCGBTS", newlabel, fixed=TRUE)
newlabel <- gsub("Fem", "Female", newlabel)
newlabel <- gsub("Mal", "Male", newlabel)
# convert some things to new units (non-log or non-offset)
# Q to non-log space
sens.table_sel_and_Q[grep("LnQ", sens.table_sel_and_Q$Label), -1] <-
  exp(sens.table_sel_and_Q[grep("LnQ", sens.table_sel_and_Q$Label), -1])
# male M offset
sens.table_sel_and_Q[grep("NatM_p_1_Mal", sens.table_sel_and_Q$Label), -1] <-
  sens.table_sel_and_Q[grep("NatM_p_1_Fem", sens.table_sel_and_Q$Label), -1] *
    exp(sens.table_sel_and_Q[grep("NatM_p_1_Mal", sens.table_sel_and_Q$Label), -1])
# male Linf offset
sens.table_sel_and_Q[grep("Linf_Mal", sens.table_sel_and_Q$Label), -1] <-
  sens.table_sel_and_Q[grep("Linf_Fem", sens.table_sel_and_Q$Label), -1] *
    exp(sens.table_sel_and_Q[grep("Linf_Mal", sens.table_sel_and_Q$Label), -1])

sens.table_sel_and_Q$Label <- newlabel
write.csv(sens.table_sel_and_Q,
          file = file.path(dir.sensitivities, 'Sensitivities_sel_and_Q.csv'),
          row.names = FALSE)

SSplotComparisons(sens.sum_sel_and_Q,
                  print = TRUE,
                  filenameprefix = "sens.sel_and_Q_",
                  legendlabels = sens.names_sel_and_Q,
                  plotdir = dir.sensitivities)



############# sensitivities to biology and miscellaneous things
getbs(72, sensname="bio1")
getbs(72, sensname="bio2")
getbs(72, sensname="bio3")
getbs(72, sensname="bio4")
getbs(72, sensname="misc1")

sens.sum_bio_and_misc <- SSsummarize(list(bs72, bs72bio1, bs72bio2, bs72bio3,
                                          bs72bio4, bs72misc1))
sens.names_bio_and_misc <- c("Base model",
                          "Bio separate M by sex",
                          "Bio no M prior",
                          "Bio von Bertalanffy growth",
                          "Bio Richards growth",
                          "Misc: McAllister-Ianelli tuning")
thingnames = c("Recr_Virgin", "R0", "NatM", "Linf",
    "LnQ_base_WCGBTS",
    "SSB_Virg", "SSB_2019",
    "Bratio_2019", "SPRratio_2018", "Ret_Catch_MSY", "Dead_Catch_MSY")

sens.table_bio_and_misc <-
    SStableComparisons(sens.sum_bio_and_misc,
                       modelnames=sens.names_bio_and_misc,
                       names=thingnames,
                       csv=TRUE,
                       csvdir = dir.sensitivities,
                       csvfile = "comparison_table_sens.72.csv"
                       )
# create a new column of labels for each quantity
newlabel <- sens.table_bio_and_misc$Label
newlabel <- gsub("p_1_", "", newlabel)
newlabel <- gsub("GP_1", "", newlabel)
newlabel <- gsub("SR_LN", "log", newlabel)
newlabel <- gsub("_", " ", newlabel)
newlabel <- gsub("LnQ base WCGBTS(5)", "Q WCGBTS", newlabel, fixed=TRUE)
newlabel <- gsub("Fem", "Female", newlabel)
newlabel <- gsub("Mal", "Male", newlabel)
# convert some things to new units (non-log or non-offset)
# Q to non-log space
sens.table_bio_and_misc[grep("Linf", sens.table_bio_and_misc$Label),
                        1 + grep("Richards", sens.names_bio_and_misc)] <- 
                          bs72bio4$Growth_Parameters$Linf
sens.table_bio_and_misc[grep("Linf", sens.table_bio_and_misc$Label),
                        1 + grep("von B", sens.names_bio_and_misc)] <- 
                          bs72bio3$Growth_Parameters$Linf

sens.table_bio_and_misc[grep("LnQ", sens.table_bio_and_misc$Label), -1] <-
  exp(sens.table_bio_and_misc[grep("LnQ", sens.table_bio_and_misc$Label), -1])
# male M offset
sens.table_bio_and_misc[grep("NatM_p_1_Mal", sens.table_bio_and_misc$Label), -1] <-
  sens.table_bio_and_misc[grep("NatM_p_1_Fem", sens.table_bio_and_misc$Label), -1] *
    exp(sens.table_bio_and_misc[grep("NatM_p_1_Mal", sens.table_bio_and_misc$Label), -1])
# male Linf offset
sens.table_bio_and_misc[grep("Linf_Mal", sens.table_bio_and_misc$Label), -1] <-
  sens.table_bio_and_misc[grep("Linf_Fem", sens.table_bio_and_misc$Label), -1] *
    exp(sens.table_bio_and_misc[grep("Linf_Mal", sens.table_bio_and_misc$Label), -1])

sens.table_bio_and_misc$Label <- newlabel

write.csv(sens.table_bio_and_misc,
          file = file.path(dir.sensitivities, 'Sensitivities_bio_and_misc.csv'),
          row.names = FALSE)

# Richards growth didn't converge, so replacing timeseries to get plot
sens.sum_bio_and_misc$SpawnBio$model5 <- bs72bio4$timeseries$SpawnBio

SSplotComparisons(sens.sum_bio_and_misc,
                  print = TRUE,
                  filenameprefix = "sens.bio_and_misc_",
                  legendlabels = sens.names_bio_and_misc,
                  plotdir = dir.sensitivities)

#### catch sensitivities

getbs(72, sensname="catch1")
getbs(72, sensname="catch2")
getbs(72, sensname="catch3")

sens.sum_catch <- SSsummarize(list(bs72, bs72catch1, bs72catch2, bs72catch3))
sens.names_catch <- c("Base model",
                          "Discards based on 3yr averages",
                          "Discard mortality = 0.4",
                          "Discard mortality = 0.6")
thingnames = c("Recr_Virgin", "R0", "NatM", "Linf",
    "LnQ_base_WCGBTS",
    "SSB_Virg", "SSB_2019",
    "Bratio_2019", "SPRratio_2018", "Ret_Catch_MSY", "Dead_Catch_MSY")

sens.table_catch <-
    SStableComparisons(sens.sum_catch,
                       modelnames=sens.names_catch,
                       names=thingnames,
                       csv=TRUE,
                       csvdir = dir.sensitivities,
                       csvfile = "comparison_table_sens.72.csv"
                       )
# create a new column of labels for each quantity
newlabel <- sens.table_catch$Label
newlabel <- gsub("p_1_", "", newlabel)
newlabel <- gsub("GP_1", "", newlabel)
newlabel <- gsub("SR_LN", "log", newlabel)
newlabel <- gsub("_", " ", newlabel)
newlabel <- gsub("LnQ base WCGBTS(5)", "Q WCGBTS", newlabel, fixed=TRUE)
newlabel <- gsub("Fem", "Female", newlabel)
newlabel <- gsub("Mal", "Male", newlabel)
# convert some things to new units (non-log or non-offset)
# Q to non-log space
sens.table_catch[grep("LnQ", sens.table_catch$Label), -1] <-
  exp(sens.table_catch[grep("LnQ", sens.table_catch$Label), -1])
# male M offset
sens.table_catch[grep("NatM_p_1_Mal", sens.table_catch$Label), -1] <-
  sens.table_catch[grep("NatM_p_1_Fem", sens.table_catch$Label), -1] *
    exp(sens.table_catch[grep("NatM_p_1_Mal", sens.table_catch$Label), -1])
# male Linf offset
sens.table_catch[grep("Linf_Mal", sens.table_catch$Label), -1] <-
  sens.table_catch[grep("Linf_Fem", sens.table_catch$Label), -1] *
    exp(sens.table_catch[grep("Linf_Mal", sens.table_catch$Label), -1])

sens.table_catch$Label <- newlabel
write.csv(sens.table_catch,
          file = file.path(dir.sensitivities, 'Sensitivities_catch.csv'),
          row.names = FALSE)

SSplotComparisons(sens.sum_catch,
                  print = TRUE,
                  filenameprefix = "sens.catch_",
                  legendlabels = sens.names_catch,
                  plotdir = dir.sensitivities)




## mortality M vs F
## Alternative catch or discard assumptions
## Data weighting (Francis, vs. M-I vs. Dirichlet-Multinomial)
## Prior on Q: on, wider, off
## Turn off the prior on M
## Turn on recruitment devs
## Jasons 3-parameter stock-recruit function (if Vlada figures out how to use this and it makes any difference for Longnose)
## Exponential logistic selectivity
