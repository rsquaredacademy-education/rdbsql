# Regression check: run every chapter script from the repo root.
files <- c("code/ch1-dbi.R", "code/ch2-dbplyr.R", "code/ch3-sqlbasics.R",
           "code/ch4-sqladvanced.R", "code/ch5-joins.R", "code/ch6-production.R",
           "code/ch7-duckdb.R")
for (f in files) {
  message("== ", f, " ==")
  source(f, chdir = FALSE)
}
message("verify OK: ", length(files), " scripts, R ", getRversion())
