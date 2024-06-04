########## Point valued maps from vectors ###############
#             Source defined functions:
#                  get_map()
#                get_layer(layer)
#########################################################
source("https://raw.githubusercontent.com/lbarqueira/pt1_db/main/R/get_map.r")
source("https://raw.githubusercontent.com/lbarqueira/pt1_db/main/R/get_layer.r")

libs <- c(
  "tidyverse"
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

gas_stations_density <- get_layer(layer = "gas_stations")

names(gas_stations_density) # [1] "grid_id"   "gas_stations_km2"
nrow(gas_stations_density) # [1] 1008
glimpse(gas_stations_density)


hex_map <- get_map() |>
  # Join static layer with the hexagonal grid
  dplyr::left_join(
    gas_stations_density,
    by = join_by(grid_id)
  )

class(hex_map)
# [1] "sf"         "tbl_df"     "tbl"        "data.frame"
names(hex_map) # [1] "grid_id"    "geom"   "gas_stations_km2"
nrow(hex_map) # [1] 1008
sf::st_crs(hex_map) # "EPSG",25829


ggplot(hex_map) +
  geom_sf(
    aes(fill = gas_stations_km2),
    color = "grey90"
  ) +
  scale_fill_gradient(
    low = "#fff95b", high = "#ff930f",
    na.value = "grey95"
  ) +
  theme_void()

#############################################
# Now that I have the spatial vector hex_map
#############################################

library(scico)
library(colorspace)

scico::scico_palette_names()

my_palette <- scico::scico(6, palette = "grayC", direction = -1)

my_palette
# [1] "#FFFFFF" "#BDBDBD" "#8B8B8B" "#636363" "#383838" "#000000"

colorspace::swatchplot(my_palette)

ggplot(hex_map) +
  geom_sf(aes(fill = gas_stations_km2), color = NA) +
  labs(fill = "# per km2") +
  scico::scale_fill_scico(
    palette = "grayC",
    direction = -1 # To reverse color palette
  ) +
  theme_void() +
  theme(
    plot.title = element_text(
      face = "bold",
      size = 12,
      color = "#260C3F",
      hjust = .5,
      vjust = -2
    ),
    plot.subtitle = element_text(
      size = 8,
      color = "#260C3F",
      hjust = .5,
      vjust = -3
    ),
    plot.caption = element_text(
      size = 6,
      color = "#260C3F",
      hjust = .5,
      vjust = 10 # 5
    ),
    legend.title = element_text(size = 9, vjust = 1, hjust = .5),
    legend.text = element_text(size = 8), #change legend text font size
    plot.background = element_rect(fill = "gray99", color = NA)
  ) +
  labs(
    title = "Mainland Portugal Gas Stations per km2",
    subtitle = "Hexagonal Grid of 100km2",
    caption = "Graphic: @barqueira | Data: @OpenStreetMaps contributors"
  )



# BREAKS AND COLORS
#----------------------

scico::scico_palette_show()

my_palette <- scico::scico(6, palette = "turku", direction = -1)

my_palette
# [1] "#FFE5E5" "#EEB1A0" "#B89F6D" "#71704C" "#3B3B32" "#000000"

colorspace::swatchplot(my_palette)


breaks <- classInt::classIntervals(
  hex_map$gas_stations_km2,
  n = 8,
  style = "pretty"
)$brks

cols <- grDevices::colorRampPalette(
  c(
    "#FFFFFF",
    "#FFE5E5", "#EEB1A0", "#B89F6D",
    "#71704C", "#3B3B32", "#000000"
  ),
  bias = 3
)

colorspace::swatchplot(cols(11))

ggplot(data = hex_map) +
  geom_sf(aes(fill = gas_stations_km2), color = NA) +
  scale_fill_gradientn(
    name = "# per km2",
    colors = cols(11),
    breaks = breaks
  ) +
  theme_void() +
  theme(
    plot.title = element_text(
      face = "bold",
      size = 12,
      color = "gray20",
      hjust = .5,
      vjust = -2
    ),
    plot.subtitle = element_text(
      size = 10,
      color = "gray20",
      hjust = .5,
      vjust = -3
    ),
    plot.caption = element_text(
      size = 6,
      color = "grey20",
      hjust = .5,
      vjust = 10 # 5
    ),
    legend.title = element_text(size = 9), #change legend title font size
    legend.text = element_text(size = 8), #change legend text font size
    plot.background = element_rect(fill = "gray99", color = NA)
  ) +
  labs(
    title = "Mainland Portugal Gas Stations per km2",
    subtitle = "Hexagonal Grid of 100km2",
    caption = "Graphic: @barqueira | Data: @OpenStreetMap contributors"
  )

ggsave(
  filename = "./plots/gas_stations_density_choropleth.png",
  width = 7, height = 7, dpi = 600, bg = "gray99"
)