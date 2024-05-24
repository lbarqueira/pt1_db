###############################################################################
#                           CO2 EMISSIONS DENSITY
# Dataset: Global Greenhouse Gas Emissions - EDGAR v8.0
# https://edgar.jrc.ec.europa.eu/gallery?release=v80ghg&substance=CO2&sector=TOTALS
# Product: EDGAR V80_FT2022_GHG TOTALS CO2, 2022, TXT Format
#                              TXT Format wrangling / Dataframe
###############################################################################

# 0. INSTALL & LOAD LIBRARIES
#----------------------------

libs <- c(
  "terra",
  "sf",
  "tidyverse",
  "readr",
  "janitor"
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
###########         GITHUB - COPY LINK ADDRESS        ###############

# Function get_map
get_map <- function() {
  hex <- sf::read_sf(
    "https://raw.githubusercontent.com/lbarqueira/pt1_db/main/maps/hex_cropped_portugal_100km2.gpkg"
  )
  return(hex)
}

hex_poly <- get_map()

hex_poly |>
  ggplot() +
  geom_sf()

#### Analyze ####

length(hex_poly$grid_id) # 1008
class(hex_poly) # [1] "sf"         "tbl_df"     "tbl"        "data.frame"
glimpse(hex_poly)
st_crs(hex_poly) # (...) EPSG ,25829
names(hex_poly) # [1] "grid_id" "geom"
summary(st_area(hex_poly))
#      Min.   1st Qu.    Median      Mean   3rd Qu.      Max.
#     13675 100000000 100000000  88033798 100000000 100000000

# where is grid_id = 135
hex_poly |>
  ggplot() +
  geom_sf() +
  geom_sf_label(
    aes(label = ifelse(grid_id == 135, grid_id, NA))
  )

# ------------------------     DATA   ------------------------------
####################################################################
############ Greenhouse Gas Emissions CO2 - TXT Format     #########
####################################################################

# 1. DOWNLOAD CO2 DATA - Done only once !
#---------------------
# https://edgar.jrc.ec.europa.eu/dataset_ghg80
# Annual gridmaps (1970-2022)
# Global Greenhouse Gas Emissions - EDGAR v8.0
# https://edgar.jrc.ec.europa.eu/gallery?release=v80ghg&substance=CO2&sector=TOTALS
# TXT format for 2022

url <- "https://jeodpp.jrc.ec.europa.eu/ftp/jrc-opendata/EDGAR/datasets/v80_FT2022_GHG/CO2/TOTALS/emi_txt/v8.0_FT2022_GHG_CO2_2022_TOTALS.zip"

# done only once ...
get_co2_data <- function() {
  url <- url
  download.file(
    url,
    destfile = paste0("./raw_data/edgar_v8/", basename(url)), mode = "wb"
  )
}

get_co2_data()

# 2. UNZIP FILE - Done only once !
#---------------

co2_zip_file <- list.files(
  path = "/home/barqueira/luis_barqueira/pt1_db/raw_data/edgar_v8",
  pattern = "*.zip",
  full.names = TRUE
)

getwd()
setwd("/home/barqueira/luis_barqueira/pt1_db/raw_data/edgar_v8")

unzip(co2_zip_file)

# turn to main directory
setwd("/home/barqueira/luis_barqueira/pt1_db")
getwd()

# 3. LOAD AND CLEAN THE DATA - begin here !
#---------------------------

file <- list.files(
  path = "/home/barqueira/luis_barqueira/pt1_db/raw_data/edgar_v8",
  pattern = "*.txt",
  full.names = TRUE
)

# "/home/barqueira/luis_barqueira/pt1_db/raw_data/edgar_v8/v8.0_FT2022_GHG_CO2_2022_TOTALS.txt"

read_df <- function() {
  main_df <- readr::read_delim(
    file,
    delim = ";",
    col_names = TRUE
  ) |>
    janitor::row_to_names(
      row_number = 2
    )

  names(main_df) <- "lat;long;emission"

  df <- main_df |>
    tidyr::separate(
      "lat;long;emission",
      into = c("lat", "long", "emission"),
      sep = ";"
    )

  final_df <- df |>
    dplyr::mutate_if(
      is.character, as.numeric
    )
  return(final_df)
}

final_df <- read_df()

problems(final_df)

summary(final_df)
#       lat               long             emission
#  Min.   :-85.200   Min.   :-180.000   Min.   :        0
#  1st Qu.:-20.300   1st Qu.: -91.700   1st Qu.:       12
#  Median :  9.900   Median :  -7.200   Median :       63
#  Mean   :  9.932   Mean   :  -3.887   Mean   :     9181
#  3rd Qu.: 40.300   3rd Qu.:  82.200   3rd Qu.:      318
#  Max.   : 89.900   Max.   : 179.900   Max.   :408823000


# 5. POINT-WITHIN HEX POLYGON - 100km2
#----------------------------

crsLONGLAT <- "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"

names(final_df) # [1] "lat"      "long"     "emission"

# convert df to sf
co2_sf <- final_df |>
  sf::st_as_sf(
    coords = c(
      "long", "lat"
    )
  ) |>
  sf::st_set_crs(crsLONGLAT)

names(co2_sf) # [1] "emission" "geometry"
class(co2_sf$geometry) # [1] "sfc_POINT" "sfc"


# returning to hex_poly to create field area_km2
# the area in km2 of each multipolygon
names(hex_poly) # [1] "grid_id" "geom"
st_crs(hex_poly) # (...) "EPSG",25829

# Criada area em km2
area_km2 <- st_area(hex_poly) |>
  units::set_units("km^2") |>
  as.double()

hex_poly$area_km2 <- area_km2

names(hex_poly) # [1] "grid_id"  "geom"     "area_km2"

# transform hex_poly (metrics) to long lat crs
hex_poly_longlat <- hex_poly |>
  sf::st_transform(crsLONGLAT)


# join co2_sf with hex_poly_longlat

co2_portugal_sf <- sf::st_join(
  co2_sf, hex_poly_longlat,
  join = sf::st_within
) |>
  drop_na()

class(co2_portugal_sf)
# [1] "sf"         "tbl_df"     "tbl"        "data.frame"
names(co2_portugal_sf)
# [1] "emission" "geometry" "grid_id"  "area_km2"

co2_portugal_sf <- co2_portugal_sf |>
  sf::st_transform(st_crs(hex_poly))

glimpse(co2_portugal_sf)

names(co2_portugal_sf) # [1] "emission" "geometry" "grid_id"  "area_km2"

st_crs(co2_portugal_sf) # "EPSG",25829

nrow(co2_portugal_sf) # 928

# 6. AGGREGATE AND JOIN
#----------------------

co2_portugal_sum <- co2_portugal_sf |>
  dplyr::group_by(grid_id) |>
  dplyr::summarise_at(
    vars(emission),
    list(sum_co2 = sum)
  ) |>
  sf::st_set_geometry(
    NULL
  )

summary(co2_portugal_sum)
#    grid_id          sum_co2
#  Min.   :   3.0   Min.   :    858.4
#  1st Qu.: 272.2   1st Qu.:   7793.4
#  Median : 499.5   Median :  14792.9
#  Mean   : 503.7   Mean   :  44688.0
#  3rd Qu.: 731.8   3rd Qu.:  31055.2
#  Max.   :1005.0   Max.   :1598450.0

co2_portugal_hex <- dplyr::left_join(
  hex_poly, co2_portugal_sum,
  by = "grid_id"
)

summary(co2_portugal_hex)

#   grid_id                  geom         area_km2            sum_co2
# Min.   :   1.0   MULTIPOLYGON :1008   Min.   :  0.01368   Min.   :    858.4
# 1st Qu.: 252.8   epsg:25829   :   0   1st Qu.:100.00000   1st Qu.:   7793.4
# Median : 504.5   +proj=utm ...:   0   Median :100.00000   Median :  14792.9
# Mean   : 504.5                        Mean   : 88.03380   Mean   :  44688.0
# 3rd Qu.: 756.2                        3rd Qu.:100.00000   3rd Qu.:  31055.2
# Max.   :1008.0                        Max.   :100.00000   Max.   :1598450.0
#                                                           NA's   :218

co2_portugal_hex$sum_co2 <- round(
  co2_portugal_hex$sum_co2, 0
)

co2_portugal_hex$sum_co2[
  is.na(co2_portugal_hex$sum_co2)
] <- 0

co2_portugal_hex$sum_co2 <- co2_portugal_hex$sum_co2 / 1000


summary(co2_portugal_hex$sum_co2)
#     Min.  1st Qu.   Median     Mean  3rd Qu.     Max.
#    0.000    2.824   10.272   35.023   25.569 1598.450

summary(co2_portugal_hex)

# Compute density by cell
# Finally we just compute densities:

co2_portugal_hex_final <- co2_portugal_hex |>
  # Compute density by cell
  mutate(co2_emission_km2 = sum_co2 / area_km2)

names(co2_portugal_hex_final)
# [1] "grid_id"          "geom"             "area_km2"         "sum_co2"
# [5] "co2_emission_km2"

summary(co2_portugal_hex_final)
# co2_emission_km2
# Min.   :  0.0000
# 1st Qu.:  0.0298
# Median :  0.1064
# Mean   :  0.7389
# 3rd Qu.:  0.2712
# Max.   :349.4334

# let`s understand the maximum value`
max_co2_emission_km2_entry <- co2_portugal_hex_final |>
  filter(co2_emission_km2 == max(co2_emission_km2))
# grid_id  135
# area_km2  0.152
# sum_co2  53.0
# co2_emission_km2  349
53 / 0.152

# See if this value is a outlier
portugal_co2_without_max <- co2_portugal_hex_final |>
  filter(!grid_id == 135)

summary(portugal_co2_without_max)

# co2_emission_km2
# Min.   : 0.00000
# 1st Qu.: 0.02975
# Median : 0.10620
# Mean   : 0.39259
# 3rd Qu.: 0.27070
# Max.   :16.01825

# conclusion, is in fact an outlier
# so we are going to give to this grid the: median value ()
co2_portugal_hex_corrected <- co2_portugal_hex_final
co2_portugal_hex_corrected[135, ]$co2_emission_km2 <- 0.10620

summary(co2_portugal_hex_corrected)
#    grid_id                  geom         area_km2            sum_co2
# Min.   :   1.0   MULTIPOLYGON :1008   Min.   :  0.01368   Min.   :   0.000
# 1st Qu.: 252.8   epsg:25829   :   0   1st Qu.:100.00000   1st Qu.:   2.824
# Median : 504.5   +proj=utm ...:   0   Median :100.00000   Median :  10.272
# Mean   : 504.5                        Mean   : 88.03380   Mean   :  35.023
# 3rd Qu.: 756.2                        3rd Qu.:100.00000   3rd Qu.:  25.569
# Max.   :1008.0                        Max.   :100.00000   Max.   :1598.450
# co2_emission_km2
# Min.   : 0.00000
# 1st Qu.: 0.02977
# Median : 0.10620
# Mean   : 0.39231
# 3rd Qu.: 0.27055
# Max.   :16.01825


# 7. BREAKS AND COLORS
#----------------------

breaks <- classInt::classIntervals(
  co2_portugal_hex_corrected$co2_emission_km2,
  n = 6,
  style = "pretty"
)$brks

cols <- colorRampPalette(
  rev(c(
    "#451a40", "#822b4c", "#b74952",
    "#e17350", "#f4a959", "#eae2b7"
  ))
)


ggplot(data = co2_portugal_hex_corrected) +
  geom_sf(aes(fill = co2_emission_km2), color = NA) +
  scale_fill_gradientn(
    name = "ktons / km2",
    colors = cols(11),
    breaks = breaks
  )

#######################################################################
#########     Prepare to save as CSV for future USE     ###############
#######################################################################
co2_portugal_hex_corrected
names(co2_portugal_hex_corrected)
# [1] "grid_id"          "geom"             "area_km2"         "sum_co2"
# [5] "co2_emission_km2"

class(co2_portugal_hex_corrected)
# [1] "sf"         "tbl_df"     "tbl"        "data.frame"

co2_emissions_density <- co2_portugal_hex_corrected |>
  select(grid_id, co2_emission_km2) |>
  st_drop_geometry()

names(co2_emissions_density)
summary(co2_emissions_density)

# Save as co2_emissions_density.csv

write.csv(
  co2_emissions_density, "./data/co2_emission/co2_emissions_density.csv",
  row.names = FALSE
)