#### script to make table of input values and uncertainty for each index

# this could point to any model prior to bigskate67 when IPHC index was removed
bs66dir <- "C:/SS/skates/models//bigskate66_tri_init_fish_asymptotic"
# read data file
dat <- SS_readdat_3.30(file = file.path(bs66dir, "BSKT2019_data.ss"))
# grab CPUE inputs
cpue <- dat$CPUE

# make table
tab <- data.frame(year = sort(as.numeric(unique(cpue$year))),
                  stringsAsFactors = FALSE)
# loop over fleets with index
for(f in sort(unique(as.numeric(cpue$index)))){
  fleetname <- dat$fleetnames[f]
  col1name <- paste0(dat$fleetname[f], ".obs")
  col2name <- paste0(dat$fleetname[f], ".se_log")
  tab[[col1name]] <- NA
  tab[[col2name]] <- NA
  # subset cpue for this fleet
  cpue.f <- cpue[cpue$index == f,]
  # loop over values within this fleet
  for(irow in 1:nrow(cpue.f)){
    y <- cpue.f$year[irow]
    scale <- 1
    if(f == 7){
      scale <- 1000
    }
    tab[tab$year == y, col1name] <- scale*as.numeric(cpue.f$obs[irow])
    tab[tab$year == y, col2name] <- round(as.numeric(cpue.f$se_log[irow]), 4)
  }
}

# rename columns to match existing file
names(tab) <- c("Year","WCGBTS","Log SE", "Triennial", "Log SE", "IPHC", "Log SE")
write.csv(tab,
          file="C:/SS/skates/BigSkate_Doc/txt_files/data_summaries/table_of_index_inputs.csv",
          row.names=FALSE)
