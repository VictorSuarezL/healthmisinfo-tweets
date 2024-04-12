library(tidyverse)
library(tidytext)

stop_words_vc <- paste(stop_words$word, collapse = " | ")

read_tsv(here::here("data_web", "data_20200504T164147.tsv")) %>%
  select(summary, country) %>%
  rowid_to_column(var = "document") %>%
  mutate(document = paste(document, "document")) %>%
  unnest_tokens(word, summary) %>%
  filter(!word %in% stop_words$word) %>%
  # mutate_at("word", ~SnowballC::wordStem(., language="en")) %>%
  mutate(country = str_remove(country, "^Country: ")) %>%
  filter(!str_detect(country, "Keywords: ")) %>%
  mutate(country = str_replace_all(country,
                                   "Bosnia and Herzegovina",
                                   "BosniaHerzegovina")) %>%
  mutate(country = str_remove_all(country, ",?and\\s+"),
         with_stop_words = str_detect(country, stop_words_vc),
         new_country = countrycode::countrycode(country,
                                                "country.name",
                                                "country.name",
                                                nomatch = "None",
                                                warn = F),
         country = case_when(
           with_stop_words == T ~ new_country,
           TRUE ~ country
           )) %>%
  select(document:word) -> tidy_words

tidy_words %>%
  count(document, word, sort = T) %>%
  cast_dtm(document, word, n) -> disinfo_dtm

disinfo_lda <- topicmodels::LDA(disinfo_dtm, k = 20, control = list(seed = 1234))

disinfo_lda %>%
  tidy() %>%
  group_by(topic) %>%
  top_n(8, beta) %>%
  ungroup() -> disinfor_lda_tidy

disinfor_lda_tidy %>%
  mutate(term = reorder_within(term, beta, topic)) %>%
  ggplot(aes(term, beta, fill = factor(topic))) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~topic, scales = "free") +
  coord_flip() +
  scale_x_reordered()

disinfo_lda %>%
  tidy(matrix = "gamma") %>%
  left_join(tidy_words %>%
              select(document, country) %>%
              distinct()) %>%
  arrange(topic, desc(gamma)) %>%
  group_by(topic) %>%
  top_n(4, wt = gamma) %>%
  # separate_rows(country, sep = ", ") %>%
  select(topic, country) %>%
  summarise(country = paste(country, collapse = "\n")) %>%
  ungroup() %>%
  left_join(disinfor_lda_tidy %>%
              group_by(topic) %>%
              summarise(term = paste(term, collapse = " "))) %>%
  gt::gt()
