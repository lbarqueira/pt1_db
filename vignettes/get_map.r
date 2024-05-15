############################################################################
#   FUNCTION    get_map()        HEX MAP 100km2 LOAD from GitHub
############################################################################

# 1. INSTALL & LOAD PACKAGES
libs <- c(
  "tidyverse",
  "sf"
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

###########          LOAD HEX MAP FROM GITHUB         #######################
###########  GITHUB -  VIEW RAW AND COPY LINK ADDRESS #######################

# Function get_map
get_map <- function() {
  hex <- sf::read_sf(
    "https://raw.githubusercontent.com/lbarqueira/pt1_db/main/maps/hex_cropped_portugal_100km2.gpkg"
  )
  return(hex)
}

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

# Plot and save

hex |>
  ggplot() +
  geom_sf() +
  theme_minimal() +
  theme(
    plot.title = element_text(
      size = 12, color = "#451a40",
      hjust = .5
    ),
    plot.background = element_rect(fill = "#f5f5f2", color = NA)
  ) +
  labs(
    title = "Mainland Portugal Map, HEX GRID w/100km2 area (GitHub)"
  )
ggsave("./plots/hex_map_100km2.png", dpi = 340)