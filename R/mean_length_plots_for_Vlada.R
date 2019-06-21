### mean length at age
meanlen <- data.frame(age = 0:15, meanF = NA, meanM = NA,
                      NF = NA, NM = NA)
for(a in 0:15){
  meanlen$meanF[meanlen$age==a] <-
    round(mean(bio.WCGBTS.BS$Length_cm[bio.WCGBTS.BS$Age == a &
                                   bio.WCGBTS.BS$Sex == "F"], na.rm=TRUE),1)
  meanlen$meanM[meanlen$age==a] <-
    round(mean(bio.WCGBTS.BS$Length_cm[bio.WCGBTS.BS$Age == a &
                                   bio.WCGBTS.BS$Sex == "M"], na.rm=TRUE),1)
  meanlen$NF[meanlen$age==a] <-
    sum(bio.WCGBTS.BS$Age == a & bio.WCGBTS.BS$Sex == "F", na.rm=TRUE)
  meanlen$NM[meanlen$age==a] <-
    sum(bio.WCGBTS.BS$Age == a & bio.WCGBTS.BS$Sex == "M", na.rm=TRUE)
}

##    age     meanF     meanM  NF  NM
## 1    0  29.35714  28.61765  28  17
## 2    1  42.32716  43.49038  81  52
## 3    2  55.89754  55.44000 122 100
## 4    3  63.71053  64.95175  95 114
## 5    4  75.98039  79.50000  51  70
## 6    5  89.19643  91.42742  28  62
## 7    6 104.36842 103.41803  19  61
## 8    7 108.69231 111.73256  13  43
## 9    8 128.75000 113.66667   8  36
## 10   9 130.00000 120.42857   5   7
## 11  10 140.75000 126.60000   4   5
## 12  11 179.00000 126.00000   1   1
## 13  12 141.00000 133.00000   3   1
## 14  13 144.00000       NaN   1   0
## 15  14 168.50000       NaN   2   0
## 16  15 177.00000       NaN   1   0

# example input
# sex codes:  0=combined; 1=use female only; 2=use male only; 3=use both as joint sexxlength distribution
# partition codes:  (0=combined; 1=discard; 2=retained
# ageerr codes:  positive means mean length-at-age; negative means mean bodywt_at_age
## #_yr month fleet sex part ageerr ignore datavector(female-male)
## #                                          samplesize(female-male)
##  1971 7 1 3 0 1 2 29.8931 40.6872 44.7411 50.027 52.5794 56.1489 57.1033 61.1728 61.7417 63.368 64.4088 65.6889 67.616 68.5972 69.9177 71.0443 72.3609 32.8188 39.5964 43.988 50.1693 53.1729 54.9822 55.3463 60.3509 60.7439 62.3432 64.3224 65.1032 64.1965 66.7452 67.5154 70.8749 71.2768 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20
##  1995 7 1 3 0 1 2 32.8974 38.2709 43.8878 49.2745 53.5343 55.1978 57.4389 62.0368 62.1445 62.9579 65.0857 65.6433 66.082 65.6117 67.0784 69.3493 72.2966 32.6552 40.5546 44.6292 50.4063 52.0796 56.1529 56.9004 60.218 61.5894 63.6613 64.0222 63.4926 65.8115 69.5357 68.2448 66.881 71.5122 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20
##  1995 7 1 3 1 1 2 31.4253 40.0692 43.5027 48.0151 49.5317 52.5139 57.1566 55.2488 58.4423 60.548 61.446 63.9418 64.9355 64.191 66.8906 66.1213 70.2574 31.5972 37.8587 43.1353 46.4582 49.7879 53.7443 55.7443 56.3585 59.4961 58.7688 61.2203 61.6839 64.6311 67.0238 66.4088 68.8365 67.8683 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20

meanlen$meanM[is.nan(meanlen$meanM)] <- -999
meanlen.SS <- data.frame(year=2011, month=7, fleet=5, sex=3, part=0, ageerr=0, ignore=99)
meanlen.SS <- cbind(meanlen.SS,
                    t(meanlen$meanF), t(meanlen$meanM),
                    t(meanlen$NF), t(meanlen$NM))
names(meanlen.SS)[-(1:7)] <- c(paste0("F",0:15), paste0("M",0:15),
                               paste0("NF",0:15), paste0("NM",0:15))


####################  function to plot mean length vs true growth curve

mod <- SS_output(...)

png('c:/SS/skates/BigSkate_Doc/Figures/mean_length_vs_growth_curve.png',
    res=300, units='in', pointsize=10, width=5.2, height=5.2)
par(mar = c(4,4,4,4))
SSplotBiology(mod, subplot=1)
scale <- .3
ladbase <- mod$ladbase
points(ladbase$Bin + 0.5, ladbase$Obs, pch=21, cex=scale*sqrt(ladbase$N),
       bg=rgb(0,0,1,.5), type='o', lty=3)
dev.off()

####################  function to plot mean length vs expected mean length

### open PNG file (change path)
png('c:/SS/skates/BigSkate_Doc/Figures/mean_length_at_age.png',
    res=300, units='in', pointsize=10, width=5.2, height=5.2)
par(mar = c(4,4,4,4))
plot(0, type='n', xlim=c(0,15), ylim=c(0,200),
     yaxs='i', xlab="Age (yr)", ylab="Length (cm)",
     main="Mean length at age from WCGBT Survey (all years combined)")
scale <- .3
grid()
ladbase <- mod$ladbase
points(ladbase$Bin, ladbase$Obs, pch=21, cex=scale*sqrt(ladbase$N),
       bg=rgb(0,0,1,.5), type='o', lty=3)
lines(ladbase$Bin, ladbase$Exp, col=rgb(0,0,1,.5), lwd=2)

#### add tick marks for length at maturity
## axis(4, at=106.9, col=4)
## axis(4, at=148.2, col=2)
## mtext(side=4, line=2, "Length at 50% maturity", adj=.7)

#### add legends
## legend(x = 0,
##        y = 200,
##        bty = 'n',
##        pch=21,
##        col=1,
##        legend = c("      Female observation",
##            "      Male observation"),
##        pt.bg=c(rgb(1,0,0,.5), rgb(0,0,1,.5)),
##        pt.cex=2)
## legend(x = 0,
##        y = 180,
##        bty = 'n',
##        lty=1,
##        lwd=2,
##        legend = c("Female estimate",
##            "Male estimate"),
##        col=c(rgb(1,0,0,.5), rgb(0,0,1,.5)))
## legend(x = 0,
##        y = 162,
##        bty = 'n',
##        fill=gray(0,0.5),
##        legend = c("    Sample size"))

#### add bars at the bottom with sample sizes
scale <- 0.1 # scales the height of the bars for sample size
width <- 0.4
for(a in 0:15){
  N <- ladbase$N[ladbase$Bin == a]
  rect(a-width, 0,
       a+width, scale*N,
       col=gray(0,.5))
  text(N, x=a, y=scale*N, pos=3)
}
# close PNG file
dev.off()
