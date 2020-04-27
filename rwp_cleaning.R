# Leaves in AutoModerator comments.
# Leaves in posts of all flair types.
# There's probably a way around this, but right now this only adds OP usernames if they have also posted a comment at some point.

library(tidyverse)
library(lubridate)
library(stringi)

SUBM_PATH <- "wp_raw_subm_apr4_to_apr13_on_apr17.csv"
COMM_PATH <- "wp_raw_comm_apr4_to_apr13_on_apr17.csv"

SUBM_DEST <- "wp_clean_subm_apr18_to_apr13_on_apr17.csv"
COMM_DEST <- "wp_clean_comm_apr18_to_apr13_on_apr17.csv"

clean_comments <- function(path) {
  comms <- read_csv(path)
  comms_trimmed <- comms %>%
    filter(body != '[removed]' & body != '[deleted]') %>%
    mutate(comm_date_EST = with_tz(as_datetime(created_utc), "Canada/Eastern")) %>%
    mutate(comm_weekday = wday(comm_date_EST, label=TRUE)) %>%
    mutate(is_top_level_comm = ifelse(link_id == parent_id, TRUE, FALSE)) %>%
    mutate(wordcount = stri_count_words(body))  %>%
    select(body, wordcount, author, author_fullname, score, gilded, is_top_level_comm, name, link_id, parent_id, comm_date_EST, comm_weekday) %>%
    rename(prompt_id = link_id, author_username = author, author_id = author_fullname, comment_id = name)
}

clean_submissions <- function(path) {
  subs <- read_csv(path)
  subs_trimmed <- subs %>%
    filter(is.na(selftext) | (selftext != '[removed]' & selftext != '[deleted]')) %>%
    mutate(prompt_date_EST = with_tz(as_datetime(created - 28800), "Canada/Eastern")) %>%
    mutate(prompt_weekday = wday(prompt_date_EST, label=TRUE)) %>%
    select(title, link_flair_text, score, gilded, name, author_fullname, prompt_date_EST, prompt_weekday) %>%
    rename(flair = link_flair_text, OP_id = author_fullname, prompt_id = name)
  subs_trimmed
}

add_OP_usernames <- function(submissions, comments) {
  authors <- comments %>%
    select(author_username, author_id) %>%
    distinct()
  joint <- left_join(submissions, authors, by = c("OP_id" = "author_id"))
  to_ret <- joint %>%
    rename(OP_username = author_username) %>%
    mutate(OP_username = replace_na(OP_username, 'unknown'))
  to_ret
}

process_comments_and_submissions <- function(comm_path, subm_path) {
  comms <- clean_comments(comm_path)
  subms <- clean_submissions(subm_path)
  subms <- add_OP_usernames(subms, comms)
  list("subs" = subms, "comms" = comms)
}

the_vals <- process_comments_and_submissions(COMM_PATH, SUBM_PATH)

write.csv(the_vals$subs, SUBM_DEST)
write.csv(the_vals$comms, COMM_DEST)
