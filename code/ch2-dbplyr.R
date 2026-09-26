# Chapter 2: dbplyr — runnable code for the book.
# Run from the repo root: Rscript code/ch2-dbplyr.R
# Uses the local data/web.csv snapshot (falls back to the online copy).

library(dbplyr)
library(dplyr)
library(DBI)
library(RSQLite)

## Connect ----
con <- dbConnect(RSQLite::SQLite(), ":memory:")

# Canonical ecom: 1000 rows x 8 cols.
web_path <- if (file.exists("data/web.csv")) "data/web.csv" else "https://raw.githubusercontent.com/rsquaredacademy/datasets/master/web.csv"
ecom <- readr::read_csv(web_path, show_col_types = FALSE)
ecom <- dplyr::select(ecom, referrer, device, bouncers, n_visit, n_pages, duration, country, purchase)
dplyr::copy_to(con, ecom)

## Reference data ----
ecom2 <- dplyr::tbl(con, "ecom")
ecom2

## Query data ----
select(ecom2, referrer, device, duration)
filter(ecom2, duration > 300)

ecom2 %>%
  group_by(device) %>%
  summarise(avg_duration = mean(duration))

## Show query ----
avg_time <-
  ecom2 %>%
  group_by(device) %>%
  summarise(avg_duration = mean(duration))

dplyr::show_query(avg_time)
dplyr::explain(avg_time)

## Collect data ----
# dplyr is lazy: nothing is pulled until you ask for it.
dplyr::collect(avg_time)

## Close connection ----
dbDisconnect(con)
