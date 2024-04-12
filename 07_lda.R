library(tidyverse)
library(tidytext)

df <- read_rds(path = here::here("data_twitter",
                                 "data_processed", "covid_19.rds"))

remove_reg <- "&amp;|&lt;|&gt;"
remove_urls <- "http"

df %>%
  mutate(text = str_remove_all(text, remove_reg),
         text = str_remove_all(text, remove_urls),
         text = str_remove_all(text, c("#covid_19", "#covid19", "#covid",
                               "#covid-19",
                               "#covid19esp", "#coronavirus", "#coronavirusesp")),
         text = str_replace_all(text, "(?<=\\S)#", " #"),
         text = str_remove_all(text, "#")) %>%
  unnest_tokens(word, text, token = "tweets") %>%
  filter(!word %in% stop_words$word,
         !word %in% str_detect(word, remove_urls),
         !word %in% str_remove_all(stop_words$word, "'"),
         !word %in% c("rt"),
         str_detect(word, "[a-z]")) -> tidy_df

tidy_df %>%
  filter(is_bot == "Bot") %>%
  count(id, word) %>%
  select(id, word, n) %>%
  cast_dtm(id, word, n) -> dtm_df

topicmodels::LDA(dtm_df, k = 20, control = list(seed = 1234)) -> lda_tweets

# topic_tweets <- tidy(lda_tweets)

write_rds(lda_tweets, path = here::here("data_twitter", "data_processed", "lda_bot.rds"))


# No Bot ------------------------------------------------------------------

tidy_df %>%
  filter(is_bot == "No Bot") %>%
  count(id, word) %>%
  select(id, word, n) %>%
  cast_dtm(id, word, n) -> dtm_df

topicmodels::LDA(dtm_df, k = 20, control = list(seed = 1234)) -> lda_tweets

# topic_tweets <- tidy(lda_tweets)

write_rds(lda_tweets, path = here::here("data_twitter", "data_processed", "lda_no_bot.rds"))


# Unknown -----------------------------------------------------------------

tidy_df %>%
  filter(is_bot == "Unknown") %>%
  count(id, word) %>%
  select(id, word, n) %>%
  cast_dtm(id, word, n) -> dtm_df

topicmodels::LDA(dtm_df, k = 20, control = list(seed = 1234)) -> lda_tweets

topic_tweets <- tidy(lda_tweets)

write_rds(lda_tweets, path = here::here("data_twitter", "data_processed", "lda_unknown.rds"))

# Bot_official -------------------------------------------------------------

tidy_df %>%
  filter(is_bot == "Bot_official") %>%
  count(id, word) %>%
  select(id, word, n) %>%
  cast_dtm(id, word, n) -> dtm_df

topicmodels::LDA(dtm_df, k = 20, control = list(seed = 1234)) -> lda_tweets

topic_tweets <- tidy(lda_tweets)

write_rds(lda_tweets, path = here::here("data_twitter", "data_processed", "lda_botofficial.rds"))
