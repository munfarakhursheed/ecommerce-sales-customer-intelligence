
-- E-commerce Sales & Customer Intelligence | SQLite-compatible SQL
-- Run against the CSV-imported tables in data/ (table names match filenames).

-- 1. Executive sales KPIs
SELECT COUNT(DISTINCT o.order_id) AS total_orders,
       ROUND(SUM(i.gross_revenue),2) AS gross_revenue,
       ROUND(SUM(i.gross_profit),2) AS gross_profit,
       ROUND(1.0*SUM(i.gross_revenue)/COUNT(DISTINCT o.order_id),2) AS average_order_value
FROM orders o JOIN order_items i USING(order_id)
WHERE o.order_status='delivered';

-- 2. Monthly revenue trend
SELECT strftime('%Y-%m',o.order_date) AS month,
       ROUND(SUM(i.gross_revenue),2) AS revenue
FROM orders o JOIN order_items i USING(order_id)
WHERE o.order_status='delivered'
GROUP BY month ORDER BY month;

-- 3. Category sales and margin
SELECT p.category, ROUND(SUM(i.gross_revenue),2) revenue,
       ROUND(SUM(i.gross_profit),2) profit,
       ROUND(100.0*SUM(i.gross_profit)/NULLIF(SUM(i.gross_revenue),0),2) margin_pct
FROM order_items i JOIN products p USING(product_id)
JOIN orders o USING(order_id)
WHERE o.order_status='delivered'
GROUP BY p.category ORDER BY revenue DESC;

-- 4. Regional performance
SELECT c.region, COUNT(DISTINCT o.order_id) orders,
       ROUND(SUM(i.gross_revenue),2) revenue
FROM orders o JOIN customers c USING(customer_id)
JOIN order_items i USING(order_id)
WHERE o.order_status='delivered'
GROUP BY c.region ORDER BY revenue DESC;

-- 5. Repeat purchase behaviour
WITH customer_orders AS (
 SELECT customer_id, COUNT(DISTINCT order_id) order_count
 FROM orders WHERE order_status='delivered' GROUP BY customer_id
)
SELECT COUNT(*) customers,
       SUM(CASE WHEN order_count>1 THEN 1 ELSE 0 END) repeat_customers,
       ROUND(100.0*SUM(CASE WHEN order_count>1 THEN 1 ELSE 0 END)/COUNT(*),2) repeat_customer_pct
FROM customer_orders;

-- 6. Top customers by lifetime revenue
SELECT o.customer_id, COUNT(DISTINCT o.order_id) orders,
       ROUND(SUM(i.gross_revenue),2) lifetime_revenue,
       DENSE_RANK() OVER(ORDER BY SUM(i.gross_revenue) DESC) revenue_rank
FROM orders o JOIN order_items i USING(order_id)
WHERE o.order_status='delivered'
GROUP BY o.customer_id ORDER BY lifetime_revenue DESC LIMIT 20;

-- 7. Delivery performance
SELECT COUNT(*) delivered_orders,
       SUM(CASE WHEN delivered_on_time=1 THEN 1 ELSE 0 END) on_time_orders,
       ROUND(100.0*SUM(CASE WHEN delivered_on_time=1 THEN 1 ELSE 0 END)/COUNT(*),2) on_time_pct,
       ROUND(AVG(delivery_days),2) avg_delivery_days
FROM orders WHERE order_status='delivered';

-- 8. Review score and delivery experience
SELECT CASE WHEN delivery_days<=estimated_delivery_days THEN 'On time' ELSE 'Late' END delivery_group,
       ROUND(AVG(r.review_score),2) avg_review, COUNT(*) orders
FROM orders o JOIN reviews r USING(order_id)
WHERE o.order_status='delivered'
GROUP BY delivery_group;

-- 9. Payment method mix
SELECT payment_method, COUNT(*) orders, ROUND(SUM(payment_value),2) payment_value
FROM payments GROUP BY payment_method ORDER BY payment_value DESC;

-- 10. Seller performance
SELECT s.seller_id, COUNT(DISTINCT o.order_id) orders,
       ROUND(AVG(o.delivery_days),2) avg_delivery_days,
       ROUND(AVG(r.review_score),2) avg_review
FROM sellers s JOIN orders o USING(seller_id)
LEFT JOIN reviews r USING(order_id)
WHERE o.order_status='delivered'
GROUP BY s.seller_id HAVING orders>=10
ORDER BY avg_delivery_days;
