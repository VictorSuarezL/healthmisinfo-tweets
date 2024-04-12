library(tidyverse)

col_names <- c("created_at", "id", "text", "truncated", "in_reply_to_status_id",
               "in_reply_to_user_id", "geo", "coordinates", "place", "retweet_count",
               "favorite_count", "retweeted", "lang", "user_id", "user_name",
               "user_screen_name", "user_location", "user_verified", "user_followers_count",
               "user_friends_count", "user_favourites_count", "user_statuses_count",
               "user_created_at", "user_time_zone", "user_lang", "extended_tweet_full_text",
               "retweeted_status_id", "retweeted_status_user_id_str",
               "retweeted_status_user_verified",
               "retweeted_status_user_followers_count", "retweeted_status_user_friends_count",
               "retweeted_status_extended_tweet_full_text", "retweeted_status_retweet_count",
               "retweeted_status_favorite_count", "possibly_sensitive",
               "retweeted_status_possibly_sensitive")

df <- read_csv("./data_twitter/to_process/tweet_in_english.csv", col_names = col_names)

fs::dir_ls(fs::path_wd("data_twitter", "data_processed", "botornot_output")) %>%
  map_df(~read_csv(., col_types = "dcd")) %>%
  distinct(user_id, .keep_all = T) %>%
  inner_join(df) %>%
  mutate(
    text = if_else(!is.na(extended_tweet_full_text), extended_tweet_full_text, text),
    text = str_replace_all(text, "(\\d+(?=[[:alpha:]]+))", "\\1 "),
    created_at = lubridate::parse_date_time(created_at,'%a %b %d %H:%M:%S %z %Y'),
    is_bot = if_else(prob_bot > .70, "Bot", "No Bot"),
    is_bot = if_else(prob_bot > .9 & str_detect(user_screen_name, "bot"),
                            "Bot_official", is_bot),
    is_bot = replace_na(is_bot, "Unknown")
    ) %>%
  filter(created_at > as.Date("2020-02-01")) %>%
  write_rds(path = here::here("data_twitter", "data_processed", "covid_19.rds"))

rm(df)
rm(col_names)



