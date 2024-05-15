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

names(human_pop) # [1] "grid_id"             "population_area_km2"
nrow(human_pop) # [1] 1008


hex_map <- get_map() |>
  # Join static layer with the hexagonal grid
  left_join(human_pop)

names(hex_map) # [1] "grid_id"             "population_area_km2" "geom"
nrow(hex_map) # [1] 1008
st_crs(hex_map)


ggplot(hex_map) +
  geom_sf(
    aes(fill = population_area_km2),
    color = "grey90"
  ) +
  scale_fill_gradient(
    low = "#fff95b", high = "#ff930f",
    na.value = "grey95"
  ) +
  theme_void()