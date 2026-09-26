# Chapter 5: JOINs — runnable code for the book.
# Run from the repo root: Rscript code/ch5-joins.R
# Uses the committed data/ecom.sqlite file (customers + orders tables).

library(dplyr)
library(DBI)
library(RSQLite)
library(dbplyr)

con <- DBI::dbConnect(RSQLite::SQLite(), "data/ecom.sqlite")

## Preview tables ----
dbGetQuery(con, "SELECT * FROM customers LIMIT 5")
dbGetQuery(con, "SELECT * FROM orders LIMIT 5")

## Inner join ----
dbGetQuery(con, "SELECT c.customer_id, c.country, o.order_id, o.amount
FROM customers c
INNER JOIN orders o ON c.customer_id = o.customer_id
ORDER BY c.customer_id, o.order_id
LIMIT 6")

dbGetQuery(con, "SELECT COUNT(*) AS n FROM customers c
INNER JOIN orders o ON c.customer_id = o.customer_id")

## Left join ----
dbGetQuery(con, "SELECT c.customer_id, c.country, o.order_id, o.amount
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL
ORDER BY c.customer_id")

# Portable alternative to RIGHT/FULL OUTER JOIN (rejected by RSQLite):
# swap the tables and use LEFT JOIN instead.

## Joins with dbplyr ----
customers <- dplyr::tbl(con, "customers")
orders <- dplyr::tbl(con, "orders")

inner_join(customers, orders, by = "customer_id")

q_inner <- inner_join(customers, orders, by = "customer_id")
dplyr::show_query(q_inner)

q_left <- left_join(customers, orders, by = "customer_id")
dplyr::show_query(q_left)

## Filtering joins ----
q_semi <- semi_join(customers, orders, by = "customer_id")
dplyr::show_query(q_semi)
dplyr::collect(q_semi)

q_anti <- anti_join(customers, orders, by = "customer_id")
dplyr::show_query(q_anti)
dplyr::collect(q_anti)

## Close connection ----
dbDisconnect(con)
