library(tidyverse)
library(rvest)

read_html("https://www.newsguardtech.com/coronavirus-misinformation-tracking-center/") %>%
  html_nodes(css = "#content li a") %>%
  html_text() %>%
  as_tibble(column_name = "misin_websites") -> newsguardtech

read_html("https://mediabiasfactcheck.com/fake-news/") %>%
  html_nodes(css = "#mbfc-table a") %>%
  html_attr("href") -> f

parse_sources <- function(u) {
  read_html(u) %>%
    html_text() %>%
    str_extract(pattern = "(?<=Source: )[^\\s]+") %>%
    as_tibble_col()-> x

  message(x)
  Sys.sleep(5)
  return(x)
}

parse_sources <- possibly(parse_sources, otherwise = NA_character_)

map(f, parse_sources) -> mediabiasfactcheck

as_data_frame(unlist(mediabiasfactcheck)) %>%
  bind_rows(newsguardtech) %>%
  write_rds(here::here("data_twitter", "data_processed", "factcheck_urls.rds"))
