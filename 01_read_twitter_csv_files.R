library(tidyverse)

file_list <- fs::dir_ls(here::here("data_twitter", "data_csv"))

file_list %>%
  map_df(~read_csv(., col_types = cols_only(created_at = "c", text = "c",
                                            extended_tweet_full_text = "c",
                                            user_id = "c",
                                            id = "c", geo = "c",
                                            coordinates = "c", place = "c",
                                            user_location = "c")) %>%
           filter(!is.na(geo) | !is.na(coordinates) | !is.na(place) | !is.na(user_location)) %>%
           mutate(user_location = str_to_lower(user_location)) %>%
           filter(str_detect(user_location,
                             pattern = "spain|españa|france|french|cyprus|Kıbrıs|chipre|greece|grek|uk|united kingdom|italy|italia"))) %>%
  mutate(country = case_when(str_detect(user_location, "spain|españa") ~ "spain",
                             str_detect(user_location, "france|frech") ~ "french",
                             str_detect(user_location, "cyprus|Kıbrıs|chipre") ~ "cyprus",
                             str_detect(user_location, "greece|grek") ~ "greece",
                             str_detect(user_location, "uk|united kingdom") ~ "uk",
                             str_detect(user_location, "italy|italia") ~ "italy",
                             TRUE ~ "other")) %>%
  count(country, sort = T)
  # write_rds(here::here("data_twitter", "data_processed", "covid_19_countries_uk_gr_cy_sp_fr.rds"))

