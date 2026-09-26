# Chapter 3: SQL Basics — runnable code for the book.
# Run from the repo root: Rscript code/ch3-sqlbasics.R
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

## Select columns ----
dbGetQuery(con, "SELECT device FROM ecom")
dbGetQuery(con, "SELECT referrer, device, purchase FROM ecom")
dbGetQuery(con, "SELECT * FROM ecom LIMIT 3")

## Limit ----
dbGetQuery(con, "SELECT * FROM ecom limit 10")

## Distinct ----
dbGetQuery(con, "SELECT distinct referrer FROM ecom")

## Filter ----
dbGetQuery(con, "SELECT * FROM ecom WHERE duration > 300")
dbGetQuery(con, "SELECT * FROM ecom WHERE device = 'mobile'")

## And, Or & Not ----
dbGetQuery(con, "SELECT * FROM ecom WHERE n_visit > 3 AND duration > 100")
dbGetQuery(con, "SELECT * FROM ecom WHERE (n_visit = 5 OR n_visit = 3) AND (device = 'mobile' OR device = 'tablet')")

## Between ----
dbGetQuery(con, "SELECT * FROM ecom WHERE n_visit BETWEEN 1 AND 3 AND device = 'mobile'")

## In ----
dbGetQuery(con, "SELECT * FROM ecom WHERE n_visit IN (2, 4, 6, 8, 10)")

## Is Null ----
dbGetQuery(con, "SELECT * FROM ecom WHERE device IS NULL")

## Like ----
dbGetQuery(con, "SELECT * FROM ecom WHERE country LIKE 'P%'")
dbGetQuery(con, "SELECT * FROM ecom WHERE country LIKE '_o%'")

## Close connection ----
dbDisconnect(con)
