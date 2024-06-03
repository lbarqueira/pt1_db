# 1. INSTALL & LOAD PACKAGES - source depends on "tidyverse" package
libs <- c(
  "tidyverse"
)

installed_libraries <- libs %in% rownames(
  installed.packages()
)

if (any(installed_libraries == FALSE)) {
  install.packages(libs[!installed_libraries])
}

# load libraries
invisible(
  lapply(
    libs, library,
    character.only = TRUE
  )
)

source("https://raw.githubusercontent.com/lbarqueira/pt1_db/main/R/get_layer.r")

pop <- get_layer(layer = "human")

names(pop) # [1] "grid_id"             "population_km2"
nrow(pop) # [1] 1008
summary(pop)
#     grid_id       population_km2
#  Min.   :   1.0   Min.   :   0.00
#  1st Qu.: 252.8   1st Qu.:   5.77
#  Median : 504.5   Median :  16.64
#  Mean   : 504.5   Mean   : 109.23
#  3rd Qu.: 756.2   3rd Qu.:  70.07
#  Max.   :1008.0   Max.   :6201.82

co2_density <- get_layer(layer = "co2")

names(co2_density) # [1] "grid_id"          "co2_emission_km2"
nrow(co2_density) # [1] 1008
summary(co2_density)
#     grid_id       co2_emission_km2
#  Min.   :   1.0   Min.   : 0.00000
#  1st Qu.: 252.8   1st Qu.: 0.02977
#  Median : 504.5   Median : 0.10620
#  Mean   : 504.5   Mean   : 0.39231
#  3rd Qu.: 756.2   3rd Qu.: 0.27055
#  Max.   :1008.0   Max.   :16.01825

gas_stations_denstity <- get_layer(layer = "gas_stations")

names(gas_stations_denstity) # [1] "grid_id"     "gas_stations_km2"
nrow(gas_stations_denstity) # [1] 1008
summary(gas_stations_denstity)
#     grid_id       gas_stations_km2
#  Min.   :   1.0   Min.   :0.000
#  1st Qu.: 252.8   1st Qu.:0.000
#  Median : 504.5   Median :0.010
#  Mean   : 504.5   Mean   :0.122
#  3rd Qu.: 756.2   3rd Qu.:0.090
#  Max.   :1008.0   Max.   :7.473