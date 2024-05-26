############################################################################
#   FUNCTION    get_map(type)     HEX MAP 100km2 LOAD from GitHub by default
#   ALL maps on Projected CRS: ETRS89 / UTM zone 29N
############################################################################


# Load 100km2 gridded hexagonal map for Mainland Portugal by default
#
# Function to add the gridded hexagonal map of Mainland Portugal by default.
# This function has the argument "type" for other map types:
# - "hex_100" (default): 100km2 gridded hexagonal map for Mainland Portugal
# - "hex_25": 25km2 gridded hexagonal map for Mainland Portugal
# -
# -
# -


get_map <- function(type = "hex_100") {
  tb <- tibble(
    name = c(
      "hex_100", #1 - Load 100km2 gridded hexagonal map for Mainland Portugal
      "hex_25"   #2 - Load 25km2 gridded hexagonal map for Mainland Portugal
    ),
    url = c(
      "https://raw.githubusercontent.com/lbarqueira/pt1_db/main/maps/hex_cropped_portugal_100km2.gpkg",
      "https://raw.githubusercontent.com/lbarqueira/pt1_db/main/maps/hex_cropped_portugal_25km2.gpkg",
    )
  ) |>
    filter(name == type)

  ext <- sf::read_sf(tb$url)

  return(ext)
}