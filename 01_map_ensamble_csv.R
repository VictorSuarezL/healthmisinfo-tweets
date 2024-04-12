library(tidyverse)
a <- fs::dir_ls(path = "data_map/health_districts_csv")

a[1:2] %>%
  map_df(~read_csv(.x) %>%
           filter(!is.na(Provincia)))


# Creating MAP ------------------------------------------------------------

library(maptools)
library(sp)
library(RColorBrewer)
library(classInt)
library(sf)

muni.map <- sf::st_read("data_map/G17_Division_Administrativa/da18_dem_sanitaria_distrito.shp")

fs::dir_ls(here::here("data_map", "data_csv", "provincias")) %>%
  map_df(~read_delim(.x, delim = ";")) %>%
  select(-X4) %>%
  rename("lugar_residencia" = "Lugar de residencia") %>%
  filter(str_detect(lugar_residencia, "\\w")) %>%
  pivot_wider(id_cols = lugar_residencia,
              names_from = Medida, values_from = Valor,
              values_fn = list(Valor = length)) %>%
  view()

muni.map %>%
  left_join(d, by = c("DISTRITO" = "Lugar de residencia")) -> d_sf

d_sf
ggplot(data = d) +
  geom_sf()
