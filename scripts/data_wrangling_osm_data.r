###############################################################################
#                               Open Street Maps
#             Gas Stations (density, i.e., number per km2 on a 100km2 grid)
# Data: @OpenStreetMap contributors
# https://dominicroye.github.io/en/2018/accessing-openstreetmap-data-with-r/?s=03
#
###############################################################################

# 0. INSTALL & LOAD LIBRARIES
#----------------------------

libs <- c(
  "sf",
  "tidyverse",
  "readr",
  "osmdata"
)

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

###########       LOAD HEX MAP 100km2 FROM GITHUB     ###############
source("https://raw.githubusercontent.com/lbarqueira/pt1_db/main/R/get_map.r")

hex <- get_map()

hex |>
  ggplot() +
  geom_sf()

#### Analyze ####

length(hex$grid_id) # 1008
class(hex) # [1] "sf"         "tbl_df"     "tbl"        "data.frame"
glimpse(hex)
st_crs(hex) # (...) EPSG ,25829
names(hex) # [1] "grid_id" "geom"
summary(st_area(hex))
#      Min.   1st Qu.    Median      Mean   3rd Qu.      Max.
#     13675 100000000 100000000  88033798 100000000 100000000

# ------------------------     DATA   ------------------------------

crsLONGLAT <- "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"

# transform hex (metrics) to long lat crs
hex_longlat <- hex |>
  sf::st_transform(crsLONGLAT)

# get Mainland Portugal bounding box

portugal_bb <- st_bbox(hex_longlat)

#      xmin      ymin      xmax      ymax
# -9.516980 36.961850 -6.189352 42.154419

portugal_bb |>
  st_as_sfc() |>
  ggplot() +
  geom_sf() +
  geom_sf(data = hex_longlat)

# building the query for fuel gas stations
# The fuel tag is used to map a fuel station, also known as a filling station

fuel_stations <- portugal_bb |>
  opq(timeout = 25 * 1000) |>
  osmdata::add_osm_feature("amenity", "fuel") |>
  osmdata::osmdata_sf()

fuel_points <- fuel_stations$osm_points |>
  select(geometry)

class(fuel_points) # [1] "sf"         "data.frame"
names(fuel_points) # [1] "geometry"

#final map
ggplot(fuel_points) +
  geom_sf(
    colour = "#08519c",
    fill = "#08306b",
    alpha = .5,
    size = 1,
    shape = 21
  ) +
  theme_void()


# join fuel_points with hex_longlat

fuel_portugal_sf <- sf::st_join(
  fuel_points, hex_longlat,
  join = sf::st_within
) |>
  drop_na()

nrow(fuel_portugal_sf) # [1] 10582
names(fuel_portugal_sf) # [1] "grid_id"  "geometry"

#final map
ggplot(fuel_portugal_sf) +
  geom_sf(
    colour = "#08519c",
    fill = "#08306b",
    alpha = .5,
    size = 1,
    shape = 21
  ) +
  theme_void()

# Criada area em km2
area_km2 <- st_area(hex) |>
  units::set_units("km^2") |>
  as.double()

hex$area_km2 <- area_km2

names(hex) # [1] "grid_id"  "geom"     "area_km2"

# transform hex (metrics) to long lat crs
hex_longlat <- hex |>
  sf::st_transform(crsLONGLAT)


# join fuel_points with hex_longlat

fuel_portugal_sf <- sf::st_join(
  fuel_points, hex_longlat,
  join = sf::st_within
) |>
  drop_na()

class(fuel_portugal_sf)
# [1] "sf"         "data.frame"
names(fuel_portugal_sf)
# [1] "grid_id"  "area_km2" "geometry"

fuel_portugal_sf <- fuel_portugal_sf |>
  sf::st_transform(st_crs(hex))

glimpse(fuel_portugal_sf)

names(fuel_portugal_sf) # [1] "grid_id"  "area_km2" "geometry"

st_crs(fuel_portugal_sf) # "EPSG",25829

nrow(fuel_portugal_sf) # [1] 10582

# 6. AGGREGATE AND JOIN
#----------------------

fuel_portugal_sum <- fuel_portugal_sf |>
  dplyr::group_by(grid_id) |>
  count() |>
  as_tibble() |>
 select(-geometry)
  

names(fuel_portugal_sum)
# [1] "grid_id" "n"

summary(fuel_portugal_sum)
#    grid_id             n
# Min.   :   1.0   Min.   :  1.00
# 1st Qu.: 194.8   1st Qu.:  2.00
# Median : 393.5   Median :  6.00
# Mean   : 427.9   Mean   : 18.24
# 3rd Qu.: 650.2   3rd Qu.: 17.00
# Max.   :1004.0   Max.   :675.00

fuel_portugal_hex <- dplyr::left_join(
  hex, fuel_portugal_sum,
  by = "grid_id"
)

summary(fuel_portugal_hex)

#    grid_id                  geom         area_km2               n
# Min.   :   1.0   MULTIPOLYGON :1008   Min.   :  0.01368   Min.   :  1.00
# 1st Qu.: 252.8   epsg:25829   :   0   1st Qu.:100.00000   1st Qu.:  2.00
# Median : 504.5   +proj=utm ...:   0   Median :100.00000   Median :  6.00
# Mean   : 504.5                        Mean   : 88.03380   Mean   : 18.24
# 3rd Qu.: 756.2                        3rd Qu.:100.00000   3rd Qu.: 17.00
# Max.   :1008.0                        Max.   :100.00000   Max.   :675.00
#                                                           NA's   :428

fuel_portugal_hex$n <- round(
  fuel_portugal_hex$n, 0
)

fuel_portugal_hex$n[
  is.na(fuel_portugal_hex$n)
] <- 0


summary(fuel_portugal_hex$n)
#   Min. 1st Qu.  Median    Mean 3rd Qu.    Max.
#    0.0     0.0     1.0    10.5     8.0   675.0

summary(fuel_portugal_hex)

# Compute density by cell
# Finally we just compute densities:

fuel_portugal_hex_final <- fuel_portugal_hex |>
  # Compute density by cell
  mutate(gas_stations_km2 = n / area_km2)



names(fuel_portugal_hex_final)
# [1] "grid_id"      "geom"             "area_km2"         "n"
# [5] "gas_stations_km2"

summary(fuel_portugal_hex_final)
# gas_stations_km2
# Min.   :0.000
# 1st Qu.:0.000
# Median :0.010
# Mean   :0.122
# 3rd Qu.:0.090
# Max.   :7.473

# let`s understand the maximum value`
max_fuel_emission_km2_entry <- fuel_portugal_hex_final |>
  filter(gas_stations_km2 == max(gas_stations_km2))
# grid_id  196
# area_km2  90.3
# n  675
# gas_stations_km2  7.47
675 / 90.3

# where is grid_id = 196
hex |>
  ggplot() +
  geom_sf() +
  geom_sf_label(
    aes(label = ifelse(grid_id == 196, grid_id, NA))
  )


# See if this value is a outlier
portugal_fuel_without_max <- fuel_portugal_hex_final |>
  filter(!grid_id == 196)

summary(portugal_fuel_without_max)

# gas_stations_km2
# Min.   :0.0000
# 1st Qu.:0.0000
# Median :0.0100
# Mean   :0.1147
# 3rd Qu.:0.0900
# Max.   :3.3900

# conclusion, it is not an outlier
# so we are going to give to this grid the: median value ()
fuel_portugal_hex_corrected <- fuel_portugal_hex_final


# 7. BREAKS AND COLORS
#----------------------

breaks <- classInt::classIntervals(
  fuel_portugal_hex_corrected$gas_stations_km2,
  n = 6,
  style = "pretty"
)$brks

cols <- colorRampPalette(
  rev(c(
    "#451a40", "#822b4c", "#b74952",
    "#e17350", "#f4a959", "#eae2b7"
  ))
)


ggplot(data = fuel_portugal_hex_corrected) +
  geom_sf(aes(fill = gas_stations_km2), color = NA) +
  scale_fill_gradientn(
    name = "gas stations / km2",
    colors = cols(11),
    breaks = breaks
  )

#######################################################################
#########     Prepare to save as CSV for future USE     ###############
#######################################################################
fuel_portugal_hex_corrected
names(fuel_portugal_hex_corrected)
# [1] "grid_id"          "geom"             "area_km2"         "n"
# [5] "gas_stations_km2"

class(fuel_portugal_hex_corrected)
# [1] "sf"         "tbl_df"     "tbl"        "data.frame"

gas_stations_density <- fuel_portugal_hex_corrected |>
  select(grid_id, gas_stations_km2) |>
  st_drop_geometry()

names(gas_stations_density) # [1] "grid_id" "gas_stations_km2"
summary(gas_stations_density)

# Save as gas_stations_density.csv

write.csv(
  gas_stations_density, "./data/gas_stations/gas_stations_density.csv",
  row.names = FALSE
)