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
#mod <- 'bigskate74_spawnbio_3.30.13.02'
mod <- 'bigskate82_base_May13'

dir.mod <- file.path(dir.outer, mod)
# read model without printing stuff (assuming it's already been looked at)
out <- SS_output(dir.mod, verbose=FALSE, printstats=FALSE)

# estimated log(R0) value
out$parameters["SR_LN(R0)","Value"]
## 8.03426

# estimated M value
out$parameters["NatM_p_1_Fem_GP_1","Value"]
## 0.380586

# fixed h value
out$parameters["SR_BH_steep","Value"]
## 0.4

# estimated Q value
out$parameters["LnQ_base_WCGBTS(5)","Value"]
## -0.143787

# vector of log(R0) spanning estimates
# (going from high to low in case low value cause crashes)
#logR0vec <- seq(9, 7, -.25)
logR0vec <- seq(9.6, 7, -.2)

# vector of M
M.vec <- seq(0.2, 0.6, 0.05)

# vector of steepness
h.vec <- seq(0.3, 0.9, 0.1)

# vector of LnQ_base_WCGBTS
Q.vec <- seq(0.25, 2.5, 0.25)
lnQ.vec <- log(Q.vec)

if(FALSE){ # don't run all the stuff below if sourcing the file

####################################################################################
# run profiles
####################################################################################

##################################################################################
# log(R0) profiles
#source('c:/SS/skates/BigSkate_Doc/R/BigSkate_profiles.R')
dir.profile.R0 <- file.path(dir.mod, "profile.R0")
copy_SS_inputs(dir.old = dir.mod,
               dir.new = dir.profile.R0,
               use_ss_new = TRUE,
               copy_exe = TRUE,
               copy_par = TRUE)
start <- SS_readstarter(file = file.path(dir.profile.R0, "starter.ss"),
                        verbose = FALSE)
start$ctlfile <- "control_modified.ss"
start$prior_like <- 1 # include prior likelihood for non-estimated parameters
SS_writestarter(start, dir = dir.profile.R0, overwrite = TRUE)
SS_profile(dir = dir.profile.R0,
           masterctlfile = "BSKT2019_control.ss",
           newctlfile = "control_modified.ss",
           string = "SR_LN(R0)",
           profilevec = logR0vec,
           extras = "-nohess -nox")
           #extras = "-nox")

##################################################################################
# mortality profile
#source('c:/SS/skates/BigSkate_Doc/R/BigSkate_profiles.R')
dir.profile.M <- file.path(dir.mod, "profile.M")
copy_SS_inputs(dir.old = dir.mod,
               dir.new = dir.profile.M,
               use_ss_new = TRUE,
               copy_exe = TRUE,
               copy_par = TRUE)
start <- SS_readstarter(file = file.path(dir.profile.M, "starter.ss"),
                        verbose = FALSE)
start$ctlfile <- "control_modified.ss"
start$prior_like <- 1 # include prior likelihood for non-estimated parameters
SS_writestarter(start, dir = dir.profile.M, overwrite = TRUE)
SS_profile(dir = dir.profile.M,
           masterctlfile = "BSKT2019_control.ss",
           newctlfile = "control_modified.ss",
           string = "NatM_p_1_Fem_GP_1",
           profilevec = M.vec,
           #extras = "-nohess -nox")
           extras = "-nox")

##################################################################################
# steepness profile
#source('c:/SS/skates/BigSkate_Doc/R/BigSkate_profiles.R')
dir.profile.h <- file.path(dir.mod, "profile.h")
copy_SS_inputs(dir.old = dir.mod,
               dir.new = dir.profile.h,
               use_ss_new = TRUE,
               copy_exe = TRUE,
               copy_par = TRUE)
start <- SS_readstarter(file = file.path(dir.profile.h, "starter.ss"),
                        verbose = FALSE)
start$ctlfile <- "control_modified.ss"
start$prior_like <- 1 # include prior likelihood for non-estimated parameters
SS_writestarter(start, dir = dir.profile.h, overwrite = TRUE)
SS_profile(dir = dir.profile.h,
           masterctlfile = "BSKT2019_control.ss",
           newctlfile = "control_modified.ss",
           string = "steep",
           profilevec = h.vec,
           #extras = "-nohess -nox")
           extras = "-nox")

##################################################################################
# Q profile
#source('c:/SS/skates/BigSkate_Doc/R/BigSkate_profiles.R')
dir.profile.Q <- file.path(dir.mod, "profile.Q")
copy_SS_inputs(dir.old = dir.mod,
               dir.new = dir.profile.Q,
               use_ss_new = TRUE,
               copy_exe = TRUE,
               copy_par = TRUE)
start <- SS_readstarter(file = file.path(dir.profile.Q, "starter.ss"),
                        verbose = FALSE)
start$ctlfile <- "control_modified.ss"
start$prior_like <- 1 # include prior likelihood for non-estimated parameters
SS_writestarter(start, dir = dir.profile.Q, overwrite = TRUE)
SS_profile(dir = dir.profile.Q,
           masterctlfile = "BSKT2019_control.ss",
           newctlfile = "control_modified.ss",
           string = "LnQ_base_WCGBTS",
           profilevec = lnQ.vec,
           #extras = "-nohess -nox")
           extras = "-nox")




####################################################################################
### plotting profile results
####################################################################################

# R0 profile
dir.profile.R0 <- file.path(dir.mod, "profile.R0")
profilemodels <- SSgetoutput(dirvec=dir.profile.R0,
                             keyvec=1:length(logR0vec), getcovar=FALSE)
profilemodels$MLE <- out
profilesummary <- SSsummarize(profilemodels)

if(FALSE){
  # some explorations contributing to the text
  plot(as.numeric(profilesummary$pars[profilesummary$pars$Label == "NatM_p_1_Fem_GP_1",1:8]),
       as.numeric(profilesummary$pars[profilesummary$pars$Label == "SR_LN(R0)",1:8]))
  cor(as.numeric(profilesummary$pars[profilesummary$pars$Label == "NatM_p_1_Fem_GP_1",1:8]),
       as.numeric(profilesummary$pars[profilesummary$pars$Label == "SR_LN(R0)",1:8]))
}

goodmodels <- which(profilesummary$likelihoods[1,1:(length(logR0vec)+1)] < 1e5)
# plot profile using summary created above
SSplotProfile(profilesummary,           # summary object
              minfraction = 0.01,
              #models = 1:length(logR0vec), # optionally exclude MLE
              models = goodmodels,
              sort.by.max.change = FALSE,
              #xlim=c(3.2,4.6),
              ymax=4, # modify as required to get reasonable scale to see differences
              legendloc='top',
              plotdir = dir.profile.R0,
              print = TRUE,
              profile.string = "R0", # substring of profile parameter
              profile.label = "Log of unfished equilibrium recruitment, log(R0)") # axis label
# copy plot with generic name to main folder with more specific name
file.copy(file.path(dir.profile.R0, 'profile_plot_likelihood.png'),
          file.path(dir.profile.R0, 'profile_logR0.png'), overwrite=TRUE)

# Piner Plot showing influence of age comps by fleet
PinerPlot(profilesummary,           # summary object
          component="Age_like",
          main="Changes in age-composition likelihoods by fleet",
          minfraction = 0.0001,
          models=goodmodels,
          #xlim=c(3.2,4.6),
          #ymax=4,
          plotdir=dir.profile.R0,
          print=TRUE,
          profile.string = "R0", # substring of profile parameter
          profile.label="Log of unfished equilibrium recruitment, log(R0)") # axis label
# copy plot with generic name to main folder with more specific name
file.copy(file.path(dir.profile.R0, 'profile_plot_likelihood.png'),
          file.path(dir.profile.R0, 'profile_age-comp_logR0.png'), overwrite=TRUE)

# Piner Plot showing influence of indices by fleet
PinerPlot(profilesummary,           # summary object
          component="Surv_like",
          main="Changes in index likelihoods by fleet",
          minfraction = 0.0001,
          models=goodmodels,
          #xlim=c(3.2,4.6),
          #ymax=4,
          plotdir=dir.profile.R0,
          print=TRUE,
          profile.string = "R0", # substring of profile parameter
          profile.label="Log of unfished equilibrium recruitment, log(R0)") # axis label
# copy plot with generic name to main folder with more specific name
file.copy(file.path(dir.profile.R0, 'profile_plot_likelihood.png'),
          file.path(dir.profile.R0, 'profile_indices_logR0.png'), overwrite=TRUE)

# Piner Plot showing influence of length comp by fleet
PinerPlot(profilesummary,           # summary object
          component="Length_like",
          main="Changes in length-composition likelihoods by fleet",
          minfraction = 0.0001,
          models=goodmodels,
          #xlim=c(3.2,4.6),
          #ymax=4,
          plotdir=dir.profile.R0,
          print=TRUE,
          profile.string = "R0", # substring of profile parameter
          profile.label="Log of unfished equilibrium recruitment, log(R0)") # axis label
# copy plot with generic name to main folder with more specific name
file.copy(file.path(dir.profile.R0, 'profile_plot_likelihood.png'),
          file.path(dir.profile.R0, 'profile_len-comp_logR0.png'), overwrite=TRUE)

SSplotComparisons(profilesummary, subplot=1, models=goodmodels,
                  legendlabels=c(paste0("log(R0)=",logR0vec),"Base Model")[goodmodels],
                  plot=FALSE, png=TRUE, plotdir=file.path(dir.profile.R0),
                  filenameprefix="profile_R0_", legendloc="bottomleft")

##################################################################################
# Mortality profile
dir.profile.M <- file.path(dir.mod, "profile.M")

profilemodels <- SSgetoutput(dirvec=dir.profile.M,
                             keyvec=1:length(M.vec), getcovar=FALSE)
# add MLE to set of models being plotted
profilemodels$MLE <- out

# summarize output
profilesummary <- SSsummarize(profilemodels)
# filter models for those with reasonable likelihoods
# and cutting off those below 0.25
goodmodels <- which(profilesummary$likelihoods[1,1:(length(logR0vec)+1)] < 1e5 &
                    M.vec >= 0.25)

# make plot
SSplotProfile(profilesummary,           # summary object
              minfraction = 0.001,
              print=TRUE,
              models=goodmodels,
              ymax=20,
              sort.by.max.change = FALSE,
              plotdir=dir.profile.M,
              profile.string = "NatM_p_1_Fem_GP_1", # substring of profile parameter
              profile.label="Natural mortality (M)") # axis label
# copy plot with generic name to main folder with more specific name
file.copy(file.path(dir.profile.M, 'profile_plot_likelihood.png'),
          file.path(dir.profile.M, 'profile_M.png'), overwrite=TRUE)

# compare spawning biomass time series
SSplotComparisons(profilesummary, subplot=1,
                  models=goodmodels,
                  legendlabels=c(paste0("M=",M.vec),"Base Model")[goodmodels],
                  png=TRUE, plotdir=dir.profile.M,
                  filenameprefix="profile_M_", legendloc="topright")

##################################################################################
# Steepness profile
dir.profile.h <- file.path(dir.mod, "profile.h")
## # ironic problem with convergence for the h = 0.4 case
## file.copy(file.path(dir.profile.h, "../Report.sso"),
##           file.path(dir.profile.h, "Report2.sso"),
##           overwrite = TRUE)
## file.copy(file.path(dir.profile.h, "../CompReport.sso"),
##           file.path(dir.profile.h, "CompReport2.sso"),
##           overwrite = TRUE)
## file.copy(file.path(dir.profile.h, "../covar.sso"),
##           file.path(dir.profile.h, "covar2.sso"),
##           overwrite = TRUE)
profilemodels <- SSgetoutput(dirvec=dir.profile.h,
                             keyvec=1:length(h.vec), getcovar=FALSE)
# summarize output
profilesummary <- SSsummarize(profilemodels)
# make plot
SSplotProfile(profilesummary,           # summary object
              minfraction = 0.001,
              print=TRUE,
              sort.by.max.change = FALSE,
              plotdir=dir.profile.h,
              profile.string = "steep", # substring of profile parameter
              profile.label="Stock-recruit steepness (h)") # axis label
# copy plot with generic name to main folder with more specific name
file.copy(file.path(dir.profile.h, 'profile_plot_likelihood.png'),
          file.path(dir.profile.h, 'profile_h.png'), overwrite=TRUE)
# compare spawning biomass time series
labels <- paste0("h=",h.vec)
h.base <- out$parameters["SR_BH_steep", "Value"]
labels[h.vec==h.base] <- paste(labels[h.vec==h.base], "(Base Model)")
SSplotComparisons(profilesummary, subplot=1,
                  legendlabels=labels,
                  png=TRUE, plotdir=dir.profile.h,
                  filenameprefix="profile_h_", legendloc="bottomleft")



##################################################################################
# Q profile
dir.profile.Q <- file.path(dir.mod, "profile.Q")
profilemodels <- SSgetoutput(dirvec=dir.profile.Q,
                             keyvec=1:length(Q.vec), getcovar=FALSE)
profilemodels$MLE <- out
# summarize output
profilesummary <- SSsummarize(profilemodels)
# make plot
goodmodels <- c(which(profilesummary$likelihoods[1,1:length(Q.vec + 1)] < 1e5 &
                        Q.vec >= 0.5 & Q.vec <= 2),
                which(names(profilemodels) == "MLE"))

png('c:/SS/skates/BigSkate_Doc/Figures/profile_Q.png', 
    width=6.5, height=5, res=300, units='in')
tmp <- SSplotProfile(profilesummary,           # summary object
                     minfraction = 0.001,
                     print=FALSE,
                     models=goodmodels,
                     ymax=10,
                     legendloc='top',
                     sort.by.max.change = FALSE,
                     plotdir=dir.profile.Q,
                     profile.string = "LnQ_base_WCGBTS", # substring of profile parameter
                     profile.label="Log of WCGBT Survey catchability, log(q)") # axis label
axis(3, at=log(Q.vec), lab = Q.vec)
mtext(side = 3, line=2.5, text = "WCGBT Survey catchability, q")
dev.off()

## # copy plot with generic name to main folder with more specific name
## file.copy(file.path(dir.profile.Q, 'profile_plot_likelihood.png'),
##           file.path(dir.profile.Q, 'profile_Q.png'), overwrite=TRUE)


### make alternative version with no prior
profilesummary2 <- profilesummary
# removing the Q likelihood contributions
likes <- profilesummary2$likelihoods
for(imod in 1:length(profilemodels)){
  # catchability prior likelihood  
  Pr_Like <- profilemodels[[imod]]$parameters["LnQ_base_WCGBTS(5)","Pr_Like"]
  likes[likes$Label == "Parm_priors", imod] <-
    likes[likes$Label == "Parm_priors", imod] - Pr_Like
  likes[likes$Label == "TOTAL", imod] <-
    likes[likes$Label == "TOTAL", imod] - Pr_Like
}
profilesummary2$likelihoods <- likes

png('c:/SS/skates/BigSkate_Doc/Figures/profile_Q_noprior.png', 
    width=6.5, height=5, res=300, units='in')
tmp2 <- SSplotProfile(profilesummary2,           # summary object
                      minfraction = 0.001,
                      print=FALSE,
                      models=goodmodels,
                      ymax=2,
                      legendloc='top',
                      sort.by.max.change = FALSE,
                      plotdir=dir.profile.Q,
                      profile.string = "LnQ_base_WCGBTS", # substring of profile parameter
                      profile.label="Log of WCGBT Survey catchability, log(q)") # axis label
axis(3, at=log(Q.vec), lab = Q.vec)
mtext(side = 3, line=2.5, text = "WCGBT Survey catchability, q")
dev.off()


# Piner Plot showing influence of length comp by fleet
tmp3 <- PinerPlot(profilesummary,           # summary object
                  component="Length_like",
                  main="Changes in length-composition likelihoods by fleet",
                  minfraction = 0.0001,
                  models=goodmodels,
                  #xlim=c(3.2,4.6),
                  #ymax=4,
                  plotdir=dir.profile.Q,
                  print=TRUE,
                  profile.string = "LnQ_base_WCGBTS", # substring of profile parameter
                  profile.label="Log of WCGBT Survey catchability, log(q)") # axis label
# copy plot with generic name to main folder with more specific name
file.copy(file.path(dir.profile.Q, 'profile_plot_likelihood.png'),
          file.path(dir.profile.Q, 'profile_len-comp_logQ.png'), overwrite=TRUE)



# compare spawning biomass time series
labels <- c(paste0("log(q)=",round(lnQ.vec,2),", q=",Q.vec), "Base Model, q=0.81")
## lnQ.base <- out$parameters["LnQ_base_WCGBTS", "Value"]
## labels[lnQ.vec==h.base] <- paste(labels[lnQ.vec==lnQ.base], "(Base Model)")
SSplotComparisons(profilesummary, subplot=1,
                  legendlabels=labels[goodmodels],
                  models=goodmodels,
                  png=TRUE, plotdir=dir.profile.Q,
                  filenameprefix="profile_Q_", legendloc="bottomleft")
# copy plot with generic name to main folder with more specific name
file.copy(file.path(dir.profile.Q, 'profile_plot_likelihood.png'),
          file.path(dir.profile.Q, 'profile_Q.png'), overwrite=TRUE)

plot(exp(as.numeric(profilesummary$pars[profilesummary$pars$Label=="LnQ_base_WCGBTS(5)",1:11])),
     as.numeric(profilesummary$pars[profilesummary$pars$Label=="SR_LN(R0)",1:11]))

dir.profile.R0 <- file.path(dir.mod, "profile.R0")
profilemodels.R0 <- SSgetoutput(dirvec=dir.profile.R0,
                                keyvec=1:length(logR0vec), getcovar=FALSE)
profilemodels.R0$MLE <- out
profilesummary.R0 <- SSsummarize(profilemodels.R0)

points(exp(as.numeric(profilesummary.R0$pars[profilesummary.R0$pars$Label=="LnQ_base_WCGBTS(5)",1:11])),
       as.numeric(profilesummary.R0$pars[profilesummary.R0$pars$Label=="SR_LN(R0)",1:11]),
       col=2)


} # end if(FALSE) section that doesn't get sourced
