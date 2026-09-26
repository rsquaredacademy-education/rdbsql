# R, Databases & SQL

*R4DS Ch. 21 in 30 minutes leaves beginners behind. This book is the 2-hour ramp before it — DBI mechanics + first 20 SQL verbs, all runnable with zero setup.*

This repository contains the source of [R, Databases & SQL](https://rdbsql.rsquaredacademy.com)
book. The book is built using [Quarto](https://quarto.org/) (CLI 1.10.18+,
`C:\Users\HP\AppData\Local\quarto\bin` on PATH for local builds).

Build (HTML + PDF into `docs/`, published via GitHub Pages):

```sh
quarto render
mv "docs/R,-Databases---SQL.pdf" docs/databases-and-sql.pdf
cp sitemap.xml docs/sitemap.xml
```

The PDF rename and sitemap copy are manual: Quarto slugs the whole-book PDF
filename from the title (ignores `output-file`), and silently skips a root
`sitemap.xml` resource (reserved name). Runnable code for each chapter lives
in `code/` (run from the repo root, offline-safe via `data/`).

Last verified: 2026-09-26 · R 4.5.2 · DBI · dbplyr 2.6.0 · RSQLite 2.4.6 · duckdb.

