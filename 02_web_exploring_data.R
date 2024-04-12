library(tidyverse)

df <- read_tsv("./data_web/data_20200504T164147.tsv")

df <- df %>%
  mutate(title = str_remove(title, "Disinfo: "),
         date_of_publication = str_remove(date_of_publication,
                                          "DATE OF PUBLICATION: "),
         keywords = str_remove(keywords, "Keywords: "))

df %>%
  filter(str_detect(keywords, "coronavirus")) %>%
  select(disproof)
