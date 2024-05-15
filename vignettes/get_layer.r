############################################################################
#   FUNCTION    get_layer(layer)
# Add data layer based on the spatial grid of the map obtained by
# get_map() -  Mainland Portugal HEX GRID MAP 100km2 area
#
# Layers:
# - Human population density from Global Human Settlement Layer (GHSL)
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
      "https://raw.githubusercontent.com/BjnNowak/frex_db/main/data/soil/soil_properties.csv", #1
      "https://raw.githubusercontent.com/BjnNowak/frex_db/main/data/crop/crop_distribution.csv" #2
    )
  ) |>
    filter(name == layer)

  ext <- read_csv(tb$url)

  return(ext)
}


pop <- get_layer(layer = "human")