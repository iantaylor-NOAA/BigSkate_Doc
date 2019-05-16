### load previously extracted survey values
# load('c:/SS/skates/data/BigSkate_survey_extractions_4-22-2019.Rdata')
max(catch.WCGBTS.BS$Depth_m[catch.WCGBTS.BS$total_catch_wt_kg > 0])
## [1] 459.2

table(catch.WCGBTS.BS$Depth_m < 500)
## FALSE  TRUE 
##  3243  7122 

catch2 <- catch.WCGBTS.BS[catch.WCGBTS.BS$Depth_m < 500,]

# create new depth variable binned to 10m 
catch2$Depth_m_bin10 <- 10*floor(catch2$Depth_m/10)

plot(table(catch2$Depth_m_bin10, catch2$cpue_kg_km2 > 0))

