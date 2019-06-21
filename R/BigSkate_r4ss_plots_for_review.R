require(r4ss)

## source('c:/SS/skates/BigSkate_Doc/R/BigSkate_functions.R')
## getbs(82)

mod1 <- SS_output('C:/SS/skates/models/clean_pre-STAR_inputs',
                  printstats=FALSE, verbose=FALSE)

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
         html = TRUE,
         maxrows = 5, 
         maxcols = 5, 
         maxrows2 = 4, 
         maxcols2 = 4,
         printfolder = 'plots')

SS_plots(mod1,
         plot = 20,
         fleetnames = fleetnames1,
         html = TRUE,
         maxrows = 1, 
         maxcols = 1, 
         printfolder = 'plots')

# fix html caption for 
plot.dir <- file.path(mod1$inputs$dir, 'plots')
csv.files <- dir(plot.dir, full.names = TRUE, pattern=".csv$")
small.file <- csv.files[file.info(csv.files)$size == min(file.info(csv.files)$size)]
info <- read.csv(small.file, stringsAsFactors = FALSE)
info$caption[1] <- "Mean length at age, WCGBT Survey. These data are excluded from the likelihood and used for comparison purposes only. All age data from the survey (2009, 2010, 2016, 2017, and 2018) were aggregated and arbitrarily assigned to 2011 for comparison to the expected mean length-at-age in a single year."
write.csv(info, file=small.file, row.names = FALSE)
SS_html(mod1, plotdir=plot.dir)

SS_plots(mod1,
         fleetnames = fleetnames1,
         html = TRUE,
         pwidth = 5.2,
         pheight = 4,
         maxrows = 5, 
         maxcols = 5, 
         maxrows2 = 4, 
         maxcols2 = 4,
         printfolder = 'plots_for_presentation')

SS_plots(mod1,
         plot = 20,
         pwidth = 5.2,
         pheight = 4,
         fleetnames = fleetnames1,
         html = TRUE,
         maxrows = 1, 
         maxcols = 1, 
         printfolder = 'plots_for_presentation')

SS_plots(mod1,
         plot = 24,
         pwidth = 5.2,
         pheight = 5,
         fleetnames = fleetnames1,
         html = TRUE,
         maxrows = 1, 
         maxcols = 1, 
         printfolder = 'plots_for_presentation')

SS_plots(mod1,
         plot = 16,
         pwidth = 5.2,
         pheight = 5,
         fleetnames = fleetnames1,
         showsampsize = FALSE,
         showeffN = FALSE,
         html = FALSE,
         printfolder = 'plots_for_presentation')


SSplotComps(bs82, kind="L@A", fleets=5, sexes=1, maxcols=1, maxrows=1, add=TRUE)
SSplotComps(bs82, kind="L@A", fleets=5, sexes=2, maxcols=1, maxrows=1, add=TRUE)

SS_plots(bs82bio3,
         plot = 16,
         pwidth = 5.2,
         pheight = 5,
         fleetnames = fleetnames1,
         showsampsize = FALSE,
         showeffN = FALSE,
         html = FALSE,
         printfolder = 'plots')

source('c:/SS/skates/BigSkate_Doc/R/make_multifig2.R')
source('c:/SS/skates/BigSkate_Doc/R/SSplotComps.R')

mean_len_at_age_plots <- function(mod = bs99,
                                  filename = 'mean_length_at_age.png'){
  png(file.path('c:/SS/skates/BigSkate_Doc/Figures/', filename),
      res=300, units='in', pointsize=10, width=5.2, height=5.2)
  par(mar = c(4,4,4,4))
  plot(0, type='n', xlim=c(0,15), ylim=c(0,200),
       yaxs='i', xlab="Age (yr)", ylab="Length (cm)",
       main="Mean length at age from WCGBT Survey (all years combined)")
  scale <- .3
  grid()
  ladbaseF <- mod$ladbase[mod$ladbase$Sex == 1 & mod$ladbase$N > 0,]
  ladbaseM <- mod$ladbase[mod$ladbase$Sex == 2 & mod$ladbase$N > 0,]
  points(ladbaseM$Bin, ladbaseM$Obs, pch=21, cex=scale*sqrt(ladbaseM$N),
         bg=rgb(0,0,1,.5), type='o', lty=3)
  points(ladbaseF$Bin, ladbaseF$Obs, pch=21, cex=scale*sqrt(ladbaseF$N),
         bg=rgb(1,0,0,.5), type='o', lty=3)
  lines(ladbaseM$Bin, ladbaseM$Exp, col=rgb(0,0,1,.5), lwd=2)
  lines(ladbaseF$Bin, ladbaseF$Exp, col=rgb(1,0,0,.5), lwd=2)

  axis(4, at=106.9, col=4)
  axis(4, at=148.2, col=2)
  mtext(side=4, line=2, "Length at 50% maturity", adj=.7)
  
  legend(x = 0,
         y = 200,
         bty = 'n',
         pch=21,
         col=1,
         legend = c("      Female observation",
             "      Male observation"),
         pt.bg=c(rgb(1,0,0,.5), rgb(0,0,1,.5)),
         pt.cex=2)
  legend(x = 0,
         y = 180,
         bty = 'n',
         lty=1,
         lwd=2,
         legend = c("Female estimate",
             "Male estimate"),
         col=c(rgb(1,0,0,.5), rgb(0,0,1,.5)))
  legend(x = 0,
         y = 162,
         bty = 'n',
         fill=gray(0,0.5),
         legend = c("    Sample size"))
  scale <- 0.1
  width <- 0.4
  for(a in 0:15){
    ## rect(a-width, 0, a, scale*ladbaseF$N[ladbaseF$Bin == a], col=rgb(1,0,0,.5))
    ## rect(a+width, 0, a, scale*ladbaseM$N[ladbaseF$Bin == a], col=rgb(0,0,1,.5))
    NF <- ladbaseF$N[ladbaseF$Bin == a]
    NM <- ladbaseM$N[ladbaseF$Bin == a]
    N <- sum(NF, NM, na.rm = TRUE)
    rect(a-width, 0,
         a+width, scale*N,
         col=gray(0,.5))
    text(N, x=a, y=scale*N, pos=3)
  }
  dev.off()
}

mean_len_at_age_plots()
mean_len_at_age_plots(bs99bio3, filename='mean_length_at_age_vonB.png')

mean_len_at_age_plots2 <- function(mod=bs99, filename='mean_length_vs_growth_curve.png'){
  png(file.path('c:/SS/skates/BigSkate_Doc/Figures/', filename),
      res=300, units='in', pointsize=10, width=5.2, height=5.2)
  par(mar = c(4,4,4,4))
  SSplotBiology(mod, subplot=1)
  scale <- .3
  ladbaseF <- mod$ladbase[mod$ladbase$Sex == 1 & mod$ladbase$N > 0,]
  ladbaseM <- mod$ladbase[mod$ladbase$Sex == 2 & mod$ladbase$N > 0,]
  points(ladbaseM$Bin + 0.5, ladbaseM$Obs, pch=21, cex=scale*sqrt(ladbaseM$N),
         bg=rgb(0,0,1,.5), type='o', lty=3)
  points(ladbaseF$Bin + 0.5, ladbaseF$Obs, pch=21, cex=scale*sqrt(ladbaseF$N),
         bg=rgb(1,0,0,.5), type='o', lty=3)
  dev.off()
}
mean_len_at_age_plots2()
mean_len_at_age_plots2(bs99bio3, filename='mean_length_vs_growth_curve_vonB.png')


png('c:/SS/skates/BigSkate_Doc/Figures/BigSkate_catch_plot_6-3-2019.png',
    res=300, units='in', width=6.5, height=5, pointsize=10)
# discards vs. dead vs. selected
fleetcols3 <-
  fleetcols2 <-
    fleetcols1 <- rich.colors.short(5)[-1]
fleetcols2[1] <- rgb(0.4,0.6,1)
fleetcols3[1] <- rgb(0.7,0.8,1)
SSplotCatch(bs82, subplot=5, fleetcols = fleetcols3, addmax=FALSE, labels=rep("",10))
SSplotCatch(bs82, subplot=16, add=TRUE, fleetcols = fleetcols2, addmax=FALSE, labels=rep("",10))
SSplotCatch(bs82, subplot=2, add=TRUE, fleetcols = fleetcols1, addmax=FALSE, labels=rep("",10))
legend(x=par()$usr[2]/3, y=par()$usr[4],
       fill = c(fleetcols3[1], fleetcols2[1], fleetcols1[1]),
       legend = c("Discard (surviving)","Discard (dead)","Landings"),
       bty='n')
dev.off()


model136 <- SS_output('c:/SS/skates/models/Model136')

# discards vs. dead vs. selected
fleetcols0 <- rich.colors.short(5)[-1]
fleetcols1 <- c(fleetcols0[c(1,2,1)],'purple')
fleetcols1[1] <- fleetcols1[3]
fleetcols3 <- fleetcols1
fleetcols2 <- fleetcols1
fleetcols2[1] <- fleetcols1[2]
fleetcols3[1] <- fleetcols0[1]


png('c:/SS/skates/BigSkate_Doc/Figures/LongnoseSkate_catch_plot_v2_6-3-2019.png',
    res=300, units='in', width=6.5, height=5, pointsize=10)
## SSplotCatch(model136, subplot=5, fleetcols = fleetcols3, addmax=FALSE,
##             labels=rep("",10))
SSplotCatch(model136, subplot=16, add=FALSE, fleetcols = fleetcols2, addmax=FALSE, labels=rep("",10), showlegend=FALSE)
SSplotCatch(model136, subplot=2, add=TRUE, fleetcols = fleetcols1, addmax=FALSE, labels=rep("",10), showlegend=FALSE)
legend('topleft',
       bg='white',
       bty='n',
       fill = fleetcols1[c(2,1,4)],
       legend = c("Dead discards", "Landings", "Tribal"))
## legend(x=par()$usr[2]/2.5, y=par()$usr[4],
##        fill = c(fleetcols3[1], fleetcols2[1], fleetcols1[1]),
##        legend = c("Discard (surviving)","Discard (dead)","Landings"),
##        bty='n')
title(ylab="Landings + dead discards (mt)")
dev.off()


png('c:/SS/skates/BigSkate_Doc/Figures/BigSkate_catch_plot_model99.png',
    res=300, units='in', width=6.5, height=5, pointsize=10)
SSplotCatch(bs99, subplot=16, add=FALSE, fleetcols = fleetcols2, addmax=FALSE, labels=rep("",10), showlegend=FALSE)
SSplotCatch(bs99, subplot=2, add=TRUE, fleetcols = fleetcols1, addmax=FALSE, labels=rep("",10), showlegend=FALSE)
legend('topleft',
       bg='white',
       bty='n',
       fill = fleetcols1[c(2,1,4)],
       legend = c("Dead discards", "Landings", "Tribal"))
title(ylab="Landings + dead discards (mt)")
dev.off()

png('c:/SS/skates/BigSkate_Doc/Figures/BigSkate_catch_plot_bs82sel4_6-3-2019.png',
    res=300, units='in', width=6.5, height=5, pointsize=10)
SSplotCatch(bs82sel4, subplot=16, add=FALSE, fleetcols = fleetcols2, addmax=FALSE, labels=rep("",10), showlegend=FALSE)
SSplotCatch(bs82sel4, subplot=2, add=TRUE, fleetcols = fleetcols1, addmax=FALSE, labels=rep("",10), showlegend=FALSE)
legend('topleft',
       bg='white',
       bty='n',
       fill = fleetcols1[c(2,1,4)],
       legend = c("Dead discards", "Landings", "Tribal"))
title(ylab="Landings + dead discards (mt)")
dev.off()

png('c:/SS/skates/BigSkate_Doc/Figures/BigSkate_catch_plot_bs82catch5_6-3-2019.png',
    res=300, units='in', width=6.5, height=5, pointsize=10)
SSplotCatch(bs82catch5, subplot=16, add=FALSE, fleetcols = fleetcols2, addmax=FALSE, labels=rep("",10), showlegend=FALSE)
SSplotCatch(bs82catch5, subplot=2, add=TRUE, fleetcols = fleetcols1, addmax=FALSE, labels=rep("",10), showlegend=FALSE)
legend('topleft',
       bg='white',
       bty='n',
       fill = fleetcols1[c(2,1,4)],
       legend = c("Dead discards", "Landings", "Tribal"))
title(ylab="Landings + dead discards (mt)")
dev.off()
