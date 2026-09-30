# Chapter 6 (Appendix A): Production R patterns.
# SQLite-backed sections execute; server sections are comments — uncomment
# with your credentials (Postgres/MariaDB/ODBC, keyring, pool).
library(DBI)
library(RSQLite)

# --- Connection strings (need a live server; display-only) ---
# con <- dbConnect(RPostgres::RPostgres(), host = "db.internal",
#   dbname = "analytics", user = Sys.getenv("DB_USER"),
#   password = Sys.getenv("DB_PASS"))
# con <- dbConnect(RMariaDB::MariaDB(), host = "db.internal",
#   dbname = "analytics", user = Sys.getenv("DB_USER"),
#   password = Sys.getenv("DB_PASS"))
# con <- dbConnect(odbc::odbc(), dsn = "warehouse",
#   uid = Sys.getenv("DB_USER"), pwd = Sys.getenv("DB_PASS"))

# --- Credentials (display-only) ---
# keyring::key_set("warehouse", "analyst")
# pwd <- keyring::key_get("warehouse", "analyst")

# --- Executable demo on SQLite ---
con <- dbConnect(RSQLite::SQLite(), ":memory:")
web_path <- if (file.exists("data/web.csv")) "data/web.csv" else "https://raw.githubusercontent.com/rsquaredacademy/datasets/master/web.csv"
ecom <- readr::read_csv(web_path, show_col_types = FALSE)
dplyr::copy_to(con, ecom)

# Parameterized queries
device <- "mobile"
q <- sqlInterpolate(con,
  "SELECT COUNT(*) AS n FROM ecom WHERE device = ?dev", dev = device)
print(q)
print(dbGetQuery(con, q))

# Transactions
dbWriteTable(con, "trial", data.frame(id = 1:3, x = c("a", "b", "c")))
dbWithTransaction(con, {
  dbExecute(con, "INSERT INTO trial (id, x) VALUES (4, 'd')")
  dbExecute(con, "DELETE FROM trial WHERE id = 1")
})
print(dbGetQuery(con, "SELECT * FROM trial ORDER BY id"))

# --- Writes at scale (display-only) ---
# dbCreateTable(con, "events",
#   fields = c(id = "INTEGER", ts = "TIMESTAMP", label = "TEXT"))
# dbWriteTable(con, "events", january, overwrite = TRUE)
# dbWriteTable(con, "events", february, append = TRUE)
# dbExecute(con, "CREATE INDEX idx_events_ts ON events (ts)")

# --- pool for Shiny (display-only) ---
# pool <- pool::dbPool(RPostgres::RPostgres(), dbname = "analytics",
#   host = "db.internal", user = Sys.getenv("DB_USER"))
# pool::poolClose(pool)

dbDisconnect(con)
message("ch6-production OK")
