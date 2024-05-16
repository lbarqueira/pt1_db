###############################################################################
#                           HUMAN POPULATION DENSITY
# Dataset: Human population density from Global Human Settlement Layer (GHSL)
# https://human-settlement.emergency.copernicus.eu/download.php?ds=pop
# Product: GHS-POP, epoch: 2020, resolution: 3 arcsec, coordinate system: WGS84
#                              RASTER wrangling
###############################################################################

# 1. INSTALL & LOAD PACKAGES

libs <- c(
  "terra",
  "sf",
  "tidyverse",
  "tidyterra",
  # Additional for hex grids
  # Supporting for units and bridge raster to polygon
  "units",
  "exactextractr"
)

installed_libraries <- libs %in% rownames(
  installed.packages()
)

if (any(installed_libraries == FALSE)) {
  install.packages(libs[!installed_libraries])
}

# load libraries
invisible(
  lapply(
    libs, library,
    character.only = TRUE
  )
)


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

# ------------------------     DATA   ------------------------------
####################################################################
#################### Population Density - RASTER  ##################
####################################################################

# Human population density from Global Human Settlement Layer (GHSL)
# https://human-settlement.emergency.copernicus.eu/download.php?ds=pop
# Epoch, 2020
# Resolution The grid cell resolution is 3 arc seconds (approximately
# 100 m at the equator)
# WGS84
# Product: GHS-POP, epoch: 2020, resolution: 3 arcsec, coordinate system: WGS84
# https://jeodpp.jrc.ec.europa.eu/ftp/jrc-opendata/GHSL/GHS_POP_GLOBE_R2023A/GHS_POP_E2020_GLOBE_R2023A_4326_3ss/V1-0/tiles/GHS_POP_E2020_GLOBE_R2023A_4326_3ss_V1_0_R5_C18.zip
# https://jeodpp.jrc.ec.europa.eu/ftp/jrc-opendata/GHSL/GHS_POP_GLOBE_R2023A/GHS_POP_E2020_GLOBE_R2023A_4326_3ss/V1-0/tiles/GHS_POP_E2020_GLOBE_R2023A_4326_3ss_V1_0_R6_C18.zip

text <-
  "https://jeodpp.jrc.ec.europa.eu/ftp/jrc-opendata/GHSL/GHS_POP_GLOBE_R2023A/GHS_POP_E2020_GLOBE_R2023A_4326_3ss/V1-0/tiles/"

urls <- c(
  paste0(text, "GHS_POP_E2020_GLOBE_R2023A_4326_3ss_V1_0_R5_C18.zip"),
  paste0(text, "GHS_POP_E2020_GLOBE_R2023A_4326_3ss_V1_0_R6_C18.zip")
)

# ----------------------------------------------------------------
urls[1]
basename(urls[1])

# change directory to row_data to download raw data
getwd() # [1] "/home/barqueira/luis_barqueira/pt1_db"
setwd("/home/barqueira/luis_barqueira/pt1_db/raw_data")
getwd()

# Checks if already downlaoaded ...
for (url in urls) {
  filename <- basename(url)
  if (!file.exists(filename)) {
    download.file(
      url,
      destfile = basename(url),
      mode = "wb"
    )
    unzip(filename)
  } else {
    cat(sprintf("File '%s' already exists. Skipping download. \n", filename))
  }
}

raster_files <- list.files(
  path = getwd(),
  pattern = "C18.tif",
  full.names = TRUE
)

raster_files

# turn to main directory
setwd("/home/barqueira/luis_barqueira/pt1_db")
getwd()

#-------------------------------------------------------------------
# read population

pop_init <- lapply(raster_files, terra::rast)

pop_init_mosaic <- do.call(terra::mosaic, pop_init)

terra::crs(pop_init_mosaic, describe = TRUE, proj = TRUE)
# EPSG 4326
# +proj=longlat +datum=WGS84 +no_defs

###################  GET COUNTRY MAP #################################
get_mainland_portugal_borders <- function() {
  mainland_portugal_borders <- giscoR::gisco_get_nuts(
    nuts_id = "PT1",
    year = "2021", # depends on the data, if old or recent
    resolution = "1", # 3
    nuts_level = "1",
    update_cache = TRUE
  )
  return(mainland_portugal_borders)
}

mainland_portugal_borders <- get_mainland_portugal_borders() |>
  sf::st_transform(crs = crs(pop_init_mosaic))

plot(sf::st_geometry(mainland_portugal_borders))

crs(pop_init_mosaic) == crs(vect(mainland_portugal_borders)) # [1] TRUE

################## CROP RASTER ##############################
get_pop_cropped <- function() {
  mainland_portugal_borders_vect <- terra::vect(
    mainland_portugal_borders
  )
  pop_cropped <- terra::crop(
    pop_init_mosaic, mainland_portugal_borders_vect,
    snap = "in",
    mask = TRUE
  )

  return(pop_cropped)
}

pop_cropped <- get_pop_cropped()

# plot
ggplot() +
  geom_spatraster(data = pop_cropped, maxcell = 50000) +
  geom_sf(
    data = mainland_portugal_borders,
    fill = NA, linewidth = 0.75, color = "black"
  ) +
  scale_fill_viridis_c(na.value = "transparent", alpha = 0.7)

plot(pop_cropped)
plot(sf::st_geometry(mainland_portugal_borders), add = TRUE)

############## Aggregate and Data wrangling #################

ncell(pop_cropped) # [1] 24870160
names(pop_cropped) # [1] "GHS_POP_E2020_GLOBE_R2023A_4326_3ss_V1_0_R5_C18"

# Consistent naming of the layer
names(pop_cropped) <- "population"
names(pop_cropped) # [1] "population"
nrow(pop_cropped) # [1] 6230

class(pop_cropped) # [1] "SpatRaster"
glimpse(pop_cropped)
ncell(pop_cropped) # [1] 24870160


##################### Project Raster to CRS of hex_poly #########
st_crs(hex_poly) # EPSG,25829


pop_cropped_projected <- pop_cropped |>
  project(crs(vect(hex_poly)))

# plot
ggplot() +
  tidyterra::geom_spatraster(data = pop_cropped_projected, maxcell = 50000) +
  geom_sf(data = hex_poly, fill = NA, linewidth = 0.75, color = "black") +
  scale_fill_viridis_c(na.value = "transparent", alpha = 0.6)


###################  IMPORTANT: Zonal statistics  #######################
# Zonal statistics - use exact_extract function

names(hex_poly) # [1] "grid_id" "geom"

# Criada area em km2
area_km2 <- st_area(hex_poly) |>
  units::set_units("km^2") |>
  as.double()

hex_poly$area_km2 <- area_km2

names(hex_poly) # [1] "grid_id"  "geom"     "area_km2"

st_area(hex_poly$geom) # to confirme values

# Now, we use exact_extract() to extract the population on each hexagonal grid.
# Extract aggregated population by hex cell
# fun = sum - the sum of non-NA raster cell values, multiplied by the fraction
#  of the cell that is covered by the polygon

hex_poly$population <- exactextractr::exact_extract(
  pop_cropped_projected,
  y = hex_poly,
  progress = FALSE,
  fun = "sum"
)


ggplot() +
  geom_sf(
    data = hex_poly |> filter(population > 0),
    aes(fill = population),
    color = NA
  ) +
  scale_fill_viridis_c(na.value = "transparent", alpha = 0.8)


summary(hex_poly$population)
sum(hex_poly$population) # [1] 8549499
nrow(hex_poly) # [1] 1008

# Compute density by cell
# Finally we just compute densities:

hex_poly_final <- hex_poly |>
  # Compute density by cell
  mutate(population_km2 = population / area_km2)

names(hex_poly_final)

# [1] "grid_id"        "geom"           "area_km2"       "population"
# [5] "population_km2"


ggplot(hex_poly_final) +
  geom_sf(
    aes(fill = population_km2),
    color = "grey40",
    size = .1
  ) +
  scale_fill_gradient(
    low = "#fff95b", high = "#ff930f",
    na.value = "grey95"
  ) +
  theme_void()


#######################################################################
#########     Prepare to save as CSV for future USE     ###############
#######################################################################
hex_poly_final
names(hex_poly_final)
# [1] "grid_id"        "geom"           "area_km2"       "population"
# [5] "population_km2"

class(hex_poly_final)
st_crs(hex_poly_final)

human_pop_density <- hex_poly_final |>
  select(grid_id, population_km2) |>
  st_drop_geometry()

names(human_pop_density) # [1] "grid_id"        "population_km2"

# Save as human_pop_density.csv

write.csv(
  human_pop_density, "./data/population/human_pop_density.csv",
  row.names = FALSE
)
