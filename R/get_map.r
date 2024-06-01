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
# - "square_100": 100km2 gridded square map for Mainland Portugal
# - "square_100_uncropped": 100km2 gridded square UNCROPPED map Main Portugal
# -

get_map <- function(type = "hex_100") {
  tb <- dplyr::tibble(
    name = c(
      "hex_100", #1 - Load 100km2 gridded hexagonal map for Mainland Portugal
      "hex_25",   #2 - Load 25km2 gridded hexagonal map for Mainland Portugal
      "square_100", #3 - Load 100km2 gridded square map for Mainland Portugal
      "square_100_un" #4 - Load 100km2 gridded square uncropped map for Mainland Portugal # nolint
    ),
    url = c(
      "https://raw.githubusercontent.com/lbarqueira/pt1_db/main/maps/hex_cropped_portugal_100km2.gpkg", # nolint
      "https://raw.githubusercontent.com/lbarqueira/pt1_db/main/maps/hex_cropped_portugal_25km2.gpkg", # nolint
      "https://raw.githubusercontent.com/lbarqueira/pt1_db/main/maps/square_cropped_portugal_100km2.gpkg", # nolint
      "https://raw.githubusercontent.com/lbarqueira/pt1_db/main/maps/square_uncropped_portugal_100km2.gpkg" # nolint
    )
  ) |>
    dplyr::filter(name == type)

  ext <- sf::read_sf(tb$url)

  return(ext)
}