###############################################################################
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

hex <- get_map() |>
  # Join layer with the hexagonal grid
  dplyr::left_join(
    get_layer(layer = "human"),
    by = join_by(grid_id)
  )


ggplot(hex) +
  geom_sf(
    aes(fill = population_km2),
    color = "grey90"
  ) +
  scale_fill_gradient(
    low = "#fff95b",
    high = "#ff930f",
    na.value = "grey95"
  ) +
  theme_void()


data <- get_layer(layer = "co2") |>
  # Join layer with population per km2 distribution
  left_join(
    get_layer(layer = "human"),
    by = join_by(grid_id)
  )

# Compare the two data
ggplot(data, aes(x = population_km2, y = co2_emission_km2)) +
  geom_point() +
  geom_smooth(method = "lm") +
  theme_light()

# As expected, there is a positive correlation between the
# population per km2 and the co2 emission per km2.

cor(
  data$co2_emission_km2,
  data$population_km2,
  method = "spearman"
) # [1] 0.3711611

## plot with statistical results
# install.packages("ggstatsplot")
library(ggstatsplot)

ggscatterstats(
  data = data,
  x = population_km2,
  y = co2_emission_km2,
  bf.message = FALSE,
  marginal = FALSE # remove histograms
)

ggsave(
  filename = "./plots/correlation_co2_pop.png",
  width = 7, height = 7, dpi = 600, bg = "#f8f8f7"
)