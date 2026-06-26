USE coffeeshop_db;

-- =========================================================
-- JOINS & RELATIONSHIPS PRACTICE
-- =========================================================

-- Q1) Join products to categories: list product_name, category_name, price.

SELECT 
	c.name AS product_name,
    o.name AS category_name,
    c.price
FROM products c
INNER JOIN categories o
	ON c.category_id = o.category_id;
    
-- Q2) For each order item, show: order_id, order_datetime, store_name,
--     product_name, quantity, line_total (= quantity * products.price).
--     Sort by order_datetime, then order_id.

SELECT 
    o.order_id,
    o.order_datetime,
    s.name AS store_name,
    p.name AS product_name,
    oi.quantity,
    (oi.quantity * p.price) AS line_total
FROM order_items oi
INNER JOIN orders o 
    ON oi.order_id = o.order_id
INNER JOIN products p 
    ON oi.product_id = p.product_id
INNER JOIN stores s 
    ON o.store_id = s.store_id
ORDER BY 
    o.order_datetime, 
    o.order_id;
    
-- Q3) Customer order history (PAID only):
--     For each order, show customer_name, store_name, order_datetime,
--     order_total (= SUM(quantity * products.price) per order).

-- Q4) Left join to find customers who have never placed an order.
--     Return first_name, last_name, city, state.

-- Q5) For each store, list the top-selling product by units (PAID only).
--     Return store_name, product_name, total_units.
--     Hint: Use a window function (ROW_NUMBER PARTITION BY store) or a correlated subquery.

-- Q6) Inventory check: show rows where on_hand < 12 in any store.
--     Return store_name, product_name, on_hand.


-- Q7) Manager roster: list each store's manager_name and hire_date.
--     (Assume title = 'Manager').

SELECT 
	b.name AS store_name,
    CONCAT(a.first_name, ' ', a.last_name) AS manager_name,
    a.hire_date
FROM employees a
INNER JOIN stores b
	ON  a.store_id = b.store_id
WHERE a.title LIKE '%manager%';

-- Q8) Using a subquery/CTE: list products whose total PAID revenue is above
--     the average PAID product revenue. Return product_name, total_revenue.

-- Q9) Churn-ish check: list customers with their last PAID order date.
--     If they have no PAID orders, show NULL.
--     Hint: Put the status filter in the LEFT JOIN's ON clause to preserve non-buyer rows.

-- Q10) Product mix report (PAID only):
--     For each store and category, show total units and total revenue (= SUM(quantity * products.price)).
