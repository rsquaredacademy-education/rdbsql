# Solutions — SQL Basics

1. `SELECT referrer, device FROM ecom WHERE n_visit > 8 ORDER BY duration DESC LIMIT 5` — top row: google / mobile.

2. `SELECT COUNT(*) FROM ecom WHERE device = 'tablet' AND country LIKE 'P%'` — 51 rows.

3. `SELECT DISTINCT device FROM ecom WHERE bouncers = 1` — laptop, tablet, mobile (all three).
