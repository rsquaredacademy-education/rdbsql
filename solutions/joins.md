# Solutions — JOINs

1. `SELECT c.customer_id, c.country FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE o.order_id IS NULL` — customers 4, 16, 17, 18, 19, 20. Same result: `anti_join(customers, orders, by = "customer_id")`.

2. `SELECT c.customer_id, c.country, SUM(o.amount) AS total FROM customers c INNER JOIN orders o ON c.customer_id = o.customer_id GROUP BY c.customer_id, c.country ORDER BY total DESC` — customer 3 (Germany, 1015.82).

3. `SELECT o.order_id, o.customer_id FROM orders o LEFT JOIN customers c ON o.customer_id = c.customer_id WHERE c.customer_id IS NULL` — order 120 (customer 99).
