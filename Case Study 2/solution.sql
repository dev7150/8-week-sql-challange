-- How many pizzas were ordered?
SELECT
count(PIZZA_ID)
FROM pizza_runner.customer_orders

-- How many unique customer orders were made?
SELECT customer_id, COUNT(order_id) AS unique_orders
FROM pizza_runner.customer_orders
GROUP BY customer_id;

--3. How many successful orders were delivered by each runner?
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
	  WHEN cancellation IS NULL or cancellation LIKE 'null' or cancellation = '' or 
  		cancellation = ' ' THEN null
	  ELSE cancellation
	  END AS cancellation
FROM pizza_runner.runner_orders
)
Select runner_id,count(order_id) from runner_orders
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
FROM pizza_runner.customer_orders
)
,ranked as(
Select co.order_id as order_id, count(pizza_id) as pizza_count,rank() over (order by count(pizza_id) desc) as rank
from customer_orders co
join runner_orders ro
on co.order_id = ro.order_id
group by 1
)

Select order_id, pizza_count from ranked
where rank = 1


-- For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
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
FROM pizza_runner.customer_orders
)
Select customer_id,
sum(case when exclusions is not null or extras is not null then 1 else 0 end) as min_1_change,
sum(case when exclusions is null and extras is null then 1 else 0 end) as no_change
from customer_orders co
join runner_orders ro
on co.order_id = ro.order_id
where cancellation is null
group by 1
order by 1

-- How many pizzas were delivered that had both exclusions and extras?
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
FROM pizza_runner.customer_orders
)
Select 
sum(case when exclusions is not null and extras is not null then 1 else 0 end) 
from customer_orders co
join runner_orders ro
on co.order_id = ro.order_id
where cancellation is null


-- What was the total volume of pizzas ordered for each hour of the day?
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
FROM pizza_runner.customer_orders
)
Select 
extract(hour from order_time),
-- DATEPART(HOUR, order_time) AS hour_of_day, //TSQL
count(pizza_id) 
from customer_orders co
group by 1
order by 1

-- What was the volume of orders for each day of the week?
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
FROM pizza_runner.customer_orders
)
Select 
to_char((order_time::date)+2,'DAY'),
-- FORMAT(DATEADD(DAY, 2, order_time),'dddd') AS day_of_week, -- add 2 to adjust 1st day of the week as Monday
count(pizza_id) 
from customer_orders co
group by 1
order by 1


-- Solution B
-- 1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
Select count(runner_id),
date_part('week' , registration_date)
from pizza_runner.runners
group by 2;


-- 2. What was the average time in minutes it took for each runner to arrive
-- at the Pizza Runner HQ to pickup the order?
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
,
time_taken as
(Select runner_id,
-- extract(minute from co.order_time::timestamp - ro.pickup_time::timestamp)
 (to_timestamp(ro.pickup_time, 'YYYY-MM-DD HH24:MI:SS') - co.order_time::timestamp) as pickup_min
from customer_orders co
join runner_orders ro
on ro.order_id = co.order_id
 -- group by 1
)
Select runner_id,round(cast(extract(epoch from avg(pickup_min))/60 AS NUMERIC),2) as avg_time_taken
from time_taken
where extract(epoch from pickup_min) > 1
group by 1;


-- Is there any relationship between the number of pizzas and how long the order takes to prepare?
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
Select co.order_id,
count(pizza_id),
 (to_timestamp(ro.pickup_time, 'YYYY-MM-DD HH24:MI:SS') - co.order_time::timestamp) as pickup_min
 from customer_orders co
 join runner_orders ro
 on co.order_id = ro.order_id
  where distance != 0
 group by 1,3
 order by 2 desc;

 -- What was the average distance travelled for each customer?
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

Select customer_id,
round(avg(distance)::numeric,2)
from customer_orders co
join runner_orders ro
on ro.order_id = co.order_id
where distance != 0
group by 1;

-- What was the difference between the longest and shortest delivery times for all orders?
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

Select 
max(duration::numeric) - min(duration::numeric) as time_diff
from runner_orders 
where distance != 0;

-- What was the average speed for each runner for each delivery and do you notice any trend for these values?
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

Select runner_id,
ro.order_id,
count(pizza_id) as pizza_count,
round(avg(distance::numeric/duration::numeric)*60,2) as avg_speed
from runner_orders ro
join customer_orders co
on co.order_id = ro.order_id
where distance != 0
group by 1,2

-- What is the successful delivery percentage for each runner?
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

Select runner_id,
100*sum(case when distance = 0 then 0 else 1 end)/count(pickup_time) as success
from runner_orders ro
group by 1