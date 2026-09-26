# Chapter 1: DBI — runnable code for the book.
# Run from the repo root: Rscript code/ch1-dbi.R
# Uses the local data/web.csv snapshot (falls back to the online copy).

library(dbplyr)
library(dplyr)
library(DBI)
library(RSQLite)

## Connection ----
con <- dbConnect(RSQLite::SQLite(), ":memory:")

# Optional: the same DBI code runs on DuckDB for analytical queries.
# install.packages("duckdb")  # once
# con_duck <- dbConnect(duckdb::duckdb())

# Canonical ecom: this chapter uses a 20-row x 6-col slice for brevity.
web_path <- if (file.exists("data/web.csv")) "data/web.csv" else "https://raw.githubusercontent.com/rsquaredacademy/datasets/master/web.csv"
ecom1 <- readr::read_csv(web_path, show_col_types = FALSE)
ecom <- ecom1 %>%
  dplyr::select(referrer, device, bouncers, n_visit, n_pages, duration, country, purchase) %>%
  dplyr::slice(1:20) %>%
  dplyr::select(referrer, device, bouncers, n_visit, n_pages, duration)
copy_to(con, ecom)

## Connection summary ----
summary(con)

## List tables / fields ----
dbListTables(con)
dbListFields(con, "ecom")

## Querying data ----
dbReadTable(con, "ecom")
dbGetQuery(con, "select * from ecom limit 10")

# Read in batches
query <- dbSendQuery(con, "select * from ecom")
result <- dbFetch(query, n = 15)
result

## Query status / info ----
dbHasCompleted(query)
dbGetInfo(query)
dbGetStatement(query)
dbGetRowCount(query)
dbGetRowsAffected(query)
dbColumnInfo(query)

# Always clear a result set once done with it.
dbClearResult(query)

## Create / overwrite / append ----
x <- 1:10
y <- letters[1:10]
trial <- tibble::tibble(x, y)
dbWriteTable(con, "trial", trial)

dbListTables(con)
dbExistsTable(con, "trial")
dbGetQuery(con, "select * from trial limit 5")

x <- sample(100, 10)
y <- letters[11:20]
trial2 <- tibble::tibble(x, y)
dbWriteTable(con, "trial", trial2, overwrite = TRUE)
dbGetQuery(con, "select * from trial limit 5")

x <- sample(100, 10)
y <- letters[5:14]
trial3 <- tibble::tibble(x, y)
dbWriteTable(con, "trial", trial3, append = TRUE)
dbReadTable(con, "trial")

sqlAppendTable(con, "ecom", head(ecom))

## Insert rows ----
dbExecute(con,
  "INSERT into trial (x, y) VALUES (32, 'c'), (45, 'k'), (61, 'h')"
)

res <- dbSendStatement(con,
  "INSERT into trial (x, y) VALUES (25, 'm'), (54, 'l'), (16, 'y')"
)
dbClearResult(res)

## Remove table / data types ----
dbRemoveTable(con, "trial")

dbDataType(RSQLite::SQLite(), "a")
dbDataType(RSQLite::SQLite(), 1:5)
dbDataType(RSQLite::SQLite(), 1.5)

## Close connection ----
dbDisconnect(con)
