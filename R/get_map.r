############################################################################
#   FUNCTION    get_map(type)     HEX MAP 100km2 LOAD from GitHub by default
############################################################################


# Load 100km2 gridded hexagonal map for Mainland Portugal by default
#
# Function to add the gridded hexagonal map of Mainland Portugal by default.
# This function has the argument "type" for other map types:
# -
# -
# -
# -
# -


get_map <- function(type = "hex_100") {
  tb <- tibble(
    name = c(
      "hex_100" #1 - Load 100km2 gridded hexagonal map for Mainland Portugal
    ),
    url = c(
      "https://raw.githubusercontent.com/lbarqueira/pt1_db/main/maps/hex_cropped_portugal_100km2.gpkg" #1 # nolint
    )
  ) |>
    filter(name == type)

  ext <- tb$url

  return(ext)
}