-- What are the standard ingredients for each pizza?
WITH toppings_cte AS (
SELECT
  pizza_id,
  REGEXP_SPLIT_TO_TABLE(toppings, ',')::INTEGER AS topping_id
FROM pizza_runner.pizza_recipes)

Select pizza_name,string_agg(topping_name,',' order by topping_name)
from toppings_cte t
join pizza_runner.pizza_names pn
on pn.pizza_id = t.pizza_id
join pizza_runner.pizza_toppings pt
on pt.topping_id = t.topping_id
group by 1;


-- What was the most commonly added extra?
with runner_orders As
(
SELECT 
  order_id, 
  runner_id,  
  CASE
	  WHEN pickup_time LIKE 'null' THEN ''
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
	  WHEN cancellation IS NULL or cancellation LIKE 'null' or cancellation = '' or 
  		cancellation = ' ' THEN null
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
	  WHEN exclusions IS null OR exclusions LIKE 'null' or exclusions ='' or exclusions=' ' THEN null
	  ELSE exclusions
	  END AS exclusions,
  CASE
	  WHEN extras IS NULL or extras LIKE 'null' or extras ='' or extras=' ' THEN null
	  ELSE extras
	  END AS extras,
	order_time
FROM pizza_runner.customer_orders)

Select unnest(string_to_array(extras,',')) as a,
count(extras)
from customer_orders
group by 1