############################################################################
#   FUNCTION    get_map()        HEX MAP 100km2 LOAD from GitHub
############################################################################


# Load 100km2 gridded hexagonal map for Mainland Portugal
#
# Function to add the gridded hexagonal map of Mainland Portugal.
# This function has no argument
get_map <- function(type = "hex_100") {
  hex <- sf::read_sf(
    "https://raw.githubusercontent.com/lbarqueira/pt1_db/main/maps/hex_cropped_portugal_100km2.gpkg"
  )
  return(hex)
}