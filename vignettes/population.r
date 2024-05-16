########## APPLYING FUNCTIONS ###########################
#        Applying defined functions:
#                  get_map()
#                get_layer(layer)
#########################################################

# Function get_map
get_map <- function() {
  hex <- sf::read_sf(
    "https://raw.githubusercontent.com/lbarqueira/pt1_db/main/maps/hex_cropped_portugal_100km2.gpkg" # nolint
  )
  return(hex)
}

get_layer <- function(layer) {
  tb <- tibble(
    name = c(
      "human" #1 - Human population density from GHSL
    ),
    url = c(
      "https://raw.githubusercontent.com/lbarqueira/pt1_db/main/data/population/human_pop_density.csv" #1 # nolint
    )
  ) |>
    filter(name == layer)

  ext <- read_csv(tb$url)

  return(ext)
}

human_pop <- get_layer("human")

names(human_pop) # [1] "grid_id"        "population_km2"
nrow(human_pop) # [1] 1008


hex_map <- get_map() |>
  # Join static layer with the hexagonal grid
  left_join(human_pop)

names(hex_map) # [1] "grid_id"        "geom"           "population_km2"
nrow(hex_map) # [1] 1008
st_crs(hex_map) # "EPSG",25829


ggplot(hex_map) +
  geom_sf(
    aes(fill = population_km2),
    color = "grey90"
  ) +
  scale_fill_gradient(
    low = "#fff95b", high = "#ff930f",
    na.value = "grey95"
  ) +
  theme_void()


# BREAKS AND COLORS
#----------------------

breaks <- classInt::classIntervals(
  hex_map$population_km2,
  n = 8,
  style = "pretty"
)$brks

cols <- colorRampPalette(
  rev(c(
    "#451a40", "#822b4c", "#b74952",
    "#e17350", "#f4a959", "#eae2b7"
  )),
  bias = 2
)


ggplot(data = hex_map) +
  geom_sf(aes(fill = population_km2), color = NA) +
  scale_fill_gradientn(
    name = "Population per km2",
    colors = cols(11),
    breaks = breaks
  ) +
  theme_void() +
  theme(
    plot.title = element_text(
      size = 12, color = "#451a40",
      hjust = .5
    ),
    plot.background = element_rect(fill = "#f8f8f7", color = NA)
  ) +
  labs(
    title = "Mainland Portugal Population Density per km2"
  )


ggsave(
  filename = "./plots/population_density.png",
  width = 7, height = 7, dpi = 600, bg = "#f8f8f7"
)