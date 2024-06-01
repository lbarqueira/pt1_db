############################################################################
#   FUNCTION    get_layer(layer)
# Add data layer based on the spatial grid of the map obtained by
# get_map() -  Mainland Portugal HEX GRID MAP 100km2 area
#
# Layers:
# - Human population density from Global Human Settlement Layer (GHSL) / km2
# - Greenhouse Gas Emissions, CO2, density from EDGAR v8.0 / ktons per km2
############################################################################

# 1. INSTALL & LOAD PACKAGES
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

###########  get_layer() - function implementation #######################
get_layer <- function(layer) {
  tb <- tibble(
    name = c(
      "human", #1 - Human population density from GHSL
      "co2" #2 - CO2 emissions
    ),
    url = c(
      "https://raw.githubusercontent.com/lbarqueira/pt1_db/main/data/population/human_pop_density.csv", #1 # nolint
      "https://raw.githubusercontent.com/lbarqueira/pt1_db/main/data/co2_emission/co2_emissions_density.csv" #2 # nolint
    )
  ) |>
    filter(name == layer)

  ext <- read_csv(tb$url)

  return(ext)
}


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