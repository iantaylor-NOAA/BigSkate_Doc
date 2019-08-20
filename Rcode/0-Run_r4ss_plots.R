### Run r4ss and notes for making model comparison plots and editing plots
### Originally developed for the 2015 China Rockfish assessment document, 
### which had three independent assessment models (South of 40-10, 
### 40-10 through OR, and WA). Written for up to 3 assessment models
### Even if you only have 1 assessment model, it will be called mod1 throughout
### 
### Section 1: run r4ss and create plots
###
### Section 2: has the code for multiple model plot comparisons 
### Edit Section 2 script based on your needs
### Don't source this code, unless you've made all necessary edits
###
### Section 3: save the entire myreplist and mod_structure files from r4ss as csv's
# =============================================================================

# start fresh here - this script is separate from the script for the assessment
# document
rm(list=ls(all=TRUE))


# define directory on a specific computer
if(Sys.info()["user"] == "Ian.Taylor"){
  setwd('c:/SS/skates/BigSkate_Doc/')
}

# SECTION1: Run r4ss, parse plotInfoTable.csv file, & add linebreaks to SS files

# stop("\n  This file should not be sourced!") # note to stop from accidental sourcing

# Here we're going to make sure you have all the required packages for the template
# Check for installtion and make sure all R libraries can be loaded
# xtable for creating tables, ggplot2 for plotting, reshape2 for melting
# dataframes, scales for printing percents
# You may have to manually install knitr - reason unknown!

requiredPackages = c('xtable', 'ggplot2', 'reshape2', 'scales', 
                     'rmarkdown', 'knitr', 'devtools')

for(p in requiredPackages){
  if(!require(p,character.only = TRUE)) install.packages(p)
  library(p,character.only = TRUE)
}

# Install the latest version of r4ss using devtools
#devtools::install_github("r4ss/r4ss")
library(r4ss)

# CHANGE values in this section ===============================================

# number of assessment models - this is run before the R_preamble.R, which also
# contains this value
 n_models = 1
 

# By default, you can only work in the directory containing the project
# Set the directory here if you're getting errors
# setwd('C:/Assessment_template')


# Give the names of the data and control files, for each model
# Used in the SS_files_linebreaks.R
mod1_dat =  'BSKT2019_data.ss'  
mod2_dat =  ''
mod3_dat =  ''

# Control file names 
mod1_ctrl = 'BSKT2019_control.ss' 
mod2_ctrl = ''
mod3_ctrl = ''

# =============================================================================

# set input and output directories
input.dir = file.path(getwd(), 'SS')
output.dir = file.path(getwd(), 'r4ss')

# IF the r4SS subdirectories don't exist, create them
# Once you have your own SS files and want to save these plots
# Uncomment the /r4SS/ in the .gitignore file
dir.create(file.path(output.dir,'plots_mod1'))
#dir.create(file.path(output.dir,'plots_mod2'))
#dir.create(file.path(output.dir,'plots_mod3'))


# BEGIN r4ss===================================================================
# REMOVE OLD r4SS OUTPUT!!!!! -------------------------------------------------
# Run this deliberately - it deletes the r4SS output plots files
do.call(file.remove, list(list.files(file.path(output.dir, 'plots_mod1'),    full.names=TRUE)))
#do.call(file.remove, list(list.files(file.path(output.dir, 'plots_mod2'),    full.names=TRUE)))
#do.call(file.remove, list(list.files(file.path(output.dir, 'plots_mod3'),    full.names=TRUE)))
#do.call(file.remove, list(list.files(file.path(output.dir, 'plots_compare'), full.names=TRUE)))

# Run r4ss for each model - **CHANGE DIRECTORY if necessary**
               mod1 = SS_output(dir = file.path(input.dir,'Base_model1'))
if(n_models>1){mod2 = SS_output(dir = file.path(input.dir,'Base_model2'))}
if(n_models>2){mod3 = SS_output(dir = file.path(input.dir,'Base_model3'))}

# Save the workspace an image
save.image('./r4ss/SS_output.RData')

# read data file
mod1dat <- SS_readdat_3.30(file = file.path(input.dir,'Base_model1', mod1_dat))


# =============================================================================
# RUN r4ss plots for each model

# output directories
out.dir.mod1 = file.path(output.dir,'plots_mod1')
#out.dir.mod2 = file.path(output.dir,'plots_mod2')
#out.dir.mod3 = file.path(output.dir,'plots_mod3')

# fleetnames for catch plot
fleetnames_catch <- c("Fishery (current)",
                      "Discard (historical)",
                      "Fishery (historical)",
                      "Fishery (tribal)",
                      "WCGBTS",
                      "Triennial")
# fleetnames for all other plots
fleetnames1 <- c("Fishery",
                 "Discard (historical)",
                 "Fishery (historical)",
                 "Fishery (tribal)",
                 "WCGBT Survey",
                 "Triennial Survey")

# Model 1
SS_plots(mod1,
         fleetnames = fleetnames1,
         png = TRUE,
         html = FALSE,
         datplot = TRUE,
         uncertainty = TRUE,
         maxrows = 5, 
         maxcols = 5, 
         maxrows2 = 4, 
         maxcols2 = 4, 
         printfolder = '', 
         dir = out.dir.mod1)

# remake catch plot with alternative names for the fleets
SS_plots(mod1,
         fleetnames = fleetnames_catch,
         plot = 7,
         png = TRUE,
         html = FALSE,
         printfolder = '', 
         dir = out.dir.mod1)

# remake length-comp multi-fleet plots to be taller
SS_plots(mod1,
         fleetnames = fleetnames1,
         plot = 13,
         pheight = 6.5,
         bub.scale.dat = 6,
         png = TRUE,
         html = FALSE,
         printfolder = 'tall_length_comp_plots', 
         dir = out.dir.mod1)
# rename file to match expectation
file.copy(from = file.path(out.dir.mod1,
              'tall_length_comp_plots/comp_lendat__multi-fleet_comparison.png'),
          to = file.path(out.dir.mod1, 'comp_lendat__multi-fleet_comparison.png'),
          overwrite = TRUE)
SS_plots(mod1,
         fleetnames = fleetnames1,
         plot = 16,
         pheight = 6.5,
         png = TRUE,
         html = FALSE,
         printfolder = 'tall_length_comp_plots', 
         dir = out.dir.mod1)
# rename file to match expectation
file.copy(from = file.path(out.dir.mod1,
              'tall_length_comp_plots/comp_lenfit__multi-fleet_comparison.png'),
          to = file.path(out.dir.mod1, 'comp_lenfit__multi-fleet_comparison.png'),
          overwrite = TRUE)

# rename a time series plot to match expected name
# (probably not necessary any more)
file.copy(from = file.path(out.dir.mod1, 'ts9_unfished_with_95_asymptotic_intervals_intervals.png'),
          to = file.path(out.dir.mod1, 'ts9_Spawning_depletion_with_95_asymptotic_intervals_intervals.png'))

png('Figures/fit_to_priors.png', width=6.5, height=4, units='in',
    res=300, pointsize=10)
par(mfrow=c(1,2))
SSplotPars(mod1,
           strings=c("NatM","LnQ_base_WCGBTS"), nrows=1, ncols=2,
           newheader=c("Natural mortality (M)", "WCGBT Survey catchability (Q)"),
           new=FALSE)
dev.off()


# get retention values
tmp <- SSplotSelex(mod1, fleets=1, sizefactors="Ret", years=2002:2018,
                   subplot=1)
tmp$infotable$col <- rich.colors.short(15, alpha=0.7)
tmp$infotable$pch <- NA
tmp$infotable$lty <- 1
tmp$infotable$longname <- tmp$infotable$Yr_range
tmp$infotable$longname[1] <- gsub(1916, 1995, tmp$infotable$longname[1])

# make plot of time-varying retention
png('Figures/retention.png', width=6.5, height=4, units='in',
    res=300, pointsize=9)
par(mfrow=c(1,2), mar=c(4,4,1,1))

SSplotSelex(mod1, fleets=1, sizefactors="Ret", showmain=FALSE,
            labels = c("Length (cm)", 
                "Age (yr)", "Year", "Retention", "Retention", "Discard mortality"),
            years=2002:2018, subplot=1, infotable=tmp$infotable)

sub <- mod1$sizeselex[mod1$sizeselex$Factor=="Ret" & mod1$sizeselex$Fleet==1 &
                       mod1$sizeselex$Yr <=2018 & mod1$sizeselex$Sex == 1, ]
plot(sub$Yr, sub$"252.5", xlim=c(2002, 2018.1), ylim=c(0,1), yaxs='r', lwd=2, type='l',
     pch=16, cex=.8,
     xlab = "Year", ylab="Asymptotic retention rate", las=1, col='grey70', axes=FALSE)
abline(h=c(0,1), col='grey')
points(x = 2004:2018, y = as.numeric(sub[sub$Yr %in% 2004:2018, "252.5"]),
       col = rich.colors.short(15, alpha=0.9), pch=16)
axis(1, at=2004:2018)
axis(2, at=seq(0,1,.2))
box()
dev.off()

### write tables of catch for exec summary (forecast values are from a different model)
mod.forecast <- SS_output(dir = file.path(input.dir,'Base_model1_forecast'))

yrs.forecast <- 2019:2030
Landings <- (mod.forecast$timeseries$"retain(B):_1" +
               mod.forecast$timeseries$"retain(B):_4")[mod.forecast$timeseries$Yr %in% yrs.forecast]
EstCatch <- (mod.forecast$timeseries$"dead(B):_1" +
               mod.forecast$timeseries$"dead(B):_4")[mod.forecast$timeseries$Yr %in% yrs.forecast]
OFL <- mod.forecast$derived_quants[paste0("OFLCatch_", yrs.forecast), "Value"]
ACL <- mod.forecast$derived_quants[paste0("ForeCatch_", yrs.forecast), "Value"]
OFL[1:2] <- 541
ACL[1:2] <- 494

#Stock,Landings,EstCatch,OFL,ACL
Exec_basemodel_summary <- data.frame(Stock = yrs.forecast,
                                     Landings = Landings,
                                     EstCatch = EstCatch,
                                     OFL = OFL,
                                     ACL = ACL)
write.csv(Exec_basemodel_summary, "./txt_files/Exec_basemodel_summary.csv",
          row.names=FALSE)

### management history
mngmnt <- read.csv('./txt_files/Exec_mngmt_performance.csv')

yrs <- 2009:2018
Landings <- (mod1$timeseries$"retain(B):_1" +
               mod1$timeseries$"retain(B):_4")[mod1$timeseries$Yr %in% yrs]
EstCatch <- (mod1$timeseries$"dead(B):_1" +
               mod1$timeseries$"dead(B):_4")[mod1$timeseries$Yr %in% yrs]
mngmnt$Catch <- c(Landings, NA, NA)
mngmnt$TotMort <- c(round(EstCatch,1), NA, NA)

write.csv(mngmnt, file='./txt_files/Exec_mngmt_performance.csv', row.names=FALSE)
###

# -----------------------------------------------------------------------------

# Run the code to parse the plotInfoTable files
source('./Rcode/Parse_r4ss_plotInfoTable.R')

# -----------------------------------------------------------------------------

# Create the SS files for the appendices
source('./Rcode/SS_files_linebreaks.R')

# =============================================================================
# END SECTION 1================================================================
# =============================================================================
# =============================================================================



# # SECTION 2: COMPARISON PLOTS ACROSS MODELS ===================================
# # IT it not recommended to blindly run this section.  You'll need to change names,
# # possibly margins, etc!!!
# 
# 
# if(n_models > 1){
# 
#  # if you need to reload the workspace
#  load("./r4ss/SS_output.RData")
#   
#  # create base model summary list
#  out.mod1 = mod1
#  out.mod2 = mod2
# if(n_models==3) {out.mod3 = mod3}
#      
#  
# # base.summary <-  SSsummarize(list(out.mod1, out.mod2))
#  
#  
#  base.summary <-  if (n_models==2) {SSsummarize(list(out.mod1, out.mod2))} else
#                    {SSsummarize(list(out.mod1, out.mod2 , out.mod3))}
#     
#  # save results to this comparison directory  
#  dir.create(file.path(output.dir,'plots_compare'))
#  dir.compare.plots <- file.path(getwd(),'/r4ss/plots_compare') 
#     
#  # vector of names and colors models as defined
#  mod.names <- c("WA","CA","OR")
#  mod.cols  <- c("blue", "purple", "red")
# } # end n_models if
# 
# 
# 
# 
# # Time series comparison plots for exec summary -------------------------------
# # These plots are repeated with regular plots
# SSplotComparisons(base.summary, 
#                   plot = FALSE, 
#                   print = TRUE, 
#                   plotdir = dir.compare.plots,
#                   spacepoints = 20,  # years between points on each line
#                   initpoint = 0,     # "first" year of points (modular arithmetic)
#                   staggerpoints = 0, # points aligned across models
#                   endyrvec = 2015,   # final year to show in time series
#                   legendlabels = mod.names, 
#                   filenameprefix = "base_", 
#                   col = mod.cols)
# 
# SSplotComparisons(base.summary, 
#                   plot = FALSE, 
#                   print = TRUE, 
#                   plotdir = dir.compare.plots,
#                   subplot = 1:10,
#                   spacepoints = 20,  # years between points on each line
#                   initpoint = 0,     # "first" year of points (modular arithmetic)
#                   staggerpoints = 0, # points aligned across models
#                   endyrvec = 2025,   # final year to show in time series
#                   legendlabels = mod.names, 
#                   filenameprefix = "forecast_", 
#                   col = mod.cols)
#   
#   
#   
# # Plot comparison of growth curves --------------------------------------------
# png(file.path(dir.compare.plots, 'growth_comparison.png'),
#     width = 6.5, 
#     height = 5, 
#     res = 300, 
#     units = 'in')
# 
# SSplotBiology(out.mod1, 
#               colvec = c(mod.cols[1], NA, NA), 
#               subplot = 1)
#       
# SSplotBiology(out.mod2, 
#               colvec = c(mod.cols[2], NA, NA),
#               subplot = 1, 
#               add = TRUE)
#       
# if(n_models>2){
#   SSplotBiology(out.mod3, 
#               colvec = c(mod.cols[3], NA, NA), 
#               subplot = 1, 
#               add = TRUE)
# }
# 
# # legend to cover up non-useful Females/Males default legend
# legend('topleft', legend = mod.names, col = mod.cols, lwd = 3, bg = 'white')
#  
# # close PNG file
# dev.off()
# 
# 
# # Plot comparison of yield curves ---------------------------------------------
# png(file.path(dir.compare.plots, 'yield_comparison_n_models.png'),
#     width = 6.5, 
#     height = 6.5, 
#     res = 300, 
#     units = 'in', 
#     pointsize = 10)
# par(las = 1)
# 
# 
# if(n_models==2){
#   SSplotYield(out.mod2, col = mod.cols[2], subplot = 1)
#   grid()
#   SSplotYield(out.mod1, col = mod.cols[1], subplot = 1, add = TRUE)
# }
# 
# if(n_models==3){
#   SSplotYield(out.mod3, col = mod.cols[3], subplot = 1)
#   grid()
#   SSplotYield(out.mod2, col = mod.cols[2], subplot = 1, add = TRUE)
#   SSplotYield(out.mod1, col = mod.cols[1], subplot = 1, add = TRUE)
#   
# }
# 
# 
# # legend to cover up non-useful Females/Males default legend
# legend('topright', legend = mod.names, col = mod.cols, lwd = 3, bg = 'white', bty = 'n')
# 
# # close PNG file
# dev.off()
# 
# # =============================================================================
# # END SECTION 2================================================================
# # =============================================================================
# 
# 
# 
# 
# # =============================================================================
# # Section 3: saves entire myreplist and mod_structure files 
# # writes the entire myreplist and mod structure to a file
# # useful if you need to find a particular variable r4ss creates
# # change model and directory
# 
# #sink("./r4ss/plots_mod1/list_of_dataframes.csv", type="output")
# #invisible(lapply(mod1, function(x) dput(write.csv(x))))
# #sink()
# 
# #sink("./r4ss/plots_mod1/mod_structure.csv", type="output")
# #invisible(str(mod1,list.len = 9999))
# #sink()
