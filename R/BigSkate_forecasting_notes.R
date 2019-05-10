#### values from Sigma_Examples.txt from Chantel

## Category 1 (baseline s = 0.5)                        
## P*   0.45    0.4     0.35    0.3     0.25
## 2021 0.935   0.873   0.813   0.754   0.696
## 2022 0.930   0.864   0.801   0.740   0.679
## 2023 0.926   0.856   0.790   0.725   0.662
## 2024 0.922   0.848   0.778   0.711   0.645
## 2025 0.917   0.840   0.767   0.697   0.629
## 2026 0.913   0.832   0.756   0.684   0.613
## 2027 0.909   0.824   0.745   0.670   0.598
## 2028 0.904   0.817   0.735   0.657   0.583
## 2029 0.900   0.809   0.724   0.645   0.568
## 2030 0.896   0.801   0.714   0.632   0.554


## Category 2 (baseline s = 1.0)                        
## P*   0.45    0.4     0.35    0.3     0.25
## 2021 0.874   0.762   0.661   0.569   0.484
## 2022 0.865   0.747   0.642   0.547   0.460
## 2023 0.857   0.733   0.624   0.526   0.438
## 2024 0.849   0.719   0.606   0.506   0.416
## 2025 0.841   0.706   0.589   0.486   0.396
## 2026 0.833   0.693   0.572   0.467   0.376
## 2027 0.826   0.680   0.556   0.449   0.358
## 2028 0.818   0.667   0.540   0.432   0.340
## 2029 0.810   0.654   0.524   0.415   0.323
## 2030 0.803   0.642   0.510   0.399   0.307


## Category 3 (sigma = 2)                       
## P*           0.45    0.4     0.35    0.3     0.25
## All Years    0.778   0.602   0.463   0.350   0.260


#### for forecast file:
## # Sigma values below based on Category 2 values with P* = 0.45
## #Yr    Sigma
## 2019   1.0
## 2020   1.0
## 2021   0.874  
## 2022   0.865  
## 2023   0.857  
## 2024   0.849  
## 2025   0.841  
## 2026   0.833  
## 2027   0.826  
## 2028   0.818  
## 2029   0.810  
## 2030   0.803
## -9999  0

# mean landings for the years 2014:2018:
mean(bs72$catch$Obs[bs72$catch$Yr %in% 2014:2018 & bs72$catch$Fleet == 1])
#[1] 258.4
mean(bs72$catch$Obs[bs72$catch$Yr %in% 2014:2018 & bs72$catch$Fleet == 4])
#[1] 54.76

# resulting fixed input catch for forecast file:
#_Yr Seas Fleet Catch(or_F)
## 2019 1    1     258.4
## 2019 1    4      54.76
## 2020 1    1     258.4
## 2020 1    4      54.76

mod.fore <- SS_output(file.path('c:/SS/skates/models/bigskate72_share_dome/',
                                'forecasts/default_2yr_fixed_3.30.13.02'))

yrs.forecast <- 2019:2030
Landings <- (mod.fore$timeseries$"retain(B):_1" +
               mod.fore$timeseries$"retain(B):_4")[mod.fore$timeseries$Yr %in% yrs.forecast]
EstCatch <- (mod.fore$timeseries$"dead(B):_1" +
               mod.fore$timeseries$"dead(B):_4")[mod.fore$timeseries$Yr %in% yrs.forecast]
OFL <- mod.fore$derived_quants[paste0("OFLCatch_", yrs.forecast), "Value"]
ACL <- mod.fore$derived_quants[paste0("ForeCatch_", yrs.forecast), "Value"]
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

