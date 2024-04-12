library(tidyverse)
library(lubridate)

custom_predict_bot <- function(x) {
  x <- tweetbotornot2::predict_bot(x)
  filename <- format(Sys.time(), "%Y%m%d%H%M%S_botornot.model")
  write_csv(x, fs::path_wd("data_twitter", "data_processed", filename))
  limit <- rtweet::rate_limit(rtweet::get_token(), "get_timeline")

  if (limit$remaining < 20) {
    elapsed_time <- lubridate::as.duration(lubridate::now() %--% limit$reset_at)
    message("Remaining: ", limit$remaining, " queries. Sleeping for: ", elapsed_time, "...")
    Sys.sleep(as.numeric(elapsed_time) + 60)
  }
}

df <- read_csv("./data_twitter/to_process/user_id_tweets_in_english.csv",
         col_types = "c")

id <- rep(1:round(nrow(df)/900), each = 900, length.out = nrow(df))

df %>%
  mutate(id = id) %>%
  slice(1:5000) %>%
  group_by(id) %>%
  group_walk(~custom_predict_bot(.$user_id))