# Author: Víctor Suárez-Lledó
# Date: Tue Oct 27 10:11:52 2020
# Summary:
# --------------

# Data Loading ------------------------------------------------------------

library(tidyverse)

file_list <- fs::dir_ls(here::here("data_twitter", "data_csv_to_delete"))

col_names <- c("created_at", "id", "text", "truncated", "in_reply_to_status_id",
               "in_reply_to_user_id", "geo", "coordinates", "place", "retweet_count",
               "favorite_count", "retweeted", "lang", "user_id", "user_name",
               "user_screen_name", "user_location", "user_verified", "user_followers_count",
               "user_friends_count", "user_favourites_count", "user_statuses_count",
               "user_created_at", "user_time_zone", "user_lang", "extended_tweet_full_text",
               "retweeted_status_id", "retweeted_status_user_id_str", "retweeted_status_user_verified",
               "retweeted_status_user_followers_count", "retweeted_status_user_friends_count",
               "retweeted_status_extended_tweet_full_text", "retweeted_status_retweet_count",
               "retweeted_status_favorite_count", "possibly_sensitive",
               "retweeted_status_possibly_sensitive")

file_list %>%
  walk(~read_csv(.) %>%
           mutate(imputed_lng = cld3::detect_language(text)) %>%
           filter(imputed_lng == "en") %>%
         select(-imputed_lng) %>%
         write_csv("./data_twitter/to_process/tweet_in_english.csv", append = T, col_names = F))

read_csv("./data_twitter/to_process/tweet_in_english.csv", col_names = col_names) -> foo_text

foo_text %>%
  select(screen_name = user_screen_name, user_id) %>%
  distinct(user_id) %>%
  mutate(user_id = as.character(user_id)) -> df

user_id_df <- data.frame(user_id = df[["user_id"]])

user_id_df %>%
  write_csv("./data_twitter/to_process/user_id_tweets_in_english.csv")

# tweetbotornot2::predict_bot(user_id_df) -> bot_user_id
#
# bot_user_id %>%
#   as_tibble %>%
#   mutate(user_id = as.double(user_id)) %>%
#   select(user_id, prob_bot) %>%
#   right_join(foo_text) %>%
#   mutate_at(vars(created_at, user_created_at), ~ parse_datetime(., "%a %b %d %H:%M:%S %z %Y")) %>%
#   mutate_at(vars(user_location), ~ case_when(. == "None" ~ NA_character_, TRUE ~ .)) %>%
#   write_rds(path = here::here("data_twitter", "data_processed", "covid_19.rds"))






