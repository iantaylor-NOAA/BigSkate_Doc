# make plot of landings by state

catch.dir <- 'C:/SS/skates/catch'

catch.table.doc <- read.csv(file.path(catch.dir, '../BigSkate_Doc/txt_files/data_summaries',
                                      'reconstructed_landings_by_state.csv'))
# this could point to any model
bs66dir <- "C:/SS/skates/models//bigskate66_tri_init_fish_asymptotic"
# read data file
dat <- SS_readdat_3.30(file = file.path(bs66dir, "data.ss_new"))

newcatch <- rbind(data.frame(year = 1916:2018,
                             seas = 1,
                             fleet = 1,
                             catch = catch.table.doc$CA,
                             catch_se = 0.01),
                  data.frame(year = 1916:2018,
                             seas = 1,
                             fleet = 2,
                             catch = catch.table.doc$OR,
                             catch_se = 0.01),
                  data.frame(year = 1916:2018,
                             seas = 1,
                             fleet = 3,
                             catch = catch.table.doc$WA,
                             catch_se = 0.01),
                  data.frame(year = 1916:2018,
                             seas = 1,
                             fleet = 4,
                             catch = catch.table.doc$Tribal,
                             catch_se = 0.01))

dat$catch <- dat$newcatch
dat$fleetnames <- c("California", "Oregon", "Washington", "Tribal")

# writedat did work so catch values and fleetnames manually pasted into the data file
SS_writedat(datlist = dat,
            outfile = 'C:/SS/skates/models/bigskate73_fake_catch_for_plot/BSKT2019_data.ss',
            overwrite = TRUE)
getbs(73)
SS_plots(bs73, plot=7)
