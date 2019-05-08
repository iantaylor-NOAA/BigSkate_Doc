
#install.packages("devtools")
#devtools::install_github("nwfsc-assess/PacFIN.Utilities")
devtools::install_github("nwfsc-assess/PacFIN.Utilities")
library(PacFIN.Utilities)

#Example file
?PacFIN_Example

#Define length and age bins

BSKT.LBINS <- seq(20, 200, by = 5)
BSKT.ABINS <- 0:15

#==============================================================
#===================  Load PacFIN BDS  ========================
#==============================================================

if(Sys.info()["user"] == "Ian.Taylor"){
  pacfin.dir <- "C:/SS/skates/bio/PacFIN_comps/"
}

# Load John Wallace's BDS .dmp file to R console
## load(file.path(pacfin.dir, "PacFIN.BSKT.bds.24.Apr.2019.dmp"))
## PacFIN.BSKT.BDS <- PacFIN.BSKT.bds.24.Apr.2029
## load(file.path(pacfin.dir, "PacFIN.BSKT.bds.30.Apr.2019.dmp"))
## PacFIN.BSKT.BDS <- PacFIN.BSKT.bds.30.Apr.2019
# after adding OR ages
load(file.path(pacfin.dir, "PacFIN.BSKT.bds.08.May.2019b.Rdata"))
PacFIN.BSKT.BDS <- PacFIN.BSKT.bds.08.May.2019b

# filter out outliers discovered in the age-length
# comparison at the bottom of this script, all of which have FISH_LENGTH_TYPE == "T"
nrow(PacFIN.BSKT.BDS)
## [1] 7785
outliers <- c(which(PacFIN.BSKT.BDS$FISH_LENGTH == 160 &
                      PacFIN.BSKT.BDS$FISH_AGE_YEARS_FINAL == 5),
              which(PacFIN.BSKT.BDS$FISH_LENGTH == 380 &
                      PacFIN.BSKT.BDS$FISH_AGE_YEARS_FINAL == 5),
              which(PacFIN.BSKT.BDS$FISH_LENGTH == 1430 &
                      PacFIN.BSKT.BDS$FISH_AGE_YEARS_FINAL == 4),
              which(PacFIN.BSKT.BDS$FISH_LENGTH == 840 &
                      PacFIN.BSKT.BDS$FISH_AGE_YEARS_FINAL == 10))

outliers
## [1] 2713 1657 2018 2017
PacFIN.BSKT.BDS <- PacFIN.BSKT.BDS[-outliers, ]

# A couple of NA's
PacFIN.BSKT.BDS <- PacFIN.BSKT.BDS[!is.na(PacFIN.BSKT.BDS$FISH_LENGTH),]

# One bad record with FISH_LENGTH_TYPE T:
PacFIN.BSKT.BDS <- PacFIN.BSKT.BDS[-c(which(PacFIN.BSKT.BDS$FISH_LENGTH == 11520.0)),]

nrow(PacFIN.BSKT.BDS)
## [1] 7760

#Select data only for one state, line below is for OR. This is for exploration purposes
#PacFIN.BSKT.BDS <- PacFIN.BSKT.bds.30.Aug.2018[PacFIN.BSKT.bds.30.Aug.2018$SOURCE_AGID %in% 'O',]

#==============================================================
#========  CONVERT ALL LENGTHS TYPES TO TOTAL LENGTH  =========
#==============================================================

# To convert from from disc width to total lengths
# (conversion is derived from WCGBTS data)

sub <- PacFIN.BSKT.BDS$FISH_LENGTH_TYPE %in% "A"
PacFIN.BSKT.BDS$FISH_LENGTH[sub] <- 1.3399 * PacFIN.BSKT.BDS$FISH_LENGTH[sub]

# To convert to from interspiracular width to total lengths
# Females or unsexed (only 2 unsexed fish with interspiracular width)
sub <- PacFIN.BSKT.BDS$FISH_LENGTH_TYPE %in% "R" &
  PacFIN.BSKT.BDS$SEX %in% c("F","U") &
  PacFIN.BSKT.BDS$FISH_LENGTH < 1000
sub[is.na(sub)] = FALSE

PacFIN.BSKT.BDS$FISH_LENGTH[sub] <- 12.111 + 9.761 * PacFIN.BSKT.BDS$FISH_LENGTH[sub]

# Males
sub <- PacFIN.BSKT.BDS$FISH_LENGTH_TYPE %in% "R" & PacFIN.BSKT.BDS$SEX %in% "M"
PacFIN.BSKT.BDS$FISH_LENGTH[sub] <- 3.824 + 10.927 * PacFIN.BSKT.BDS$FISH_LENGTH[sub]

#Check how many samples are in the data
#table(PacFIN.BSKT.BDS$SAMPLE_NO)
table(PacFIN.BSKT.BDS$FISH_LENGTH_TYPE)
##    A    F    R    T 
## 1299    2  502 5957 

table(PacFIN.BSKT.BDS$SAMPLE_METHOD)
##    R    S 
## 7694   66 

# confirm that "S" samples are all from WA in 2009:
table(PacFIN.BSKT.BDS$SAMPLE_AGENCY[PacFIN.BSKT.BDS$SAMPLE_METHOD == "S"],
      PacFIN.BSKT.BDS$SAMPLE_YEAR[PacFIN.BSKT.BDS$SAMPLE_METHOD == "S"])
  ##   2009
  ## W   66

#Clean PacFIN bds file
# note that all lengths types have already been converted to total length above
PacFIN.BSKT.BDS.clean <- cleanPacFIN(PacFIN.BSKT.BDS,
                                     keep_length_type = c("A","F","R","T"),
                                     keep_INPFC = c("VUS","CL","VN","COL","NC","SC","EU","CP","EK","MT"))
## Removal Report

## Records in input:                  7760 
## Records not in USINPFC             0 
## Records not in INPFC_AREA:         0 
## Records in bad INPFC_AREA:         0 
## Records in badRecords list:        0 
## Records with bad SAMPLE_TYPE       2 
## Records with bad SAMPLE_METHOD     66 
## Records with no SAMPLE_NO          0 
## Records with no usable length      0 
## Records remaining:                 7692 

write.csv(PacFIN.BSKT.BDS.clean, file = file.path(pacfin.dir, "PacFIN.BSKT.BDS_cleaned_5-5-2019.csv"))

#==============================================================
#==================  Stratification  ==========================
#==============================================================

table(PacFIN.BSKT.BDS.clean$geargroup) 
 ## HKL  TWL 
 ## 158 7517 

PacFIN.BSKT.BDS.clean$mygear <- PacFIN.BSKT.BDS.clean$geargroup

# this line doesn't change anything
PacFIN.BSKT.BDS.clean$mygear[ PacFIN.BSKT.BDS.clean$mygear != c("HKL")] <- "TWL"

PacFIN.BSKT.BDS.clean$stratification <- paste(PacFIN.BSKT.BDS.clean$state,
                                        PacFIN.BSKT.BDS.clean$mygear, sep=".")

table(PacFIN.BSKT.BDS.clean$stratification)
## CA.HKL CA.TWL OR.HKL OR.TWL WA.HKL WA.TWL 
##     24   1277     91   5005     53   1255 
# 
# NOW:
#   
# CA.HKL CA.TWL OR.HKL OR.TWL WA.HKL WA.TWL 
# 24   1277     89   4985     45   1255

# look at histograms of different groups
par(mfrow=c(6,1), mar=rep(1,4), oma=c(4,4,1,1))
hist(subset(PacFIN.BSKT.BDS.clean, FISH_LENGTH_TYPE == "A" & SEX == "F",
            select = lengthcm)[[1]],
     breaks = seq(10, 205, 5))
hist(subset(PacFIN.BSKT.BDS.clean, FISH_LENGTH_TYPE == "A" & SEX == "M",
            select = lengthcm)[[1]],
     breaks = seq(10, 205, 5))
hist(subset(PacFIN.BSKT.BDS.clean, FISH_LENGTH_TYPE == "R" & SEX == "F",
            select = lengthcm)[[1]],
     breaks = seq(10, 205, 5))
hist(subset(PacFIN.BSKT.BDS.clean, FISH_LENGTH_TYPE == "R" & SEX == "M",
            select = lengthcm)[[1]],
     breaks = seq(10, 205, 5))
hist(subset(PacFIN.BSKT.BDS.clean, FISH_LENGTH_TYPE == "T" & SEX == "F",
            select = lengthcm)[[1]],
     breaks = seq(10, 205, 5))
hist(subset(PacFIN.BSKT.BDS.clean, FISH_LENGTH_TYPE == "T" & SEX == "M",
            select = lengthcm)[[1]],
     breaks = seq(10, 205, 5))

#==============================================================
#=====================  Expansion  ============================
#==============================================================

# Expansion 1 (WL parameters estimated from WCGBTS data)
PacFIN.BSKT.BDS.exp1 <- getExpansion_1(PacFIN.BSKT.BDS.clean, maxExp = 0.95,
                                  Exp_WA = TRUE,
                                  fa = 7.4924e-06, fb = 2.9925,
                                  ma = 7.4924e-06, mb = 2.9925,
                                  ua = 7.4924e-06, ub = 2.9925)

# Expansion 2
#Read in catch file
Catch <- read.csv(file.path(pacfin.dir,
                            'Length comps/Landings - PacFIN BDS/Catch.csv'))
head(Catch)
summary(Catch)
PacFIN.BSKT.BDS.exp2 <- getExpansion_2(PacFIN.BSKT.BDS.exp1, Catch,
                                       Convert=TRUE, maxExp = 0.95)

#Add column for final sample sizes
#No expansion
#PacFIN.BSKT.BDS.exp1$Final_Sample_Size = 1

#One-stage expantion
#PacFIN.BSKT.BDS.exp1$Final_Sample_Size = PacFIN.BSKT.BDS.exp1$Expansion_Factor_1

#Two-stage expantion
PacFIN.BSKT.BDS.exp2$Final_Sample_Size <-
  PacFIN.BSKT.BDS.exp2$Expansion_Factor_1 * PacFIN.BSKT.BDS.exp2$Expansion_Factor_2

#write csv. file of clean BDS file, with final samples sizes added

write.csv(PacFIN.BSKT.BDS.exp2, file.path(pacfin.dir, "PacFIN.BSKT.BDS_expanded2.csv"))

# Generate Length Comps
table(PacFIN.BSKT.BDS.exp2$SEX)
##    F    M    U 
## 2828 4854   10 

Lcomps <- getComps(PacFIN.BSKT.BDS.exp2, Comps="LEN")

Lcomps = doSexRatio(Lcomps)

# Write length comps into csv. file
Lcomps.SS <- writeComps(Lcomps,
                        fname = file.path(pacfin.dir, "PacFIN.BSKT.BDS_length_comps_5-5-2019.csv"),
                        lbins = BSKT.LBINS,
                        partition = 2, ageErr = 1, returns = "FthenM",
                        dummybins = FALSE, sum1 = TRUE,
                        overwrite = TRUE, verbose = TRUE)

#### make table of sample sizes for each state
PacFIN.BSKT.BDS.exp2.WA <- PacFIN.BSKT.BDS.exp2[PacFIN.BSKT.BDS.exp2$state=="WA",]
PacFIN.BSKT.BDS.exp2.OR <- PacFIN.BSKT.BDS.exp2[PacFIN.BSKT.BDS.exp2$state=="OR",]
PacFIN.BSKT.BDS.exp2.CA <- PacFIN.BSKT.BDS.exp2[PacFIN.BSKT.BDS.exp2$state=="CA",]
Lcomps.WA <- getComps(PacFIN.BSKT.BDS.exp2.WA, Comps="LEN")
Lcomps.OR <- getComps(PacFIN.BSKT.BDS.exp2.OR, Comps="LEN")
Lcomps.CA <- getComps(PacFIN.BSKT.BDS.exp2.CA, Comps="LEN")

for(s in c("WA","OR","CA")){
Lcomps.SS <- writeComps(get(paste0("Lcomps.", s)),
                        fname = file.path(pacfin.dir, paste0("PacFIN.BSKT.BDS_length_comps_", s, "5-7-2019.csv")),
                        lbins = BSKT.LBINS,
                        partition = 2, ageErr = 1, returns = "FthenM",
                        dummybins = FALSE, sum1 = TRUE,
                        overwrite = TRUE, verbose = TRUE)
assign(paste0("Lcomps.SS.", s), value=Lcomps.SS)
}
SS.table <- data.frame(yr = 1995:2018,
                       CA.Ntows=0, CA.Nfish=0,
                       OR.Ntows=0, OR.Nfish=0,
                       WA.Ntows=0, WA.Nfish=0)
for(irow in 1:nrow(Lcomps.SS.CA)){
  y <- Lcomps.SS.CA$fishyr[irow]
  SS.table$CA.Ntows[SS.table$yr == y] <- Lcomps.SS.CA$Ntows[irow]
  SS.table$CA.Nfish[SS.table$yr == y] <- Lcomps.SS.CA$Nsamp[irow]
}
for(irow in 1:nrow(Lcomps.SS.OR)){
  y <- Lcomps.SS.OR$fishyr[irow]
  SS.table$OR.Ntows[SS.table$yr == y] <- Lcomps.SS.OR$Ntows[irow]
  SS.table$OR.Nfish[SS.table$yr == y] <- Lcomps.SS.OR$Nsamp[irow]
}
for(irow in 1:nrow(Lcomps.SS.WA)){
  y <- Lcomps.SS.WA$fishyr[irow]
  SS.table$WA.Ntows[SS.table$yr == y] <- Lcomps.SS.WA$Ntows[irow]
  SS.table$WA.Nfish[SS.table$yr == y] <- Lcomps.SS.WA$Nsamp[irow]
}
SS.table$AllLandings.Ntows <- SS.table$CA.Ntows + SS.table$OR.Ntows + SS.table$WA.Ntows
SS.table$AllLandings.Nfish <- SS.table$CA.Nfish + SS.table$OR.Nfish + SS.table$WA.Nfish

# add discard comps to the table
discard_comp_dir <- 'C:/SS/skates/bio/WCGOP_comps'
LF_Sample_Sizes <- read.csv(file.path(discard_comp_dir,
                                      'BigSkate_WCGOP_Comps_V3_LF_Sample_Sizes.csv'))
SS.table$Discard.Ntows <- 0
SS.table$Discard.Nfish <- 0
for(y in unique(LF_Sample_Sizes$Year)){
  SS.table$Discard.Ntows[SS.table$yr == y] <-
    sum(LF_Sample_Sizes$N_unique_Hauls[LF_Sample_Sizes$Year == y])
  SS.table$Discard.Nfish[SS.table$yr == y] <-
    sum(LF_Sample_Sizes$N_Fish[LF_Sample_Sizes$Year == y])
}

write.csv(SS.table,
          file.path(pacfin.dir, "../../BigSkate_Doc/txt_files/data_summaries",
                    "PacFIN.sample_sizes_by_state.csv"),
          row.names = FALSE)


# apply sample size calculation
## N_input=N_trips+0.138N_fish          when    N_fish/N_trips <44
## N_input=7.06N_trips                  when    N_fish/N_trips >=44
summary(Lcomps.SS$Nsamp / Lcomps.SS$Ntows)
   ## Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
   ## 2.00   10.27   12.85   13.54   16.60   33.17 
# no need to apply 2nd formula
Ninput <- Lcomps.SS$Ntows + 0.138 * Lcomps.SS$Nsamp
Lcomps.SS$Nsamps <- Ninput
Lcomps.SS <- Lcomps.SS[,!names(Lcomps.SS) %in% c("ageErr", "Ntows")]
names(Lcomps.SS)[1] <- "Year"
names(Lcomps.SS)[names(Lcomps.SS) %in% paste0("L",BSKT.LBINS)] <- paste0("F",BSKT.LBINS)
names(Lcomps.SS)[names(Lcomps.SS) %in% paste0("L",BSKT.LBINS,".1")] <- paste0("M",BSKT.LBINS)
write.csv(Lcomps.SS,
          file.path(pacfin.dir, "PacFIN.BSKT.BDS_length_comps_forSS_5-5-2019.csv"),
          row.names = FALSE)


#==============================================================
#========  AGES  =========
#==============================================================

## Ages:
#Clean PacFIN bds file again, but include non-random sampling
PacFIN.BSKT.BDS.clean.ages <- cleanPacFIN(PacFIN.BSKT.BDS,
                                          keep_length_type = c("A","F","R","T"),
                                          keep_INPFC = c("VUS","CL","VN","COL","NC","SC","EU","CP","EK","MT"),
                                          keep_sample_method = c("R", "S"))
## Removal Report

## Records in input:                  7825 
## Records not in USINPFC             0 
## Records not in INPFC_AREA:         22 
## Records in bad INPFC_AREA:         0 
## Records in badRecords list:        0 
## Records with bad SAMPLE_TYPE       2 
## Records with bad SAMPLE_METHOD     0 
## Records with no SAMPLE_NO          0 
## Records with no usable length      20 
## Records remaining:                 7781 

PacFIN.BSKT.BDS.ages <- cleanAges(PacFIN.BSKT.BDS.clean.ages, minAge = 0,
                                  keep_age_methods=c(4,"X"))
## Removal report

## Records in input:                   7758 
## Records with age less than min:     7123 
## Records with bad agemethods:        0 
## Records remaining:                  635 

## Removal report

## Records in input:                   7781 
## Records with age less than min:     6982 
## Records with bad agemethods:        0 
## Records remaining:                  799 

PacFIN.BSKT.BDS.ages.exp1 <- getExpansion_1(PacFIN.BSKT.BDS.ages,
                                            maxExp = 0.95,
                                            Exp_WA = TRUE,
                                            fa = 7.4924e-06, fb = 2.9925,
                                            ma = 7.4924e-06, mb = 2.9925,
                                            ua = 7.4924e-06, ub = 2.9925)
# expansion factor 1 only
PacFIN.BSKT.BDS.ages.exp1$Final_Sample_Size <-
  PacFIN.BSKT.BDS.ages.exp1$Expansion_Factor_1

table(PacFIN.BSKT.BDS.ages$SAMPLE_YEAR, PacFIN.BSKT.BDS.ages$state)
##       OR  WA
## 2004   0  11
## 2008  79   0
## 2009  85  65
## 2010 102   0
## 2011 201   0
## 2018   0  92

# new ages on May 8
  ##       OR  WA
  ## 2004   0  11
  ## 2008  80   0
  ## 2009  87  65
  ## 2010 102   0
  ## 2011 202   0
  ## 2012 120   0
  ## 2018  39  93

PacFIN.BSKT.BDS.ages.exp1$stratification <- PacFIN.BSKT.BDS.ages$state

# don't do expansion factor 2 because WA samples from 2009 are non-random and
# should not be included in marginal age comps

PacFIN.BSKT.BDS.ages.exp1 <- subset(PacFIN.BSKT.BDS.ages.exp1,
                                    SAMPLE_METHOD != "S")
Acomps.exp1 = getComps(PacFIN.BSKT.BDS.ages.exp1, Comps="AGE")

# no unsexed fish
table(PacFIN.BSKT.BDS.ages.exp1$SEX)
##   F   M 
## 234 500 
## Acomps = doSexRatio(Acomps)

marginal_ages <- writeComps(Acomps.exp1,
                            fname = file.path(pacfin.dir, "PacFIN.BSKT.BDS_age_comps_5-8-2019.csv"),
                            abins = BSKT.ABINS,
                            partition = 2, ageErr = 1, returns = "FthenM",
                            dummybins = FALSE, sum1 = TRUE,
                            overwrite = TRUE, verbose = TRUE)

# unexpanded ages
PacFIN.BSKT.BDS.ages$Final_Sample_Size <- 1
Acomps.nox = getComps(PacFIN.BSKT.BDS.ages, Comps="AGE")
marginal_ages_nox <- writeComps(Acomps.nox,
                                fname = file.path(pacfin.dir, "PacFIN.BSKT.BDS_age_comps_nox_5-8-2019.csv"),
                                abins = BSKT.ABINS,
                                partition = 2, ageErr = 1, returns = "FthenM",
                                dummybins = FALSE, sum1 = TRUE,
                                overwrite = TRUE, verbose = TRUE)

# Age-at-Length:

PacFIN.BSKT.BDS.AAL <- PacFIN.BSKT.BDS.ages
PacFIN.BSKT.BDS.AAL$Final_Sample_Size <- 1 

ALcomps <- getComps(PacFIN.BSKT.BDS.AAL, Comps="AAL")
# bin into 5cm bins by rounding down the length values
ALcomps$lengthcm <- 5*floor(ALcomps$lengthcm / 5)

#ALcomps <- doSexRatio(ALcomps) 

CAAL_F <- writeComps(ALcomps,
                     fname = file.path(pacfin.dir, "PacFIN.BSKT.BDS_AAL_comps_Female_5-5-2019.csv"),
                     abins = BSKT.ABINS,
                     lbins = BSKT.LBINS,
                     partition = 2, ageErr = 1, returns = "Fout",
                     dummybins = FALSE, sum1 = FALSE,
                     overwrite = TRUE, verbose = TRUE)
CAAL_M <- writeComps(ALcomps,
                     fname = file.path(pacfin.dir, "PacFIN.BSKT.BDS_AAL_comps_Male_5-5-2019.csv"),
                     abins = BSKT.ABINS,
                     lbins = BSKT.LBINS,
                     partition = 2, ageErr = 1, returns = "Mout",
                     dummybins = FALSE, sum1 = FALSE,
                     overwrite = TRUE, verbose = TRUE)
CAAL_both <- rbind(CAAL_F, CAAL_M)
# change to preferred format with LbinHi = LbinLo = length at lower bound of bin
CAAL_both$LbinHi <- CAAL_both$LbinLo

# put in preferred sorting
CAAL_both <- CAAL_both[order(CAAL_both$fishyr, CAAL_both$LbinLo, CAAL_both$gender),]

marginal_ages2 <- data.frame(marginal_ages[,c(1,2,4:6)],
                            LbinLo = -1, LbinHi = -1,
                             marginal_ages[,-(1:6)])
# turn off likelihood for marginals
marginal_ages2$fleet <- -1

names(CAAL_both) <- names(marginal_ages2)
all_ages <- rbind(marginal_ages2, CAAL_both)
ages_fixed <- data.frame(year = all_ages$fishyr,
                         month = 7,
                         all_ages[,!names(all_ages) %in% c("fishyr", "Ntows")])
names(ages_fixed)[names(ages_fixed) %in% paste0("A",0:15)] <- paste0("F",0:15)
names(ages_fixed)[names(ages_fixed) %in% paste0("A",0:15,".1")] <- paste0("M",0:15)

write.csv(ages_fixed,
          file = file.path(pacfin.dir, "PacFIN.BSKT.BDS_AAL_comps_forSS_5-8-2019.csv"),
          row.names=FALSE)


# brute force calcs of values for sample size table
length(unique(PacFIN.BSKT.BDS.ages$SAMPLE_NO[PacFIN.BSKT.BDS.ages$fishyr==2012 & PacFIN.BSKT.BDS.ages$state=="OR"]))
length(unique(PacFIN.BSKT.BDS.ages$SAMPLE_NO[PacFIN.BSKT.BDS.ages$fishyr==2018 & PacFIN.BSKT.BDS.ages$state=="OR"]))
sum(PacFIN.BSKT.BDS.ages$fishyr==2012 & PacFIN.BSKT.BDS.ages$state=="OR")
sum(PacFIN.BSKT.BDS.ages$fishyr==2018 & PacFIN.BSKT.BDS.ages$state=="OR")


#==============================================================
#========  OUTLIERS  =========
#==============================================================

### find some outliers that can then be filtered at the top
# #16cm fish at age 5:
# PacFIN.BSKT.BDS.ages[PacFIN.BSKT.BDS.ages$age==5 & PacFIN.BSKT.BDS.ages$lengthcm < 50 & PacFIN.BSKT.BDS.ages$SEX=="M" & PacFIN.BSKT.BDS.ages$SAMPLE_YEAR==2011,]
"OR115082"
# #38cm fish at age 5:
# PacFIN.BSKT.BDS.ages[PacFIN.BSKT.BDS.ages$age==5 & PacFIN.BSKT.BDS.ages$lengthcm < 50 & PacFIN.BSKT.BDS.ages$SEX=="M" & PacFIN.BSKT.BDS.ages$SAMPLE_YEAR==2011,]
"OR084015"
# #143cm fish at age 4
# PacFIN.BSKT.BDS.ages[PacFIN.BSKT.BDS.ages$age==4 & PacFIN.BSKT.BDS.ages$lengthcm > 130 & PacFIN.BSKT.BDS.ages$SEX=="F" & PacFIN.BSKT.BDS.ages$SAMPLE_YEAR==2009,]
"OR095017"
# #84cm fish at age 10
# PacFIN.BSKT.BDS.ages[PacFIN.BSKT.BDS.ages$age==10 & PacFIN.BSKT.BDS.ages$lengthcm < 90 & PacFIN.BSKT.BDS.ages$SEX=="M" & PacFIN.BSKT.BDS.ages$SAMPLE_YEAR==2009,]
"OR095017"
