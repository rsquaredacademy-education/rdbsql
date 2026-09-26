# Chapter 4: SQL Advanced — runnable code for the book.
# Run from the repo root: Rscript code/ch4-sqladvanced.R
# Uses the local data/web.csv snapshot (falls back to the online copy).

library(dplyr)
library(DBI)
library(RSQLite)

# Canonical ecom: 1000 rows x 8 cols.
web_path <- if (file.exists("data/web.csv")) "data/web.csv" else "https://raw.githubusercontent.com/rsquaredacademy/datasets/master/web.csv"
ecom <- readr::read_csv(web_path, show_col_types = FALSE)
ecom <- dplyr::select(ecom, referrer, device, bouncers, n_visit, n_pages, duration, country, purchase)
con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
copy_to(con, ecom)

## Aggregate ----
dbGetQuery(con, "SELECT SUM(n_visit) FROM ecom")
dbGetQuery(con, "SELECT SUM(n_visit) FROM ecom WHERE n_visit > 5")
dbGetQuery(con, "SELECT AVG(n_visit) FROM ecom")
dbGetQuery(con, "SELECT AVG(n_visit) FROM ecom WHERE country LIKE 'P%'")
dbGetQuery(con, "SELECT MAX(n_visit) FROM ecom")
dbGetQuery(con, "SELECT MAX(n_visit) FROM ecom WHERE device = 'tablet'")
dbGetQuery(con, "SELECT MIN(n_visit) FROM ecom")
dbGetQuery(con, "SELECT MIN(n_visit) FROM ecom WHERE duration BETWEEN 600 AND 900")

## Alias ----
dbGetQuery(con, "SELECT AVG(n_visit) AS avg_mobile FROM ecom WHERE device = 'mobile'")
dbGetQuery(con, "SELECT MAX(n_visit) AS max_visit FROM ecom")
dbGetQuery(con, "SELECT MIN(duration) AS min_duration FROM ecom")

## Order By ----
dbGetQuery(con, "SELECT * FROM ecom ORDER BY country LIMIT 5")
dbGetQuery(con, "SELECT * FROM ecom ORDER BY duration LIMIT 5")
dbGetQuery(con, "SELECT * FROM ecom ORDER BY n_visit DESC LIMIT 5")

## Group By ----
dbGetQuery(con, "SELECT device, count(*) AS visits FROM ecom GROUP BY device ORDER by visits DESC")
dbGetQuery(con, "SELECT device, MAX(duration) AS max_duration FROM ecom GROUP BY device ORDER by max_duration DESC")

## Close connection ----
dbDisconnect(con)
