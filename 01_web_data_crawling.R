library(tidyverse)
library(rvest)
library(polite)

url_land <- "https://euvsdisinfo.eu/disinformation-cases/"

css_pattern <- c(".b-catalog__report-title",
                 ".b-report__summary-text",
                 ".b-report__disproof-text",
                 ".b-catalog__link a:nth-child(1)",
                 "#main-content li:nth-child(1)",
                 "#main-content li:nth-child(2)",
                 "#main-content li:nth-child(3)",
                 "#main-content li:nth-child(4)",
                 "#main-content li:nth-child(5)",
                 "#main-content li:nth-child(6)",
                 ".b-catalog__repwidget")

pattern_names <- c("title",
                   "summary",
                   "disproof",
                   "publication_media",
                   "reported_in",
                   "date_of_publication",
                   "language_target_audience",
                   "country",
                   "keywords",
                   "outlet",
                   "column_info")

first_page <- read_html(x = url_land)

get_last_page <- function(html) {

  html %>%
    html_node(css = ".disinfo-db-current-paging") %>%
    html_text(trim = T) %>%
    str_extract_all(pattern = "[0-9]+") -> last_index

  last_index %>%
    as_vector() %>%
    as.double() %>%
    max()

}

latest_page_number <- get_last_page(first_page)

list_of_pages <- str_c(url_land, "?offset=",
                       seq(0, (latest_page_number-1)*10, by = 10))

# scrape_results <- function(url_result) {
#
#   position <- match(url_result, list_of_pages)
#   percentage <- round(position/length(list_of_pages)*100, 2)
#   seg_sys_sleep <- sample(5:15, 1, replace = T)
#   message(paste0("Search result ", str_trunc(url_result, 70, "center"), "\n",
#                  position, " of ", length(list_of_pages), " : ",
#                  percentage, "% search result completed. Sleeping... ",
#                  seg_sys_sleep, ".\n"))
#   Sys.sleep(seg_sys_sleep)
#
#   url_result %>%
#     read_html() %>%
#     html_nodes(css = ".disinfo-db-post a") %>%
#     html_attr("href")
# }

# scrape_results <- slowly(scrape_results, rate = rate_delay(5), quiet = F)

extract_pattern <- function(css_pattern, html_to_exctract) {
  html_to_exctract %>%
    html_node(css = css_pattern) %>%
    html_text()
}

get_data_table <- function(html_report) {
  css_pattern %>%
    map(possibly(~extract_pattern(., html_to_exctract = html_report),
                 otherwise = NA_character_)) %>%
    set_names(pattern_names) %>%
    bind_cols() %>%
    mutate_all(str_squish)
}

get_data_from_result <- function(url_report, list_of_pages_result, bow_session) {

  position <- match(x = url_report, list_of_pages_result)
  percentage <- round(position/length(list_of_pages_result)*100, 2)

  message(paste0("Scraping ", str_trunc(url_report, 70, "center"), "\n",
                 position, " of ", length(list_of_pages_result), " : ",
                 percentage, "% completed."))
  # seg_sys_sleep <- sample(5:7, 1, replace = T)
  # message(paste0("System sleeping: ", seg_sys_sleep, " seconds.\n"))
  # Sys.sleep(seg_sys_sleep)

  url_session <- nod(bow = bow_session,
      path = url_report,
      verbose = T)

  html_report <- scrape(url_session, verbose = T)

  get_data_table(html_report)
}

get_data_from_result <- slowly(get_data_from_result, rate = rate_delay(5), quiet = F)
slowly_scrape <- slowly(scrape, rate = rate_delay(5), quiet = F)

scrape_write_table <- function(url_land = url_land,
                               css_pattern = css_pattern,
                               pattern_names = pattern_names) {

  # message(paste0("Reading url_land: ", url_land))

  session <- bow(url_land, force = TRUE)

  first_page <- scrape(session, verbose = T)

  latest_page_number <- get_last_page(first_page)

  message(paste0("Last page number obtained: ", latest_page_number))

  # list_of_pages <- str_c(url_land, "?offset=",
  #                        seq(0, (latest_page_number-1)*10, by = 10))

  sequency <- seq(0, (latest_page_number-1)*10, by = 10)

  list_of_pages_result <- map(sequency,
                              ~slowly_scrape(session, query = list(offset = .x),
                                      verbose = T) %>%
           html_nodes(css = ".disinfo-db-post a") %>%
           html_attr("href")) %>%
    as_vector()


  # list_of_pages_result <- list_of_pages[1:4] %>%
  #   map(scrape_results) %>%
  #   as_vector()

  index_filename <- as.character(filenamer::filename("index", ext = "tsv",
                                                     subdir = F))

  write_tsv(as.data.frame(list_of_pages_result),
            here::here("data_web", index_filename))

  fn <- as.character(filenamer::filename("data", ext="tsv", subdir = F))

  # list_of_pages[1:2] %>%
  #   map(get_data_from_result) %>%
  #   bind_rows()

  list_of_pages_result %>%
    map(~get_data_from_result(.,
                              list_of_pages_result = list_of_pages_result,
                              bow_session = session)) %>%
    bind_rows() %>%
    write_tsv(here::here("data_web", fn))
}

scrape_write_table(url_land)
