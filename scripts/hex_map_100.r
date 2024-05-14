########################################################
# CREATE HEX MAP OF MAINLAND PORTUGAL WITH R
#   CROPPED BY PT1 BORDERS, 100KM2 AREA FOR EACH POLYGON
#              Luis Barqueira 14/05/2024
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
# 1. MAKE MAINLAND PORTUGAL HEXAGONS, 100KM2
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

portugal_hex_100 <- sf::st_make_grid(
  portugal_transformed,
  cellsize = units::as_units(
    100, "km^2"
  ),
  what = "polygons",
  square = FALSE
) |>
  sf::st_intersection(
    sf::st_buffer(
      portugal_transformed, 0
    )
  ) |>
  sf::st_as_sf() |>
  sf::st_make_valid()

# rename
sf::st_geometry(portugal_hex_100) <- "geometry"

portugal_hex_100_final <- portugal_hex_100 |>
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
  geom_sf(data = portugal_hex_100_final, alpha = 0.3) +
  theme_void()

summary(st_area(portugal_hex_100_final))

#      Min.   1st Qu.    Median      Mean   3rd Qu.      Max.
#     13675 100000000 100000000  88033798 100000000 100000000

sum(st_area(portugal_hex_100_final)) # 88738068090 [m^2]
sum(st_area(portugal_hex_100_final)) / 1000000 # 88738.07 [km2]
nrow(portugal_hex_100_final) # [1] 1008
names(portugal_hex_100_final) # [1] "geometry" "grid_id"

####################################################################
############# SAVE AS GPKG #########################################

sf::st_write(
  portugal_hex_100_final,
  "./maps/hex_cropped_portugal_100km2.gpkg", driver = "GPKG",
  delete_layer = TRUE # To force overwrite file
)  # Create a geopackage file


############# TEST - LOAD GPKG #####################################
nc <- sf::st_read("./maps/hex_cropped_portugal_100km2.gpkg")

ggplot() +
  geom_sf(data = portugal_transformed) +
  geom_sf(data = nc, alpha = 0.3) +
  theme_void()

names(nc) # [1] "grid_id" "geom"

sum(st_area(nc)) # 88738068090 [m^2]
sum(st_area(nc)) / 1000000 # 88738.07 [km2]
st_crs(nc) # (...) "EPSG",25829

st_area(nc)
summary(st_area(nc))
#      Min.   1st Qu.    Median      Mean   3rd Qu.      Max.
#     13675 100000000 100000000  88033798 100000000 100000000

names(nc) # [1] "grid_id"  "geom"