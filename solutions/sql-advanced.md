# Solutions — SQL Advanced

1. `SELECT referrer, AVG(n_pages) AS avg_pages FROM ecom GROUP BY referrer ORDER BY avg_pages DESC` — direct (~6.38) tops the list.

2. `SELECT MAX(duration) FROM ecom WHERE purchase = 1` — 580.

3. `SELECT country, COUNT(*) AS visits FROM ecom WHERE device = 'mobile' GROUP BY country ORDER BY visits DESC LIMIT 5` — China (53) is first.
