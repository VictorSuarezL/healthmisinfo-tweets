library(tidyverse)

file_list <- fs::dir_ls(here::here("data_twitter", "data_csv_to_delete"))

file_list[1:5] %>%
  walk(~read_csv(.) %>%
           mutate(imputed_lng = cld3::detect_language(text)) %>%
           filter(imputed_lng == "en") %>%
         select(-imputed_lng) %>%
         write_csv("this_is_to_delete.csv", append = T, col_names = T))

read_csv("this_is_to_delete.csv") -> foo_text

foo_text %>%
  select(screen_name = user_screen_name) %>%
  distinct(screen_name) %>%
  slice(1:20) -> foo_screenname

tweetbotornot2::predict_bot(foo_screenname) -> foobot

foo_text %>%
  select(user_id) %>%
  distinct(user_id) %>%
  slice(4:20) -> user_id
# user_id <- as.double(user_id)
tweetbotornot2::predict_bot(user_id) -> foobot2
