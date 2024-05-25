############################################################################
#   FUNCTION    get_map()        HEX MAP 100km2 LOAD from GitHub
############################################################################
get_map <- function() {
  hex <- sf::read_sf(
    "https://raw.githubusercontent.com/lbarqueira/pt1_db/main/maps/hex_cropped_portugal_100km2.gpkg"
  )
  return(hex)
}