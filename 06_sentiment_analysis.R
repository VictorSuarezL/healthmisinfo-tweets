library(tidytext)
library(tidyverse)

remove_reg <- "&amp;|&lt;|&gt;"
remove_urls <- "http"

# df <- read_rds(path = here::here("data_twitter", "data_processed", "covid_19.rds"))
#
# df %>%
#   count(is_bot)
#
# df %>%
#   filter(is_bot %in% c("Bot_official", "Bot")) %>%
#   distinct(user_screen_name, .keep_all = T) %>%
#   select(user_screen_name, prob_bot, is_bot) %>%
#   arrange(desc(prob_bot)) %>%
#   filter(str_detect(user_screen_name, "bot")) %>%
#   mutate(is_bot = if_else(prob_bot > .9 & str_detect(user_screen_name, "bot"),
#          "Bot_official", is_bot))

read_rds(path = here::here("data_twitter", "data_processed", "covid_19.rds")) %>%
  mutate(text = str_remove_all(text, remove_reg),
         text = str_replace_all(text, "(?<=\\S)#", " #")) %>%
  unnest_tokens(word, text, token = "tweets") %>%
  filter(!word %in% stop_words$word,
         !word %in% str_detect(word, remove_urls),
         !word %in% str_remove_all(stop_words$word, "'"),
         !word %in% c("rt", "#covid_19", "#covid19", "#covid", "#covid19esp", "#coronavirus", "#coronavirusesp"),
         str_detect(word, "[a-z]")) -> tidy_df

tidy_df %>%
  select(is_bot, id, word, created_at) %>%
  mutate(id = as.character(id)) %>%
  inner_join(get_sentiments("afinn")) %>%
  mutate(round_created_at_tweet = lubridate::round_date(created_at, unit = "hour")) %>%
  group_by(id) %>%
  mutate(sentiment = mean(value)) %>%
  ungroup() %>%
  group_by(is_bot, round_created_at_tweet) %>%
  mutate(sentiment_per_day = mean(sentiment)) -> foo

library(scales)

foo %>%
  ggplot(aes(x = round_created_at_tweet, y = sentiment_per_day, colour = is_bot)) +
  geom_line() +
  scale_x_datetime() +
  theme_light() +
  theme(legend.position = "bottom") +
  scale_color_brewer(palette = "Set1")


