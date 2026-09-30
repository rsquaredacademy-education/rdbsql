# Chapter 7 (Appendix B): DuckDB + Parquet.
# Skips gracefully when duckdb is not installed (e.g. book CI builds).
if (!requireNamespace("duckdb", quietly = TRUE)) {
  message("ch7-duckdb SKIPPED: duckdb not installed (install.packages(\"duckdb\"))")
} else {
  library(DBI)
  con_duck <- dbConnect(duckdb::duckdb())
  web_path <- if (file.exists("data/web.csv")) "data/web.csv" else "https://raw.githubusercontent.com/rsquaredacademy/datasets/master/web.csv"
  ecom <- readr::read_csv(web_path, show_col_types = FALSE)
  dbWriteTable(con_duck, "ecom", ecom)
  print(dbGetQuery(con_duck,
    "SELECT referrer, AVG(duration) AS avg_d FROM ecom GROUP BY referrer"))

  # Query files directly without loading them (needs a .parquet file):
  # dbGetQuery(con_duck, "SELECT country, SUM(amount) AS revenue
  #   FROM 'orders.parquet' GROUP BY country ORDER BY revenue DESC LIMIT 10")

  # dbplyr on DuckDB (needs dplyr + dbplyr):
  # e <- dplyr::tbl(con_duck, "ecom")
  # q <- e |> dplyr::filter(duration > 300) |> dplyr::group_by(device) |>
  #   dplyr::summarise(avg = mean(duration))
  # dplyr::show_query(q)
  # dplyr::collect(q)

  dbDisconnect(con_duck)
  message("ch7-duckdb OK")
}
