############################################################################
#   FUNCTION    get_layer(layer)
# Add data layer based on the spatial grid of the map obtained by
# get_map() -  Mainland Portugal HEX GRID MAP 100km2 area
#
# Layers:
# - Human population density from Global Human Settlement Layer (GHSL) / km2
# - Greenhouse Gas Emissions, CO2, density from EDGAR v8.0 / ktons per km2
# -
# -
# -
############################################################################

###########  get_layer() - function implementation #######################
get_layer <- function(layer) {
  tb <- tidyverse::tibble(
    name = c(
      "human", #1 - Human population density from GHSL
      "co2" #2 - CO2 emissions
    ),
    url = c(
      "https://raw.githubusercontent.com/lbarqueira/pt1_db/main/data/population/human_pop_density.csv", #1 # nolint
      "https://raw.githubusercontent.com/lbarqueira/pt1_db/main/data/co2_emission/co2_emissions_density.csv" #2 # nolint
    )
  ) |>
    tidyverse::filter(name == layer)

  ext <- readr::read_csv(tb$url)

  return(ext)
}