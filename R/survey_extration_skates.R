### extract data from NWFSC data warehouse

if(FALSE){
  devtools::install_github("nwfsc-assess/nwfscSurvey", build_vignettes=TRUE)
  library(nwfscSurvey)
}

# WGBTS for Big Skate
catch.WCGBTS.BS <- PullCatch.fn(Name = "big skate", SurveyName = "NWFSC.Combo")
bio.WCGBTS.BS   <- PullBio.fn(Name = "big skate", SurveyName = "NWFSC.Combo")
catch.Tri.BS <- PullCatch.fn(Name = "big skate", SurveyName = "Triennial")
bio.Tri.BS   <- PullBio.fn(Name = "big skate", SurveyName = "Triennial")
catch.WCGBTS.Starry <- PullCatch.fn(Name = "starry flounder", SurveyName = "NWFSC.Combo")
catch.Tri.Starry <- PullCatch.fn(Name = "starry flounder", SurveyName = "Triennial")
catch.WCGBTS.Petrale <- PullCatch.fn(Name = "petrale sole", SurveyName = "NWFSC.Combo")

catch.Tri.LN <- PullCatch.fn(Name = "longnose skate", SurveyName = "Triennial")
bio.Tri.LN   <- PullBio.fn(Name = "longnose skate", SurveyName = "Triennial")


### other skates
catch.WCGBTS.Aleu   <- PullCatch.fn(Name = "Aleutian skate", SurveyName = "NWFSC.Combo")
catch.WCGBTS.Deep   <- PullCatch.fn(Name = "deepsea skate", SurveyName = "NWFSC.Combo")
catch.WCGBTS.Star   <- PullCatch.fn(Name = "starry skate", SurveyName = "NWFSC.Combo")
catch.WCGBTS.Sand   <- PullCatch.fn(Name = "sandpaper skate", SurveyName = "NWFSC.Combo")
catch.WCGBTS.Rough   <- PullCatch.fn(Name = "roughtail skate", SurveyName = "NWFSC.Combo")
catch.WCGBTS.Cali   <- PullCatch.fn(Name = "California skate", SurveyName = "NWFSC.Combo")
catch.WCGBTS.Bering   <- PullCatch.fn(Name = "Bering skate", SurveyName = "NWFSC.Combo")
catch.WCGBTS.Long   <- PullCatch.fn(Name = "longnose skate", SurveyName = "NWFSC.Combo")

strata <- CreateStrataDF.fn(
    names=c("shallow_s", "mid_s","deep_s","shallow_n", "mid_n","deep_n"), 
    depths.shallow = c( 55, 183,  549,  55, 183,  549),
    depths.deep    = c(183, 549, 1280, 183, 549, 1280),
    lats.south     = c( 32,  32,   32,  42,  42,   42),
    lats.north     = c( 42,  42,   42,  49,  49,   49))
##        name      area Depth_m.1 Depth_m.2 Latitude_dd.1 Latitude_dd.2
## 1 shallow_s 187251226        55       183            32            42
## 2    deep_s 182594511       183       549            32            42
## 3 shallow_n 208174619        55       183            42            49
## 4    deep_n 106872334       183       549            42            49


# design-based indices
biomass.WCGBTS.Aleu <- Biomass.fn(dir = 'c:/SS/skates/other', 
                                  dat = catch.WCGBTS.Aleu,  
                                  strat.df = strata, 
                                  printfolder = "",
                                  outputMedian = TRUE)
biomass.WCGBTS.Deep <- Biomass.fn(dir = 'c:/SS/skates/other', 
                                  dat = catch.WCGBTS.Deep,  
                                  strat.df = strata, 
                                  printfolder = "",
                                  outputMedian = TRUE)
biomass.WCGBTS.Star <- Biomass.fn(dir = 'c:/SS/skates/other', 
                                  dat = catch.WCGBTS.Star,  
                                  strat.df = strata, 
                                  printfolder = "",
                                  outputMedian = TRUE)
biomass.WCGBTS.Sand <- Biomass.fn(dir = 'c:/SS/skates/other', 
                                  dat = catch.WCGBTS.Sand,  
                                  strat.df = strata, 
                                  printfolder = "",
                                  outputMedian = TRUE)
biomass.WCGBTS.Rough <- Biomass.fn(dir = 'c:/SS/skates/other', 
                                  dat = catch.WCGBTS.Rough,  
                                  strat.df = strata, 
                                  printfolder = "",
                                  outputMedian = TRUE)
biomass.WCGBTS.Cali <- Biomass.fn(dir = 'c:/SS/skates/other', 
                                  dat = catch.WCGBTS.Cali,  
                                  strat.df = strata, 
                                  printfolder = "",
                                  outputMedian = TRUE)
biomass.WCGBTS.BS <- Biomass.fn(dir = 'c:/SS/skates/other', 
                                  dat = catch.WCGBTS.BS,  
                                  strat.df = strata, 
                                  printfolder = "",
                                  outputMedian = TRUE)
biomass.WCGBTS.Long <- Biomass.fn(dir = 'c:/SS/skates/other', 
                                  dat = catch.WCGBTS.Long,  
                                  strat.df = strata, 
                                  printfolder = "",
                                  outputMedian = TRUE)
mean(tail(biomass.WCGBTS.Aleu$Bio$Value,5), na.rm=TRUE)/1e3
mean(tail(biomass.WCGBTS.Deep$Bio$Value,5))/1e3
mean(tail(biomass.WCGBTS.Star$Bio$Value,5))/1e3
mean(tail(biomass.WCGBTS.Sand$Bio$Value,5))/1e3
mean(tail(biomass.WCGBTS.Rough$Bio$Value,5))/1e3
mean(tail(biomass.WCGBTS.Cali$Bio$Value,5))/1e3
mean(tail(biomass.WCGBTS.BS$Bio$Value,5))/1e3
mean(tail(biomass.WCGBTS.Long$Bio$Value,5))/1e3

sd(tail(biomass.WCGBTS.Sand$Bio$Value,5))/mean(tail(biomass.WCGBTS.Sand$Bio$Value,5))
sd(tail(biomass.WCGBTS.Rough$Bio$Value,5))/mean(tail(biomass.WCGBTS.Rough$Bio$Value,5))
sd(tail(biomass.WCGBTS.Cali$Bio$Value,5))/mean(tail(biomass.WCGBTS.Cali$Bio$Value,5))
sd(tail(biomass.WCGBTS.BS$Bio$Value,5))/mean(tail(biomass.WCGBTS.BS$Bio$Value,5))


# save data for offline use
save(catch.WCGBTS.BS, bio.WCGBTS.BS,
     catch.Tri.BS,    bio.Tri.BS,
     file = 'c:/SS/skates/data/BigSkate_survey_extractions_5-17-2019.Rdata')
save(catch.WCGBTS.Petrale,
     file = 'c:/SS/skates/data/BigSkate_petrale_extraction_5-31-2019.Rdata')

### load previously extracted values
# load('c:/SS/skates/data/BigSkate_survey_extractions_4-22-2019.Rdata')
# load('c:/SS/skates/data/BigSkate_survey_extractions_5-17-2019.Rdata')


# WGBTS for Longnose Skate
catch.WCGBTS.LN <- PullCatch.fn(Name = "longnose skate", SurveyName = "NWFSC.Combo")
bio.WCGBTS.LN   <- PullBio.fn(Name = "longnose skate", SurveyName = "NWFSC.Combo")
save(catch.WCGBTS.LN,
     file = 'c:/SS/skates/data/LSKT_survey_catch_5-09-2019.Rdata')

catch.tri.CA <- PullCatch.fn(Name = "California skate", SurveyName = "Triennial")
catch.combo.CA <- PullCatch.fn(Name = "California skate", SurveyName = "NWFSC.Combo")

# AFSC Slope (no data)
catch.AFSC.Slope.BS <- PullCatch.fn(Name = "big skate", SurveyName = "AFSC.Slope")
## No data returned by the warehouse for the filters given.
##  Make sure the year range is correct for the project selected and the input name is correct,
##  otherwise there may be no data for this species from this project.
## Error in PullCatch.fn(Name = "big skate", SurveyName = "AFSC.Slope") :
  
# NWFSC Slope (depth started at 183m, too few positive tows)
catch.NWFSC.Slope.BS <- PullCatch.fn(Name = "big skate", SurveyName = "NWFSC.Slope")
table(catch.NWFSC.Slope.BS$Year, catch.NWFSC.Slope.BS$cpue_kg_km2 > 0)
  ##      FALSE TRUE
  ## 1998   301    0
  ## 1999   324    0
  ## 2000   329    0
  ## 2001   333    1
  ## 2002   424    2

# NWFSC Shelf (2001 only, narrow range of latitudes)
catch.NWFSC.Shelf.BS <- PullCatch.fn(Name = "big skate", SurveyName = "NWFSC.Shelf")
table(catch.NWFSC.Shelf.BS$Year, catch.NWFSC.Shelf.BS$cpue_kg_km2 > 0)
  ##      FALSE TRUE
  ## 2001    49   22

# Video survey (?)
catch.NWFSC.Video.BS <- PullCatch.fn(Name = "big skate", SurveyName = "NWFSC.Video")
table(catch.NWFSC.Video.BS$Year, catch.NWFSC.Video.BS$cpue_kg_km2 > 0)
  ##      FALSE TRUE
  ## 2009    27   21

