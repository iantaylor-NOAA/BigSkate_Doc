### notes on running sensitivities
### for 2019 Big Skate assessment
### code to gather results is in /R/BigSkate_sensitivity_results.R

#stop("\n  This file should not be sourced!") # note to stop Ian from accidental sourcing

# define directory on a specific computer
if(Sys.info()["user"] == "Ian.Taylor"){
  dir.outer <- c('c:/SS/skates/models')
}

require(r4ss)
require(SSutils) # package with functions for copying SS input files
#devtools::install_github('r4ss/SSutils')

mod <- 'bigskate82_base_May13'
dir.mod <- file.path(dir.outer, mod)
dir.sensitivities <- file.path(dir.outer, "sensitivity.bigskate82")
#dir.create(dir.sensitivities)

if(FALSE){
################################################################################
# alternative approach to sensitivities where the change is easy to make
# standard approach is below, after the commented out stuff
################################################################################

## # in which case the files from a previous set of sensitivities are all copied
## # for a new model

## ## outerdir.old <- file.path(dir.outer, 
## ## old.bigskate74_spawnbio_3.30.13.02

## populate_multiple_folders(outerdir.old = file.path(dir.outer, "sensitivity.bigskate72"),
##                           outerdir.new = file.path(dir.outer, "sensitivity.bigskate74"),
##                           create.dir = TRUE,
##                           overwrite = FALSE,
##                           use_ss_new = FALSE,
##                           exe.dir = file.path(dir.outer, "bigskate74_spawnbio_3.30.13.02"),
##                           exe.file = "ss.exe",
##                           exe.only = FALSE,
##                           verbose = TRUE) 
## ##                     dir results.files results.exe
## ## 1    bio1_male_M_offset          TRUE        TRUE
## ## 2         bio2_noMprior          TRUE        TRUE
## ## 3         bio3_VBgrowth          TRUE        TRUE
## ## 4  bio4_Richards_growth          TRUE        TRUE
## ## 5   catch1_alt_discards          TRUE        TRUE
## ## 6  catch2_disc_mort_0.4          TRUE        TRUE
## ## 7  catch3_disc_mort_0.6          TRUE        TRUE
## ## 8        misc1_MItuning          TRUE        TRUE
## ## 9           Q1_no_prior          TRUE        TRUE
## ## 10     Q2_no_tri_offset          TRUE        TRUE
## ## 11  sel1_all_asymptotic          TRUE        TRUE
## ## 12        sel2_all_dome          TRUE        TRUE
## ## 13   sel3_no_fem_offset          TRUE        TRUE

## dir.sensitivities <- file.path(dir.outer, "sensitivity.bigskate74")
## dir.sensitivities.old <- file.path(dir.outer, "sensitivity.bigskate72")
## sens.list     <- dir(dir.sensitivities)

## # base model on May 8
## #mod <- 'bigskate74_share_dome'
## # new base May 11 (new exe to fix forecast uncertainty and fix fecundity = 0.5) 
## # mod <- 'bigskate74_spawnbio_3.30.13.02'
## # new base May 13 (fix prior on M)
## mod <- 'bigskate82_base_May13'

## # load model output into R
## dir.mod <- file.path(dir.outer, mod)

## # replace all forecast files with updated version
## for(imod in 1:length(sens.list)){
##   dir.sens <- file.path(dir.sensitivities, sens.list[imod])
##   # get forecast file with time-varying sigma, fixed catches, and benchmark year = 1916
##   file.copy(from = file.path(dir.mod, "forecast.ss"),
##             to   = file.path(dir.sens, "forecast.ss"),
##             overwrite = TRUE)
##   SS_changepars(dir = dir.sens,
##                 ctlfile = "BSKT2019_control.ss",
##                 newctlfile = "BSKT2019_control.ss",
##                 strings = "Eggs/kg_inter_Fem_GP_1",
##                 newvals = 1)
## }

## dirvec <- file.path(dir.sensitivities, sens.list)
## run_SS_models(dirvec=dirvec)
  
################################################################################
#### standard approach creating one directory at a time
################################################################################


# read model without printing stuff (assuming it's already been looked at)
out <- SS_output(dir.mod, verbose=FALSE, printstats=FALSE)


dir.sens <- file.path(dir.sensitivities, "sel1_all_asymptotic")
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

dir.sens <- file.path(dir.sensitivities, "sel2_all_dome")
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
run_SS_models(dir.sens)

# note: had to change init for LN(R0) to be 10 and phase to be 5 to avoid nan values
dir.sens <- file.path(dir.sensitivities, "sel3_no_fem_offset")
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
run_SS_models(dir.sens)

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
run_SS_models(dir.sens)

### ended here 3:15pm on 5/13/2019



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

dir.sens <- file.path(dir.sensitivities, "catch4_multiplier")
copy_SS_inputs(dir.old = dir.mod,
               dir.new = dir.sens,
               use_ss_new = FALSE,
               copy_exe = TRUE,
               copy_par = TRUE)

dir.sens <- file.path(dir.sensitivities, "catch5_constantF")
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


dir.sens <- file.path(dir.sensitivities, "misc2_DMtuning")
copy_SS_inputs(dir.old = dir.mod,
               dir.new = dir.sens,
               use_ss_new = FALSE,
               copy_exe = TRUE,
               copy_par = TRUE, overwrite=TRUE)

dir.sens <- file.path(dir.sensitivities, "misc3_DepletionIndex")
copy_SS_inputs(dir.old = dir.mod,
               dir.new = dir.sens,
               use_ss_new = FALSE,
               copy_exe = TRUE,
               copy_par = TRUE, overwrite=TRUE)

dir.sens <- file.path(dir.sensitivities, "rec1_recruit_devs")
copy_SS_inputs(dir.old = dir.mod,
               dir.new = dir.sens,
               use_ss_new = FALSE,
               copy_exe = TRUE,
               copy_par = TRUE)

dir.sens <- file.path(dir.sensitivities, "rec3_est_h")
copy_SS_inputs(dir.old = dir.mod,
               dir.new = dir.sens,
               use_ss_new = FALSE,
               copy_exe = TRUE,
               copy_par = TRUE)

dir.sens <- file.path(dir.sensitivities, "misc4_NoExtraSD")
copy_SS_inputs(dir.old = dir.mod,
               dir.new = dir.sens,
               use_ss_new = FALSE,
               copy_exe = TRUE,
               copy_par = TRUE)



} # end if(FALSE)
