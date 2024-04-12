#!/usr/bin/env Rscript
suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(rtweet))

#source("./recover_stream.R")

recover_stream <- function(path, dir = NULL, verbose = TRUE) {

  # read file and split to tweets
  tweets <- readLines(path, encoding = "UTF-8", warn = FALSE)
  tweets <- tweets[!tweets == ""]

  # write tweets to disk and try to read them in individually
  if (is.null(dir)) {
    dir <- paste0(tempdir(), "/tweets/")
    dir.create(dir)
  }

  if (verbose) {
    pb <- progress::progress_bar$new(
      format = "Processing tweets [:bar] :percent, :eta remaining",
      total = length(tweets), clear = FALSE
    )
    pb$tick(0)
  }

  tweets_l <- lapply(tweets, function(t) {
    pb$tick()
    id <- unlist(stringi::stri_extract_first_regex(t, "(?<=id\":)\\d+(?=,)"))[1]
    f <- paste0(dir, id, ".json")
    writeLines(t, f, useBytes = TRUE)
    out <- tryCatch(rtweet::parse_stream(f),
                    error = function(e) {})
    if ("tbl_df" %in% class(out)) {
      return(out)
    } else {
      return(id)
    }
  })

  # test which ones failed
  test <- vapply(tweets_l, is.character, FUN.VALUE = logical(1L))
  bad_files <- unlist(tweets_l[test])

  # Let user decide what to do
  if (length(bad_files) > 0) {
    message("There were ", length(bad_files),
            " tweets with problems. Should they be copied to your working directory?")
    sel <- 3
    if (sel == 2) {
      dir.create(paste0(getwd(), "/broken_tweets/"))
      file.copy(
        from = paste0(dir, bad_files, ".json"),
        to = paste0(getwd(), "/broken_tweets/", bad_files, ".json")
      )
    } else if (sel == 3) {
      writeLines(bad_files, "broken_tweets.txt")
    }
  }

  # clean up
  unlink(dir, recursive = TRUE)

  # return good tweets
  return(dplyr::bind_rows(tweets_l[!test]))
}


filenames <- fs::dir_ls(path = here::here("data_twitter", "splited"), regexp = "[.]json$")

parse_tweets <- function(x = NA) {

  filename <- str_remove(fs::path_file(x), ".json")

  message(glue::glue("Reading {filename}..."))

  recover_stream(path = x) %>%
    write_as_csv(file_name = here::here("data_twitter", "data_csv", filename))

  message(glue::glue("Finish with {filename}..."))

  fs::file_delete(x)
}

walk(filenames, parse_tweets)
