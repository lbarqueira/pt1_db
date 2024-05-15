The content presented here will be used in a future package (under development).
This data will be called up by the future package via URL.  

### Organization: ###

- __maps__: include hex map of Mainland Portugal, cropped by Mainland geometry (border), with 100 km2 area for each (not all) hex polygon.
  - hex_cropped_portugal_100km2.gpkg
  - (other maps will be presented - for future projects / use ...)

- __data__: __data__ is strictly related with __map__ (Gridded map of Mainland Portugal in hexagons of about 100 km2), through the variable __grid_id__ which is present in both files. Data was worked out based on the grid of the map
  - population: [GHSL - Global Human Settlement Layer](https://human-settlement.emergency.copernicus.eu/download.php?ds=pop)

- __scripts__ (R code to generate __maps__ and __data__):
  - __hex_map_100.r__: R code to generate hexagonal map of Mainland Portugal, cropped by Mainland geometry (border), with 100 km2 area for each (not all) hex polygon. The output of this script is present on the folder __maps__.  

- __vignettes__: practical examples to help users get the most out of this containts. 
  - get_map.r: R code to implement __get_map()__, a function that loads hex gridded map of Mainland Portugal with 100km2 area for each (not all) hex polygon, __from GitHub__


__Note:__ This repository is inspired by the work carried out by Benjamin Nowak (@BjnNowak)  

### Plots from vignettes ###

[Mainland Portugal Map, HEX GRID w/100km2 area (loaded from present GitHub Link)](https://github.com/lbarqueira/pt1_db/blob/main/plots/hex_map_100km2.png)

