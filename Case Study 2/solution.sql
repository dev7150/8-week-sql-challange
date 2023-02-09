-- How many pizzas were ordered?
SELECT
count(PIZZA_ID)
FROM pizza_runner.customer_orders

-- How many unique customer orders were made?
SELECT customer_id, COUNT(order_id) AS unique_orders
FROM pizza_runner.customer_orders
GROUP BY customer_id