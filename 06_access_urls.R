library(tidyverse)
library(tidytext)

df <- read_rds(path = here::here("data_twitter", "data_processed", "covid_19.rds"))

remove_reg <- "&amp;|&lt;|&gt;"
remove_urls <- "http"

df %>%
  # mutate(text = str_remove_all(text, remove_reg)) %>%
  unnest_tokens(shortened_urls, text, token = "tweets", to_lower = F) %>%
  select(id, shortened_urls) %>%
  filter(str_detect(shortened_urls, remove_urls)) %>%
  mutate(shortened_urls = str_extract(shortened_urls, "https:\\/\\/t.co\\/[[:alnum:]]+"))-> urls

urls %>%
  write_csv(here::here("data_twitter", "to_process", "shorted_url.csv"))

decode.short.url <- function(u) {
  x <- try(RCurl::getURL(u, header = TRUE, nobody = TRUE, followlocation = FALSE))

  if(class(x) == 'try-error') {
    return(NA_character_)
  } else {
    x <- strsplit(x, "location: ")[[1]][2]
    x.2  <- strsplit(x, "\r")[[1]][1]
    return(x.2)
    }
}

urls %>%
  slice(1:10) %>%
  mutate(real_url = map_chr(shortened_urls, decode.short.url)) %>%
  # filter(!str_detect(real_url, "twitter"))
  write_rds(here::here("data_twitter", "data_processed", "extended_urls_in_tweets.rds"))


u <- "https://t.co/mmxMbomepo"

x <- try(RCurl::getURL(u, header = TRUE, nobody = TRUE, followlocation = FALSE))

if(class(x) == 'try-error') {
  return(NA_character_)
} else {
  x <- strsplit(x, "location: ")[[1]][2]
  x.2  <- strsplit(x, "\r")[[1]][1]
  return(x.2)
}
