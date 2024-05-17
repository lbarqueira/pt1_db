########################################################
# CREATE SQUARE MAP OF MAINLAND PORTUGAL WITH R
#   UNCROPPED BY PT1 BORDERS, 100KM2 AREA FOR EACH POLYGON
#              Luis Barqueira 17/05/2024
########################################################

# 0. INSTALL & LOAD LIBRARIES
#----------------------------
# libraries we need

libs <- c(
  "giscoR",
  "sf",
  "tidyverse"
)

# install missing libraries
installed_libs <- libs %in% rownames(
  installed.packages()
)

if (any(installed_libs == FALSE)) {
  install.packages(
    libs[!installed_libs]
  )
}

# load libraries
invisible(lapply(libs, library, character.only = TRUE))

#######################################################
# 1. MAKE MAINLAND PORTUGAL SQUARES, 100KM2
#######################################################

portugal_sf <- giscoR::gisco_get_nuts(
  nuts_id = "PT1",
  year = "2021", # depends on the data, if old or recent
  resolution = "1",
  nuts_level = "1",
  update_cache = TRUE
)

# EPSG:25829 - ETRS89 / UTM zone 29N
portugal_transformed <- portugal_sf |>
  sf::st_transform(25829)

st_crs(portugal_transformed)

st_is_longlat(portugal_transformed) # [1] FALSE
# sf object is in a metric CRS
# tem de estar num CRS metrico e nao long/lat

portugal_square_100 <- sf::st_make_grid(
  portugal_transformed,
  cellsize = units::as_units(
    100, "km^2"
  ),
  what = "polygons",
  square = TRUE
) # Now I do not do intersection


# Select the hexagons that are included in the first object
# (portugal_transformed).
# This process does not crop the hexagons.

portugal_square_100 <- portugal_square_100[portugal_transformed]
class(portugal_square_100) # [1] "sfc_POLYGON" "sfc"

# convert from sfc object to sf object
portugal_square_100_final <- portugal_square_100 |>
  sf::st_as_sf() |>
  sf::st_make_valid()

class(portugal_square_100_final) # [1] "sf"    "data.frame"
names(portugal_square_100_final) # [1] "x"

# rename
sf::st_geometry(portugal_square_100_final) <- "geometry"
names(portugal_square_100_final) # [1] "geometry"

portugal_square_100_final <- portugal_square_100_final |>
  dplyr::filter(
    !grepl(
      "POINT",
      sf::st_geometry_type(geometry)
    )
  ) |>
  sf::st_cast("MULTIPOLYGON") |>
  dplyr::mutate(
    grid_id = seq_len(n()) # row_number() as alternative
  )


# ggplot
ggplot() +
  geom_sf(data = portugal_transformed) +
  geom_sf(data = portugal_square_100_final, alpha = 0.3) +
  theme_void()

summary(st_area(portugal_square_100_final))

#    Min. 1st Qu.  Median    Mean 3rd Qu.    Max.
#   1e+08   1e+08   1e+08   1e+08   1e+08   1e+08

sum(st_area(portugal_square_100_final)) # 1.005e+11 [m^2]
sum(st_area(portugal_square_100_final)) / 1000000 # 100500 [m^2]
nrow(portugal_square_100_final) # [1] 1005
names(portugal_square_100_final) # [1] "geometry" "grid_id"

####################################################################
############# SAVE AS GPKG #########################################

sf::st_write(
  portugal_square_100_final,
  "./maps/square_uncropped_portugal_100km2.gpkg", driver = "GPKG",
  delete_layer = TRUE # To force overwrite file
)  # Create a geopackage file


############# TEST - LOAD GPKG #####################################
nc <- sf::st_read("./maps/square_uncropped_portugal_100km2.gpkg")

ggplot() +
  geom_sf(data = portugal_transformed) +
  geom_sf(data = nc, alpha = 0.3) +
  theme_void()

names(nc) # [1] "grid_id" "geom"

sum(st_area(nc)) # 1.005e+11 [m^2]
sum(st_area(nc)) / 1000000 # 100500 [m^2]
st_crs(nc) # (...) "EPSG",25829

st_area(nc)
summary(st_area(nc))
#    Min. 1st Qu.  Median    Mean 3rd Qu.    Max.
#   1e+08   1e+08   1e+08   1e+08   1e+08   1e+08

names(nc) # [1] "grid_id"  "geom"