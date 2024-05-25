########## Point valued maps from vectors ###############
#             Source defined functions:
#                  get_map()
#                get_layer(layer)
#########################################################

# NOTA: Terei ainda de explorar melhor outra forma de carregar as funções
# uma vez que com source ele corre o ficheiro na sua totalidade.
# Eventualmente apenas incluir as definições das funções para aí
# sim, só chamá-las aqui.

source("https://raw.githubusercontent.com/lbarqueira/pt1_db/main/vignettes/get_layer.r")
source("https://raw.githubusercontent.com/lbarqueira/pt1_db/main/R/get_map.r")


co2_density <- get_layer("co2")

names(co2_density) # [1] "grid_id"        "population_km2"
nrow(co2_density) # [1] 1008


hex_map <- get_map() |>
  # Join static layer with the hexagonal grid
  left_join(co2_density)

class(hex_map)
# [1] "sf"         "tbl_df"     "tbl"        "data.frame"
names(hex_map) # [1] "grid_id"    "geom"   "co2_emission_km2"
nrow(hex_map) # [1] 1008
st_crs(hex_map) # "EPSG",25829


ggplot(hex_map) +
  geom_sf(
    aes(fill = co2_emission_km2),
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

my_palette <- scico::scico(6, palette = "acton", direction = -1)

my_palette
# [1] "#F0EAF9" "#E1B2CE" "#CA7199" "#85648D" "#4E4674" "#260C3F"

swatchplot(my_palette)

ggplot(hex_map) +
  geom_sf(aes(fill = co2_emission_km2), color = NA) +
  labs(fill = "ktons per km2") +
  scale_fill_scico(
    palette = "acton",
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
    legend.title = element_text(size = 9, vjust = 1, hjust = .5), #change legend title font size
    legend.text = element_text(size = 8), #change legend text font size
    plot.background = element_rect(fill = "gray99", color = NA)
  ) +
  labs(
    title = "Mainland Portugal CO2 Emissions per km2",
    subtitle = "Hexagonal Grid of 100km2",
    caption = "Graphic: @barqueira | Data: Global Greenhouse Gas Emissions - EDGAR v8.0, 2022"
  )

# ficheiro removido ...
ggsave(
  filename = "./plots/co2_emissions_density_choropleth.png",
  width = 7, height = 7, dpi = 600, bg = "gray99"
)


# Time to convert this choropleth in a point valued map!
# Point valued maps from vectors
# Make a grid from basemap
# Extract centroid for each cell of the grid
# Intersect centroid and basemap to get the variable of interest value for each point
# Customize layout

# First step - hex grid
grd_simple <- get_map()

ggplot(grd_simple) +
  geom_sf()

# Second step is to extract centroid for each cell of the basemap

grd_cent <- grd_simple |>
  st_centroid()

ggplot(grd_cent) +
  geom_sf()

# Third step is to intersect centroid and basemap to assign the value
# of the variable of interest for each centroid

# Intersect grid with polygons
grd <- grd_cent |>
  st_intersection(hex_map)

ggplot(grd, aes(size = co2_emission_km2)) +
  geom_sf() +
  scale_size(range = c(0, 4))

# Customize layout
summary(grd$co2_emission_km2)
#     Min.  1st Qu.   Median     Mean  3rd Qu.     Max.
#  0.00000  0.03084  0.10693  0.39437  0.27070 16.01825

grd <- grd |>
  mutate(clss = case_when(
    co2_emission_km2 < 1 ~ "1",
    co2_emission_km2 < 2 ~ "2",
    co2_emission_km2 < 4 ~ "3",
    co2_emission_km2 < 8 ~ "4",
    co2_emission_km2 < 16 ~ "5",
    TRUE ~ "6"
  ))

names(grd)

# Mainland Portugal border for background:

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

################# PLOT 1 ################################
ggplot() +
#  geom_sf(
#    portugal_transformed,
#    mapping = aes(geometry = geometry),
#    color = "black", fill = "white"
#  ) +
  geom_sf(
    hex_map,
    mapping = aes(geometry = geom),
    color = "gray80", fill = "#f8f8f7"
  ) +
  geom_sf(
    grd,
    # Change point size according to value of interest
    mapping = aes(size = clss, geometry = geom),
    # pch=21 for points with fill and color attributes
    pch = 21,
    fill = "#5c6630",
    color = "#5c6630",
    alpha = .5,
    stroke = 0.1
  ) +
  scale_size_manual(
    values = 1.6 * seq(0.5, 4.25, 0.75),
    labels = c("< 1", "< 2", "< 4", "< 8", "< 16", "≥ 16")
  ) +
  labs(size = "ktons per km2") +
  theme_void() +
  theme(
    plot.title = element_text(
      face = "bold",
      size = 12,
      color = "#451a40",
      hjust = .5,
      vjust = -2
    ),
    plot.subtitle = element_text(
      size = 8,
      color = "#451a40",
      hjust = .5,
      vjust = -3
    ),
    plot.caption = element_text(
      size = 6,
      color = "grey20",
      hjust = .5,
      vjust = 10 # 5
    ),
    plot.background = element_rect(fill = "#f8f8f7", color = NA)
  ) +
  labs(
    title = "Mainland Portugal CO2 Emissions per km2",
    subtitle = "Hexagonal Grid of 100km2",
    caption = "Graphic: @barqueira | Data: Global Greenhouse Gas Emissions - EDGAR v8.0, 2022"
  )


ggsave(
  filename = "./plots/co2_emissions_density.png",
  width = 7, height = 7, dpi = 600, bg = "#f8f8f7"
)

################# PLOT 2 ################################
ggplot() +
#  geom_sf(
#    portugal_transformed,
#    mapping = aes(geometry = geometry),
#    color = "black", fill = "white"
#  ) +
  geom_sf(
    hex_map,
    mapping = aes(geometry = geom),
    color = "gray99", fill = "gray92"
  ) +
  geom_sf(
    grd,
    # Change point size according to value of interest
    mapping = aes(size = clss, geometry = geom),
    # pch=21 for points with fill and color attributes
    pch = 21,
    fill = "#440814",
    color = "#440814",
    alpha = .5,
    stroke = 0.1
  ) +
  scale_size_manual(
    values = 1.6 * seq(0.5, 4.25, 0.75),
    labels = c("< 1", "< 2", "< 4", "< 8", "< 16", "≥ 16")
  ) +
  labs(size = "ktons per km2") +
  theme_void() +
  theme(
    plot.title = element_text(
      face = "bold",
      size = 12,
      color = "#451a40",
      hjust = .5,
      vjust = -2
    ),
    plot.subtitle = element_text(
      size = 9,
      color = "#451a40",
      hjust = .5,
      vjust = -3
    ),
    plot.caption = element_text(
      size = 6,
      color = "grey20",
      hjust = .6,
      vjust = 10 # 5
    ),
    legend.title = element_text(size = 9), #change legend title font size
    legend.text = element_text(size = 8), #change legend text font size
    plot.background = element_rect(fill = "#f8f8f7", color = NA)
  ) +
  labs(
    title = "Mainland Portugal CO2 Emissions per km2",
    subtitle = "Hexagonal Grid of 100km2",
    caption = "Graphic: @barqueira | Data: Global Greenhouse Gas Emissions - EDGAR v8.0, 2022"
  )


ggsave(
  filename = "./plots/co2_emissions_density.png",
  width = 7, height = 7, dpi = 600, bg = "#f8f8f7"
)