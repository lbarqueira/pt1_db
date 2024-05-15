############################################################################
#   FUNCTION    get_layer(layer)
# Add data layer based on the spatial grid of the map obtained by
# get_map() -  Mainland Portugal HEX GRID MAP 100km2 area
#
# Layers:
# - Human population density from Global Human Settlement Layer (GHSL) / km2
# - (...)
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
      "https://raw.githubusercontent.com/lbarqueira/pt1_db/main/data/population/human_pop_density.csv" #2 # nolint
    )
  ) |>
    filter(name == layer)

  ext <- read_csv(tb$url)

  return(ext)
}


pop <- get_layer(layer = "human")

names(pop) # [1] "grid_id"             "population_area_km2"
nrow(pop) # [1] 1008