-- How many pizzas were ordered?
SELECT
count(PIZZA_ID)
FROM pizza_runner.customer_orders

-- How many unique customer orders were made?
SELECT customer_id, COUNT(order_id) AS unique_orders
FROM pizza_runner.customer_orders
GROUP BY customer_id;

--3. How many successful orders were delivered by each runner?
with runner_orders_temp As
(
SELECT 
  order_id, 
  runner_id,  
  CASE
	  WHEN pickup_time LIKE 'null' THEN ' '
	  ELSE pickup_time
	  END AS pickup_time,
  CASE
	  WHEN distance LIKE 'null' THEN ' '
	  WHEN distance LIKE '%km' THEN TRIM('km' from distance)
	  ELSE distance 
    END AS distance,
  CASE
	  WHEN duration LIKE 'null' THEN ' '
	  WHEN duration LIKE '%mins' THEN TRIM('mins' from duration)
	  WHEN duration LIKE '%minute' THEN TRIM('minute' from duration)
	  WHEN duration LIKE '%minutes' THEN TRIM('minutes' from duration)
	  ELSE duration
	  END AS duration,
  CASE
	  WHEN cancellation IS NULL or cancellation LIKE 'null' or cancellation = '' THEN null
	  ELSE cancellation
	  END AS cancellation
FROM pizza_runner.runner_orders)

Select runner_id,count(order_id) from runner_orders_temp
where cancellation is null
group by 1;

-- 4. How many of each type of pizza was delivered?
with runner_orders As
(
SELECT 
  order_id, 
  runner_id,  
  CASE
	  WHEN pickup_time LIKE 'null' THEN ' '
	  ELSE pickup_time
	  END AS pickup_time,
  CASE
	  WHEN distance LIKE 'null' THEN 0
	  WHEN distance LIKE '%km' THEN cast(TRIM('km' from distance) as float)
	  ELSE cast(distance as float) 
    END AS distance,
  CASE
	  WHEN duration LIKE 'null' THEN ' '
	  WHEN duration LIKE '%mins' THEN TRIM('mins' from duration)
	  WHEN duration LIKE '%minute' THEN TRIM('minute' from duration)
	  WHEN duration LIKE '%minutes' THEN TRIM('minutes' from duration)
	  ELSE duration
	  END AS duration,
  CASE
	  WHEN cancellation IS NULL or cancellation LIKE 'null' or cancellation = '' THEN null
	  ELSE cancellation
	  END AS cancellation
FROM pizza_runner.runner_orders
),
customer_orders as
(
SELECT 
  order_id, 
  customer_id, 
  pizza_id, 
  CASE
	  WHEN exclusions IS null OR exclusions LIKE 'null' THEN ' '
	  ELSE exclusions
	  END AS exclusions,
  CASE
	  WHEN extras IS NULL or extras LIKE 'null' THEN ' '
	  ELSE extras
	  END AS extras,
	order_time
FROM pizza_runner.customer_orders
)


Select p.pizza_name, 
COUNT(c.pizza_id) AS delivered_pizza_count
from customer_orders c
JOIN runner_orders AS r
ON c.order_id = r.order_id
JOIN pizza_runner.pizza_names AS p
ON c.pizza_id = p.pizza_id
where r.distance != 0
group by 1