### notes on retros, doing jitters, and making associated plots
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
#mod <- 'bigskate72_share_dome'
#mod <- 'bigskate74_spawnbio_3.30.13.02'
#mod <- 'bigskate82_base_May13'
mod <- 'bigskate99_new_prior_98percent_priorSD'
dir.mod <- file.path(dir.outer, mod)

# run retrospectives
# (default is to create a new directory "retrospectives" within masterdir
# and then fill that fill directorys with names like "retro-2")
SS_doRetro(masterdir = dir.mod, oldsubdir = "")

# make retro plot
legendlabels <- c("Base Model", paste("Data",-1:-5,"years"))

# retro North
# make time-series plots
retro.mods <- SSgetoutput(dirvec=file.path(dir.mod, 'retrospectives',
                              paste0("retro",0:-5)))
# replace one that had a bad Hessian
## retroMods.N[[6]] <- SS_output(file.path(YTdir.mods,
##                                         'retrospectives/retro.N/retro-5_nohess'))
retro.summary <- SSsummarize(retro.mods)
endyrvec <- retro.summary$endyrs + 0:-5
# general timeseries plots
SSplotComparisons(retro.summary, endyrvec=endyrvec, png=TRUE, indexUncertainty=TRUE,
                  #legendloc=c(0,0.4),
                  legendloc='top',
                  spacepoints=10000,
                  plot=FALSE,
                  plotdir=file.path(dir.mod, 'retrospectives'),
                  filenameprefix="retro_",
                  legendlabels=paste("Data",0:-5,"years"))
file.copy(file.path(dir.mod, 'retrospectives',
                    "retro_compare2_spawnbio_uncertainty.png"),
          file.path(dir.mod, '../../BigSkate_Doc/Figures',
                    "retro_compare2_spawnbio_uncertainty.png"),
          overwrite=TRUE)
# fits to indices
for(index in unique(retro.summary$indices$Fleet)){
  #index <- 5
  SSplotComparisons(retro.summary, endyrvec=endyrvec, png=TRUE, indexUncertainty=TRUE,
                    plotdir=file.path(dir.mod, 'retrospectives'),
                    subplot=11:12,indexfleets=index,
                    #indexPlotEach=TRUE,
                    legendloc='top',
                    filenameprefix="retro_", 
                    legendlabels=paste("Data",0:-5,"years"))
}
file.copy(file.path(dir.mod, 'retrospectives',
                    "retro_compare11_indices_flt5.png"),
          file.path(dir.mod, '../../BigSkate_Doc/Figures',
                    "retro_compare11_indices_flt5.png"),
          overwrite=TRUE)


##### jitter
# switch to allow file to be sourced for running the retros only
runjitter <- TRUE
# run jitter
if(runjitter){
  dir.jit <- file.path(dir.mod, "jitter")
  copy_SS_inputs(dir.old = dir.mod,
                 dir.new = dir.jit,
                 use_ss_new = TRUE,
                 copy_exe = TRUE,
                 copy_par = TRUE)
  jit.out <- SS_RunJitter(dir.jit, Njitter=100)
  save(jit.out, file = file.path(dir.mod, "jitter/jitter_results.Rdata"))
}


dir.mod <- 'c:/SS/skates/models/bigskate99_new_prior_98percent_priorSD'

# vector of total likelihood after estimation
likesaved <- rep(NA, 100)

# loop over jitter models
for(i in 1:100){
  # read first row of ParmTrace for each jitter
  file = file.path(dir.mod, "jitter", paste0("ParmTrace",i,".sso"))
  pars.i <- read.table(file, header = TRUE, nrows = 1, check.names = FALSE)

  # combine parameter values into a data.frame
  if(i == 1){
    pars <- pars.i
  }else{
    pars <- rbind(pars, pars.i)
  }

  # get total likelihood after estimation
  repfile <- file.path(dir.mod, "jitter", paste0("Report",i,".sso"))
  Rep.head <- readLines(repfile, n = 300)
  likelinenum <- grep("^LIKELIHOOD", Rep.head)
  likeline <- Rep.head[likelinenum]
  like <- as.numeric(substring(likeline, nchar("LIKELIHOOD") + 2))
  likesaved[i] <- like
}

# convert total likelihoods into a TRUE/FALSE if equal to MLE
likegood <- likesaved == min(likesaved)

# look at correlation between TRUE/FALSE values and MLE
cors <- cor(likegood, pars, use = "complete.obs")

range(cors, na.rm=TRUE)
## [1] -0.3182141  0.2577683
names(pars)[!is.na(cors) & abs(cors) > 0.2]
## [1] "VonBert_K_Fem_GP_1"                                       
## [2] "VonBert_K_Mal_GP_1"                                       
## [3] "Size_DblN_ascend_se_Fishery_current(1)"                   
## [4] "Retain_L_asymptote_logit_Fishery_current(1)_BLK2repl_2015"

